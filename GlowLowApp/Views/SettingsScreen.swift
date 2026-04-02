import SwiftUI

struct SettingsScreen: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var reminderTime = Date.now

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                reminderCard
                dangerCard
            }
            .padding(AppSpacing.large)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadSettings()
            reminderTime = configuredReminderDate
        }
        .confirmationDialog(
            "Delete all entries and notes?",
            isPresented: $viewModel.showClearDataConfirmation
        ) {
            Button("Clear all data", role: .destructive) {
                viewModel.clearAllData()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @MainActor
    private var configuredReminderDate: Date {
        Calendar.autoupdatingCurrent.date(
            bySettingHour: viewModel.reminderHour,
            minute: viewModel.reminderMinute,
            second: 0,
            of: .now
        ) ?? .now
    }

    private var reminderCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Reminder")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            Toggle("Daily reminder", isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { viewModel.toggleNotifications($0) }
            ))
            .tint(AppColors.glow)

            DatePicker(
                "Reminder time",
                selection: $reminderTime,
                displayedComponents: .hourAndMinute
            )
            .onChange(of: reminderTime) { _, value in
                let components = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: value)
                viewModel.updateReminderTime(
                    hour: components.hour ?? 21,
                    minute: components.minute ?? 0
                )
            }
            .disabled(!viewModel.notificationsEnabled)
            .opacity(viewModel.notificationsEnabled ? 1 : 0.5)

            if viewModel.notificationPermissionDenied {
                Text("Notifications are denied in system settings. You can still use the app without reminders.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(AppSpacing.large)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    private var dangerCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Danger")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            Button("Clear all data", role: .destructive) {
                viewModel.showClearDataConfirmation = true
            }
            .font(AppTypography.button)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppSpacing.large)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }
}
