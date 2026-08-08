import SwiftUI
import SwiftData
import PhotosUI

public struct PlantingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var planting: Planting

    @State private var showingAddLogSheet = false
    @State private var newLogNote = ""
    @State private var selectedStage: PlantingStatus = .sprouted
    @State private var logPhotoItem: PhotosPickerItem?
    @State private var logPhotoData: Data?

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        return formatter
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)

                        if let photoData = planting.initialPhotoData, let uiImage = UIImage(data: photoData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: planting.status.systemIcon)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                        }
                    }

                    VStack(spacing: 6) {
                        Text(planting.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))

                        Text(planting.locationName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        StatusBadgeView(status: planting.status)
                            .padding(.top, 2)
                    }

                    // Advancement Button
                    if planting.status != .harvested {
                        Button(action: advanceStage) {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                Text(nextStageButtonTitle)
                            }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 16/255, green: 185/255, blue: 129/255))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)

                // Sowing Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Informations du Semis")
                        .font(.headline)

                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                            Text("Date de semis")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(dateFormatter.string(from: planting.sownDate))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(.orange)
                            Text("Temps écoulé")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(planting.daysSinceSown) jour(s)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        if !planting.notes.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Remarques :")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(planting.notes)
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .padding(.horizontal)

                // Growth Photo Timeline
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Suivi Photos & Étapes 📸")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingAddLogSheet = true }) {
                            Label("Ajouter photo", systemImage: "plus")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }

                    if planting.logs.isEmpty {
                        Text("Aucune photo ou observation pour l'instant.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(planting.logs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(log.stageName)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                                        Spacer()
                                        Text(dateFormatter.string(from: log.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    if let photoData = log.photoData, let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxHeight: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }

                                    if !log.noteText.isEmpty {
                                        Text(log.noteText)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .padding(14)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .cornerRadius(16)
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
            }
            .padding(.vertical)
        }
        .navigationTitle(planting.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showingAddLogSheet) {
            NavigationStack {
                Form {
                    Section("Étape & Photo") {
                        Picker("Étape courante", selection: $selectedStage) {
                            ForEach(PlantingStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }

                        PhotosPicker(selection: $logPhotoItem, matching: .images) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(.green)
                                Text(logPhotoData == nil ? "Sélectionner une photo" : "Changer la photo")
                                Spacer()
                                if logPhotoData != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .onChange(of: logPhotoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    logPhotoData = data
                                }
                            }
                        }

                        if let data = logPhotoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Section("Commentaire") {
                        TextField("Observations (ex: premières feuilles bien vertes...)", text: $newLogNote, axis: .vertical)
                            .lineLimit(3...5)
                    }
                }
                .navigationTitle("Nouveau Suivi Photo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { showingAddLogSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Enregistrer") {
                            let newLog = GardenLog(
                                timestamp: Date(),
                                stageName: selectedStage.rawValue,
                                noteText: newLogNote,
                                photoData: logPhotoData
                            )
                            planting.logs.append(newLog)
                            planting.status = selectedStage
                            try? modelContext.save()

                            newLogNote = ""
                            logPhotoData = nil
                            logPhotoItem = nil
                            showingAddLogSheet = false
                        }
                    }
                }
            }
        }
    }

    private var nextStageButtonTitle: String {
        switch planting.status {
        case .sown: return "Marquer les Premières Pousses 🌱"
        case .sprouted: return "Passer en Croissance 🌿"
        case .growing: return "Marquer la Floraison 🌸"
        case .flowering: return "Marquer les Premiers Fruits 🍅"
        case .fruiting: return "Marquer la Récolte 🧺"
        case .harvested: return "Terminé"
        }
    }

    private func advanceStage() {
        let nextStatus: PlantingStatus
        switch planting.status {
        case .sown: nextStatus = .sprouted
        case .sprouted: nextStatus = .growing
        case .growing: nextStatus = .flowering
        case .flowering: nextStatus = .fruiting
        case .fruiting: nextStatus = .harvested
        case .harvested: return
        }

        planting.status = nextStatus
        planting.logs.append(GardenLog(timestamp: Date(), stageName: nextStatus.rawValue, noteText: "Passage à l'étape \(nextStatus.rawValue)."))
        try? modelContext.save()
    }
}
