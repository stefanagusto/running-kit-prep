import Foundation

/// Where a session's place came from.
public enum PlaceSource: Sendable {
    /// The user picked it (picker or notification action).
    case chosen
    /// Read from the event location.
    case calendar
}

public struct Session: Equatable, Sendable {
    /// "<calendarItemIdentifier>|<start ISO8601 UTC>"
    public var key: String
    public var title: String
    public var type: SessionType
    public var start: Date
    /// Always nil for races.
    public var place: Place?
    /// Name of the calendar the session came from.
    public var calendarTitle: String
    /// Nil when the place is nil.
    public var placeSource: PlaceSource?
    /// The event's location text, for display.
    public var location: String?

    public init(
        key: String,
        title: String,
        type: SessionType,
        start: Date,
        place: Place? = nil,
        calendarTitle: String = "",
        placeSource: PlaceSource? = nil,
        location: String? = nil
    ) {
        self.key = key
        self.title = title
        self.type = type
        self.start = start
        self.place = place
        self.calendarTitle = calendarTitle
        self.placeSource = placeSource
        self.location = location
    }
}
