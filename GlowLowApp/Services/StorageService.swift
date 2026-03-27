import Foundation
import SwiftData

@MainActor
final class StorageService {
    private let modelContext: ModelContext
    private let dateService: DateService

    init(modelContext: ModelContext, dateService: DateService) {
        self.modelContext = modelContext
        self.dateService = dateService
    }

    func seedDefaultSettingsIfNeeded() {
        guard fetchSettings() == nil else { return }
        let settings = AppSettings()
        modelContext.insert(settings)
        saveContext()
    }

    func fetchTodayEntry() -> DayEntry? {
        fetchEntry(for: .now)
    }

    func fetchEntry(for date: Date) -> DayEntry? {
        let key = dateService.dayKey(for: date)
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.dayKey == key }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func upsertStatus(for date: Date, status: DayStatus) -> DayEntry {
        let entry = fetchOrCreateEntry(for: date)
        entry.status = status
        entry.updatedAt = .now
        saveContext()
        return entry
    }

    func upsertNote(for date: Date, note: String?) -> DayEntry {
        let trimmed = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = fetchOrCreateEntry(for: date)
        entry.textNote = trimmed?.isEmpty == true ? nil : trimmed
        entry.updatedAt = .now
        saveContext()
        return entry
    }

    func deleteNote(for date: Date) {
        guard let entry = fetchEntry(for: date) else { return }
        entry.textNote = nil
        entry.updatedAt = .now
        saveContext()
    }

    func fetchRecentEntries(limit: Int) -> [DayEntry] {
        var descriptor = FetchDescriptor<DayEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func fetchAllEntries() -> [DayEntry] {
        let descriptor = FetchDescriptor<DayEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func clearAllData() {
        let entries = fetchAllEntries()
        entries.forEach(modelContext.delete)
        saveContext()
    }

    func fetchSettings() -> AppSettings? {
        let descriptor = FetchDescriptor<AppSettings>()
        return try? modelContext.fetch(descriptor).first
    }

    func upsertSettings(
        notificationsEnabled: Bool? = nil,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil,
        accessibilityMode: Bool? = nil,
        onboardingShown: Bool? = nil
    ) -> AppSettings {
        let existingSettings = fetchSettings()
        let settings = existingSettings ?? AppSettings()
        if existingSettings == nil {
            modelContext.insert(settings)
        }

        if let notificationsEnabled {
            settings.notificationsEnabled = notificationsEnabled
        }
        if let reminderHour {
            settings.reminderHour = reminderHour
        }
        if let reminderMinute {
            settings.reminderMinute = reminderMinute
        }
        if let accessibilityMode {
            settings.accessibilityMode = accessibilityMode
        }
        if let onboardingShown {
            settings.onboardingShown = onboardingShown
        }

        saveContext()
        return settings
    }

    private func fetchOrCreateEntry(for date: Date) -> DayEntry {
        if let existingEntry = fetchEntry(for: date) {
            return existingEntry
        }

        let entry = DayEntry(
            dayKey: dateService.dayKey(for: date),
            date: dateService.startOfDay(for: date)
        )
        modelContext.insert(entry)
        return entry
    }

    private func saveContext() {
        try? modelContext.save()
    }
}
