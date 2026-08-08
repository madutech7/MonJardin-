import SwiftUI

public struct PlantingRowCard: View {
    let planting: Planting

    public init(planting: Planting) {
        self.planting = planting
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Leading: Photo thumbnail or icon
            Group {
                if let data = planting.initialPhotoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(statusColor.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: planting.status.systemIcon)
                            .font(.system(size: 20))
                            .foregroundStyle(statusColor)
                    }
                }
            }

            // Center: Title + subtitle
            VStack(alignment: .leading, spacing: 3) {
                Text(planting.name)
                    .font(.body)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Text(planting.locationName)

                    if planting.status == .sown {
                        let days = planting.daysRemainingUntilGermination
                        Text("·")
                        Text(days <= 0 ? "Germination imminente" : "\(days)j restants")
                            .foregroundStyle(days <= 0 ? .orange : .secondary)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Trailing: Status capsule
            Text(planting.status.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var statusColor: Color {
        switch planting.status {
        case .sown:      return .orange
        case .sprouted:  return .green
        case .growing:   return .blue
        case .flowering: return .pink
        case .fruiting:  return .purple
        case .harvested: return .secondary
        }
    }
}
