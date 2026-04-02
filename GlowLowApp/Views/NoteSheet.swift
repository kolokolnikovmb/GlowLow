import SwiftUI

struct NoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String

    let limit = 160
    let onSave: (String) -> Void

    init(initialText: String, onSave: @escaping (String) -> Void) {
        _text = State(initialValue: initialText)
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Capsule()
                .fill(AppColors.stroke)
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.small)

            Text("Add a short note")
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            TextField(
                "A small win, a rough moment, anything you want to remember.",
                text: $text,
                axis: .vertical
            )
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
            .padding(AppSpacing.medium)
            .frame(minHeight: 120, alignment: .topLeading)
            .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.stroke, lineWidth: 1)
            )
            .lineLimit(3...6)
            .onChange(of: text) { _, newValue in
                if newValue.count > limit {
                    text = String(newValue.prefix(limit))
                }
            }

            HStack {
                Text("\(text.count)/\(limit)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                Spacer()
                Button("Discuss with AI") {}
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }

            HStack(spacing: AppSpacing.small) {
                secondaryToolButton(icon: "photo.on.rectangle.angled", label: "Photo")
                secondaryToolButton(icon: "waveform", label: "Audio")
                secondaryToolButton(icon: "location", label: "Location")
            }

            Button {
                onSave(text)
                dismiss()
            } label: {
                Text("Save")
                    .font(AppTypography.button)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.medium)
                    .background(AppColors.glow.opacity(0.78), in: RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.bottom, AppSpacing.large)
        .background(AppColors.background.ignoresSafeArea())
    }

    private func secondaryToolButton(icon: String, label: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                Text(label)
                    .font(AppTypography.caption)
            }
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.small)
            .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(true)
        .opacity(0.8)
    }
}
