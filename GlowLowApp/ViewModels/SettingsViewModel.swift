import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
final class SettingsViewModel {
    private let storageService: StorageService
    private let notificationService: NotificationService

    var notificationsEnabled = false
    var reminderHour = 21
    var reminderMinute = 0
    var accessibilityMode = false
    var notificationPermissionDenied = false
    var showClearDataConfirmation = false

    init(storageService: StorageService, notificationService: NotificationService) {
        self.storageService = storageService
        self.notificationService = notificationService
        loadSettings()
    }

    func loadSettings() {
        let settings = storageService.fetchSettings() ?? storageService.upsertSettings()
        notificationsEnabled = settings.notificationsEnabled
        reminderHour = settings.reminderHour
        reminderMinute = settings.reminderMinute
        accessibilityMode = settings.accessibilityMode

        Task {
            let status = await notificationService.getAuthorizationStatus()
            notificationPermissionDenied = status == .denied
        }
    }

    func toggleNotifications(_ enabled: Bool) {
        Task {
            if enabled {
                let granted = await notificationService.requestAuthorization()
                let status = await notificationService.getAuthorizationStatus()
                notificationPermissionDenied = status == .denied

                guard granted else {
                    notificationsEnabled = false
                    storageService.upsertSettings(notificationsEnabled: false)
                    return
                }

                notificationsEnabled = true
                storageService.upsertSettings(notificationsEnabled: true)
                await notificationService.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            } else {
                notificationService.cancelDailyReminder()
                notificationsEnabled = false
                notificationPermissionDenied = false
                storageService.upsertSettings(notificationsEnabled: false)
            }
        }
    }

    func updateReminderTime(hour: Int, minute: Int) {
        reminderHour = hour
        reminderMinute = minute
        storageService.upsertSettings(reminderHour: hour, reminderMinute: minute)

        guard notificationsEnabled else { return }
        Task {
            await notificationService.scheduleDailyReminder(hour: hour, minute: minute)
        }
    }

    func toggleAccessibilityMode(_ enabled: Bool) {
        accessibilityMode = enabled
        storageService.upsertSettings(accessibilityMode: enabled)
    }

    func clearAllData() {
        storageService.clearAllData()
        showClearDataConfirmation = false
    }
}
