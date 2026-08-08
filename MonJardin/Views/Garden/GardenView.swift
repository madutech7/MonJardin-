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
                planting.name.localizedCaseInsensitiveContains(searchText) ||
                planting.locationName.localizedCaseInsensitiveContains(searchText)

            let matchesStatus = selectedStatusFilter == nil || planting.status == selectedStatusFilter
            return matchesSearch && matchesStatus
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Pill Bar
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

                // List
                if filteredPlantings.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("Aucune plantation dans cette catégorie")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredPlantings) { planting in
                                NavigationLink(value: planting) {
                                    PlantingRowCard(planting: planting)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Mes Plantations")
            .searchable(text: $searchText, prompt: "Rechercher une plante...")
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
