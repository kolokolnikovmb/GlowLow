import SwiftUI

struct StatsSummaryView: View {
    let page: StatsPeriodPage

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            Text(page.title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            LazyVGrid(columns: columns, spacing: AppSpacing.small) {
                ForEach(Array(page.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                }

                ForEach(page.cells) { cell in
                    dayCell(cell)
                }
            }

            HStack(spacing: AppSpacing.small) {
                metricCard(title: "Glow", value: page.glowCount, color: AppColors.glow)
                metricCard(title: "Mid", value: page.midCount, color: AppColors.mid)
                metricCard(title: "Low", value: page.lowCount, color: AppColors.low)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text("Glow ratio")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Text("\(page.glowRatio)%")
                    .font(AppTypography.metric)
                    .foregroundStyle(AppColors.primaryText)
            }
        }
        .padding(AppSpacing.large)
        .background(Color.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.stroke, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func dayCell(_ cell: StatsDayCell) -> some View {
        if cell.isPlaceholder {
            Color.clear
                .frame(height: 46)
        } else {
            VStack(spacing: 4) {
                Text(cell.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(dayNumberColor(for: cell))
                Circle()
                    .fill(backgroundColor(for: cell.status, isFuture: cell.isFuture))
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(cell.isToday ? AppColors.primaryText : .clear, lineWidth: 1.5)
                    )
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .padding(.vertical, 6)
            .background(cellBackground(for: cell), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(cellBorderColor(for: cell), lineWidth: cell.isToday ? 1.5 : 1)
            )
        }
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
        .background(color.opacity(0.18), in: RoundedRectangle(cornerRadius: 18))
    }

    private func backgroundColor(for status: DayStatus?, isFuture: Bool) -> Color {
        guard !isFuture else { return Color.black.opacity(0.05) }

        switch status {
        case .glow:
            return AppColors.glow.opacity(0.95)
        case .mid:
            return AppColors.mid.opacity(0.75)
        case .low:
            return AppColors.low.opacity(0.75)
        case nil:
            return Color.black.opacity(0.08)
        }
    }

    private func cellBackground(for cell: StatsDayCell) -> Color {
        if cell.isFuture {
            return Color.white.opacity(0.22)
        }

        if cell.isToday {
            return Color.white.opacity(0.94)
        }

        return Color.white.opacity(0.58)
    }

    private func cellBorderColor(for cell: StatsDayCell) -> Color {
        if cell.isToday {
            return AppColors.primaryText.opacity(0.16)
        }

        if cell.isFuture {
            return AppColors.stroke.opacity(0.55)
        }

        return AppColors.stroke
    }

    private func dayNumberColor(for cell: StatsDayCell) -> Color {
        if cell.isFuture {
            return AppColors.secondaryText.opacity(0.38)
        }

        if cell.isToday {
            return AppColors.primaryText
        }

        return AppColors.primaryText.opacity(0.85)
    }
}
