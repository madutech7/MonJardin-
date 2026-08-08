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
            VStack(spacing: 24) {
                // Hero Banner & Basic Info Card
                VStack(spacing: 0) {
                    if let photoData = planting.initialPhotoData,
                       let uiImage = UIImage(data: photoData) {
                        ZStack(alignment: .bottomLeading) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                            
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(planting.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                    Text(planting.locationName)
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                            }
                            .padding()
                        }
                    }

                    VStack(spacing: 20) {
                        if planting.initialPhotoData == nil {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(planting.name)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(.primary)
                                    
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                        Text(planting.locationName)
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                StatusBadgeView(status: planting.status)
                            }
                        } else {
                            HStack {
                                Text("Statut actuel")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                StatusBadgeView(status: planting.status)
                            }
                        }

                        Divider()

                        // Germination Gauge if sown
                        if planting.status == .sown {
                            let progress = planting.germinationProgress
                            let days = planting.daysRemainingUntilGermination
                            let status = planting.status

                            VStack(spacing: 16) {
                                GerminationProgressGauge(
                                    progress: progress,
                                    daysRemaining: days,
                                    status: status
                                )
                                
                                Button(action: {
                                    planting.status = .sprouted
                                }) {
                                    Label("Confirmer les Premières Pousses 🌿", systemImage: "checkmark.circle.fill")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.emeraldGreen.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(color: .emeraldGreen.opacity(0.3), radius: 8, y: 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                planting.lastWateredDate = Date()
                            }) {
                                HStack {
                                    Image(systemName: "drop.fill")
                                    Text("Arroser")
                                }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                            }

                            Menu {
                                ForEach(PlantingStatus.allCases, id: \.self) { s in
                                    Button(s.rawValue) { planting.status = s }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Statut")
                                }
                                .font(.headline)
                                .foregroundStyle(Color.orange)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }
                    .padding(20)
                }
                .background {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal)

                // Journal / Log Timeline Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("Journal de suivi", systemImage: "book.pages.fill")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        Button(action: { showingAddLogSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.emeraldGreen.gradient)
                        }
                    }
                    .padding(.horizontal)

                    if planting.logs.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "note.text.badge.plus")
                                .font(.system(size: 36))
                                .foregroundStyle(.tertiary)
                            Text("Aucune note enregistrée.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(planting.logs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(log.stageName)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.emeraldGreen)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.emeraldGreen.opacity(0.12), in: Capsule())
                                        
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
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(.regularMaterial)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Fiche Plantation")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddLogSheet) {
            NavigationStack {
                Form {
                    Section(header: Text("Observation")) {
                        TextEditor(text: $newLogNote)
                            .frame(height: 120)
                    }
                }
                .navigationTitle("Nouvelle Note")
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
