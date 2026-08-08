import SwiftUI
import SwiftData
import PhotosUI

public struct AddPlantingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var plantName: String = ""
    @State private var locationName: String = "Potager"
    @State private var sownDate: Date = Date()
    @State private var notes: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    private let defaultLocations = ["Potager", "Balcon", "Serre", "Jardinière", "Pots d'intérieur"]

    public var body: some View {
        NavigationStack {
            Form {
                Section("Informations de la Plante") {
                    TextField("Nom de la plante (ex: Tomates Marmande)", text: $plantName)

                    Picker("Emplacement", selection: $locationName) {
                        ForEach(defaultLocations, id: \.self) { loc in
                            Text(loc).tag(loc)
                        }
                    }
                }

                Section("Date de Semis") {
                    DatePicker("Date du semis", selection: $sownDate, in: ...Date(), displayedComponents: .date)
                }

                Section("Photo Initiale (Optionnel)") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .foregroundColor(.green)
                            Text(selectedPhotoData == nil ? "Ajouter une photo du semis" : "Changer la photo")
                            Spacer()
                            if selectedPhotoData != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .onChange(of: selectedPhotoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedPhotoData = data
                            }
                        }
                    }

                    if let photoData = selectedPhotoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.vertical, 4)
                    }
                }

                Section("Notes & Remarques") {
                    TextField("Notes (ex: graines bio, terreau terreau léger...)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
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
                    .disabled(plantName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func savePlanting() {
        let newPlanting = Planting(
            name: plantName,
            locationName: locationName,
            status: .sown,
            sownDate: sownDate,
            notes: notes,
            initialPhotoData: selectedPhotoData
        )

        let initialLog = GardenLog(
            timestamp: sownDate,
            stageName: "Semé",
            noteText: "Semis mis en terre.",
            photoData: selectedPhotoData
        )
        newPlanting.logs.append(initialLog)

        modelContext.insert(newPlanting)
        try? modelContext.save()
        dismiss()
    }
}
