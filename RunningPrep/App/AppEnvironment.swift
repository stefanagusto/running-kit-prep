import SwiftData

/// Shared by the SwiftUI scene and the notification delegate, so a notification
/// action works on a cold launch with no UI.
@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let container: ModelContainer
    let sync: SyncCoordinator
    let router = Router()

    private init() {
        do {
            container = try ModelContainer(for: AppSettings.self, SessionStateRecord.self, ItemRecord.self)
        } catch {
            fatalError("Could not open the store: \(error)")
        }
        sync = SyncCoordinator(container: container)
    }
}
