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
        ScrollView {
            VStack(spacing: 20) {
                // Main Info Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(planting.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(planting.locationName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        StatusBadgeView(status: planting.status)
                    }

                    Divider()

                    if planting.status == .sown {
                        let progress = planting.germinationProgress
                        let days = planting.daysRemainingUntilGermination
                        let status = planting.status

                        VStack(spacing: 12) {
                            GerminationProgressGauge(
                                progress: progress,
                                daysRemaining: days,
                                status: status
                            )
                            Button(action: {
                                planting.status = .sprouted
                            }) {
                                Label("Confirmer les Premières Pousses", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    HStack(spacing: 16) {
                        Button(action: {
                            planting.lastWateredDate = Date()
                        }) {
                            HStack {
                                Image(systemName: "drop.fill")
                                Text("Arroser")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(12)
                        }

                        Menu {
                            ForEach(PlantingStatus.allCases, id: \.self) { s in
                                Button(s.rawValue) { planting.status = s }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Changer statut")
                            }
                            .font(.headline)
                            .foregroundColor(.orange)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)

                // Journal / Log Timeline
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Journal de suivi")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: { showingAddLogSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }

                    if planting.logs.isEmpty {
                        Text("Aucune note pour le moment.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(planting.logs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(log.stageName)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                    Spacer()
                                    Text(log.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                if !log.noteText.isEmpty {
                                    Text(log.noteText)
                                        .font(.body)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddLogSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Nouvelle note de suivi")) {
                        TextEditor(text: $newLogNote)
                            .frame(height: 120)
                    }
                }
                .navigationTitle("Ajouter au journal")
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
