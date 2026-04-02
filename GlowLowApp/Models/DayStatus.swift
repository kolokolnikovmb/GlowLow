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

    var symbolName: String {
        switch self {
        case .glow: "sparkles"
        case .mid: "face.smiling"
        case .low: "hand.thumbsdown"
        }
    }

    var monochromeGlyph: String? {
        nil
    }

    var helperCopy: String {
        switch self {
        case .glow: "A warm, light day."
        case .mid: "A steady kind of day."
        case .low: "A heavier day than usual."
        }
    }

    var colorToken: String {
        rawValue
    }
}
