import SwiftUI
import SwiftData

public struct PlantingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var planting: Planting

    @State private var showingAddLogSheet = false
    @State private var newLogNote = ""

    public init(planting: Planting) {
        self.planting = planting
    }

    public var body: some View {
        List {
            // Photo Section
            if let photoData = planting.initialPhotoData,
               let uiImage = UIImage(data: photoData) {
                Section {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)
            }

            // Overview Section
            Section("Informations") {
                LabeledContent("Nom", value: planting.name)
                LabeledContent("Emplacement", value: planting.locationName)
                LabeledContent("Date de semis", value: planting.sownDate.formatted(date: .long, time: .omitted))
                
                Picker("Statut actuel", selection: Binding(
                    get: { planting.status },
                    set: { planting.status = $0 }
                )) {
                    ForEach(PlantingStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
            }

            // Germination Progress Section (if sown)
            if planting.status == .sown {
                Section("Progression de germination") {
                    HStack(spacing: 20) {
                        GerminationProgressGauge(
                            progress: planting.germinationProgress,
                            daysRemaining: planting.daysRemainingUntilGermination,
                            status: planting.status
                        )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            let days = planting.daysRemainingUntilGermination
                            Text(days <= 0 ? "Germination imminente !" : "\(days) jours restants")
                                .font(.headline)
                                .foregroundStyle(days <= 0 ? .orange : .primary)
                            
                            Text("Semé le \(planting.sownDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Button {
                                planting.status = .sprouted
                            } label: {
                                Label("Confirmer la levée", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            // Journal / Notes Section
            Section {
                if planting.logs.isEmpty {
                    Text("Aucune note enregistrée.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(planting.logs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(log.stageName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                                
                                Spacer()
                                
                                Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !log.noteText.isEmpty {
                                Text(log.noteText)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                HStack {
                    Text("Journal de suivi")
                    Spacer()
                    Button {
                        showingAddLogSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(planting.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddLogSheet) {
            NavigationStack {
                Form {
                    Section("Observation") {
                        TextEditor(text: $newLogNote)
                            .frame(height: 120)
                    }
                }
                .navigationTitle("Nouvelle note")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { showingAddLogSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Ajouter") {
                            let log = GardenLog(noteText: newLogNote)
                            planting.logs.append(log)
                            newLogNote = ""
                            showingAddLogSheet = false
                        }
                        .disabled(newLogNote.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }
}
