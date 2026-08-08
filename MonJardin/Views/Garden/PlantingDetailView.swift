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
            // ── Photo Hero ──
            if let photoData = planting.initialPhotoData,
               let uiImage = UIImage(data: photoData) {
                Section {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .listRowInsets(EdgeInsets())
                }
                .listRowBackground(Color.clear)
            }

            // ── Informations ──
            Section("Informations") {
                LabeledContent("Emplacement", value: planting.locationName)
                LabeledContent("Semé le", value: planting.sownDate.formatted(date: .long, time: .omitted))
                LabeledContent("Jours depuis semis", value: "\(planting.daysSinceSown)")

                Picker("Statut", selection: Binding(
                    get: { planting.status },
                    set: { planting.status = $0 }
                )) {
                    ForEach(PlantingStatus.allCases, id: \.self) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
            }

            // ── Germination ──
            if planting.status == .sown {
                Section("Germination") {
                    HStack(spacing: 16) {
                        GerminationProgressGauge(
                            progress: planting.germinationProgress,
                            daysRemaining: planting.daysRemainingUntilGermination,
                            status: planting.status
                        )
                        .frame(width: 80, height: 80)

                        VStack(alignment: .leading, spacing: 6) {
                            let days = planting.daysRemainingUntilGermination
                            Text(days <= 0 ? "Germination imminente" : "\(days) jours restants")
                                .font(.headline)

                            Text("\(Int(planting.germinationProgress * 100))% de progression")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button {
                                planting.status = .sprouted
                            } label: {
                                Text("Confirmer la levée")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            .controlSize(.small)
                            .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            // ── Notes ──
            if !planting.notes.isEmpty {
                Section("Notes") {
                    Text(planting.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // ── Journal ──
            Section {
                if planting.logs.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "text.book.closed")
                                .font(.title2)
                                .foregroundStyle(.tertiary)
                            Text("Aucune entrée")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                } else {
                    ForEach(planting.logs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(log.stageName)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                                Spacer()
                                Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            if !log.noteText.isEmpty {
                                Text(log.noteText)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            } header: {
                HStack {
                    Text("Journal")
                    Spacer()
                    Button { showingAddLogSheet = true } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(planting.name)
        .navigationBarTitleDisplayMode(.large)
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
                        .fontWeight(.semibold)
                        .disabled(newLogNote.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }
}
