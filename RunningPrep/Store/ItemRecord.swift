import Foundation
import RunPrepCore
import SwiftData

/// One item the user can bring or charge. Stored copy of an `ItemRule` (TDD 4.2).
@Model
final class ItemRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    /// `ItemGroup` raw values.
    var groupsRaw: [String]
    var normal: Bool
    var long: Bool
    var race: Bool
    var uiOnly: Bool
    var sortOrder: Int

    init(_ rule: ItemRule) {
        id = rule.id
        name = rule.name
        groupsRaw = []
        normal = false
        long = false
        race = false
        uiOnly = false
        sortOrder = rule.sortOrder
        apply(rule)
    }

    var rule: ItemRule {
        var types: Set<SessionType> = []
        if normal { types.insert(.normal) }
        if long { types.insert(.long) }
        if race { types.insert(.race) }
        return ItemRule(
            id: id,
            name: name,
            groups: Set(groupsRaw.compactMap(ItemGroup.init(rawValue:))),
            appliesTo: types,
            uiOnly: uiOnly,
            sortOrder: sortOrder
        )
    }

    /// Copies every field except the id, which stays so saved ticks remain valid.
    func apply(_ rule: ItemRule) {
        name = rule.name
        groupsRaw = ItemGroup.allCases.filter { rule.groups.contains($0) }.map(\.rawValue)
        normal = rule.appliesTo.contains(.normal)
        long = rule.appliesTo.contains(.long)
        race = rule.appliesTo.contains(.race)
        uiOnly = rule.uiOnly
        sortOrder = rule.sortOrder
    }
}
