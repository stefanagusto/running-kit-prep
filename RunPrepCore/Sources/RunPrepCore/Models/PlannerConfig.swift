import Foundation

public struct PlannerConfig: Equatable, Sendable {
    public var h24Minutes: Int
    public var h12Minutes: Int
    public var leaveMinutes: Int
    public var windowDays: Int
    /// Maximum session reminders; the reinstall reminder is outside it.
    public var cap: Int
    /// Used for day words and clock times in the text. Inject a fixed zone in tests.
    public var calendar: Calendar

    public init(
        h24Minutes: Int = 1440,
        h12Minutes: Int = 720,
        leaveMinutes: Int = 30,
        windowDays: Int = 14,
        cap: Int = 60,
        calendar: Calendar = .current
    ) {
        self.h24Minutes = h24Minutes
        self.h12Minutes = h12Minutes
        self.leaveMinutes = leaveMinutes
        self.windowDays = windowDays
        self.cap = cap
        self.calendar = calendar
    }
}
