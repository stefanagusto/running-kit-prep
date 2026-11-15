import Foundation

/// The one-line rule shown under an item name on the Items screen. Pure.
public enum ItemSummary {
    /// "All sessions", or the types joined with " · ", plus " · UI only".
    public static func text(for rule: ItemRule) -> String {
        var parts: [String]
        if rule.appliesTo.isSuperset(of: Set(SessionType.allCases)) {
            parts = ["All sessions"]
        } else {
            parts = SessionType.allCases.filter { rule.appliesTo.contains($0) }.map(label)
        }
        if rule.uiOnly { parts.append("UI only") }
        return parts.joined(separator: " \u{00B7} ")
    }

    private static func label(_ type: SessionType) -> String {
        switch type {
        case .normal: return "Normal"
        case .long: return "Long run"
        case .race: return "Race"
        }
    }
}
