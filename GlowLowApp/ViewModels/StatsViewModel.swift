import Foundation
import Observation

struct StatsDayCell: Identifiable {
    let id: String
    let date: Date?
    let title: String
    let status: DayStatus?
    let isToday: Bool
    let isFuture: Bool
    let isPlaceholder: Bool
}

struct StatsPeriodPage: Identifiable {
    enum Kind {
        case week
        case month
    }

    let id: String
    let title: String
    let kind: Kind
    let weekdaySymbols: [String]
    let cells: [StatsDayCell]
    let glowCount: Int
    let midCount: Int
    let lowCount: Int
    let glowRatio: Int
}

@MainActor
@Observable
final class StatsViewModel {
    private let storageService: StorageService
    private let dateService: DateService

    var recentEntries: [DayEntry] = []
    var pages: [StatsPeriodPage] = []
    var selectedPageID: String?
    var streak = 0

    init(storageService: StorageService, dateService: DateService) {
        self.storageService = storageService
        self.dateService = dateService
    }

    var isEmpty: Bool {
        recentEntries.isEmpty
    }

    func loadStats() {
        let allEntries = storageService.fetchAllEntries()
        let validEntries = allEntries.filter { $0.status != nil }

        recentEntries = validEntries
        streak = dateService.calculateStreak(entries: validEntries)
        pages = buildPages(from: validEntries)
        selectedPageID = pages.last?.id
    }

    private func buildPages(from entries: [DayEntry]) -> [StatsPeriodPage] {
        let keyedEntries = Dictionary(uniqueKeysWithValues: entries.map { ($0.dayKey, $0) })
        let activeMonths = activeMonthDates(from: entries)

        var result = activeMonths.map { buildMonthPage(for: $0, entriesByDay: keyedEntries) }
        result.append(buildWeekPage(entriesByDay: keyedEntries))
        return result
    }

    private func buildWeekPage(entriesByDay: [String: DayEntry]) -> StatsPeriodPage {
        let dates = dateService.weekDates(containing: .now)
        let cells = dates.map { date in
            let key = dateService.dayKey(for: date)
            return StatsDayCell(
                id: key,
                date: date,
                title: String(Calendar.autoupdatingCurrent.component(.day, from: date)),
                status: entriesByDay[key]?.status,
                isToday: dateService.isSameDay(date, .now),
                isFuture: dateService.isDateInFuture(date),
                isPlaceholder: false
            )
        }

        let summary = summary(for: cells)

        return StatsPeriodPage(
            id: "week",
            title: "This week",
            kind: .week,
            weekdaySymbols: dateService.shortWeekdaySymbols(),
            cells: cells,
            glowCount: summary.glowCount,
            midCount: summary.midCount,
            lowCount: summary.lowCount,
            glowRatio: summary.glowRatio
        )
    }

    private func buildMonthPage(for monthDate: Date, entriesByDay: [String: DayEntry]) -> StatsPeriodPage {
        let gridDates = dateService.monthDatesGrid(for: monthDate)
        let cells = gridDates.enumerated().map { index, date -> StatsDayCell in
            guard let date else {
                return StatsDayCell(
                    id: "placeholder-\(monthDate.timeIntervalSince1970)-\(index)",
                    date: nil,
                    title: "",
                    status: nil,
                    isToday: false,
                    isFuture: false,
                    isPlaceholder: true
                )
            }

            let key = dateService.dayKey(for: date)
            return StatsDayCell(
                id: key,
                date: date,
                title: String(Calendar.autoupdatingCurrent.component(.day, from: date)),
                status: entriesByDay[key]?.status,
                isToday: dateService.isSameDay(date, .now),
                isFuture: dateService.isDateInFuture(date),
                isPlaceholder: false
            )
        }

        let summary = summary(for: cells)

        return StatsPeriodPage(
            id: "month-\(dateService.monthTitle(for: monthDate))",
            title: dateService.monthTitle(for: monthDate),
            kind: .month,
            weekdaySymbols: dateService.shortWeekdaySymbols(),
            cells: cells,
            glowCount: summary.glowCount,
            midCount: summary.midCount,
            lowCount: summary.lowCount,
            glowRatio: summary.glowRatio
        )
    }

    private func activeMonthDates(from entries: [DayEntry]) -> [Date] {
        let months = Set(entries.map { dateService.startOfMonth(for: $0.date) })
        return months.sorted(by: <)
    }

    private func summary(for cells: [StatsDayCell]) -> (glowCount: Int, midCount: Int, lowCount: Int, glowRatio: Int) {
        let relevant = cells.filter { !$0.isPlaceholder && !$0.isFuture }
        let glowCount = relevant.filter { $0.status == .glow }.count
        let midCount = relevant.filter { $0.status == .mid }.count
        let lowCount = relevant.filter { $0.status == .low }.count
        let totalCount = glowCount + midCount + lowCount

        return (
            glowCount,
            midCount,
            lowCount,
            totalCount == 0 ? 0 : Int((Double(glowCount) / Double(totalCount)) * 100)
        )
    }
}
