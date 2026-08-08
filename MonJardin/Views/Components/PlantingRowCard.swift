import SwiftUI

public struct PlantingRowCard: View {
    let planting: Planting

    public init(planting: Planting) {
        self.planting = planting
    }

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail or system icon
            ZStack {
                if let data = planting.initialPhotoData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: planting.status.systemIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.green)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(planting.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text(planting.locationName)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if planting.status == .sown {
                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        let days = planting.daysRemainingUntilGermination
                        Text(days <= 0 ? "Germination imminente" : "\(days) j restants")
                            .font(.footnote)
                            .foregroundStyle(days <= 0 ? .orange : .secondary)
                    }
                }
            }

            Spacer()

            StatusBadgeView(status: planting.status)
        }
        .padding(.vertical, 4)
    }
}
