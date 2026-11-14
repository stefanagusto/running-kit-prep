import Foundation

extension SyncCoordinator {
    /// Session keys end in the start time (ISO 8601 UTC), see SessionBuilder.key.
    static func startDate(fromKey key: String) -> Date? {
        guard let text = key.split(separator: "|").last else { return nil }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: String(text))
    }
}
