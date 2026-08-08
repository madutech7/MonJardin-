import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]
    @State private var showingAddPlanting = false

    private var activePlantings: [Planting] {
        plantings.filter { $0.status != .completed }
    }

    private var germinationWatchlist: [Planting] {
        plantings.filter { $0.status == .sown }
    }

    private var needsWaterCount: Int {
        plantings.filter { $0.needsWateringToday }.count
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: Date()).capitalized
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Header greeting & date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text("Mon Jardin 🌿")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)

                    // Stats Grid
                    HStack(spacing: 12) {
                        StatCardView(
                            title: "Plantations",
                            value: "\(activePlantings.count)",
                            subtitle: "Actives",
                            icon: "leaf.fill",
                            color: .emeraldGreen
                        )

                        StatCardView(
                            title: "Germination",
                            value: "\(germinationWatchlist.count)",
                            subtitle: "En cours",
                            icon: "sprout.fill",
                            color: .orange
                        )

                        StatCardView(
                            title: "Arrosage",
                            value: "\(needsWaterCount)",
                            subtitle: "Requis aujourd'hui",
                            icon: "drop.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Germination Watchlist Section
                    if !germinationWatchlist.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Label("Suivi Germination", systemImage: "timer")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(germinationWatchlist.count) semis")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(germinationWatchlist) { planting in
                                        NavigationLink(value: planting) {
                                            VStack(spacing: 10) {
                                                GerminationProgressGauge(
                                                    progress: planting.germinationProgress,
                                                    daysRemaining: planting.daysRemainingUntilGermination,
                                                    status: planting.status
                                                )
                                                Text(planting.customName)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                Text(planting.speciesName)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(14)
                                            .frame(width: 140)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Active Plantings Overview
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Derniers Semis & Plantations")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: { showingAddPlanting = true }) {
                                Label("Ajouter", systemImage: "plus.circle.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.horizontal)

                        if activePlantings.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "sprout")
                                    .font(.system(size: 44))
                                    .foregroundColor(.emeraldGreen.opacity(0.6))
                                Text("Aucune plantation pour le moment")
                                    .font(.headline)
                                Text("Commencez par ajouter votre premier semis !")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Button(action: { showingAddPlanting = true }) {
                                    Text("Nouveau Semis")
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.emeraldGreen)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            )
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(activePlantings.prefix(5)) { planting in
                                    NavigationLink(value: planting) {
                                        PlantingRowCard(planting: planting) {
                                            planting.lastWateredDate = Date()
                                            try? modelContext.save()
                                        }
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
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationDestination(for: Planting.self) { planting in
                PlantingDetailView(planting: planting)
            }
            .sheet(isPresented: $showingAddPlanting) {
                AddPlantingView()
            }
        }
    }
}
