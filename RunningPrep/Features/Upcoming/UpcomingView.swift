import RunPrepCore
import SwiftData
import SwiftUI
import UIKit

struct UpcomingView: View {
    let sync: SyncCoordinator
    @Bindable var router: Router
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var showCalendarPicker = false
    @State private var draftSelection: Set<String> = []

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .safeAreaInset(edge: .top) {
                    if showsNotificationsBanner {
                        NotificationsOffBanner(openSettings: openSettings)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    }
                }
                .navigationTitle("Upcoming")
                .toolbar { toolbarItems }
                .navigationDestination(for: String.self) { destination(for: $0) }
        }
        .task { await sync.start() }
        .onChange(of: router.pendingSessionKey, initial: true) { consumePending() }
        .onChange(of: sync.state) { consumePending() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { sync.requestRebuild() }
        }
        .sheet(isPresented: $showCalendarPicker, onDismiss: { sync.setCalendars(draftSelection) }) {
            CalendarPickerSheet(options: sync.calendarOptions, selection: $draftSelection)
                .debugAppearance()
        }
    }

    private var showsNotificationsBanner: Bool {
        guard sync.notificationStatus == .denied else { return false }
        switch sync.state {
        case .sessions, .empty: return true
        default: return false
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                draftSelection = sync.selectedCalendarIds
                showCalendarPicker = true
            } label: {
                Label("Choose calendars", systemImage: "calendar")
            }
            .disabled(sync.calendarOptions.isEmpty)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                sync.requestRebuild()
            } label: {
                Label("Refresh sessions", systemImage: "arrow.clockwise")
            }
        }
        #if DEBUG
        // TEMPORARY (test only): remove before release
        ToolbarItem(placement: .topBarLeading) {
            DebugAppearanceMenu()
        }
        #endif
    }

    @ViewBuilder
    private var content: some View {
        switch sync.state {
        case .loading:
            ProgressView("Reading your training calendar")
        case .needsPermission:
            ContentUnavailableView {
                Label("Calendar access needed", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Run Prep reads your training calendar to know when you run.")
            } actions: {
                Button("Allow calendar access") {
                    Task { await sync.requestCalendarAccess() }
                }
                .buttonStyle(.borderedProminent)
            }
        case .denied:
            ContentUnavailableView {
                Label("No calendar access", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Run Prep needs to read your training calendar to know when you run. Turn on Full Access in Settings.")
            } actions: {
                Button("Open iOS Settings", action: openSettings)
                    .buttonStyle(.borderedProminent)
            }
        case .calendarNotFound(let options):
            CalendarPickerList(
                options: options,
                selection: [],
                onToggle: { sync.addCalendar($0) },
                footer: "Run Prep could not find a calendar with \"training\" in its name. Choose the one that holds your runs."
            )
        case .empty:
            ContentUnavailableView(
                "Nothing planned",
                systemImage: "figure.run",
                description: Text("Nothing planned in the next 14 days. Rest well.")
            )
            .refreshable { await sync.rebuildNow() }
        case .sessions(let sessions):
            sessionList(sessions)
        }
    }

    private func sessionList(_ sessions: [Session]) -> some View {
        List {
            if let next = sessions.first {
                Section {
                    NextSessionCard(
                        session: next,
                        slots: sync.slots(for: next),
                        onPlace: { place in Task { await sync.setPlace(place, for: next.key) } },
                        onOpenChecklist: { router.path.append(next.key) }
                    )
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            let rest = Array(sessions.dropFirst())
            if !rest.isEmpty {
                Section("Coming up") {
                    ForEach(rest, id: \.key) { session in
                        NavigationLink(value: session.key) { SessionRow(session: session) }
                    }
                }
            }
        }
        .refreshable { await sync.rebuildNow() }
    }

    /// A notification tap waits until the sessions have loaded (cold launch), then opens that checklist.
    private func consumePending() {
        guard let key = router.pendingSessionKey else { return }
        if case .loading = sync.state { return }
        router.pendingSessionKey = nil
        router.path = [key]
    }

    @ViewBuilder
    private func destination(for key: String) -> some View {
        if case .sessions(let sessions) = sync.state, let session = sessions.first(where: { $0.key == key }) {
            ChecklistView(session: session, sync: sync)
        } else {
            ContentUnavailableView {
                Label("This session was changed", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("It is no longer in your calendar, or it moved.")
            } actions: {
                Button("Back to Upcoming") { router.path = [] }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}
