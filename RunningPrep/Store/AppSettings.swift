import Foundation
import RunPrepCore
import SwiftData

@Model
final class AppSettings {
    /// Old single choice. Only read to migrate into calendarIds.
    var calendarId: String?
    var calendarIds: [String] = []
    var longRunPrefixes: [String]
    var raceKeywords: [String]
    var runKeywords: [String]
    /// Declaration-level defaults let SwiftData migrate old stores without a custom plan.
    var uiKeywords: [String] = PlaceRules.default.uiKeywords
    var homeKeywords: [String] = PlaceRules.default.homeKeywords

    init() {
        let rules = KeywordRules.default
        calendarId = nil
        calendarIds = []
        longRunPrefixes = rules.longRunPrefixes
        raceKeywords = rules.raceKeywords
        runKeywords = rules.runKeywords
    }

    var keywordRules: KeywordRules {
        KeywordRules(longRunPrefixes: longRunPrefixes, raceKeywords: raceKeywords, runKeywords: runKeywords)
    }

    var placeRules: PlaceRules {
        PlaceRules(uiKeywords: uiKeywords, homeKeywords: homeKeywords)
    }
}
