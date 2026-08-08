import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]
    @State private var showingAddPlanting = false

    public init() {}

    private var activePlantings: [Planting] {
        plantings.filter { $0.status != .harvested }
    }

    private var sownPlantings: [Planting] {
        plantings.filter { $0.status == .sown }
    }

    private var harvestedCount: Int {
        plantings.filter { $0.status == .harvested }.count
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ── Summary Rings (Apple Health Style) ──
                    HStack(spacing: 0) {
                        Spacer()
                        ZStack {
                            // Outer ring: Active
                            ActivityRing(
                                progress: activePlantings.isEmpty ? 0 : min(1.0, Double(activePlantings.count) / 10.0),
                                ringColor: .green,
                                lineWidth: 18,
                                size: 150
                            )
                            // Inner ring: Germinating
                            ActivityRing(
                                progress: sownPlantings.isEmpty ? 0 : min(1.0, Double(sownPlantings.count) / 10.0),
                                ringColor: .orange,
                                lineWidth: 18,
                                size: 110
                            )
                            // Center ring: Harvested
                            ActivityRing(
                                progress: harvestedCount == 0 ? 0 : min(1.0, Double(harvestedCount) / 10.0),
                                ringColor: .pink,
                                lineWidth: 18,
                                size: 70
                            )
                        }
                        .frame(width: 160, height: 160)

                        Spacer()

                        VStack(alignment: .leading, spacing: 16) {
                            RingLegendRow(color: .green, label: "En culture", value: "\(activePlantings.count)")
                            RingLegendRow(color: .orange, label: "Germination", value: "\(sownPlantings.count)")
                            RingLegendRow(color: .pink, label: "Récolté", value: "\(harvestedCount)")
                        }

                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal)

                    // ── Germination Watchlist ──
                    if !sownPlantings.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeader(title: "Germination", icon: "clock.fill")
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(sownPlantings) { planting in
                                        NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                            GerminationCard(planting: planting)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // ── Recent Activity ──
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            SectionHeader(title: "Activité récente", icon: "clock.arrow.circlepath")

                            Spacer()

                            if !plantings.isEmpty {
                                NavigationLink(destination: GardenView()) {
                                    Text("Tout voir")
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .padding(.horizontal)

                        if plantings.isEmpty {
                            ContentUnavailableView {
                                Label("Aucune plantation", systemImage: "leaf")
                            } description: {
                                Text("Touchez + pour enregistrer votre premier semis.")
                            } actions: {
                                Button("Nouveau Semis") { showingAddPlanting = true }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                            }
                            .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(plantings.prefix(5).enumerated()), id: \.element.id) { index, planting in
                                    NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                        PlantingRowCard(planting: planting)
                                    }

                                    if index < min(4, plantings.count - 1) {
                                        Divider()
                                            .padding(.leading, 62)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Mon Jardin")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPlanting = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPlanting) {
                AddPlantingView()
            }
        }
    }
}

// MARK: - Apple Activity Ring
private struct ActivityRing: View {
    let progress: Double
    let ringColor: Color
    let lineWidth: CGFloat
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(ringColor.opacity(0.15), lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.8), value: progress)

            // End cap glow
            if progress > 0.05 {
                Circle()
                    .fill(ringColor)
                    .frame(width: lineWidth, height: lineWidth)
                    .shadow(color: ringColor.opacity(0.5), radius: 4)
                    .offset(y: -(size / 2))
                    .rotationEffect(.degrees(360 * progress - 90))
                    .animation(.easeOut(duration: 0.8), value: progress)
            }
        }
    }
}

// MARK: - Ring Legend Row
private struct RingLegendRow: View {
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

// MARK: - Germination Card
private struct GerminationCard: View {
    let planting: Planting

    var body: some View {
        VStack(spacing: 10) {
            GerminationProgressGauge(
                progress: planting.germinationProgress,
                daysRemaining: planting.daysRemainingUntilGermination,
                status: planting.status
            )

            VStack(spacing: 2) {
                Text(planting.name)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(planting.locationName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .frame(width: 120)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
