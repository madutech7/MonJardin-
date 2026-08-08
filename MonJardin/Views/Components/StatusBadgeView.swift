import SwiftUI

public struct StatusBadgeView: View {
    let status: PlantingStatus

    public init(status: PlantingStatus) {
        self.status = status
    }

    private var badgeColor: Color {
        switch status {
        case .sown:       return .orange
        case .sprouted:   return .green
        case .growing:    return .blue
        case .flowering:  return .pink
        case .fruiting:   return .purple
        case .harvested:  return .secondary
        }
    }

    public var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.12), in: Capsule())
            .foregroundStyle(badgeColor)
    }
}
