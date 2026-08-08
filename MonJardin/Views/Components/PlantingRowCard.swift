import SwiftUI

public struct PlantingRowCard: View {
    let planting: Planting
    let onWaterTap: () -> Void

    public init(planting: Planting, onWaterTap: @escaping () -> Void) {
        self.planting = planting
        self.onWaterTap = onWaterTap
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Mini photo or icon placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 54, height: 54)

                if let photoData = planting.initialPhotoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    Image(systemName: planting.status.systemIcon)
                        .font(.title2)
                        .foregroundColor(.emeraldGreen)
                }
            }

            // Info details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(planting.customName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    StatusBadgeView(status: planting.status)
                }

                Text("\(planting.speciesName) • \(planting.bedName)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Label("Semé le \(dateFormatter.string(from: planting.sownDate))", systemicon: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if planting.status == .sown {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Germination ~\(planting.daysRemainingUntilGermination)j")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            // Quick Water Action Button
            Button(action: onWaterTap) {
                ZStack {
                    Circle()
                        .fill(planting.needsWateringToday ? Color.blue.opacity(0.15) : Color.gray.opacity(0.08))
                        .frame(width: 38, height: 38)
                    Image(systemName: planting.needsWateringToday ? "drop.fill" : "drop")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(planting.needsWateringToday ? .blue : .secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }
}

extension Label where Title == Text, Icon == Image {
    init(_ titleKey: String, systemicon: String) {
        self.init {
            Text(titleKey)
        } icon: {
            Image(systemName: systemicon)
        }
    }
}
