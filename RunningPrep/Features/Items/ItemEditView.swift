import RunPrepCore
import SwiftUI

/// Frame 06: change one item. Pushed from the list, or shown in a sheet for a new item.
/// Edits stay in a local draft until Save.
struct ItemEditView: View {
    let sync: SyncCoordinator
    private let isNew: Bool
    @State private var draft: ItemRule
    @State private var pendingDelete: ItemRule?
    @Environment(\.dismiss) private var dismiss

    /// Pass nil for a new item.
    init(sync: SyncCoordinator, item: ItemRule?) {
        self.sync = sync
        isNew = item == nil
        _draft = State(initialValue: item ?? ItemRule(
            id: UUID(),
            name: "",
            groups: [.bring],
            appliesTo: Set(SessionType.allCases),
            uiOnly: false,
            sortOrder: 0
        ))
    }

    private var nameValid: Bool { !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var valid: Bool { nameValid && !draft.groups.isEmpty && !draft.appliesTo.isEmpty }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Item name", text: $draft.name)
                    .textInputAutocapitalization(.sentences)
                    .submitLabel(.done)
            }
            Section {
                groupRow(.charge, "Charge it (day before)")
                groupRow(.pack, "Pack it (day before)")
                groupRow(.bring, "Bring it (on the way out)")
            } header: {
                Text("Remind me to")
            } footer: {
                if draft.groups.isEmpty { Text("Pick at least one.") }
            }
            Section {
                Toggle("Normal run", isOn: typeBinding(.normal))
                Toggle("Long run", isOn: typeBinding(.long))
                Toggle("Race", isOn: typeBinding(.race))
            } header: {
                Text("For these sessions")
            } footer: {
                if draft.appliesTo.isEmpty { Text("Pick at least one.") }
            }
            Section {
                Toggle("Only when starting at UI", isOn: $draft.uiOnly)
            } header: {
                Text("Where")
            } footer: {
                Text("Only shows when you pick UI campus as the start. Races never include it.")
            }
            if !isNew {
                Section {
                    Button("Delete item", role: .destructive) { pendingDelete = draft }
                }
            }
        }
        .navigationTitle(isNew ? "New item" : "Edit item")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: { Label("Cancel", systemImage: "xmark") }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: save) { Label("Save item", systemImage: "checkmark") }
                    .buttonStyle(.glassProminent)
                    .disabled(!valid)
            }
        }
        .deleteItemDialog($pendingDelete) { rule in
            sync.deleteItem(id: rule.id)
            dismiss()
        }
    }

    private func groupRow(_ group: ItemGroup, _ title: String) -> some View {
        let on = draft.groups.contains(group)
        return Button {
            if on { draft.groups.remove(group) } else { draft.groups.insert(group) }
        } label: {
            HStack {
                Text(title).foregroundStyle(.primary)
                Spacer()
                if on { Image(systemName: "checkmark").foregroundStyle(Color.accentColor) }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private func typeBinding(_ type: SessionType) -> Binding<Bool> {
        Binding(
            get: { draft.appliesTo.contains(type) },
            set: { on in
                if on { draft.appliesTo.insert(type) } else { draft.appliesTo.remove(type) }
            }
        )
    }

    private func save() {
        draft.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        sync.saveItem(draft)
        dismiss()
    }
}
