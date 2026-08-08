import SwiftUI
import SwiftData
import PhotosUI

public struct AddPlantingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \PlantSpecies.name) private var catalogSpecies: [PlantSpecies]

    @State private var name: String = ""
    @State private var selectedSpecies: PlantSpecies? = nil
    @State private var sownDate: Date = Date()
    @State private var locationName: String = "Intérieur"
    @State private var notes: String = ""
    @State private var expectedDays: Int = 7

    // Photo
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                // Photo Picker Section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(uiColor: .tertiarySystemFill))
                                        .frame(width: 120, height: 120)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 32))
                                        .foregroundStyle(.secondary)
                                }
                            }

                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Text(selectedImageData == nil ? "Ajouter une photo" : "Modifier la photo")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                    }
                                }
                            }

                            if selectedImageData != nil {
                                Button(role: .destructive) {
                                    selectedImageData = nil
                                    selectedPhotoItem = nil
                                } label: {
                                    Text("Supprimer")
                                        .font(.caption)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)

                // Main Details Section
                Section("Détails") {
                    TextField("Nom de la plante", text: $name)

                    Picker("Espèce (Optionnel)", selection: $selectedSpecies) {
                        Text("Aucune").tag(Optional<PlantSpecies>.none)
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

                // Notes Section
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nouveau semis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { savePlanting() }
                        .fontWeight(.semibold)
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
            notes: notes,
            initialPhotoData: selectedImageData
        )
        modelContext.insert(newPlanting)
        dismiss()
    }
}
