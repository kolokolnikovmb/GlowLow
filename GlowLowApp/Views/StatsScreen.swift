import SwiftUI

struct StatsScreen: View {
    @Bindable var viewModel: StatsViewModel
    let settingsBuilder: () -> SettingsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                if viewModel.isEmpty {
                    EmptyStateView(
                        title: "No entries yet",
                        subtitle: "Start checking in daily to unlock your 7-day summary and streak."
                    )
                } else {
                    StatsSummaryView(
                        last7DaysSummary: viewModel.last7DaysSummary,
                        glowCount: viewModel.glowCount,
                        midCount: viewModel.midCount,
                        lowCount: viewModel.lowCount,
                        glowRatio: viewModel.glowRatio
                    )

                    StreakBadge(streak: viewModel.streak)
                }
            }
            .padding(AppSpacing.large)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Stats")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsScreen(viewModel: settingsBuilder())
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .onAppear {
            viewModel.loadStats()
        }
    }
}
