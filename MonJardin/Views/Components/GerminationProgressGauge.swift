import SwiftUI

public struct GerminationProgressGauge: View {
    let progress: Double // 0.0 to 1.0
    let daysRemaining: Int
    let status: PlantingStatus

    public init(progress: Double, daysRemaining: Int, status: PlantingStatus) {
        self.progress = progress
        self.daysRemaining = daysRemaining
        self.status = status
    }

    public var body: some View {
        ZStack {
            // Track circle
            Circle()
                .stroke(Color.green.opacity(0.15), lineWidth: 10)

            // Progress stroke
            Circle()
                .trim(from: 0, to: status == .sown ? CGFloat(progress) : 1.0)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.7), Color.emeraldGreen]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: progress)

            // Center Info
            VStack(spacing: 2) {
                if status == .sown {
                    Text("\(daysRemaining)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(daysRemaining <= 1 ? "jour restant" : "jours restants")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                } else {
                    Image(systemName: status.systemIcon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.green)
                    Text(status.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 100, height: 100)
    }
}

extension Color {
    static let emeraldGreen = Color(red: 16/255, green: 185/255, blue: 129/255)
}
