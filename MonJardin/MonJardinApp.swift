import SwiftUI
import SwiftData

@main
struct MonJardinApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Planting.self,
            PlantSpecies.self,
            GardenLog.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Erreur d'initialisation du conteneur SwiftData MonJardin: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
