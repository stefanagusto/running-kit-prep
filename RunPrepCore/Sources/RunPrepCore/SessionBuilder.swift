import Foundation

public enum SessionBuilder {
    /// Turns calendar events in [now, now + windowDays) into sessions, sorted by start.
    public static func sessions(
        from events: [CalendarEvent],
        rules: KeywordRules = .default,
        now: Date,
        windowDays: Int = 14,
        places: [String: Place] = [:]
    ) -> [Session] {
        let end = now.addingTimeInterval(TimeInterval(windowDays) * 86_400)
        var result: [Session] = []
        for event in events where event.start >= now && event.start < end {
            guard let type = TitleClassifier.classify(title: event.title, rules: rules) else { continue }
            let sessionKey = Self.key(id: event.id, start: event.start)
            let place: Place? = type == .race ? nil : places[sessionKey]
            result.append(Session(key: sessionKey, title: event.title, type: type, start: event.start, place: place))
        }
        return result.sorted { $0.start < $1.start }
    }

    /// "<id>|<start as ISO8601 UTC, whole seconds>", for example "abc|2026-11-21T05:00:00Z".
    public static func key(id: String, start: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(identifier: "UTC")
        return "\(id)|\(formatter.string(from: start))"
    }
}
