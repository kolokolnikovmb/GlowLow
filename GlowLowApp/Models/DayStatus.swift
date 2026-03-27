import Foundation

enum DayStatus: String, Codable, CaseIterable, Identifiable {
    case glow
    case mid
    case low

    var id: String { rawValue }

    var title: String {
        switch self {
        case .glow: "Glow"
        case .mid: "Mid"
        case .low: "Low"
        }
    }

    var emoji: String {
        switch self {
        case .glow: "✨"
        case .mid: "🙂"
        case .low: "🌧️"
        }
    }

    var colorToken: String {
        rawValue
    }
}
