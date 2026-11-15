import Foundation
import RunPrepCore
import SwiftData

@MainActor
private func itemRecords(in context: ModelContext) -> [ItemRecord] {
    (try? context.fetch(FetchDescriptor<ItemRecord>(sortBy: [SortDescriptor(\.sortOrder)]))) ?? []
}

/// First launch only (`seedVersion == 0`): inserts the starter items. Never overwrites edits.
@MainActor
func seedItemsIfNeeded(in context: ModelContext) {
    let settings = fetchOrCreateSettings(in: context)
    guard settings.seedVersion == 0 else { return }
    let existing = Set(itemRecords(in: context).map(\.id))
    for rule in SeedItems.all where !existing.contains(rule.id) {
        context.insert(ItemRecord(rule))
    }
    settings.seedVersion = 1
    try? context.save()
}

/// All items, sorted by sortOrder.
@MainActor
func fetchItems(in context: ModelContext) -> [ItemRule] {
    itemRecords(in: context).map(\.rule)
}

/// Updates the item with this id, or inserts it. A new item goes to the end of the list.
@MainActor
func upsertItem(_ rule: ItemRule, in context: ModelContext) {
    let id = rule.id
    let descriptor = FetchDescriptor<ItemRecord>(predicate: #Predicate { $0.id == id })
    if let existing = try? context.fetch(descriptor).first {
        existing.apply(rule)
    } else {
        var fresh = rule
        fresh.sortOrder = ItemOrdering.nextSortOrder(after: fetchItems(in: context))
        context.insert(ItemRecord(fresh))
    }
    try? context.save()
}

@MainActor
func removeItem(id: UUID, in context: ModelContext) {
    let descriptor = FetchDescriptor<ItemRecord>(predicate: #Predicate { $0.id == id })
    for record in (try? context.fetch(descriptor)) ?? [] {
        context.delete(record)
    }
    try? context.save()
}

/// Writes new sortOrder values (from `ItemOrdering.move`) to the stored items.
@MainActor
func storeSortOrders(_ rules: [ItemRule], in context: ModelContext) {
    let orders = Dictionary(uniqueKeysWithValues: rules.map { ($0.id, $0.sortOrder) })
    for record in itemRecords(in: context) {
        if let order = orders[record.id], record.sortOrder != order { record.sortOrder = order }
    }
    try? context.save()
}
