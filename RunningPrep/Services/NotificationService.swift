import Foundation
import RunPrepCore
import UserNotifications

enum NotificationStatus: Equatable {
    case notDetermined, denied, allowed
}

@MainActor
final class NotificationService {
    /// The free Apple ID cannot sign Time Sensitive, so every reminder is `.active`.
    static let useTimeSensitive = false

    private let center = UNUserNotificationCenter.current()

    func authorizationStatus() async -> NotificationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .authorized, .provisional, .ephemeral: return .allowed
        default: return .denied
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Place actions only on the H-24 and H-12 ask categories. Options are empty, so a press does not open the app.
    func registerCategories() {
        let placeActions = [
            UNNotificationAction(identifier: PlaceAction.ui, title: "Start at UI campus", options: []),
            UNNotificationAction(identifier: PlaceAction.home, title: "Start at home", options: [])
        ]
        let categories = ReminderCategory.allCases.map { category in
            let hasPlaceActions = category == .h24 || category == .h12Ask
            return UNNotificationCategory(
                identifier: category.rawValue,
                actions: hasPlaceActions ? placeActions : [],
                intentIdentifiers: [],
                options: []
            )
        }
        center.setNotificationCategories(Set(categories))
    }

    /// Remove every pending request, then add the plan. Safe to run twice.
    func replaceAll(_ plan: [PlannedReminder]) async {
        center.removeAllPendingNotificationRequests()
        for reminder in plan {
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.threadIdentifier = reminder.sessionKey ?? "app"
            var info: [String: String] = ["kind": reminder.kind.rawValue]
            if let key = reminder.sessionKey { info["sessionKey"] = key }
            content.userInfo = info
            if let category = reminder.category { content.categoryIdentifier = category.rawValue }
            content.interruptionLevel = Self.useTimeSensitive && reminder.kind == .leave ? .timeSensitive : .active
            let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    /// A completed session needs no reminder left in Notification Centre.
    func removeDelivered(forSessions keys: Set<String>) async {
        guard !keys.isEmpty else { return }
        let delivered = await center.deliveredNotifications()
        let ids = delivered.compactMap { note -> String? in
            guard let key = note.request.content.userInfo["sessionKey"] as? String, keys.contains(key) else { return nil }
            return note.request.identifier
        }
        if !ids.isEmpty { center.removeDeliveredNotifications(withIdentifiers: ids) }
    }

    func pendingCount() async -> Int {
        await center.pendingNotificationRequests().count
    }
}
