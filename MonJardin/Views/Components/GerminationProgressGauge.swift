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

    private var gaugeColor: Color {
        if daysRemaining <= 0 { return .orange }
        if progress > 0.75 { return .emeraldGreen }
        return Color(red: 0.2, green: 0.7, blue: 0.5)
    }

    public var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(gaugeColor.opacity(0.06), lineWidth: 14)

            // Track
            Circle()
                .stroke(Color.primary.opacity(0.06), lineWidth: 10)

            // Progress arc
            Circle()
                .trim(from: 0, to: status == .sown ? CGFloat(progress) : 1.0)
                .stroke(
                    LinearGradient(
                        colors: [gaugeColor.opacity(0.6), gaugeColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.75), value: progress)

            // Center content
            VStack(spacing: 1) {
                if status == .sown {
                    if daysRemaining <= 0 {
                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.orange.gradient)
                    } else {
                        Text("\(daysRemaining)")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(daysRemaining <= 1 ? "jour" : "jours")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(gaugeColor.gradient)
                }
            }
        }
        .frame(width: 100, height: 100)
    }
}

extension Color {
    static let emeraldGreen = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let forestGreen = Color(red: 27/255, green: 67/255, blue: 50/255)
    static let sageGreen = Color(red: 82/255, green: 183/255, blue: 136/255)
}
