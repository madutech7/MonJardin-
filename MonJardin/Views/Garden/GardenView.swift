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
            VStack(spacing: 0) {
                // Filter Pills Bar
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
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(uiColor: .systemGroupedBackground))

                // List of Plantings
                ScrollView {
                    VStack(spacing: 12) {
                        if filteredPlantings.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 44, weight: .light))
                                    .foregroundStyle(.tertiary)
                                
                                Text("Aucune plantation trouvée")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ForEach(filteredPlantings) { planting in
                                NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                    PlantingRowCard(planting: planting)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Mes Plantes")
            .searchable(text: $searchText, prompt: "Rechercher une plante...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.emeraldGreen.gradient)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPlantingView()
            }
        }
    }
}
