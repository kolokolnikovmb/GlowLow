import Foundation

struct DateService {
    private let calendar: Calendar

    init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }

    func dayKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    func isDateInFuture(_ date: Date, from referenceDate: Date = .now) -> Bool {
        startOfDay(for: date) > startOfDay(for: referenceDate)
    }

    func last7DayKeys(from date: Date = .now) -> [String] {
        (0..<7).compactMap { offset in
            guard let previousDate = calendar.date(byAdding: .day, value: -offset, to: date) else {
                return nil
            }
            return dayKey(for: previousDate)
        }.reversed()
    }

    func last7Dates(from date: Date = .now) -> [Date] {
        last7DayKeys(from: date).compactMap(dateFromDayKey)
    }

    func dateFromDayKey(_ dayKey: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dayKey)
    }

    func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components).map(startOfDay(for:)) ?? startOfDay(for: date)
    }

    func weekDates(containing date: Date = .now) -> [Date] {
        let start = startOfWeek(for: date)
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: start).map(startOfDay(for:))
        }
    }

    func startOfMonth(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components).map(startOfDay(for:)) ?? startOfDay(for: date)
    }

    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return formatter.string(from: startOfMonth(for: date))
    }

    func addingMonths(_ value: Int, to date: Date) -> Date {
        calendar.date(byAdding: .month, value: value, to: startOfMonth(for: date)) ?? date
    }

    func monthDatesGrid(for date: Date) -> [Date?] {
        let start = startOfMonth(for: date)
        guard
            let dayRange = calendar.range(of: .day, in: .month, for: start),
            let weekdayRange = calendar.range(of: .weekday, in: .weekOfYear, for: start)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: start)
        let leadingDays = (firstWeekday - calendar.firstWeekday + weekdayRange.count) % weekdayRange.count

        var grid: [Date?] = Array(repeating: nil, count: leadingDays)
        grid.append(contentsOf: dayRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start).map(startOfDay(for:))
        })

        while grid.count % weekdayRange.count != 0 {
            grid.append(nil)
        }

        return grid
    }

    func shortWeekdaySymbols() -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = max(calendar.firstWeekday - 1, 0)
        return Array(symbols[shift...]) + Array(symbols[..<shift])
    }

    func calculateStreak(entries: [DayEntry], from referenceDate: Date = .now) -> Int {
        let completedKeys = Set(entries.compactMap { entry in
            entry.status == nil ? nil : entry.dayKey
        })

        var streak = 0
        var currentDate = referenceDate

        while completedKeys.contains(dayKey(for: currentDate)) {
            streak += 1
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDate
        }

        return streak
    }
}
