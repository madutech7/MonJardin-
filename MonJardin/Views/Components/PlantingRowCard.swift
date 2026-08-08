import SwiftUI

public struct PlantingRowCard: View {
    let planting: Planting
    var onWaterTap: (() -> Void)? = nil

    public init(planting: Planting, onWaterTap: (() -> Void)? = nil) {
        self.planting = planting
        self.onWaterTap = onWaterTap
    }

    private var germinationSummary: String {
        let days = planting.daysRemainingUntilGermination
        if planting.status == .sown {
            if days <= 0 {
                return "Germination attendue !"
            } else {
                return "~\(days) j avant germination"
            }
        }
        return ""
    }

    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: planting.status.systemIcon)
                    .font(.title2)
                    .foregroundColor(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(planting.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    StatusBadgeView(status: planting.status)
                }

                Text("Semé le \(planting.sownDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if planting.status == .sown && !germinationSummary.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(germinationSummary)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.orange)
                    .padding(.top, 2)
                }
            }

            if let onWaterTap = onWaterTap {
                Button(action: onWaterTap) {
                    Image(systemName: "drop.fill")
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}
