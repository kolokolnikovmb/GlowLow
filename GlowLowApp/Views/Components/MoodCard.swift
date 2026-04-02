import SwiftUI

struct MoodCard: View {
    let selectedStatus: DayStatus?
    let note: String?
    let onSwipe: (DayStatus) -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text(selectedStatus?.title ?? "Today")
                        .font(AppTypography.sectionTitle)
                        .foregroundStyle(AppColors.primaryText)

                    Text(descriptionText)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(3)
                }

                Spacer()

                Image(systemName: selectedStatus?.symbolName ?? "circle.grid.2x2.fill")
                    .font(.system(size: selectedStatus == .low ? 24 : 26, weight: .semibold))
                    .frame(width: 26, height: 26)
                .foregroundStyle(iconColor)
                .padding(12)
                .background(Color.white.opacity(0.42), in: Circle())
            }

            Spacer(minLength: 0)

            Text(selectedStatus?.title ?? "Choose your mood")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryText.opacity(selectedStatus == nil ? 0.55 : 0.9))
        }
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
        .padding(AppSpacing.large)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
        .offset(dragOffset)
        .animation(AppAnimations.swipeSettle, value: dragOffset)
        .highPriorityGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { dragOffset = $0.translation }
                .onEnded { value in
                    handleSwipe(value.translation)
                }
        )
    }

    private var backgroundColor: LinearGradient {
        switch selectedStatus {
        case .glow:
            LinearGradient(
                colors: [
                    Color(red: 1.00, green: 0.79, blue: 0.28),
                    Color(red: 0.99, green: 0.88, blue: 0.53),
                    Color(red: 0.98, green: 0.96, blue: 0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mid:
            LinearGradient(
                colors: [Color(red: 0.92, green: 0.95, blue: 0.98), Color(red: 0.80, green: 0.87, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .low:
            LinearGradient(
                colors: [Color(red: 0.82, green: 0.85, blue: 0.89), Color(red: 0.69, green: 0.74, blue: 0.79)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case nil:
            LinearGradient(
                colors: [Color.white, AppColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var descriptionText: String {
        if let note, !note.isEmpty {
            return note
        }

        return selectedStatus?.helperCopy ?? "Choose Glow, Mid, or Low for today."
    }

    private var iconColor: Color {
        switch selectedStatus {
        case .glow:
            return Color(red: 0.52, green: 0.42, blue: 0.08)
        case .mid:
            return Color(red: 0.28, green: 0.34, blue: 0.42)
        case .low:
            return Color(red: 0.30, green: 0.35, blue: 0.41)
        case nil:
            return AppColors.secondaryText
        }
    }

    private func handleSwipe(_ translation: CGSize) {
        defer { dragOffset = .zero }

        let threshold: CGFloat = 70
        if translation.width > threshold {
            onSwipe(stepStatus(from: selectedStatus ?? .mid, movingRight: true))
        } else if translation.width < -threshold {
            onSwipe(stepStatus(from: selectedStatus ?? .mid, movingRight: false))
        }
    }

    private func stepStatus(from currentStatus: DayStatus, movingRight: Bool) -> DayStatus {
        switch (currentStatus, movingRight) {
        case (.low, true):
            return .mid
        case (.mid, true):
            return .glow
        case (.glow, true):
            return .glow
        case (.glow, false):
            return .mid
        case (.mid, false):
            return .low
        case (.low, false):
            return .low
        }
    }
}
