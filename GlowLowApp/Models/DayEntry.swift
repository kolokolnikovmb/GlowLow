import Foundation
import SwiftData

@Model
final class DayEntry {
    @Attribute(.unique) var dayKey: String
    var date: Date
    var statusRaw: String?
    var textNote: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        dayKey: String,
        date: Date,
        statusRaw: String? = nil,
        textNote: String? = nil,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.dayKey = dayKey
        self.date = date
        self.statusRaw = statusRaw
        self.textNote = textNote
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var status: DayStatus? {
        get { statusRaw.flatMap(DayStatus.init(rawValue:)) }
        set { statusRaw = newValue?.rawValue }
    }
}
