import SwiftUI

public struct PlantingRowCard: View {
    let planting: Planting

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Photo thumbnail or default native leaf icon
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 56, height: 56)

                if let photoData = planting.initialPhotoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                }
            }

            // Plant Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(planting.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    StatusBadgeView(status: planting.status)
                }

                Text(planting.locationName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Semé le \(dateFormatter.string(from: planting.sownDate)) (\(planting.daysSinceSown)j)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }
}
