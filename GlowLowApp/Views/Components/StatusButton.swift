import SwiftUI

struct StatusButton: View {
    let status: DayStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xSmall) {
                Text(status.emoji)
                    .font(.title2)
                Text(status.title)
                    .font(AppTypography.button)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.medium)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? buttonColor.opacity(0.9) : AppColors.stroke, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var buttonBackground: Color {
        isSelected ? buttonColor.opacity(0.2) : Color.white.opacity(0.72)
    }

    private var buttonColor: Color {
        switch status {
        case .glow: AppColors.glow
        case .mid: AppColors.mid
        case .low: AppColors.low
        }
    }
}
