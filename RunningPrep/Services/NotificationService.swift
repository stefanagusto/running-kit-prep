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

    /// Categories have no actions yet; the place actions arrive with S4.
    func registerCategories() {
        let categories = ReminderCategory.allCases.map {
            UNNotificationCategory(identifier: $0.rawValue, actions: [], intentIdentifiers: [], options: [])
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

    func pendingCount() async -> Int {
        await center.pendingNotificationRequests().count
    }
}
