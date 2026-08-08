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

    private var ringColor: Color {
        daysRemaining <= 0 ? .orange : .green
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(ringColor.opacity(0.15), lineWidth: 8)

            // Progress ring
            Circle()
                .trim(from: 0, to: status == .sown ? CGFloat(progress) : 1.0)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.6), value: progress)

            // Center label
            VStack(spacing: 1) {
                if status == .sown {
                    if daysRemaining <= 0 {
                        Image(systemName: "exclamationmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.orange)
                    } else {
                        Text("\(daysRemaining)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("j")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.green)
                }
            }
        }
    }
}
