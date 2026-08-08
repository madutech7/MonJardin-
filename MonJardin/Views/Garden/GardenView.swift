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
        plantings.filter { p in
            let matchesSearch = searchText.isEmpty ||
                p.name.localizedCaseInsensitiveContains(searchText) ||
                p.locationName.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedStatusFilter == nil || p.status == selectedStatusFilter
            return matchesSearch && matchesFilter
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                // Filter chips
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(title: "Tous", isSelected: selectedStatusFilter == nil) {
                                withAnimation { selectedStatusFilter = nil }
                            }
                            ForEach(PlantingStatus.allCases, id: \.self) { status in
                                let count = plantings.filter { $0.status == status }.count
                                if count > 0 {
                                    FilterPill(title: status.rawValue, isSelected: selectedStatusFilter == status) {
                                        withAnimation { selectedStatusFilter = status }
                                    }
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                // Plant list
                Section {
                    if filteredPlantings.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        ForEach(filteredPlantings) { planting in
                            NavigationLink(destination: PlantingDetailView(planting: planting)) {
                                HStack(spacing: 12) {
                                    Group {
                                        if let data = planting.initialPhotoData, let img = UIImage(data: data) {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 44, height: 44)
                                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        } else {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(Color.green.opacity(0.12))
                                                    .frame(width: 44, height: 44)
                                                Image(systemName: planting.status.systemIcon)
                                                    .foregroundStyle(.green)
                                            }
                                        }
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(planting.name)
                                            .font(.body)
                                        Text(planting.locationName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 2)
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
            .searchable(text: $searchText, prompt: "Rechercher...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPlantingView()
            }
        }
    }
}
