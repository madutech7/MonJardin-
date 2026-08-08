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
        case .harvested:  return .gray
        }
    }

    public var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.15))
            .foregroundColor(badgeColor)
            .clipShape(Capsule())
    }
}
