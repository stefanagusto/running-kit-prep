import Foundation
import RunPrepCore
import SwiftData

/// Per-session state the user changed: the chosen place now, ticks and completion later (S5).
@Model
final class SessionStateRecord {
    @Attribute(.unique) var sessionKey: String
    var placeRaw: String?
    var checkedItemIds: [String] = []
    var completedAt: Date?
    var startDate: Date

    init(sessionKey: String, startDate: Date) {
        self.sessionKey = sessionKey
        self.startDate = startDate
    }
}

/// The places the user chose, keyed by session key.
@MainActor
func places(in context: ModelContext) -> [String: Place] {
    let records = (try? context.fetch(FetchDescriptor<SessionStateRecord>())) ?? []
    var result: [String: Place] = [:]
    for record in records {
        if let raw = record.placeRaw, let place = Place(rawValue: raw) {
            result[record.sessionKey] = place
        }
    }
    return result
}

/// Upsert: one record per session key.
@MainActor
func storePlace(_ place: Place, for key: String, start: Date, in context: ModelContext) {
    let descriptor = FetchDescriptor<SessionStateRecord>(predicate: #Predicate { $0.sessionKey == key })
    if let existing = try? context.fetch(descriptor).first {
        existing.placeRaw = place.rawValue
        existing.startDate = start
    } else {
        let record = SessionStateRecord(sessionKey: key, startDate: start)
        record.placeRaw = place.rawValue
        context.insert(record)
    }
    try? context.save()
}

/// Deletes records whose session started more than 30 days ago.
@MainActor
func deleteOldRecords(before now: Date, in context: ModelContext) {
    let cutoff = now.addingTimeInterval(-30 * 86_400)
    let descriptor = FetchDescriptor<SessionStateRecord>(predicate: #Predicate { $0.startDate < cutoff })
    for record in (try? context.fetch(descriptor)) ?? [] {
        context.delete(record)
    }
    try? context.save()
}
