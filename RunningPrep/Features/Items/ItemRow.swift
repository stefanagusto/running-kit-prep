import RunPrepCore
import SwiftUI

/// Name plus the rule summary. The row is a `NavigationLink` label.
struct ItemRow: View {
    let rule: ItemRule

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(rule.name)
                .font(.body)
            Text(ItemSummary.text(for: rule))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

extension ItemGroup {
    /// Section header on the Items screen.
    var itemsHeader: String {
        switch self {
        case .charge: return "Charge \u{00B7} day before"
        case .pack: return "Pack \u{00B7} day before"
        case .bring: return "Bring \u{00B7} on the way out"
        }
    }
}

extension View {
    /// The delete confirmation shared by the list and the edit screen.
    func deleteItemDialog(_ item: Binding<ItemRule?>, onDelete: @escaping (ItemRule) -> Void) -> some View {
        confirmationDialog(
            item.wrappedValue.map { "Delete \($0.name)?" } ?? "Delete item?",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            titleVisibility: .visible,
            presenting: item.wrappedValue
        ) { rule in
            Button("Delete item", role: .destructive) { onDelete(rule) }
        } message: { _ in
            Text("It disappears from every checklist and reminder.")
        }
    }
}
