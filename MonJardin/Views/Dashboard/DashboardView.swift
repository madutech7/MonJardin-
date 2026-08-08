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

    public var body: some View {
        NavigationStack {
            List {
                // Key Metrics Section
                Section {
                    HStack(spacing: 12) {
                        StatMetricTile(
                            title: "En cours",
                            value: "\(activePlantings.count)",
                            systemImage: "leaf.fill",
                            tint: .green
                        )
                        
                        StatMetricTile(
                            title: "Germination",
                            value: "\(sownPlantings.count)",
                            systemImage: "timer",
                            tint: .orange
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                // Germination Watchlist Section
                if !sownPlantings.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(sownPlantings) { planting in
                                    NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                        VStack(spacing: 10) {
                                            GerminationProgressGauge(
                                                progress: planting.germinationProgress,
                                                daysRemaining: planting.daysRemainingUntilGermination,
                                                status: planting.status
                                            )
                                            
                                            VStack(spacing: 2) {
                                                Text(planting.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                                
                                                Text(planting.locationName)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 14)
                                        .frame(width: 130)
                                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    } header: {
                        Text("Suivi de germination")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .textCase(nil)
                    }
                }

                // Recent Plantings Section
                Section {
                    if plantings.isEmpty {
                        ContentUnavailableView(
                            "Aucune plantation",
                            systemImage: "leaf",
                            description: Text("Touchez le bouton + pour enregistrer votre premier semis.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(plantings.prefix(5)) { planting in
                            NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                PlantingRowCard(planting: planting)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Plantations récentes")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .textCase(nil)
                        
                        Spacer()
                        
                        if !plantings.isEmpty {
                            NavigationLink(destination: GardenView()) {
                                Text("Tout voir")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Accueil")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPlanting = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showingAddPlanting) {
                AddPlantingView()
            }
        }
    }
}

// Apple Fitness / Health Style Metric Tile
private struct StatMetricTile: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(tint)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
