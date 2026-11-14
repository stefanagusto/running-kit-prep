import UserNotifications

/// Action identifiers (TDD 8.1). Plain constants, so the delegate reads them from any isolation.
enum PlaceAction {
    static let ui = "PLACE_UI"
    static let home = "PLACE_HOME"
    static let openKit = "OPEN_KIT"
}

/// Assigned in RunningPrepApp.init so a cold-launch tap is not lost.
/// Place actions work with no UI. The default tap sets the router's pending session, which Upcoming turns into the checklist.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = NotificationDelegate()

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let action = response.actionIdentifier
        guard let key = response.notification.request.content.userInfo["sessionKey"] as? String else { return }
        switch action {
        case PlaceAction.ui:
            await AppEnvironment.shared.sync.setPlace(.ui, for: key)
        case PlaceAction.home:
            await AppEnvironment.shared.sync.setPlace(.home, for: key)
        case UNNotificationDefaultActionIdentifier, PlaceAction.openKit:
            await MainActor.run { AppEnvironment.shared.router.pendingSessionKey = key }
        default:
            break
        }
    }
}
