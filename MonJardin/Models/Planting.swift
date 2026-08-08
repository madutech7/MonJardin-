import Foundation
import SwiftData

/// Étapes clés du cycle de vie de la plante de la graine aux fruits
public enum PlantingStatus: String, Codable, CaseIterable {
    case sown = "Semé"
    case sprouted = "Premières pousses"
    case growing = "En croissance"
    case flowering = "Floraison"
    case fruiting = "Premiers fruits"
    case harvested = "Récolté"

    public var systemIcon: String {
        switch self {
        case .sown: return "circle.dotted"
        case .sprouted: return "leaf.arrow.triangle.circlepath"
        case .growing: return "leaf.fill"
        case .flowering: return "sparkles"
        case .fruiting: return "square.stack.3d.up.fill"
        case .harvested: return "checkmark.circle.fill"
        }
    }
}

/// Modèle SwiftData local pour enregistrer et suivre une plantation
@Model
public final class Planting {
    public var id: UUID
    public var name: String
    public var locationName: String
    public var statusRaw: String
    public var sownDate: Date
    public var expectedGerminationDays: Int?
    public var notes: String
    public var initialPhotoData: Data?

    @Relationship(deleteRule: .cascade)
    public var logs: [GardenLog]

    public init(
        id: UUID = UUID(),
        name: String,
        locationName: String = "Jardin",
        status: PlantingStatus = .sown,
        sownDate: Date = Date(),
        expectedGerminationDays: Int? = nil,
        notes: String = "",
        initialPhotoData: Data? = nil,
        logs: [GardenLog] = []
    ) {
        self.id = id
        self.name = name
        self.locationName = locationName
        self.statusRaw = status.rawValue
        self.sownDate = sownDate
        self.expectedGerminationDays = expectedGerminationDays
        self.notes = notes
        self.initialPhotoData = initialPhotoData
        self.logs = logs
    }

    public var status: PlantingStatus {
        get { PlantingStatus(rawValue: statusRaw) ?? .sown }
        set { statusRaw = newValue.rawValue }
    }

    /// Nombre de jours écoulés depuis le semis
    public var daysSinceSown: Int {
        let components = Calendar.current.dateComponents([.day], from: sownDate, to: Date())
        return max(0, components.day ?? 0)
    }
}
