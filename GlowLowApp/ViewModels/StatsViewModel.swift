import Foundation
import Observation

struct DaySummary: Identifiable {
    let id: String
    let dayKey: String
    let title: String
    let status: DayStatus?
}

@MainActor
@Observable
final class StatsViewModel {
    private let storageService: StorageService
    private let dateService: DateService

    var recentEntries: [DayEntry] = []
    var last7DaysSummary: [DaySummary] = []
    var glowCount = 0
    var midCount = 0
    var lowCount = 0
    var glowRatio = 0
    var streak = 0

    init(storageService: StorageService, dateService: DateService) {
        self.storageService = storageService
        self.dateService = dateService
    }

    var isEmpty: Bool {
        glowCount + midCount + lowCount == 0
    }

    func loadStats() {
        let allEntries = storageService.fetchAllEntries()
        let validEntries = allEntries.filter { $0.status != nil }

        recentEntries = validEntries
        glowCount = validEntries.filter { $0.status == .glow }.count
        midCount = validEntries.filter { $0.status == .mid }.count
        lowCount = validEntries.filter { $0.status == .low }.count

        let totalCount = glowCount + midCount + lowCount
        glowRatio = totalCount == 0 ? 0 : Int((Double(glowCount) / Double(totalCount)) * 100)
        streak = dateService.calculateStreak(entries: validEntries)
        last7DaysSummary = buildLast7DaysSummary(from: validEntries)
    }

    func buildLast7DaysSummary(from entries: [DayEntry]? = nil) -> [DaySummary] {
        let sourceEntries = entries ?? recentEntries
        let keyedEntries = Dictionary(uniqueKeysWithValues: sourceEntries.map { ($0.dayKey, $0) })
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")

        return dateService.last7DayKeys().map { dayKey in
            let date = dateService.dateFromDayKey(dayKey) ?? .now
            return DaySummary(
                id: dayKey,
                dayKey: dayKey,
                title: formatter.string(from: date),
                status: keyedEntries[dayKey]?.status
            )
        }
    }
}
