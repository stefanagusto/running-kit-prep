import XCTest
@testable import RunPrepCore

final class TitleClassifierTests: XCTestCase {
    private func classify(_ title: String) -> SessionType? {
        TitleClassifier.classify(title: title)
    }

    func testExampleTable() {
        let cases: [(String, SessionType?)] = [
            ("Long Run 18 km", .long),
            ("long run 18km", .long),
            ("Race - Pertamina Eco RunFest HM", .race),
            ("Pertamina Eco RunFest HM", .race),
            ("Easy Run 8 km", .normal),
            ("Tempo 6 km", .normal),
            ("Interval 6 x 800", .normal),
            ("Fartlek", .normal),
            ("Morning Long Run", .normal),
            ("10K tempo", .normal),
            ("10K", nil),
            ("Strength", nil),
            ("Padel", nil),
            ("  RACE day  ", .race),
            ("Race pace 5 km", .race),
            ("", nil)
        ]
        for (title, expected) in cases {
            XCTAssertEqual(classify(title), expected, "title: \(title)")
        }
    }

    func testRaceBeatsLongRun() {
        XCTAssertEqual(classify("Long Run Race"), .race)
    }

    func testDiacriticsAreIgnored() {
        XCTAssertEqual(classify("Lóng Rún 20 km"), .long)
    }

    func testWhitespaceOnlyTitleIsSkipped() {
        XCTAssertNil(classify("   "))
    }

    func testBlankKeywordIsIgnored() {
        let rules = KeywordRules(longRunPrefixes: ["  "], raceKeywords: [""], runKeywords: [" "])
        XCTAssertNil(TitleClassifier.classify(title: "Padel", rules: rules))
    }

    func testCustomKeywords() {
        let rules = KeywordRules(
            longRunPrefixes: ["Endurance"],
            raceKeywords: ["Marathon"],
            runKeywords: ["Jog"]
        )
        XCTAssertEqual(TitleClassifier.classify(title: "Endurance 25 km", rules: rules), .long)
        XCTAssertEqual(TitleClassifier.classify(title: "Bali Marathon", rules: rules), .race)
        XCTAssertEqual(TitleClassifier.classify(title: "Easy jog", rules: rules), .normal)
        XCTAssertNil(TitleClassifier.classify(title: "Easy Run", rules: rules))
    }

    func testRemovingRaceKeywordFixesRacePaceLimit() {
        var rules = KeywordRules.default
        rules.raceKeywords = ["RunFest"]
        XCTAssertNotEqual(TitleClassifier.classify(title: "Race pace 5 km", rules: rules), .race)
        XCTAssertEqual(TitleClassifier.classify(title: "Race pace run 5 km", rules: rules), .normal)
    }
}
