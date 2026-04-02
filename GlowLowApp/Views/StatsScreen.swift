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
                        subtitle: "Start checking in daily to unlock your weekly rhythm and monthly history."
                    )
                } else {
                    TabView(selection: $viewModel.selectedPageID) {
                        ForEach(viewModel.pages) { page in
                            VStack(alignment: .leading, spacing: AppSpacing.large) {
                                StatsSummaryView(page: page)
                                    .padding(.horizontal, 2)

                                if page.kind == .week {
                                    StreakBadge(streak: viewModel.streak)
                                        .padding(.horizontal, 2)
                                }

                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .tag(Optional(page.id))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 700, maxHeight: 700, alignment: .top)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .padding(AppSpacing.large)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsScreen(viewModel: settingsBuilder())
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(AppColors.primaryText)
                }
            }
        }
        .onAppear {
            viewModel.loadStats()
        }
    }
}
