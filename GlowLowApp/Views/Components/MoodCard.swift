import SwiftUI

struct MoodCard: View {
    let selectedStatus: DayStatus?
    let note: String?
    let onSwipe: (DayStatus) -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text(selectedStatus?.emoji ?? "☀️")
                .font(.system(size: 54))

            Text(selectedStatus?.title ?? "No check-in yet")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            Text(descriptionText)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
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
        .gesture(
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
            LinearGradient(colors: [AppColors.glow.opacity(0.95), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mid:
            LinearGradient(colors: [AppColors.mid.opacity(0.9), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .low:
            LinearGradient(colors: [AppColors.low.opacity(0.85), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
        case nil:
            LinearGradient(colors: [Color.white, AppColors.background], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var descriptionText: String {
        if let note, !note.isEmpty {
            return note
        }

        return "Swipe right for Glow, up for Mid, left for Low, or tap one of the buttons below."
    }

    private func handleSwipe(_ translation: CGSize) {
        defer { dragOffset = .zero }

        let threshold: CGFloat = 70
        if translation.width > threshold {
            onSwipe(.glow)
        } else if translation.width < -threshold {
            onSwipe(.low)
        } else if translation.height < -threshold {
            onSwipe(.mid)
        }
    }
}
