import Foundation

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

    public init(
        key: String,
        title: String,
        type: SessionType,
        start: Date,
        place: Place? = nil,
        calendarTitle: String = ""
    ) {
        self.key = key
        self.title = title
        self.type = type
        self.start = start
        self.place = place
        self.calendarTitle = calendarTitle
    }
}
