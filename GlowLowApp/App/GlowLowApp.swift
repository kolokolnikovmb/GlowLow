import SwiftUI
import SwiftData

@main
struct GlowLowApp: App {
    private let container: AppContainer
    @State private var mainViewModel: MainViewModel

    init() {
        let container = AppContainer()
        self.container = container
        _mainViewModel = State(
            initialValue: MainViewModel(
                storageService: container.storageService,
                hapticsService: container.hapticsService
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            MainScreen(
                viewModel: mainViewModel,
                statsBuilder: {
                    StatsViewModel(
                        storageService: container.storageService,
                        dateService: container.dateService
                    )
                },
                settingsBuilder: {
                    SettingsViewModel(
                        storageService: container.storageService,
                        notificationService: container.notificationService
                    )
                }
            )
            .preferredColorScheme(nil)
        }
        .modelContainer(container.modelContainer)
    }
}
