import Foundation
import Observation
import RunPrepCore
import SwiftData
import SwiftUI

/// The single rebuild pipeline (TDD 9): calendar -> sessions -> plan -> notifications.
@MainActor
@Observable
final class SyncCoordinator {
    private(set) var state: UpcomingState = .loading
    private(set) var plan: [PlannedReminder] = []
    private(set) var notificationStatus: NotificationStatus = .notDetermined
    private(set) var calendarOptions: [CalendarOption] = []
    private(set) var selectedCalendarIds: Set<String> = []
    private(set) var lastSyncDate: Date?

    @ObservationIgnored private let calendar = CalendarService()
    @ObservationIgnored private let notifications = NotificationService()
    @ObservationIgnored private var context: ModelContext?
    @ObservationIgnored private var running = false
    @ObservationIgnored private var rerunRequested = false
    @ObservationIgnored private var debounce: Task<Void, Never>?
    @ObservationIgnored private var changeWatcher: Task<Void, Never>?

    /// Starts watching calendar changes and runs the first rebuild.
    func start(context: ModelContext) async {
        self.context = context
        notifications.registerCategories()
        if changeWatcher == nil {
            changeWatcher = Task { [weak self] in
                guard let stream = self?.calendar.changes() else { return }
                for await _ in stream { self?.calendarChanged() }
            }
        }
        await rebuildNow()
    }

    func requestRebuild() {
        Task { await rebuildNow() }
    }

    func requestCalendarAccess() async {
        _ = await calendar.requestAccess()
        await rebuildNow()
    }

    /// Replaces the ticked calendars. One rebuild follows.
    func setCalendars(_ ids: Set<String>) {
        guard let context, !ids.isEmpty, ids != selectedCalendarIds else { return }
        fetchOrCreateSettings(in: context).calendarIds = ids.sorted()
        try? context.save()
        requestRebuild()
    }

    /// Used by the "calendar not found" state: choosing one adds it.
    func addCalendar(_ id: String) {
        guard let context else { return }
        let settings = fetchOrCreateSettings(in: context)
        if !settings.calendarIds.contains(id) { settings.calendarIds.append(id) }
        try? context.save()
        requestRebuild()
    }

    func slots(for session: Session) -> [ReminderSlot] {
        ReminderPlanner.slots(for: session, config: PlannerConfig())
    }

    /// EventKit changes arrive in bursts, so wait 1.5 s of quiet first.
    private func calendarChanged() {
        debounce?.cancel()
        debounce = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            await self?.rebuildNow()
        }
    }

    /// Single flight: a trigger during a run asks for one more run afterwards.
    func rebuildNow() async {
        if running {
            rerunRequested = true
            return
        }
        running = true
        repeat {
            rerunRequested = false
            await rebuild()
        } while rerunRequested
        running = false
    }

    private func rebuild() async {
        guard let context else { return }
        notificationStatus = await notifications.authorizationStatus()
        switch calendar.access {
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
        calendarOptions = loadOptions()
        let picked = resolveSelection(settings, context)
        selectedCalendarIds = Set(picked.map(\.id))
        guard !picked.isEmpty else {
            // Existing reminders stay until a calendar is chosen (TDD 10).
            state = .calendarNotFound(calendarOptions)
            return
        }
        let now = Date()
        let config = PlannerConfig()
        let events = calendar.events(calendarIds: picked.map(\.id), from: now, days: config.windowDays)
        let sessions = SessionBuilder.sessions(
            from: events, rules: settings.keywordRules, now: now, windowDays: config.windowDays
        )
        plan = ReminderPlanner.plan(
            sessions: sessions, states: [:], items: SeedItems.all, config: config, now: now, reinstallDate: nil
        )
        state = sessions.isEmpty ? .empty : .sessions(sessions)
        if notificationStatus == .notDetermined, !sessions.isEmpty {
            _ = await notifications.requestAuthorization()
            notificationStatus = await notifications.authorizationStatus()
        }
        if notificationStatus == .allowed {
            await notifications.replaceAll(plan)
        }
        lastSyncDate = now
    }

    private func loadOptions() -> [CalendarOption] {
        calendar.calendars().map {
            CalendarOption(
                id: $0.calendarIdentifier,
                title: $0.title,
                account: $0.source?.title ?? "Other",
                color: Color(cgColor: $0.cgColor)
            )
        }
    }

    /// Stored ids that still exist; when nothing is stored, auto-pick and save.
    private func resolveSelection(_ settings: AppSettings, _ context: ModelContext) -> [CalendarOption] {
        let stored = settings.calendarIds
        let valid = calendarOptions.filter { stored.contains($0.id) }
        if !valid.isEmpty || !stored.isEmpty { return valid }
        let auto = calendarOptions.first { $0.title == "Stefan's' Training" }
            ?? calendarOptions.first { $0.title.localizedCaseInsensitiveContains("training") }
        guard let auto else { return [] }
        settings.calendarIds = [auto.id]
        try? context.save()
        return [auto]
    }
}
