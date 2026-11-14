import SwiftData
import SwiftUI
import UserNotifications

@main
struct RunningPrepApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            UpcomingView()
                .tint(Color.accentColor)
                .debugAppearance()
        }
        .modelContainer(for: AppSettings.self)
    }
}
