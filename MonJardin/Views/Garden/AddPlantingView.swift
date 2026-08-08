import SwiftUI
import SwiftData

public struct AddPlantingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \PlantSpecies.name) private var catalogSpecies: [PlantSpecies]

    @State private var name: String = ""
    @State private var selectedSpecies: PlantSpecies? = nil
    @State private var sownDate: Date = Date()
    @State private var locationName: String = "Intérieur / Serre"
    @State private var notes: String = ""
    @State private var expectedDays: Int = 7

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informations générales")) {
                    TextField("Nom de la plantation", text: $name)

                    Picker("Espèce", selection: $selectedSpecies) {
                        Text("Aucune (Personnalisée)").tag(Optional<PlantSpecies>.none)
                        ForEach(catalogSpecies) { species in
                            Text(species.name).tag(Optional(species))
                        }
                    }
                    .onChange(of: selectedSpecies) { _, newValue in
                        if let s = newValue {
                            if name.isEmpty { name = s.name }
                            expectedDays = (s.minGerminationDays + s.maxGerminationDays) / 2
                        }
                    }

                    DatePicker("Date de semis", selection: $sownDate, displayedComponents: .date)

                    TextField("Emplacement", text: $locationName)

                    Stepper("Germination estimée : \(expectedDays) j", value: $expectedDays, in: 1...120)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nouveau Semis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { savePlanting() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func savePlanting() {
        let wateringDays = selectedSpecies?.defaultWateringDays ?? 2
        let newPlanting = Planting(
            name: name,
            locationName: locationName,
            status: .sown,
            sownDate: sownDate,
            expectedGerminationDays: expectedDays,
            wateringIntervalDays: wateringDays,
            notes: notes
        )
        modelContext.insert(newPlanting)
        dismiss()
    }
}
