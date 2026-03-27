import SwiftUI

struct StatusSelector: View {
    let selectedStatus: DayStatus?
    let onSelect: (DayStatus) -> Void

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(DayStatus.allCases) { status in
                StatusButton(
                    status: status,
                    isSelected: selectedStatus == status,
                    action: { onSelect(status) }
                )
            }
        }
    }
}
