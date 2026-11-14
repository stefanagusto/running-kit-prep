import Foundation
import Observation
import RunPrepCore
import SwiftData

struct CalendarOption: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
}

enum UpcomingState: Equatable {
    case loading
    case needsPermission
    case denied
    case calendarNotFound([CalendarOption])
    case empty
    case sessions([Session])
}

@MainActor
@Observable
final class UpcomingViewModel {
    private(set) var state: UpcomingState = .loading
    private(set) var calendarOptions: [CalendarOption] = []
    private(set) var selectedCalendarId: String?
    private(set) var calendarName = ""

    @ObservationIgnored private let service = CalendarService()
    @ObservationIgnored private var context: ModelContext?

    /// Loads once, then reloads on every calendar change until the task is cancelled.
    func run(context: ModelContext) async {
        self.context = context
        load()
        for await _ in service.changes() {
            load()
        }
    }

    func requestAccess() async {
        _ = await service.requestAccess()
        load()
    }

    func choose(calendarId: String) {
        guard let context else { return }
        fetchOrCreateSettings(in: context).calendarId = calendarId
        try? context.save()
        load()
    }

    func load() {
        guard let context else { return }
        switch service.access {
        case .notDetermined:
            state = .needsPermission
            return
        case .denied:
            state = .denied
            return
        case .granted:
            break
        }
        let settings = fetchOrCreateSettings(in: context)
        calendarOptions = service.calendars().map {
            CalendarOption(id: $0.calendarIdentifier, title: $0.title)
        }
        guard let picked = pickCalendar(stored: settings.calendarId) else {
            selectedCalendarId = nil
            calendarName = ""
            state = .calendarNotFound(calendarOptions)
            return
        }
        selectedCalendarId = picked.id
        calendarName = picked.title
        let now = Date()
        let events = service.events(calendarId: picked.id, from: now, days: 14)
        let sessions = SessionBuilder.sessions(from: events, rules: settings.keywordRules, now: now)
        state = sessions.isEmpty ? .empty : .sessions(sessions)
    }

    private func pickCalendar(stored: String?) -> CalendarOption? {
        if let stored, let match = calendarOptions.first(where: { $0.id == stored }) {
            return match
        }
        if let exact = calendarOptions.first(where: { $0.title == "Stefan's' Training" }) {
            return exact
        }
        return calendarOptions.first { $0.title.localizedCaseInsensitiveContains("training") }
    }
}
