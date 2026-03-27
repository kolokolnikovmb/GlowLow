import SwiftUI

struct NoteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String

    let limit = 160
    let onSave: (String) -> Void
    let onDelete: (() -> Void)?

    init(initialText: String, onSave: @escaping (String) -> Void, onDelete: (() -> Void)? = nil) {
        _text = State(initialValue: initialText)
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text("Add a short note")
                    .font(AppTypography.sectionTitle)

                TextField("A small win, a rough moment, anything you want to remember.", text: $text, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5...8)
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
                    if let onDelete {
                        Button("Delete note", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.large)
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(text)
                        dismiss()
                    }
                }
            }
        }
    }
}
