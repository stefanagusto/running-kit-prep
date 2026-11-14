import Foundation

/// Pure: the clock, the calendar and the items all come in as arguments.
public enum ReminderPlanner {
    /// The reminders a session is entitled to, in order h24, h12, leave.
    /// A normal run gets the H-12 reminder only while its place is unset.
    public static func slots(for session: Session, config: PlannerConfig) -> [ReminderSlot] {
        var slots = [ReminderSlot(kind: .h24, fireDate: fire(session, config.h24Minutes))]
        if session.type != .normal || session.place == nil {
            slots.append(ReminderSlot(kind: .h12, fireDate: fire(session, config.h12Minutes)))
        }
        slots.append(ReminderSlot(kind: .leave, fireDate: fire(session, config.leaveMinutes)))
        return slots
    }

    /// `reinstallDate` is the day the free-team build expires.
    public static func plan(
        sessions: [Session],
        states: [String: SessionState],
        items: [ItemRule],
        config: PlannerConfig,
        now: Date,
        reinstallDate: Date?
    ) -> [PlannedReminder] {
        let windowEnd = now.addingTimeInterval(TimeInterval(config.windowDays) * 86_400)
        var out: [PlannedReminder] = []
        var seen: Set<String> = []
        for session in sessions where session.start > now && session.start <= windowEnd {
            if states[session.key]?.completed == true { continue }
            guard seen.insert(session.key).inserted else { continue }
            let kit = KitBuilder.kit(for: session.type, place: session.place, items: items)
            for slot in slots(for: session, config: config) where slot.fireDate > now {
                out.append(reminder(slot, session, kit, config.calendar))
            }
        }
        out.sort { ($0.fireDate, $0.identifier) < ($1.fireDate, $1.identifier) }
        out = Array(out.prefix(max(0, config.cap)))
        if let reinstall = reinstallReminder(expiry: reinstallDate, now: now, calendar: config.calendar) {
            out.append(reinstall)
        }
        return out
    }

    private static func fire(_ session: Session, _ minutes: Int) -> Date {
        session.start.addingTimeInterval(-TimeInterval(minutes) * 60)
    }

    private static func reminder(
        _ slot: ReminderSlot,
        _ session: Session,
        _ kit: Kit,
        _ calendar: Calendar
    ) -> PlannedReminder {
        let asksPlace = session.type != .race && session.place == nil
        let time = clock(session.start, calendar)
        let title: String
        var clauses: [String]
        let category: ReminderCategory
        switch slot.kind {
        case .h24:
            let day = dayWord(from: slot.fireDate, to: session.start, calendar)
            title = "\(day) \(time) \(session.title)"
            clauses = [clause("Charge", kit, [.charge]), clause("Pack", kit, [.pack])]
            if asksPlace { clauses.append("Where do you start? Choose in Run Prep.") }
            category = session.type == .race ? .h24Race : .h24
        case .h12:
            title = "Pack tonight: \(session.title), \(time)"
            clauses = [clause("Pack", kit, [.pack])]
            if asksPlace { clauses.append("Where do you start? Choose in Run Prep.") }
            category = asksPlace ? .h12Ask : .h12
        default:
            title = "Time to go: \(session.title)"
            clauses = ["Check your kit."]
            category = .leave
        }
        let body = clauses.filter { !$0.isEmpty }.joined(separator: " ")
        return PlannedReminder(
            identifier: "session:\(session.key):\(slot.kind.rawValue)",
            sessionKey: session.key,
            kind: slot.kind,
            fireDate: slot.fireDate,
            title: title,
            body: body.isEmpty ? "Nothing on your list." : body,
            category: category
        )
    }

    private static func clause(_ label: String, _ kit: Kit, _ groups: Set<ItemGroup>) -> String {
        let names = kit.items(in: groups).map(\.name)
        return names.isEmpty ? "" : "\(label): \(names.joined(separator: ", "))."
    }

    /// "Today" or "Tomorrow" relative to the fire date, else the short weekday.
    private static func dayWord(from fire: Date, to start: Date, _ calendar: Calendar) -> String {
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: fire), to: calendar.startOfDay(for: start)
        ).day ?? 0
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return calendar.shortWeekdaySymbols[calendar.component(.weekday, from: start) - 1]
    }

    private static func clock(_ date: Date, _ calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return "\(pad(parts.hour ?? 0)):\(pad(parts.minute ?? 0))"
    }

    private static func pad(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    /// 09:00 local on the day before the build expires, if still ahead (TDD 7.6).
    private static func reinstallReminder(expiry: Date?, now: Date, calendar: Calendar) -> PlannedReminder? {
        guard let expiry,
              let dayBefore = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: expiry)),
              let fire = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dayBefore),
              fire > now else { return nil }
        return PlannedReminder(
            identifier: "app:reinstall",
            sessionKey: nil,
            kind: .reinstall,
            fireDate: fire,
            title: "Renew Run Prep",
            body: "Open Xcode and run the app again to renew it.",
            category: nil
        )
    }
}
