import Foundation

/// Keywords that map an event location to a place (stored in AppSettings).
public struct PlaceRules: Equatable, Sendable {
    public var uiKeywords: [String]
    public var homeKeywords: [String]

    public init(uiKeywords: [String], homeKeywords: [String]) {
        self.uiKeywords = uiKeywords
        self.homeKeywords = homeKeywords
    }

    public static let `default` = PlaceRules(
        uiKeywords: ["Universitas Indonesia", "UI", "Depok"],
        homeKeywords: ["Home", "Rumah"]
    )
}

public enum PlaceResolver {
    /// UI keywords are checked before home keywords. Nil when nothing matches.
    public static func place(location: String?, rules: PlaceRules = .default) -> Place? {
        guard let location else { return nil }
        let text = normalize(location)
        guard !text.isEmpty else { return nil }
        let words = Set(text.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map(String.init))
        if matches(text, words, rules.uiKeywords) { return .ui }
        if matches(text, words, rules.homeKeywords) { return .home }
        return nil
    }

    /// Short keywords such as "UI" match whole words only, so "Building" does not match.
    private static func matches(_ text: String, _ words: Set<String>, _ keywords: [String]) -> Bool {
        for raw in keywords {
            let keyword = normalize(raw)
            if keyword.isEmpty { continue }
            if keyword.count <= 3 {
                if words.contains(keyword) { return true }
            } else if text.contains(keyword) {
                return true
            }
        }
        return false
    }

    private static func normalize(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
