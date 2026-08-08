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

    private var displayCatalog: [PlantSpecies] {
        let source = catalog.isEmpty ? PlantSpecies.defaultCatalog : catalog
        return source.filter { species in
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
                                withAnimation(.easeInOut) { selectedCategory = cat }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(uiColor: .systemGroupedBackground))

                // Catalog Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                        ForEach(displayCatalog) { species in
                            Button(action: { activeDetailSpecies = species }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.emeraldGreen.opacity(0.12))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: species.iconName.isEmpty ? "leaf.fill" : species.iconName)
                                                .foregroundStyle(Color.emeraldGreen.gradient)
                                                .font(.system(size: 20, weight: .bold))
                                        }
                                        Spacer()
                                        Text(species.category)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.emeraldGreen.opacity(0.1), in: Capsule())
                                            .foregroundStyle(Color.emeraldGreen)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(species.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        Text("Germination: \(species.minGerminationDays)-\(species.maxGerminationDays)j")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(14)
                                .background {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(.regularMaterial)
                                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Catalogue 📚")
            .searchable(text: $searchText, prompt: "Rechercher une plante...")
            .sheet(item: $activeDetailSpecies) { species in
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(Color.emeraldGreen.opacity(0.12))
                                    .frame(width: 80, height: 80)
                                Image(systemName: species.iconName.isEmpty ? "leaf.fill" : species.iconName)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(Color.emeraldGreen.gradient)
                            }
                            .padding(.top)

                            VStack(spacing: 4) {
                                Text(species.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(species.category)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            VStack(spacing: 12) {
                                InfoRow(icon: "timer", title: "Germination", value: "\(species.minGerminationDays) à \(species.maxGerminationDays) jours")
                                InfoRow(icon: "calendar", title: "Période idéale", value: species.idealSowingMonths)
                                InfoRow(icon: "sun.max.fill", title: "Ensoleillement", value: species.sunlightRequirement)
                                InfoRow(icon: "drop.fill", title: "Arrosage", value: "Tous les \(species.defaultWateringDays) jours")
                                InfoRow(icon: "basket.fill", title: "Récolte estimée", value: "~\(species.averageHarvestDays) jours")
                            }
                            .padding(16)
                            .background {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.regularMaterial)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Conseils de culture")
                                    .font(.headline)
                                Text(species.careTips)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.regularMaterial)
                            }
                        }
                        .padding()
                    }
                    .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
                    .navigationTitle(species.name)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
