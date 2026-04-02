import SwiftUI

struct MainScreen: View {
    @Bindable var viewModel: MainViewModel
    let statsBuilder: () -> StatsViewModel
    let settingsBuilder: () -> SettingsViewModel

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        header

                        MoodCard(
                            selectedStatus: viewModel.cardStatus,
                            note: viewModel.cardNotePreview,
                            onSwipe: { viewModel.handleSwipe($0) }
                        )

                        StatusSelector(
                            selectedStatus: viewModel.cardStatus,
                            onSelect: { viewModel.selectStatus($0) }
                        )

                        actionRow

                        Spacer(minLength: AppSpacing.xLarge)
                    }
                    .padding(AppSpacing.large)
                }

                if viewModel.showSavedToast {
                    Text("Saved for today")
                        .font(AppTypography.button)
                        .foregroundStyle(AppColors.primaryText)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.vertical, AppSpacing.small)
                        .background(Color.white.opacity(0.92), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppColors.stroke, lineWidth: 1)
                        )
                        .padding(.bottom, AppSpacing.xLarge)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.isNoteSheetPresented) {
            NoteSheet(
                initialText: viewModel.noteText,
                onSave: { viewModel.saveNote($0) }
            )
            .presentationDetents([.height(380), .medium])
        }
        .onAppear {
            viewModel.loadToday()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .top) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Spacer()
                NavigationLink {
                    StatsScreen(
                        viewModel: statsBuilder(),
                        settingsBuilder: settingsBuilder
                    )
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.82), in: Circle())
                        .overlay(Circle().stroke(AppColors.stroke, lineWidth: 1))
                }
            }

            Text("How was your day?")
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColors.primaryText)
        }
    }

    private var actionRow: some View {
        HStack(spacing: AppSpacing.small) {
            Button(action: viewModel.openNoteSheet) {
                HStack(spacing: AppSpacing.small) {
                    Image(systemName: "square.and.pencil")
                    Text("Add note")
                }
                .font(AppTypography.button)
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.medium)
                .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.stroke, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button(action: viewModel.saveEntry) {
                HStack(spacing: AppSpacing.small) {
                    Text("Save")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .font(AppTypography.button)
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.medium)
                .background(saveBackground, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(viewModel.canSave ? AppColors.primaryText.opacity(0.08) : AppColors.stroke, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSave)
        }
    }

    private var saveBackground: Color {
        guard viewModel.canSave else {
            return Color.white.opacity(0.45)
        }

        switch viewModel.cardStatus {
        case .glow:
            return AppColors.glow.opacity(0.86)
        case .mid:
            return AppColors.mid.opacity(0.72)
        case .low:
            return AppColors.low.opacity(0.62)
        case nil:
            return Color.white.opacity(0.45)
        }
    }
}
