import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]
    @State private var showingAddPlanting = false

    public init() {}

    private var activePlantingsCount: Int {
        plantings.filter { $0.status != .harvested }.count
    }

    private var germinatingCount: Int {
        plantings.filter { $0.status == .sown }.count
    }

    private var needsWaterTodayCount: Int {
        plantings.filter { $0.needsWateringToday }.count
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section with Summary
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mon Jardin 🌿")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.emeraldGreen, .forestGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(summarySubtitleText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Header Stats Grid
                    HStack(spacing: 12) {
                        StatCardView(
                            title: "En cours",
                            value: "\(activePlantingsCount)",
                            subtitle: "Plantations",
                            icon: "leaf.fill",
                            color: .emeraldGreen
                        )
                        
                        StatCardView(
                            title: "Attente",
                            value: "\(germinatingCount)",
                            subtitle: "Germination",
                            icon: "timer",
                            color: .orange
                        )

                        StatCardView(
                            title: "Aujourd'hui",
                            value: "\(needsWaterTodayCount)",
                            subtitle: "Arrosage",
                            icon: "drop.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Germination Watchlist Section
                    let germinatingPlantings = plantings.filter { $0.status == .sown }
                    if !germinatingPlantings.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("Suivi de germination", systemImage: "clock.badge.checkmark.fill")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(germinatingPlantings) { planting in
                                        NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                            VStack(spacing: 12) {
                                                let progress = planting.germinationProgress
                                                let days = planting.daysRemainingUntilGermination
                                                let status = planting.status
                                                
                                                GerminationProgressGauge(
                                                    progress: progress,
                                                    daysRemaining: days,
                                                    status: status
                                                )
                                                
                                                VStack(spacing: 2) {
                                                    Text(planting.name)
                                                        .font(.system(size: 15, weight: .bold))
                                                        .foregroundStyle(.primary)
                                                        .lineLimit(1)
                                                    
                                                    Text(planting.locationName)
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            .padding(16)
                                            .frame(width: 140)
                                            .background {
                                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                    .fill(.regularMaterial)
                                                    .overlay {
                                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                                            .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                                                    }
                                            }
                                            .shadow(color: .orange.opacity(0.06), radius: 10, x: 0, y: 5)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Recent Plantings Section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Plantations Récentes")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Spacer()

                            NavigationLink(destination: GardenView()) {
                                Text("Tout voir")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.emeraldGreen)
                            }
                        }
                        .padding(.horizontal)

                        if plantings.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "sprout")
                                    .font(.system(size: 48, weight: .light))
                                    .foregroundStyle(Color.emeraldGreen.gradient)
                                
                                VStack(spacing: 4) {
                                    Text("Votre jardin est prêt")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text("Ajoutez votre premier semis pour commencer le suivi.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                }

                                Button(action: { showingAddPlanting = true }) {
                                    Label("Nouveau Semis", systemImage: "plus.circle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.emeraldGreen.gradient, in: Capsule())
                                        .shadow(color: .emeraldGreen.opacity(0.3), radius: 8, y: 4)
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .padding(.horizontal)
                            .background {
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(plantings.prefix(5)) { planting in
                                    NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                        PlantingRowCard(planting: planting)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPlanting = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.emeraldGreen.gradient)
                    }
                }
            }
            .sheet(isPresented: $showingAddPlanting) {
                AddPlantingView()
            }
        }
    }

    private var summarySubtitleText: String {
        let count = needsWaterTodayCount
        if count == 0 {
            return "Toutes vos plantes vont bien aujourd'hui."
        } else if count == 1 {
            return "1 plante a besoin d'eau aujourd'hui."
        } else {
            return "\(count) plantes nécessitent votre attention aujourd'hui."
        }
    }
}
