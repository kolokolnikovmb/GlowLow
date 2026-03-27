import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: AppSpacing.medium) {
            Text("🌤️")
                .font(.system(size: 48))
            Text(title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)
            Text(subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xLarge)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
    }
}
