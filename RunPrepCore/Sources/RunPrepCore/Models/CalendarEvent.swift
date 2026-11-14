import Foundation

public struct CalendarEvent: Equatable, Sendable {
    public var id: String
    public var title: String
    public var start: Date

    public init(id: String, title: String, start: Date) {
        self.id = id
        self.title = title
        self.start = start
    }
}
