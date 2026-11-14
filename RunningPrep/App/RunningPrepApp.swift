import SwiftData
import SwiftUI
import UserNotifications

@main
struct RunningPrepApp: App {
    private let env: AppEnvironment

    @MainActor
    init() {
        env = AppEnvironment.shared
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            UpcomingView(sync: env.sync)
                .tint(Color.accentColor)
                .debugAppearance()
        }
        .modelContainer(env.container)
    }
}
