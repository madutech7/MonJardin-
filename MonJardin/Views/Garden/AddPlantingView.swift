import SwiftUI
import SwiftData

public struct AddPlantingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \PlantSpecies.name) private var catalogSpecies: [PlantSpecies]

    @State private var name: String = ""
    @State private var selectedSpecies: PlantSpecies? = nil
    @State private var sownDate: Date = Date()
    @State private var location: String = "Interieur / Serre"
    @State private var notes: String = ""

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
                        if let newValue = newValue, name.isEmpty {
                            name = newValue.name
                        }
                    }

                    DatePicker("Date de semis", selection: $sownDate, displayedComponents: .date)
                    
                    TextField("Emplacement (ex: Balcon, Potager...)", text: $location)
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
                    Button("Enregistrer") {
                        savePlanting()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func savePlanting() {
        let estimatedDays = selectedSpecies?.averageGerminationDays ?? 7
        let estimatedDate = Calendar.current.date(byAdding: .day, value: estimatedDays, to: sownDate) ?? sownDate

        let newPlanting = Planting(
            name: name,
            sownDate: sownDate,
            estimatedGerminationDate: estimatedDate,
            location: location,
            notes: notes,
            species: selectedSpecies
        )

        modelContext.insert(newPlanting)
        dismiss()
    }
}
