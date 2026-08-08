import SwiftUI

public struct PlantingRowCard: View {
    let planting: Planting
    @State private var isPressed = false

    public init(planting: Planting) {
        self.planting = planting
    }

    private var germinationSummary: String {
        let days = planting.daysRemainingUntilGermination
        if planting.status == .sown {
            return days <= 0 ? "Germination imminente" : "\(days) j restants"
        }
        return ""
    }

    private var accentColor: Color {
        switch planting.status {
        case .sown:      return .orange
        case .sprouted:  return .emeraldGreen
        case .growing:   return .blue
        case .flowering: return .pink
        case .fruiting:  return .purple
        case .harvested: return .gray
        }
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Photo or icon
            ZStack {
                if let data = planting.initialPhotoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor.gradient.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: planting.status.systemIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(accentColor.gradient)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(planting.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    StatusChip(status: planting.status)
                }

                Text(planting.locationName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if planting.status == .sown {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.caption2)
                        Text(germinationSummary)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(planting.daysRemainingUntilGermination <= 0 ? Color.orange : accentColor)
                    .padding(.top, 1)
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// Compact status chip
private struct StatusChip: View {
    let status: PlantingStatus

    var color: Color {
        switch status {
        case .sown:      return .orange
        case .sprouted:  return .emeraldGreen
        case .growing:   return .blue
        case .flowering: return .pink
        case .fruiting:  return .purple
        case .harvested: return .gray
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text(status.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1), in: Capsule())
    }
}
