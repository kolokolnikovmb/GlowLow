import SwiftUI

struct StreakBadge: View {
    let streak: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text("Current streak")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text("\(streak) day\(streak == 1 ? "" : "s")")
                    .font(AppTypography.metric)
                    .foregroundStyle(AppColors.primaryText)
            }
            Spacer()
            Text("🔥")
                .font(.system(size: 42))
        }
        .padding(AppSpacing.large)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
    }
}
