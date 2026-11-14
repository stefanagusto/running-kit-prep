import Foundation
import UserNotifications

/// Action identifiers (TDD 8.1). Plain constants, so the delegate reads them from any isolation.
enum PlaceAction {
    static let ui = "PLACE_UI"
    static let home = "PLACE_HOME"
    static let openKit = "OPEN_KIT"
}

/// Carries a non-Sendable value (the system completion handler) onto the main actor.
/// Safe here because the handler is called exactly once, on the main thread.
private struct MainThreadBox<T>: @unchecked Sendable {
    let value: T
}

/// Assigned in RunningPrepApp.init so a cold-launch tap is not lost.
///
/// Uses the completion-handler versions on purpose: with the async versions, iOS
/// completes the notification on a background thread and UserNotifications throws
/// "Call must be made on main thread" (crash seen on device, 14 Nov 2026).
/// All work and every completion call happen on the main actor.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let box = MainThreadBox(value: completionHandler)
        DispatchQueue.main.async {
            box.value([.banner, .list, .sound])
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Read everything needed from the response here; it does not cross threads.
        let action = response.actionIdentifier
        let key = response.notification.request.content.userInfo["sessionKey"] as? String
        let box = MainThreadBox(value: completionHandler)

        Task { @MainActor in
            defer { box.value() }
            guard let key else { return }
            switch action {
            case PlaceAction.ui:
                await AppEnvironment.shared.sync.setPlace(.ui, for: key)
            case PlaceAction.home:
                await AppEnvironment.shared.sync.setPlace(.home, for: key)
            case UNNotificationDefaultActionIdentifier, PlaceAction.openKit:
                AppEnvironment.shared.router.pendingSessionKey = key
            default:
                break
            }
        }
    }
}
