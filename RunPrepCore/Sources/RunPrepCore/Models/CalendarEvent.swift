import Foundation

public struct CalendarEvent: Equatable, Sendable {
    public var id: String
    public var title: String
    public var start: Date
    /// Name of the calendar the event came from.
    public var calendarTitle: String
    /// The event's location text, if any.
    public var location: String?

    public init(id: String, title: String, start: Date, calendarTitle: String = "", location: String? = nil) {
        self.id = id
        self.title = title
        self.start = start
        self.calendarTitle = calendarTitle
        self.location = location
    }
}
