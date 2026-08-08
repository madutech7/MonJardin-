import SwiftUI
import SwiftData

public struct PlantingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var planting: Planting

    @State private var showingAddLogSheet = false
    @State private var newLogNote = ""
    @State private var newLogHeight: String = ""

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        return formatter
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Hero Card
                VStack(spacing: 16) {
                    GerminationProgressGauge(
                        progress: planting.germinationProgress,
                        daysRemaining: planting.daysRemainingUntilGermination,
                        status: planting.status
                    )

                    VStack(spacing: 4) {
                        Text(planting.customName)
                            .font(.system(size: 26, weight: .bold, design: .rounded))

                        Text("\(planting.speciesName) • \(planting.bedName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        StatusBadgeView(status: planting.status)
                            .padding(.top, 4)
                    }

                    // Action Controls
                    HStack(spacing: 12) {
                        Button(action: {
                            planting.lastWateredDate = Date()
                            try? modelContext.save()
                        }) {
                            HStack {
                                Image(systemName: "drop.fill")
                                Text("Arroser")
                            }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        if planting.status == .sown {
                            Button(action: {
                                planting.status = .germinated
                                planting.actualGerminationDate = Date()
                                planting.logs.append(GardenLog(noteText: "Germination confirmée aujourd'hui ! 🌱"))
                                try? modelContext.save()
                            }) {
                                HStack {
                                    Image(systemName: "sprout.fill")
                                    Text("Germé !")
                                }
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.emeraldGreen)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)

                // Key Information Grid
                VStack(alignment: .leading, spacing: 14) {
                    Text("Dates & Calendrier")
                        .font(.headline)

                    VStack(spacing: 10) {
                        InfoRow(icon: "calendar", title: "Date de semis", value: dateFormatter.string(from: planting.sownDate))
                        InfoRow(
                            icon: "timer",
                            title: "Germination estimée",
                            value: dateFormatter.string(from: planting.expectedGerminationDate)
                        )
                        if let germDate = planting.actualGerminationDate {
                            InfoRow(icon: "checkmark.circle.fill", title: "Germé le", value: dateFormatter.string(from: germDate))
                        }
                        InfoRow(
                            icon: "drop",
                            title: "Dernier arrosage",
                            value: dateFormatter.string(from: planting.lastWateredDate)
                        )
                        InfoRow(
                            icon: "repeat",
                            title: "Fréquence d'arrosage",
                            value: "Tous les \(planting.wateringIntervalDays) jours"
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .padding(.horizontal)

                // Notes & Journal Timeline
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Journal de bord & Photos")
                            .font(.headline)
                        Spacer()
                        Button(action: { showingAddLogSheet = true }) {
                            Label("Note/Photo", systemImage: "plus")
                                .font(.subheadline)
                        }
                    }

                    if planting.logs.isEmpty {
                        Text("Aucune note dans le journal pour le moment.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(planting.logs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(dateFormatter.string(from: log.timestamp))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.emeraldGreen)
                                        Spacer()
                                        if let height = log.heightCm {
                                            Text("Taille: \(String(format: "%.1f", height)) cm")
                                                .font(.caption2)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.gray.opacity(0.15))
                                                .cornerRadius(6)
                                        }
                                    }

                                    Text(log.noteText)
                                        .font(.subheadline)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .cornerRadius(12)
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
        .navigationTitle(planting.customName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showingAddLogSheet) {
            NavigationStack {
                Form {
                    Section("Nouvelle Observation") {
                        TextField("Notes (ex: premières feuilles vives...)", text: $newLogNote, axis: .vertical)
                            .lineLimit(3...6)
                        TextField("Taille en cm (optionnel)", text: $newLogHeight)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Ajouter au Journal")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") { showingAddLogSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Enregistrer") {
                            let heightVal = Double(newLogHeight)
                            let log = GardenLog(noteText: newLogNote, heightCm: heightVal)
                            planting.logs.append(log)
                            try? modelContext.save()
                            newLogNote = ""
                            newLogHeight = ""
                            showingAddLogSheet = false
                        }
                        .disabled(newLogNote.isEmpty)
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.emeraldGreen)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
