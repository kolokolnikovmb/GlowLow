import Foundation
import SwiftData

@Model
final class AppSettings {
    var notificationsEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var accessibilityMode: Bool
    var onboardingShown: Bool

    init(
        notificationsEnabled: Bool = false,
        reminderHour: Int = 21,
        reminderMinute: Int = 0,
        accessibilityMode: Bool = false,
        onboardingShown: Bool = false
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.accessibilityMode = accessibilityMode
        self.onboardingShown = onboardingShown
    }
}
