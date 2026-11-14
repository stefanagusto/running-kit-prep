import Observation

/// Navigation state shared with the notification delegate.
/// `path` holds session keys; `pendingSessionKey` is a tap waiting for the sessions to load.
@MainActor
@Observable
final class Router {
    var path: [String] = []
    var pendingSessionKey: String?
}
