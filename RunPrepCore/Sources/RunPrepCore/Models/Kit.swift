import Foundation

public struct KitItem: Equatable, Sendable {
    public var id: UUID
    public var name: String
    /// The group this row is shown under.
    public var group: ItemGroup
    /// A uiOnly item shown while the place is still unset.
    public var conditional: Bool

    public init(id: UUID, name: String, group: ItemGroup, conditional: Bool) {
        self.id = id
        self.name = name
        self.group = group
        self.conditional = conditional
    }
}

public struct Kit: Equatable, Sendable {
    /// All groups, ordered by group then sortOrder.
    public var items: [KitItem]

    public init(items: [KitItem]) {
        self.items = items
    }

    public func items(in groups: Set<ItemGroup>) -> [KitItem] {
        items.filter { groups.contains($0.group) }
    }
}
