import SwiftUI

enum AppAnimations {
    static let saveFeedback = Animation.spring(response: 0.35, dampingFraction: 0.78)
    static let cardSelection = Animation.spring(response: 0.42, dampingFraction: 0.75)
    static let swipeSettle = Animation.interactiveSpring(response: 0.32, dampingFraction: 0.82)
}
