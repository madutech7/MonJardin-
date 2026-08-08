import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddSheet = false
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)

            GardenView()
                .tabItem {
                    Label("Mes Plantes", systemImage: "leaf.fill")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Label("Nouveau", systemImage: "plus.circle.fill")
                }
                .tag(2)

            PlantCatalogView()
                .tabItem {
                    Label("Catalogue", systemImage: "square.grid.2x2.fill")
                }
                .tag(3)

            CareView()
                .tabItem {
                    Label("Soins", systemImage: "drop.fill")
                }
                .tag(4)
        }
        .tint(Color.emeraldGreen)
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 2 {
                showingAddSheet = true
                selectedTab = 0
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddPlantingView()
        }
    }
}
