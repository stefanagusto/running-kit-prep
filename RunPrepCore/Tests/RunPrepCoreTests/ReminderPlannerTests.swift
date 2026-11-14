import XCTest
@testable import RunPrepCore

final class ReminderPlannerTests: XCTestCase {
    // 2026-11-14T00:00:00Z, 07:00 in Jakarta
    private let now = Date(timeIntervalSince1970: 1_794_614_400)
    // Saturday 2026-11-21 05:00 in Jakarta (2026-11-20T22:00:00Z)
    private let sat5 = Date(timeIntervalSince1970: 1_795_212_000)
    private let day: TimeInterval = 86_400

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Jakarta")!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    private func config(cap: Int = 60) -> PlannerConfig {
        PlannerConfig(cap: cap, calendar: calendar)
    }

    private func session(
        _ key: String,
        _ type: SessionType = .long,
        start: Date? = nil,
        title: String = "Long Run 18 km",
        place: Place? = nil
    ) -> Session {
        Session(key: key, title: title, type: type, start: start ?? sat5, place: place)
    }

    private func plan(
        _ sessions: [Session],
        states: [String: SessionState] = [:],
        now: Date? = nil,
        cap: Int = 60,
        reinstall: Date? = nil
    ) -> [PlannedReminder] {
        ReminderPlanner.plan(
            sessions: sessions,
            states: states,
            items: SeedItems.all,
            config: config(cap: cap),
            now: now ?? self.now,
            reinstallDate: reinstall
        )
    }

    func testLongRunTimesTitlesAndBodies() {
        let result = plan([session("a")])
        XCTAssertEqual(result.map(\.kind), [.h24, .h12, .leave])
        XCTAssertEqual(result.map(\.fireDate), [
            sat5.addingTimeInterval(-86_400),
            sat5.addingTimeInterval(-43_200),
            sat5.addingTimeInterval(-1_800)
        ])
        let times = result.map { calendar.dateComponents([.day, .hour, .minute], from: $0.fireDate) }
        XCTAssertEqual(times.map { $0.day }, [20, 20, 21])
        XCTAssertEqual(times.map { $0.hour }, [5, 17, 4])
        XCTAssertEqual(times.map { $0.minute }, [0, 0, 30])

        XCTAssertEqual(result[0].title, "Tomorrow 05:00 Long Run 18 km")
        XCTAssertEqual(
            result[0].body,
            "Charge: Watch, AirPods. Pack: Energy gel, Electrolyte, Running cap, Banana. Where do you start? Choose in Run Prep."
        )
        XCTAssertEqual(result[1].title, "Pack tonight: Long Run 18 km, 05:00")
        XCTAssertEqual(
            result[1].body,
            "Pack: Energy gel, Electrolyte, Running cap, Banana. Where do you start? Choose in Run Prep."
        )
        XCTAssertEqual(result[2].title, "Time to go: Long Run 18 km")
        XCTAssertEqual(result[2].body, "Check your kit.")
    }

    func testBodyWithPlaceSetHasNoQuestion() {
        let result = plan([session("a", place: .ui)])
        XCTAssertEqual(
            result[0].body,
            "Charge: Watch, AirPods. Pack: Energy gel, Electrolyte, Running cap, Banana."
        )
        XCTAssertEqual(result[1].category, .h12)
    }

    func testWeekdayWordWhenFarFromFireDate() {
        var custom = config()
        custom.h24Minutes = 36 * 60
        let result = ReminderPlanner.plan(
            sessions: [session("a")], states: [:], items: SeedItems.all,
            config: custom, now: now, reinstallDate: nil
        )
        XCTAssertEqual(result[0].title, "Sat 05:00 Long Run 18 km")
    }

    func testLateAddedSessionGetsOnlyLeave() {
        let result = plan([session("a")], now: sat5.addingTimeInterval(-10 * 3_600))
        XCTAssertEqual(result.map(\.kind), [.leave])
    }

    func testFireEqualToNowIsSkipped() {
        let result = plan([session("a")], now: sat5.addingTimeInterval(-1_800))
        XCTAssertTrue(result.isEmpty)
    }

    func testStartedSessionIgnored() {
        XCTAssertTrue(plan([session("a")], now: sat5).isEmpty)
        XCTAssertTrue(plan([session("a")], now: sat5.addingTimeInterval(1)).isEmpty)
    }

    func testCompletedSessionGetsNone() {
        let result = plan([session("a")], states: ["a": SessionState(completed: true)])
        XCTAssertTrue(result.isEmpty)
    }

    func testRaceCategoriesAndNoPlaceQuestion() {
        let result = plan([session("r", .race, title: "Race - RunFest HM")])
        XCTAssertEqual(result.map(\.category), [.h24Race, .h12, .leave])
        XCTAssertFalse(result.contains { $0.body.contains("UI or home") || $0.body.contains("Where do you start") })
    }

    func testNormalRunAsksPlaceAtH12() {
        let result = plan([session("n", .normal, title: "Easy Run 8 km")])
        XCTAssertEqual(result.map(\.category), [.h24, .h12Ask, .leave])
        XCTAssertEqual(result[1].body, "Where do you start? Choose in Run Prep.")
    }

    func testNormalRunWithPlaceSetSkipsH12() {
        let result = plan([session("n", .normal, title: "Easy Run 8 km", place: .home)])
        XCTAssertEqual(result.map(\.kind), [.h24, .leave])
    }

    func testThreeWeeksRespectsWindow() {
        let sessions = (1...21).map { session("s\($0)", start: now.addingTimeInterval(Double($0) * day)) }
        let result = plan(sessions)
        // Days 1...14 are inside the window; day 1 has no H-24 because it fires exactly at now.
        XCTAssertEqual(result.count, 14 * 3 - 1)
        let keys = Set(result.compactMap(\.sessionKey))
        XCTAssertEqual(keys, Set((1...14).map { "s\($0)" }))
    }

    func testCapKeepsSoonest() {
        let sessions = (0..<30).map {
            session("s\($0)", start: now.addingTimeInterval(2 * day + Double($0) * 3_600))
        }
        let capped = plan(sessions, cap: 60)
        let all = plan(sessions, cap: 1_000)
        XCTAssertEqual(all.count, 90)
        XCTAssertEqual(capped.count, 60)
        XCTAssertEqual(capped, Array(all.prefix(60)))
        XCTAssertEqual(capped.map(\.fireDate), capped.map(\.fireDate).sorted())
    }

    func testIdentifiersStable() {
        let sessions = [session("a"), session("b", start: sat5.addingTimeInterval(day))]
        let first = plan(sessions)
        XCTAssertEqual(first, plan(sessions))
        XCTAssertTrue(first.contains { $0.identifier == "session:a:h24" })
        XCTAssertTrue(first.contains { $0.identifier == "session:b:leave" })
        XCTAssertEqual(Set(first.map(\.identifier)).count, first.count)
    }

    func testReinstallOutsideCap() {
        let sessions = (0..<10).map { session("s\($0)", start: now.addingTimeInterval(2 * day + Double($0) * 3_600)) }
        let expiry = now.addingTimeInterval(5 * day) // Nov 19, 07:00 in Jakarta
        let result = plan(sessions, cap: 5, reinstall: expiry)
        XCTAssertEqual(result.count, 6)
        let last = result.last!
        XCTAssertEqual(last.identifier, "app:reinstall")
        XCTAssertNil(last.sessionKey)
        XCTAssertNil(last.category)
        let parts = calendar.dateComponents([.day, .hour, .minute], from: last.fireDate)
        XCTAssertEqual(parts.day, 18)
        XCTAssertEqual(parts.hour, 9)
        XCTAssertEqual(parts.minute, 0)
    }

    func testReinstallInPastSkipped() {
        let result = plan([], reinstall: now.addingTimeInterval(3_600))
        XCTAssertTrue(result.isEmpty)
    }
}
