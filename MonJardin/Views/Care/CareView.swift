import SwiftUI
import SwiftData

public struct CareView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.lastWateredDate) private var plantings: [Planting]

    private var needsWaterToday: [Planting] {
        plantings.filter { $0.needsWateringToday }
    }

    private var upcomingWatering: [Planting] {
        plantings.filter { !$0.needsWateringToday }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Quick Action Hero Header
                    if !needsWaterToday.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Arrosage Requis 💧")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                    Text("\(needsWaterToday.count) plantation(s) ont besoin d'eau.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(action: waterAllToday) {
                                    Text("Tout Arroser")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.blue.gradient, in: Capsule())
                                        .foregroundStyle(.white)
                                        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                                }
                            }

                            VStack(spacing: 12) {
                                ForEach(needsWaterToday) { planting in
                                    PlantingRowCard(planting: planting) {
                                        planting.lastWateredDate = Date()
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.regularMaterial)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                }
                        }
                        .shadow(color: .blue.opacity(0.06), radius: 12, x: 0, y: 6)
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(Color.blue.gradient)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Plantes hydratées ! 💧")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Aucun arrosage urgent requis pour le moment.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 36)
                        .background {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(.regularMaterial)
                        }
                        .padding(.horizontal)
                    }

                    // Upcoming Watering Schedule
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Prochains Arrosages Planifiés")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal)

                        if upcomingWatering.isEmpty {
                            Text("Aucune autre plantation enregistrée.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(upcomingWatering) { planting in
                                    PlantingRowCard(planting: planting) {
                                        planting.lastWateredDate = Date()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Soins & Arrosage 💧")
        }
    }

    private func waterAllToday() {
        for planting in needsWaterToday {
            planting.lastWateredDate = Date()
        }
    }
}
