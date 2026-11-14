import Foundation

public enum CountdownTier: Sendable {
    /// Today or tomorrow.
    case soon
    /// 2 to 3 days.
    case near
    case later
}

public struct CountdownLabel: Equatable, Sendable {
    public var text: String
    public var tier: CountdownTier
    public var days: Int

    public init(text: String, tier: CountdownTier, days: Int) {
        self.text = text
        self.tier = tier
        self.days = days
    }
}

public enum Countdown {
    /// Counts calendar days (startOfDay to startOfDay), not 24-hour blocks.
    public static func label(from now: Date, to start: Date, calendar: Calendar) -> CountdownLabel {
        let raw = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: start)
        ).day ?? 0
        let days = max(0, raw)
        switch days {
        case 0: return CountdownLabel(text: "Today", tier: .soon, days: 0)
        case 1: return CountdownLabel(text: "Tomorrow", tier: .soon, days: 1)
        case 2, 3: return CountdownLabel(text: "In \(days) days", tier: .near, days: days)
        default: return CountdownLabel(text: "In \(days) days", tier: .later, days: days)
        }
    }
}
