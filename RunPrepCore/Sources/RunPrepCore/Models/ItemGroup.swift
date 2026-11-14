/// Declaration order is the display order: charge, pack, bring.
public enum ItemGroup: String, Codable, CaseIterable, Sendable {
    case charge, pack, bring
}
