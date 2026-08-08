import SwiftUI
import SwiftData

public struct AddPlantingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \PlantSpecies.name) private var catalogSpecies: [PlantSpecies]

    @State private var selectedSpecies: PlantSpecies?
    @State private var customName: String = ""
    @State private var bedName: String = "Potager Princpal"
    @State private var sownDate: Date = Date()
    @State private var wateringIntervalDays: Int = 2
    @State private var notes: String = ""

    private let availableBeds = ["Potager Principal", "Potager Sud", "Serre Chaude", "Jardinière Balcon", "Pot d'Intérieur", "Bac à Fleurs"]

    private var calculatedGerminationDate: Date {
        let minDays = selectedSpecies?.minGerminationDays ?? 7
        return Calendar.current.date(byAdding: .day, value: minDays, to: sownDate) ?? sownDate
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Sélection de l'Espèce") {
                    Picker("Plante à semer", selection: $selectedSpecies) {
                        Text("Sélectionnez dans le catalogue").tag(PlantSpecies?.none)
                        ForEach(catalogSpecies) { species in
                            HStack {
                                Text(species.name)
                                Spacer()
                                Text(species.category).foregroundColor(.secondary)
                            }
                            .tag(PlantSpecies?.some(species))
                        }
                    }
                    .onChange(of: selectedSpecies) { _, newSpecies in
                        if let species = newSpecies, customName.isEmpty {
                            customName = species.name
                            wateringIntervalDays = species.defaultWateringDays
                        }
                    }

                    TextField("Nom personnalisé (ex: Mes Radis 18j)", text: $customName)
                }

                Section("Emplacement & Dates") {
                    Picker("Emplacement du semis", selection: $bedName) {
                        ForEach(availableBeds, id: \.self) { bed in
                            Text(bed).tag(bed)
                        }
                    }

                    DatePicker("Date de semis", selection: $sownDate, displayedComponents: .date)

                    if let species = selectedSpecies {
                        HStack {
                            Text("Germination estimée")
                            Spacer()
                            Text("~\(species.minGerminationDays) à \(species.maxGerminationDays) jours")
                                .foregroundColor(.orange)
                                .fontWeight(.semibold)
                        }
                    }

                    Stepper("Arrosage tous les \(wateringIntervalDays) jours", value: $wateringIntervalDays, in: 1...7)
                }

                Section("Conseils de culture & Notes") {
                    if let species = selectedSpecies {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Astuce pour \(species.name) :")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.emeraldGreen)
                            Text(species.careTips)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    TextField("Notes de semis (ex: substrat, terreau...)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Nouveau Semis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer Semis") {
                        savePlanting()
                    }
                    .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if selectedSpecies == nil, let first = catalogSpecies.first {
                    selectedSpecies = first
                    customName = first.name
                    wateringIntervalDays = first.defaultWateringDays
                }
            }
        }
    }

    private func savePlanting() {
        let speciesName = selectedSpecies?.name ?? "Inconnu"
        let category = selectedSpecies?.category ?? "Légume"

        let newPlanting = Planting(
            customName: customName,
            speciesName: speciesName,
            category: category,
            bedName: bedName,
            status: .sown,
            sownDate: sownDate,
            expectedGerminationDate: calculatedGerminationDate,
            wateringIntervalDays: wateringIntervalDays,
            notes: notes
        )

        let initialLog = GardenLog(timestamp: sownDate, noteText: "Semis mis en terre le \(sownDate.formatted(date: .abbreviated, time: .omitted)).")
        newPlanting.logs.append(initialLog)

        modelContext.insert(newPlanting)
        try? modelContext.save()
        dismiss()
    }
}
