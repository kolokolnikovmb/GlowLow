import SwiftUI

struct StatsSummaryView: View {
    let last7DaysSummary: [DaySummary]
    let glowCount: Int
    let midCount: Int
    let lowCount: Int
    let glowRatio: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            Text("Last 7 days")
                .font(AppTypography.sectionTitle)

            HStack(spacing: AppSpacing.small) {
                ForEach(last7DaysSummary) { item in
                    VStack(spacing: AppSpacing.xSmall) {
                        Text(item.title)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                        Text(item.status?.emoji ?? "·")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.small)
                            .background(backgroundColor(for: item.status), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
            }

            HStack(spacing: AppSpacing.small) {
                metricCard(title: "Glow", value: glowCount, color: AppColors.glow)
                metricCard(title: "Mid", value: midCount, color: AppColors.mid)
                metricCard(title: "Low", value: lowCount, color: AppColors.low)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text("Glow ratio")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text("\(glowRatio)%")
                    .font(AppTypography.metric)
                    .foregroundStyle(AppColors.primaryText)
            }
        }
        .padding(AppSpacing.large)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 24))
    }

    private func metricCard(title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
            Text("\(value)")
                .font(AppTypography.metric)
                .foregroundStyle(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.medium)
        .background(color.opacity(0.2), in: RoundedRectangle(cornerRadius: 18))
    }

    private func backgroundColor(for status: DayStatus?) -> Color {
        switch status {
        case .glow: AppColors.glow.opacity(0.35)
        case .mid: AppColors.mid.opacity(0.35)
        case .low: AppColors.low.opacity(0.35)
        case nil: Color.black.opacity(0.05)
        }
    }
}
