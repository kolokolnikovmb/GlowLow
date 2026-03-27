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

                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    header
                    MoodCard(
                        selectedStatus: viewModel.selectedStatus,
                        note: viewModel.todayEntry?.textNote,
                        onSwipe: { viewModel.handleSwipe($0) }
                    )

                    StatusSelector(
                        selectedStatus: viewModel.selectedStatus,
                        onSelect: { viewModel.selectStatus($0) }
                    )

                    Button(action: viewModel.openNoteSheet) {
                        HStack {
                            Text(viewModel.hasNoteToday ? "Edit note" : "Add note")
                            Spacer()
                            Image(systemName: "square.and.pencil")
                        }
                        .font(AppTypography.button)
                        .foregroundStyle(AppColors.primaryText)
                        .padding()
                        .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.stroke, lineWidth: 1)
                        )
                    }

                    if let note = viewModel.todayEntry?.textNote, !note.isEmpty {
                        Text(note)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
                    }

                    Spacer()
                }
                .padding(AppSpacing.large)

                if viewModel.showSavedToast {
                    Text("Saved")
                        .font(AppTypography.button)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.vertical, AppSpacing.small)
                        .background(AppColors.primaryText.opacity(0.92), in: Capsule())
                        .padding(.bottom, AppSpacing.xLarge)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        StatsScreen(
                            viewModel: statsBuilder(),
                            settingsBuilder: settingsBuilder
                        )
                    } label: {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundStyle(AppColors.primaryText)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isNoteSheetPresented) {
            NoteSheet(
                initialText: viewModel.noteText,
                onSave: { viewModel.saveNote($0) },
                onDelete: viewModel.hasNoteToday ? { viewModel.deleteNote() } : nil
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            viewModel.loadToday()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(Date.now.formatted(date: .complete, time: .omitted))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
            Text("How was your day?")
                .font(AppTypography.screenTitle)
                .foregroundStyle(AppColors.primaryText)
        }
    }
}
