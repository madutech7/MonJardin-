import SwiftUI
import SwiftData

public struct GardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Planting.sownDate, order: .reverse) private var plantings: [Planting]

    @State private var searchText = ""
    @State private var selectedStatusFilter: PlantingStatus? = nil
    @State private var showingAddSheet = false

    public init() {}

    private var filteredPlantings: [Planting] {
        plantings.filter { planting in
            let matchesSearch = searchText.isEmpty || 
                planting.name.localizedCaseInsensitiveContains(searchText) ||
                planting.locationName.localizedCaseInsensitiveContains(searchText)
            
            let matchesFilter = selectedStatusFilter == nil || planting.status == selectedStatusFilter
            
            return matchesSearch && matchesFilter
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                // Filter Picker Section
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(title: "Tous (\(plantings.count))", isSelected: selectedStatusFilter == nil) {
                                withAnimation(.easeInOut) { selectedStatusFilter = nil }
                            }

                            ForEach(PlantingStatus.allCases, id: \.self) { status in
                                let count = plantings.filter { $0.status == status }.count
                                if count > 0 {
                                    FilterPill(title: "\(status.rawValue) (\(count))", isSelected: selectedStatusFilter == status) {
                                        withAnimation(.easeInOut) { selectedStatusFilter = status }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                // Main Plantings List
                Section {
                    if filteredPlantings.isEmpty {
                        ContentUnavailableView(
                            "Aucun résultat",
                            systemImage: "magnifyingglass",
                            description: Text(searchText.isEmpty ? "Aucune plante disponible." : "Aucune plantation ne correspond à « \(searchText) ».")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(filteredPlantings) { planting in
                            NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                PlantingRowCard(planting: planting)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(planting)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Mes Plantes")
            .searchable(text: $searchText, prompt: "Rechercher une plante...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPlantingView()
            }
        }
    }
}
