import Foundation
import SwiftData

@MainActor
final class AppContainer {
    let modelContainer: ModelContainer
    let dateService: DateService
    let storageService: StorageService
    let notificationService: NotificationService
    let hapticsService: HapticsService

    init() {
        let schema = Schema([DayEntry.self, AppSettings.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        dateService = DateService()
        storageService = StorageService(
            modelContext: modelContainer.mainContext,
            dateService: dateService
        )
        notificationService = NotificationService()
        hapticsService = HapticsService()
        storageService.seedDefaultSettingsIfNeeded()
    }
}
