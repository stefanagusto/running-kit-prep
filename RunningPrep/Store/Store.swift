import SwiftData

/// The app keeps exactly one settings row.
@MainActor
func fetchOrCreateSettings(in context: ModelContext) -> AppSettings {
    if let existing = try? context.fetch(FetchDescriptor<AppSettings>()).first {
        if existing.calendarIds.isEmpty, let old = existing.calendarId {
            existing.calendarIds = [old]
            try? context.save()
        }
        return existing
    }
    let settings = AppSettings()
    context.insert(settings)
    try? context.save()
    return settings
}
