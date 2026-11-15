import SwiftUI

/// The tab bar. Settings joins in S7.
struct RootView: View {
    let sync: SyncCoordinator
    @Bindable var router: Router
    @State private var selection: AppTab = .upcoming

    enum AppTab: Hashable {
        case upcoming, items
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Upcoming", systemImage: "figure.run", value: AppTab.upcoming) {
                UpcomingView(sync: sync, router: router)
            }
            Tab("Items", systemImage: "checklist", value: AppTab.items) {
                ItemsView(sync: sync)
            }
        }
        // A notification tap opens a checklist, which lives on the Upcoming tab.
        .onChange(of: router.pendingSessionKey, initial: true) {
            if router.pendingSessionKey != nil { selection = .upcoming }
        }
    }
}
