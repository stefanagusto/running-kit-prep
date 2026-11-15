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
    /// An alert, not a confirmation dialog: on iOS 26 the dialog becomes a popover
    /// anchored to the whole list, so it pointed at the wrong row and had no Cancel.
    func deleteItemDialog(_ item: Binding<ItemRule?>, onDelete: @escaping (ItemRule) -> Void) -> some View {
        alert(
            item.wrappedValue.map { "Delete \($0.name)?" } ?? "Delete item?",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            presenting: item.wrappedValue
        ) { rule in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { onDelete(rule) }
        } message: { _ in
            Text("It disappears from every checklist and reminder.")
        }
    }
}
