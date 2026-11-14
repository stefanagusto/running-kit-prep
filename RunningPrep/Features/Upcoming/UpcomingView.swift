import RunPrepCore
import SwiftData
import SwiftUI
import UIKit

struct UpcomingView: View {
    @State private var sync = SyncCoordinator()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var showCalendarPicker = false
    @State private var draftSelection: Set<String> = []

    var body: some View {
        NavigationStack {
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
        }
        .task { await sync.start(context: modelContext) }
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
                    NextSessionCard(session: next, slots: sync.slots(for: next))
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            let rest = Array(sessions.dropFirst())
            if !rest.isEmpty {
                Section("Next 14 days") {
                    ForEach(rest, id: \.key) { SessionRow(session: $0) }
                }
            }
        }
        .refreshable { await sync.rebuildNow() }
    }
}
