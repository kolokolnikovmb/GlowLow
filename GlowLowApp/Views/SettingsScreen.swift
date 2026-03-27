import SwiftUI

struct SettingsScreen: View {
    @Bindable var viewModel: SettingsViewModel
    @State private var reminderTime = Date.now

    var body: some View {
        Form {
            Section("Reminder") {
                Toggle("Daily reminder", isOn: Binding(
                    get: { viewModel.notificationsEnabled },
                    set: { viewModel.toggleNotifications($0) }
                ))

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

                if viewModel.notificationPermissionDenied {
                    Text("Notifications are denied in system settings. You can still use the app without reminders.")
                        .font(AppTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Accessibility") {
                Toggle("Accessibility mode", isOn: Binding(
                    get: { viewModel.accessibilityMode },
                    set: { viewModel.toggleAccessibilityMode($0) }
                ))
            }

            Section {
                Button("Clear all data", role: .destructive) {
                    viewModel.showClearDataConfirmation = true
                }
            }
        }
        .navigationTitle("Settings")
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
}
