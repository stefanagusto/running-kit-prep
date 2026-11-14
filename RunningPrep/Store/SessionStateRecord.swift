import Foundation
import RunPrepCore
import SwiftData

/// Per-session state the user changed: the chosen place, ticked kit items and completion.
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

@MainActor
private func record(for key: String, in context: ModelContext) -> SessionStateRecord? {
    let descriptor = FetchDescriptor<SessionStateRecord>(predicate: #Predicate { $0.sessionKey == key })
    return try? context.fetch(descriptor).first
}

/// Tick keys ("<itemId>:<group>") saved for one session.
@MainActor
func ticks(for key: String, in context: ModelContext) -> Set<String> {
    Set(record(for: key, in: context)?.checkedItemIds ?? [])
}

/// Flips one tick (upsert) and returns the ticks after the change.
@MainActor
@discardableResult
func toggleTick(_ tickKey: String, for key: String, start: Date, in context: ModelContext) -> Set<String> {
    let target: SessionStateRecord
    if let existing = record(for: key, in: context) {
        target = existing
    } else {
        target = SessionStateRecord(sessionKey: key, startDate: start)
        context.insert(target)
    }
    var current = Set(target.checkedItemIds)
    if current.contains(tickKey) {
        current.remove(tickKey)
    } else {
        current.insert(tickKey)
    }
    target.checkedItemIds = current.sorted()
    try? context.save()
    return current
}

/// Sets or clears completedAt. Does nothing when no record exists and the value is false.
@MainActor
func setCompleted(_ completed: Bool, for key: String, in context: ModelContext) {
    guard let existing = record(for: key, in: context) else { return }
    if completed {
        if existing.completedAt == nil { existing.completedAt = Date() }
    } else {
        existing.completedAt = nil
    }
    try? context.save()
}

/// Completed sessions, keyed by session key, for ReminderPlanner.
@MainActor
func completedStates(in context: ModelContext) -> [String: SessionState] {
    let records = (try? context.fetch(FetchDescriptor<SessionStateRecord>())) ?? []
    var result: [String: SessionState] = [:]
    for item in records where item.completedAt != nil {
        result[item.sessionKey] = SessionState(completed: true)
    }
    return result
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
