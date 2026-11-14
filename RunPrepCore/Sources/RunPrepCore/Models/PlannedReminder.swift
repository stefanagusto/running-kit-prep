import Foundation

public enum ReminderKind: String, Equatable, Sendable {
    case h24, h12, leave, reinstall
}

/// Raw values are the UNNotificationCategory identifiers (TDD 8.1).
public enum ReminderCategory: String, Equatable, CaseIterable, Sendable {
    case h24 = "RUN_H24"
    case h24Race = "RUN_H24_RACE"
    case h12Ask = "RUN_H12_ASK"
    case h12 = "RUN_H12"
    case leave = "RUN_LEAVE"
}

public struct PlannedReminder: Equatable, Sendable {
    /// "session:<key>:<kind>", or "app:reinstall".
    public var identifier: String
    /// Nil for the app-level reinstall reminder.
    public var sessionKey: String?
    public var kind: ReminderKind
    public var fireDate: Date
    public var title: String
    public var body: String
    /// Nil for the reinstall reminder.
    public var category: ReminderCategory?

    public init(
        identifier: String,
        sessionKey: String?,
        kind: ReminderKind,
        fireDate: Date,
        title: String,
        body: String,
        category: ReminderCategory?
    ) {
        self.identifier = identifier
        self.sessionKey = sessionKey
        self.kind = kind
        self.fireDate = fireDate
        self.title = title
        self.body = body
        self.category = category
    }
}

/// A reminder a session is entitled to, whether or not its time has passed.
public struct ReminderSlot: Equatable, Sendable {
    public var kind: ReminderKind
    public var fireDate: Date

    public init(kind: ReminderKind, fireDate: Date) {
        self.kind = kind
        self.fireDate = fireDate
    }
}
