import SwiftUI
import SwiftData

public struct PlantCatalogView: View {
    @Query(sort: \PlantSpecies.name) private var catalog: [PlantSpecies]
    @State private var searchText = ""
    @State private var selectedCategory = "Tous"
    @State private var activeDetailSpecies: PlantSpecies?

    private var categories: [String] {
        ["Tous", "Légume", "Herbe", "Fruit", "Fleur"]
    }

    private var filteredCatalog: [PlantSpecies] {
        catalog.filter { species in
            let matchesSearch = searchText.isEmpty ||
                species.name.localizedCaseInsensitiveContains(searchText) ||
                species.careTips.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "Tous" || species.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            FilterPill(title: cat, isSelected: selectedCategory == cat) {
                                selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))

                // Catalog Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                        ForEach(filteredCatalog) { species in
                            Button(action: { activeDetailSpecies = species }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.emeraldGreen.opacity(0.15))
                                                .frame(width: 42, height: 42)
                                            Image(systemName: species.iconName)
                                                .foregroundColor(.emeraldGreen)
                                                .font(.system(size: 18, weight: .bold))
                                        }
                                        Spacer()
                                        Text(species.category)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(Color.gray.opacity(0.12))
                                            .cornerRadius(6)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(species.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Text("Germination: \(species.minGerminationDays)-\(species.maxGerminationDays)j")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                            .fontWeight(.medium)
                                    }

                                    HStack {
                                        Label(species.sunlightRequirement, systemImage: "sun.max.fill")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Catalogue de Plantes")
            .searchable(text: $searchText, prompt: "Rechercher une espèce (ex: Radis, Tomate...)")
            .background(Color(uiColor: .systemGroupedBackground))
            .sheet(item: $activeDetailSpecies) { species in
                SpeciesDetailSheet(species: species)
            }
        }
    }
}

struct SpeciesDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let species: PlantSpecies
    @State private var showingAddPlanting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.emeraldGreen.opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: species.iconName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.emeraldGreen)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(species.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(species.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(18)

                    // Care specs
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Caractéristiques de Culture")
                            .font(.headline)

                        VStack(spacing: 10) {
                            InfoRow(icon: "timer", title: "Temps de germination", value: "\(species.minGerminationDays) à \(species.maxGerminationDays) jours")
                            InfoRow(icon: "calendar", title: "Période idéale de semis", value: species.idealSowingMonths)
                            InfoRow(icon: "sun.max", title: "Ensoleillement", value: species.sunlightRequirement)
                            InfoRow(icon: "drop", title: "Arrosage suggéré", value: "Tous les \(species.defaultWateringDays) jours")
                            InfoRow(icon: "basket", title: "Estimation récolte", value: "~\(species.averageHarvestDays) jours après semis")
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(18)

                    // Care tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Conseils de Jardinier 💡")
                            .font(.headline)
                        Text(species.careTips)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(18)

                    Button(action: {
                        dismiss()
                        showingAddPlanting = true
                    }) {
                        Label("Semer cette espèce", systemImage: "sprout.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.emeraldGreen)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .navigationTitle(species.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        }
    }
}
