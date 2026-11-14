import SwiftUI
import RunPrepCore

@main
struct RunningPrepApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

/// Placeholder that proves the package links. Replaced in S2.
struct RootView: View {
    private let kit = KitBuilder.kit(for: .long, place: .ui, items: SeedItems.all)

    var body: some View {
        NavigationStack {
            List {
                ForEach(ItemGroup.allCases, id: \.self) { group in
                    Section(group.rawValue.capitalized) {
                        ForEach(kit.items(in: [group]), id: \.id) { item in
                            Text(item.name)
                        }
                    }
                }
            }
            .navigationTitle("Run Prep")
        }
    }
}
