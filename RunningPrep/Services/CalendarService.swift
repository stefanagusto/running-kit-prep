import EventKit
import Foundation
import RunPrepCore

enum CalendarAccess {
    case granted, denied, notDetermined
}

@MainActor
final class CalendarService {
    private let store = EKEventStore()

    var access: CalendarAccess {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess: return .granted
        case .notDetermined: return .notDetermined
        default: return .denied
        }
    }

    func requestAccess() async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    func calendars() -> [EKCalendar] {
        store.calendars(for: .event).sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }

    func events(calendarId: String, from start: Date, days: Int) -> [CalendarEvent] {
        guard let calendar = store.calendar(withIdentifier: calendarId),
              let end = Calendar.current.date(byAdding: .day, value: days, to: start) else { return [] }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: [calendar])
        return store.events(matching: predicate).map { event in
            let id = event.calendarItemIdentifier.isEmpty
                ? (event.eventIdentifier ?? "")
                : event.calendarItemIdentifier
            return CalendarEvent(id: id, title: event.title ?? "", start: event.startDate)
        }
    }

    /// Fires whenever the calendar database changes.
    nonisolated func changes() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let token = ObserverToken(NotificationCenter.default.addObserver(
                forName: .EKEventStoreChanged, object: nil, queue: .main
            ) { _ in continuation.yield() })
            continuation.onTermination = { _ in
                NotificationCenter.default.removeObserver(token.value)
            }
        }
    }
}

private final class ObserverToken: @unchecked Sendable {
    let value: NSObjectProtocol
    init(_ value: NSObjectProtocol) { self.value = value }
}
