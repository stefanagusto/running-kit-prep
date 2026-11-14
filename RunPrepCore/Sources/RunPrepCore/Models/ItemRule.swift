import Foundation

public struct ItemRule: Identifiable, Codable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var groups: Set<ItemGroup>
    public var appliesTo: Set<SessionType>
    /// Only when the place is UI.
    public var uiOnly: Bool
    public var sortOrder: Int

    public init(
        id: UUID,
        name: String,
        groups: Set<ItemGroup>,
        appliesTo: Set<SessionType>,
        uiOnly: Bool,
        sortOrder: Int
    ) {
        self.id = id
        self.name = name
        self.groups = groups
        self.appliesTo = appliesTo
        self.uiOnly = uiOnly
        self.sortOrder = sortOrder
    }
}
