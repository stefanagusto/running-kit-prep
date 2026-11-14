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
    @ObservationIgnored private let container: ModelContainer
    @ObservationIgnored private var started = false
    @ObservationIgnored private var running = false
    @ObservationIgnored private var rerunRequested = false
    @ObservationIgnored private var debounce: Task<Void, Never>?
    @ObservationIgnored private var changeWatcher: Task<Void, Never>?

    init(container: ModelContainer) {
        self.container = container
    }

    private var context: ModelContext { container.mainContext }

    /// Starts watching calendar changes and runs the first rebuild. Safe to call again.
    func start() async {
        if !started {
            started = true
            notifications.registerCategories()
        }
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
        guard !ids.isEmpty, ids != selectedCalendarIds else { return }
        fetchOrCreateSettings(in: context).calendarIds = ids.sorted()
        try? context.save()
        requestRebuild()
    }

    /// Used by the "calendar not found" state: choosing one adds it.
    func addCalendar(_ id: String) {
        let settings = fetchOrCreateSettings(in: context)
        if !settings.calendarIds.contains(id) { settings.calendarIds.append(id) }
        try? context.save()
        requestRebuild()
    }

    /// Saves the chosen place, then rebuilds. Awaited so a notification action finishes before the app suspends.
    func setPlace(_ place: Place, for key: String) async {
        if case .sessions(let sessions) = state, sessions.first(where: { $0.key == key })?.type == .race { return }
        let start = Self.startDate(fromKey: key) ?? Date()
        storePlace(place, for: key, start: start, in: context)
        if case .sessions(let sessions) = state, let session = sessions.first(where: { $0.key == key }) {
            // A new place changes the kit, so the saved ticks may now complete it or not.
            refreshCompletion(session: session, place: place)
        }
        await rebuildNow()
    }

    /// Saves one tick, updates "all set" and rebuilds when completion changed (leave reminder goes or returns).
    func tick(_ tickKey: String, session: Session, kit: Kit) {
        let wasComplete = completedStates(in: context)[session.key]?.completed == true
        let ticked = toggleTick(tickKey, for: session.key, start: session.start, in: context)
        let nowComplete = Checklist.isComplete(kit: kit, ticked: ticked)
        guard nowComplete != wasComplete else { return }
        setCompleted(nowComplete, for: session.key, in: context)
        requestRebuild()
    }

    private func refreshCompletion(session: Session, place: Place) {
        let kit = KitBuilder.kit(for: session.type, place: place, items: SeedItems.all)
        let complete = Checklist.isComplete(kit: kit, ticked: ticks(for: session.key, in: context))
        setCompleted(complete, for: session.key, in: context)
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
        deleteOldRecords(before: now, in: context)
        let sessions = SessionBuilder.sessions(
            from: events,
            rules: settings.keywordRules,
            now: now,
            windowDays: config.windowDays,
            places: places(in: context),
            placeRules: settings.placeRules
        )
        let states = completedStates(in: context)
        plan = ReminderPlanner.plan(
            sessions: sessions, states: states, items: SeedItems.all, config: config, now: now, reinstallDate: nil
        )
        state = sessions.isEmpty ? .empty : .sessions(sessions)
        if notificationStatus == .notDetermined, !sessions.isEmpty {
            _ = await notifications.requestAuthorization()
            notificationStatus = await notifications.authorizationStatus()
        }
        if notificationStatus == .allowed {
            await notifications.replaceAll(plan)
            await notifications.removeDelivered(forSessions: Set(states.keys))
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
