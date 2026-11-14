import RunPrepCore
import SwiftData
import SwiftUI
import UIKit

struct UpcomingView: View {
    @State private var viewModel = UpcomingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Upcoming")
                .toolbar { toolbarItems }
        }
        .task { await viewModel.run(context: modelContext) }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { viewModel.load() }
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(viewModel.calendarOptions) { option in
                    Button {
                        viewModel.choose(calendarId: option.id)
                    } label: {
                        if option.id == viewModel.selectedCalendarId {
                            Label(option.title, systemImage: "checkmark")
                        } else {
                            Text(option.title)
                        }
                    }
                }
            } label: {
                Label("Choose calendar", systemImage: "calendar")
            }
            .disabled(viewModel.calendarOptions.isEmpty)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.load()
            } label: {
                Label("Refresh sessions", systemImage: "arrow.clockwise")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Reading your training calendar")
        case .needsPermission:
            ContentUnavailableView {
                Label("Calendar access needed", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Run Prep reads your training calendar to know when you run.")
            } actions: {
                Button("Allow calendar access") {
                    Task { await viewModel.requestAccess() }
                }
                .buttonStyle(.borderedProminent)
            }
        case .denied:
            ContentUnavailableView {
                Label("No calendar access", systemImage: "calendar.badge.exclamationmark")
            } description: {
                Text("Run Prep needs to read your training calendar to know when you run. Turn on Full Access in Settings.")
            } actions: {
                Button("Open iOS Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        case .calendarNotFound(let options):
            calendarPicker(options)
        case .empty:
            ContentUnavailableView(
                "Nothing planned",
                systemImage: "figure.run",
                description: Text("Nothing planned in the next 14 days. Rest well.")
            )
            .refreshable { viewModel.load() }
        case .sessions(let sessions):
            sessionList(sessions)
        }
    }

    private func calendarPicker(_ options: [CalendarOption]) -> some View {
        List {
            Section {
                ForEach(options) { option in
                    Button(option.title) { viewModel.choose(calendarId: option.id) }
                        .frame(minHeight: 44, alignment: .leading)
                }
            } header: {
                Text("Choose your training calendar")
            } footer: {
                Text("Run Prep could not find a calendar with \"training\" in its name.")
            }
        }
    }

    private func sessionList(_ sessions: [Session]) -> some View {
        List {
            if let next = sessions.first {
                Section {
                    NextSessionCard(session: next, calendarName: viewModel.calendarName)
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
        .refreshable { viewModel.load() }
    }
}
