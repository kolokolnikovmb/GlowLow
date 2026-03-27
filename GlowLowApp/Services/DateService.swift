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
