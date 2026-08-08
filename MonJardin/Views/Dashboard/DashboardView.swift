import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]
    @State private var showingAddPlanting = false

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: Date()).capitalized
    }

    private var activeCount: Int {
        plantings.filter { $0.status != .harvested }.count
    }

    private var fruitingCount: Int {
        plantings.filter { $0.status == .fruiting }.count
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title & Date Header
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

                    // Stat Cards
                    HStack(spacing: 12) {
                        StatCardView(
                            title: "Semis & Plantes",
                            value: "\(plantings.count)",
                            subtitle: "Total enregistré",
                            icon: "leaf.fill",
                            color: Color(red: 16/255, green: 185/255, blue: 129/255)
                        )

                        StatCardView(
                            title: "Premiers Fruits",
                            value: "\(fruitingCount)",
                            subtitle: "En fructification",
                            icon: "square.stack.3d.up.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)

                    // Plant List Section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Mes Plantations")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: { showingAddPlanting = true }) {
                                Label("Nouveau Semis", systemImage: "plus.circle.fill")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                            }
                        }
                        .padding(.horizontal)

                        if plantings.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "sprout.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.7))
                                Text("Votre jardin est prêt")
                                    .font(.headline)
                                Text("Commencez par ajouter votre tout premier semis avec la date et le nom de votre plante.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Button(action: { showingAddPlanting = true }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Ajouter mon premier semis")
                                    }
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            )
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(plantings) { planting in
                                    NavigationLink(value: planting) {
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
