import Foundation

public struct CalendarEvent: Equatable, Sendable {
    public var id: String
    public var title: String
    public var start: Date
    /// Name of the calendar the event came from.
    public var calendarTitle: String

    public init(id: String, title: String, start: Date, calendarTitle: String = "") {
        self.id = id
        self.title = title
        self.start = start
        self.calendarTitle = calendarTitle
    }
}
