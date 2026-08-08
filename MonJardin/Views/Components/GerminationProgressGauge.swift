import SwiftUI

public struct GerminationProgressGauge: View {
    let progress: Double
    let daysRemaining: Int
    let status: PlantingStatus

    public init(progress: Double, daysRemaining: Int, status: PlantingStatus) {
        self.progress = progress
        self.daysRemaining = daysRemaining
        self.status = status
    }

    public var body: some View {
        ZStack {
            // Background Track
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 8)

            // Progress Ring
            Circle()
                .trim(from: 0, to: status == .sown ? CGFloat(progress) : 1.0)
                .stroke(
                    daysRemaining <= 0 ? Color.orange : Color.green,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)

            // Center Content
            VStack(spacing: 2) {
                if status == .sown {
                    if daysRemaining <= 0 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(daysRemaining)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(daysRemaining <= 1 ? "jour" : "jours")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.green)
                }
            }
        }
        .frame(width: 80, height: 80)
    }
}
