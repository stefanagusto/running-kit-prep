import RunPrepCore
import SwiftUI

/// Frame 05: what the reminders and the checklist ask for.
struct ItemsView: View {
    let sync: SyncCoordinator
    @State private var showAdd = false
    @State private var pendingDelete: ItemRule?

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Items")
                .toolbar {
                    if !sync.items.isEmpty {
                        ToolbarItem(placement: .topBarLeading) { EditButton() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showAdd = true } label: {
                            Label("Add item", systemImage: "plus")
                        }
                    }
                }
                .deleteItemDialog($pendingDelete) { sync.deleteItem(id: $0.id) }
                .sheet(isPresented: $showAdd) {
                    NavigationStack { ItemEditView(sync: sync, item: nil) }
                        .debugAppearance()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if sync.items.isEmpty {
            ContentUnavailableView {
                Label("No items", systemImage: "checklist")
            } description: {
                Text("Add what you bring to a run.")
            } actions: {
                Button("Add item") { showAdd = true }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            list
        }
    }

    private var list: some View {
        List {
            Section {
                Text("What the reminders and the checklist ask for. Tap an item to change when it applies.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
            }
            ForEach(ItemGroup.allCases, id: \.self) { group in
                let rows = ItemOrdering.items(in: group, from: sync.items)
                if !rows.isEmpty {
                    Section(group.itemsHeader) {
                        ForEach(rows) { rule in
                            NavigationLink {
                                ItemEditView(sync: sync, item: rule)
                            } label: {
                                ItemRow(rule: rule)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // No destructive role: that role removes the row before the
                                // confirmation, and it would jump back on Cancel.
                                Button("Delete") { pendingDelete = rule }
                                    .tint(.red)
                            }
                        }
                        .onMove { source, destination in
                            sync.moveItems(in: group, from: source, to: destination)
                        }
                    }
                }
            }
        }
    }
}
