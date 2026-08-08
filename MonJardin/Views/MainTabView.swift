import SwiftUI
import SwiftData

// MARK: - Shared Color Palette
public extension Color {
    static let emeraldGreen = Color(red: 16/255, green: 185/255, blue: 129/255)
}

// MARK: - Conditional Glass Modifier
extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self
        }
    }
}

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
        }
        .tint(.green)
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
