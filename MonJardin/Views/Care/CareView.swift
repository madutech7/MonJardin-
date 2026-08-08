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
                VStack(alignment: .leading, spacing: 20) {
                    // Quick Action Hero Header
                    if !needsWaterToday.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Arrosage Requis 💧")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("\(needsWaterToday.count) plantation(s) ont soif aujourd'hui.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: waterAllToday) {
                                    Text("Tout Arroser")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }

                            VStack(spacing: 10) {
                                ForEach(needsWaterToday) { planting in
                                    PlantingRowCard(planting: planting) {
                                        planting.lastWateredDate = Date()
                                        try? modelContext.save()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.blue)
                            Text("Toutes vos plantes sont hydratées !")
                                .font(.headline)
                            Text("Aucun arrosage urgent requis pour aujourd'hui.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal)
                    }

                    // Upcoming Watering Schedule
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Prochains Arrosages Planifiés")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        if upcomingWatering.isEmpty {
                            Text("Aucune autre plantation enregistrée.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(upcomingWatering) { planting in
                                    PlantingRowCard(planting: planting) {
                                        planting.lastWateredDate = Date()
                                        try? modelContext.save()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Arrosage & Soins")
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
    }

    private func waterAllToday() {
        for planting in needsWaterToday {
            planting.lastWateredDate = Date()
        }
        try? modelContext.save()
    }
}
