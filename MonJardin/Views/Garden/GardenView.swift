import SwiftUI
import SwiftData

public struct GardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]

    @State private var searchText = ""
    @State private var selectedStatusFilter: PlantingStatus? = nil
    @State private var showingAddSheet = false

    private var filteredPlantings: [Planting] {
        plantings.filter { planting in
            let matchesSearch = searchText.isEmpty ||
                planting.customName.localizedCaseInsensitiveContains(searchText) ||
                planting.speciesName.localizedCaseInsensitiveContains(searchText) ||
                planting.bedName.localizedCaseInsensitiveContains(searchText)

            let matchesStatus = selectedStatusFilter == nil || planting.status == selectedStatusFilter

            return matchesSearch && matchesStatus
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status Filter Pill Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(title: "Tous", isSelected: selectedStatusFilter == nil) {
                            selectedStatusFilter = nil
                        }

                        ForEach(PlantingStatus.allCases, id: \.self) { status in
                            FilterPill(title: status.rawValue, isSelected: selectedStatusFilter == status) {
                                selectedStatusFilter = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))

                // Plantings List / Grid
                if filteredPlantings.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Aucune plantation trouvée")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPlantings) { planting in
                                NavigationLink(value: planting) {
                                    PlantingRowCard(planting: planting) {
                                        planting.lastWateredDate = Date()
                                        try? modelContext.save()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mon Jardin")
            .searchable(text: $searchText, prompt: "Chercher une plante ou un potager...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: Planting.self) { planting in
                PlantingDetailView(planting: planting)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPlantingView()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.emeraldGreen : Color(uiColor: .tertiarySystemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
