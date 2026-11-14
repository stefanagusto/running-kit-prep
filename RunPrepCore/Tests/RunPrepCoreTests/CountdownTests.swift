import XCTest
@testable import RunPrepCore

final class CountdownTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Jakarta")!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    private func label(daysAhead: Int) -> CountdownLabel {
        Countdown.label(from: date(14, 10), to: date(14 + daysAhead, 5), calendar: calendar)
    }

    func testToday() {
        XCTAssertEqual(label(daysAhead: 0), CountdownLabel(text: "Today", tier: .soon, days: 0))
    }

    func testTomorrow() {
        XCTAssertEqual(label(daysAhead: 1), CountdownLabel(text: "Tomorrow", tier: .soon, days: 1))
    }

    func testNearTier() {
        XCTAssertEqual(label(daysAhead: 2), CountdownLabel(text: "In 2 days", tier: .near, days: 2))
        XCTAssertEqual(label(daysAhead: 3), CountdownLabel(text: "In 3 days", tier: .near, days: 3))
    }

    func testLaterTier() {
        XCTAssertEqual(label(daysAhead: 4), CountdownLabel(text: "In 4 days", tier: .later, days: 4))
        XCTAssertEqual(label(daysAhead: 13).days, 13)
        XCTAssertEqual(label(daysAhead: 16), CountdownLabel(text: "In 16 days", tier: .later, days: 16))
    }

    func testLateEveningToEarlyMorningIsTomorrow() {
        let result = Countdown.label(from: date(14, 23, 30), to: date(15, 5), calendar: calendar)
        XCTAssertEqual(result.text, "Tomorrow")
    }

    func testJustAfterMidnightSameDayIsToday() {
        let result = Countdown.label(from: date(14, 0, 5), to: date(14, 23, 55), calendar: calendar)
        XCTAssertEqual(result.text, "Today")
    }
}
