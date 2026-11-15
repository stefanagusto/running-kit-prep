import Foundation

/// Reordering inside one group (TDD 4.3, decision 15 Nov 2026). Pure.
public enum ItemOrdering {
    /// The items of one group in display order.
    public static func items(in group: ItemGroup, from items: [ItemRule]) -> [ItemRule] {
        items.filter { $0.groups.contains(group) }.sorted(by: displayOrder)
    }

    /// The sortOrder for a new item: one more than the largest, or 0 for an empty list.
    public static func nextSortOrder(after items: [ItemRule]) -> Int {
        (items.map(\.sortOrder).max() ?? -1) + 1
    }

    /// Moves rows of `group` the way SwiftUI's `onMove` describes it (`destination` counts
    /// in the list before the move). The moved list takes the sortOrder slots the group
    /// already used, so items outside the group keep their values. Returns every item,
    /// in the order it came in.
    public static func move(
        items: [ItemRule],
        in group: ItemGroup,
        from source: IndexSet,
        to destination: Int
    ) -> [ItemRule] {
        let current = Self.items(in: group, from: items)
        let valid = source.filter { current.indices.contains($0) }
        guard !valid.isEmpty else { return items }
        let slots = current.map(\.sortOrder).sorted()
        let moving = valid.sorted().map { current[$0] }
        var rest = current.enumerated().filter { !valid.contains($0.offset) }.map(\.element)
        let before = valid.filter { $0 < destination }.count
        let at = min(max(destination - before, 0), rest.count)
        rest.insert(contentsOf: moving, at: at)
        var newOrder: [UUID: Int] = [:]
        for (slot, item) in zip(slots, rest) { newOrder[item.id] = slot }
        return items.map { item in
            var copy = item
            if let order = newOrder[item.id] { copy.sortOrder = order }
            return copy
        }
    }

    private static func displayOrder(_ lhs: ItemRule, _ rhs: ItemRule) -> Bool {
        if lhs.sortOrder != rhs.sortOrder { return lhs.sortOrder < rhs.sortOrder }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
