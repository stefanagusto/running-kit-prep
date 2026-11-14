import XCTest
@testable import RunPrepCore

final class SessionBuilderTests: XCTestCase {
    // 2026-11-14T00:00:00Z
    private let now = Date(timeIntervalSince1970: 1_794_614_400)
    private let day: TimeInterval = 86_400

    private func event(_ id: String, _ title: String, _ offset: TimeInterval) -> CalendarEvent {
        CalendarEvent(id: id, title: title, start: now.addingTimeInterval(offset))
    }

    func testWindowBoundaries() {
        let events = [
            event("past", "Easy Run", -1),
            event("now", "Easy Run", 0),
            event("last", "Easy Run", 14 * day - 1),
            event("edge", "Easy Run", 14 * day)
        ]
        let ids = SessionBuilder.sessions(from: events, now: now).map { String($0.key.split(separator: "|")[0]) }
        XCTAssertEqual(ids, ["now", "last"])
    }

    func testSkipsStrengthAndPadel() {
        let events = [event("a", "Strength", day), event("b", "Padel", day), event("c", "Tempo 6 km", day)]
        let sessions = SessionBuilder.sessions(from: events, now: now)
        XCTAssertEqual(sessions.map(\.title), ["Tempo 6 km"])
    }

    func testSortedByStart() {
        let events = [event("c", "Easy Run", 3 * day), event("a", "Easy Run", day), event("b", "Long Run 18 km", 2 * day)]
        let sessions = SessionBuilder.sessions(from: events, now: now)
        XCTAssertEqual(sessions.map(\.start), sessions.map(\.start).sorted())
        XCTAssertEqual(sessions.map(\.type), [.normal, .long, .normal])
    }

    func testKeyFormat() {
        let start = Date(timeIntervalSince1970: 1_795_237_200) // 2026-11-21T05:00:00Z
        XCTAssertEqual(SessionBuilder.key(id: "ABC-1", start: start), "ABC-1|2026-11-21T05:00:00Z")
    }

    func testRacePlaceForcedNil() {
        let e = event("r", "Race - RunFest HM", day)
        let key = SessionBuilder.key(id: e.id, start: e.start)
        let sessions = SessionBuilder.sessions(from: [e], now: now, places: [key: .ui])
        XCTAssertEqual(sessions.first?.type, .race)
        XCTAssertNil(sessions.first?.place)
    }

    func testPlaceLookupForRun() {
        let e = event("n", "Easy Run 8 km", day)
        let key = SessionBuilder.key(id: e.id, start: e.start)
        let sessions = SessionBuilder.sessions(from: [e], now: now, places: [key: .home])
        XCTAssertEqual(sessions.first?.place, .home)
    }

    func testCustomRulesPassThrough() {
        let rules = KeywordRules(longRunPrefixes: ["Big One"], raceKeywords: ["Marathon"], runKeywords: ["Jog"])
        let events = [event("a", "Big One 30k", day), event("b", "Easy Run", day), event("c", "Jog", 2 * day)]
        let sessions = SessionBuilder.sessions(from: events, rules: rules, now: now)
        XCTAssertEqual(sessions.map(\.type), [.long, .normal])
    }
}
