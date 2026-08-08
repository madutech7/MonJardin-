import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext

    public init() {}

    public var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Tableau de bord", systemImage: "square.grid.2x2.fill")
                }

            GardenView()
                .tabItem {
                    Label("Mon Jardin", systemImage: "sprout.fill")
                }

            PlantCatalogView()
                .tabItem {
                    Label("Catalogue", systemImage: "book.closed.fill")
                }

            CareView()
                .tabItem {
                    Label("Arrosage", systemImage: "drop.fill")
                }
        }
        .accentColor(.emeraldGreen)
        .onAppear {
            SampleData.populate(context: modelContext)
        }
    }
}
