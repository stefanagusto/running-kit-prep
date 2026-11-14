import Foundation
import RunPrepCore
import SwiftData

@Model
final class AppSettings {
    var calendarId: String?
    var longRunPrefixes: [String]
    var raceKeywords: [String]
    var runKeywords: [String]

    init() {
        let rules = KeywordRules.default
        calendarId = nil
        longRunPrefixes = rules.longRunPrefixes
        raceKeywords = rules.raceKeywords
        runKeywords = rules.runKeywords
    }

    var keywordRules: KeywordRules {
        KeywordRules(longRunPrefixes: longRunPrefixes, raceKeywords: raceKeywords, runKeywords: runKeywords)
    }
}
