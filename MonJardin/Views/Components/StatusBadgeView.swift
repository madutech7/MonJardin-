import SwiftUI

public struct StatusBadgeView: View {
    let status: PlantingStatus

    public init(status: PlantingStatus) {
        self.status = status
    }

    private var badgeColor: Color {
        switch status {
        case .sown: return .orange
        case .germinated: return .green
        case .growing: return .emeraldGreen
        case .harvesting: return .purple
        case .completed: return .blue
        }
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemIcon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.15))
        .foregroundColor(badgeColor)
        .clipShape(Capsule())
    }
}
