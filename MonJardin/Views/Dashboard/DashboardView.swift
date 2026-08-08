import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]
    @State private var showingAddPlanting = false

    public init() {}

    private var activePlantingsCount: Int {
        plantings.filter { $0.status != .completed }.count
    }

    private var germinatingCount: Int {
        plantings.filter { $0.status == .sown }.count
    }

    private var needsWaterTodayCount: Int {
        plantings.filter { $0.needsWaterToday }.count
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Stats Row
                    HStack(spacing: 12) {
                        StatCardView(
                            title: "Plantations",
                            value: "\(activePlantingsCount)",
                            subtitle: "En cours",
                            icon: "leaf.fill",
                            color: .green
                        )
                        
                        StatCardView(
                            title: "Germination",
                            value: "\(germinatingCount)",
                            subtitle: "En attente",
                            icon: "timer",
                            color: .orange
                        )

                        StatCardView(
                            title: "Arrosage",
                            value: "\(needsWaterTodayCount)",
                            subtitle: "Aujourd'hui",
                            icon: "drop.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Germination Watchlist Section
                    let germinatingPlantings = plantings.filter { $0.status == .sown }
                    if !germinatingPlantings.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Suivi de germination")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(germinatingPlantings) { planting in
                                        NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                            VStack(spacing: 10) {
                                                GerminationProgressGauge(
                                                    progress: planting.germinationProgress,
                                                    daysRemaining: planting.daysUntilGermination,
                                                    status: planting.status
                                                )
                                                
                                                Text(planting.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                            }
                                            .padding()
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                            .cornerRadius(16)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Recent Plantings Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mes Plantations Récents")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal)

                        if plantings.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "square.stack.3d.up.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Aucune plantation pour le moment.")
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(plantings.prefix(5)) { planting in
                                    NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                        PlantingRowCard(planting: planting)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Mon Jardin 🌿")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPlanting = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddPlanting) {
                AddPlantingView()
            }
        }
    }
}
