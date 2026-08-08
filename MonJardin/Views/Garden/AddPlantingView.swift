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
    @State private var locationName: String = "Intérieur / Serre"
    @State private var notes: String = ""
    @State private var expectedDays: Int = 7

    // Photo
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                // Photo Section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green.opacity(0.08))
                                        .frame(width: 140, height: 140)
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.green.opacity(0.6))
                                        Text("Ajouter une photo")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images
                            ) {
                                Label(
                                    selectedImageData == nil ? "Choisir une photo" : "Changer la photo",
                                    systemImage: "photo.badge.plus"
                                )
                                .font(.subheadline)
                                .foregroundColor(.green)
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
                                    Label("Supprimer la photo", systemImage: "trash")
                                        .font(.caption)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

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
            notes: notes,
            initialPhotoData: selectedImageData
        )
        modelContext.insert(newPlanting)
        dismiss()
    }
}
