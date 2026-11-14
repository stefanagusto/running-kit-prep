import RunPrepCore
import SwiftUI

struct CalendarOption: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    /// The account the calendar belongs to (iCloud, a Google address, ...).
    let account: String
    let color: Color
}

enum UpcomingState: Equatable {
    case loading
    case needsPermission
    case denied
    case calendarNotFound([CalendarOption])
    case empty
    case sessions([Session])
}
