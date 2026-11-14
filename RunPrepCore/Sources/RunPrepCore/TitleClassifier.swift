import Foundation

public struct KeywordRules: Equatable, Sendable {
    public var longRunPrefixes: [String]
    public var raceKeywords: [String]
    public var runKeywords: [String]

    public init(longRunPrefixes: [String], raceKeywords: [String], runKeywords: [String]) {
        self.longRunPrefixes = longRunPrefixes
        self.raceKeywords = raceKeywords
        self.runKeywords = runKeywords
    }

    public static let `default` = KeywordRules(
        longRunPrefixes: ["Long Run"],
        raceKeywords: ["Race", "RunFest"],
        runKeywords: ["Run", "Fartlek", "Interval", "Tempo"]
    )
}

public enum TitleClassifier {
    /// Order: race keyword, long-run phrase (anywhere in the title), run keyword, else nil (skip).
    public static func classify(title: String, rules: KeywordRules = .default) -> SessionType? {
        let text = normalize(title)
        if keys(rules.raceKeywords).contains(where: { text.contains($0) }) {
            return .race
        }
        if keys(rules.longRunPrefixes).contains(where: { text.contains($0) }) {
            return .long
        }
        if keys(rules.runKeywords).contains(where: { text.contains($0) }) {
            return .normal
        }
        return nil
    }

    /// Blank keywords are dropped: an empty string would match every title.
    private static func keys(_ keywords: [String]) -> [String] {
        keywords.map(normalize).filter { !$0.isEmpty }
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
