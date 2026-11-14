import SwiftData
import SwiftUI

@main
struct RunningPrepApp: App {
    var body: some Scene {
        WindowGroup {
            UpcomingView()
                .tint(Color.accentColor)
        }
        .modelContainer(for: AppSettings.self)
    }
}
