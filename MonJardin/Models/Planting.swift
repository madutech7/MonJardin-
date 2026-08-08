import Foundation
import SwiftData

/// Étape de développement de la plantation
public enum PlantingStatus: String, Codable, CaseIterable {
    case sown = "Semé"
    case germinated = "Germé"
    case growing = "En croissance"
    case harvesting = "En récolte"
    case completed = "Terminé"

    public var systemIcon: String {
        switch self {
        case .sown: return "circle.dotted"
        case .germinated: return "sprout.fill"
        case .growing: return "leaf.fill"
        case .harvesting: return "basket.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

/// Modèle SwiftData principal pour une plantation dans le jardin
@Model
public final class Planting {
    public var id: UUID
    public var customName: String
    public var speciesName: String
    public var category: String
    public var bedName: String // ex: Potager Sud, Serre, Balcon
    public var statusRaw: String
    public var sownDate: Date
    public var expectedGerminationDate: Date
    public var actualGerminationDate: Date?
    public var expectedHarvestDate: Date?
    public var wateringIntervalDays: Int
    public var lastWateredDate: Date
    public var notes: String
    public var initialPhotoData: Data?

    @Relationship(deleteRule: .cascade)
    public var logs: [GardenLog]

    public init(
        id: UUID = UUID(),
        customName: String,
        speciesName: String,
        category: String = "Légume",
        bedName: String = "Potager Princpal",
        status: PlantingStatus = .sown,
        sownDate: Date = Date(),
        expectedGerminationDate: Date,
        actualGerminationDate: Date? = nil,
        expectedHarvestDate: Date? = nil,
        wateringIntervalDays: Int = 2,
        lastWateredDate: Date = Date(),
        notes: String = "",
        initialPhotoData: Data? = nil,
        logs: [GardenLog] = []
    ) {
        self.id = id
        self.customName = customName
        self.speciesName = speciesName
        self.category = category
        self.bedName = bedName
        self.statusRaw = status.rawValue
        self.sownDate = sownDate
        self.expectedGerminationDate = expectedGerminationDate
        self.actualGerminationDate = actualGerminationDate
        self.expectedHarvestDate = expectedHarvestDate
        self.wateringIntervalDays = wateringIntervalDays
        self.lastWateredDate = lastWateredDate
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
        Calendar.current.dateComponents([.day], from: sownDate, to: Date()).day ?? 0
    }

    /// Jours restants avant l'estimation de germination
    public var daysRemainingUntilGermination: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: expectedGerminationDate).day ?? 0
        return max(0, remaining)
    }

    /// Progression de la germination (valeur entre 0.0 et 1.0)
    public var germinationProgress: Double {
        let totalDuration = expectedGerminationDate.timeIntervalSince(sownDate)
        guard totalDuration > 0 else { return 1.0 }
        let elapsed = Date().timeIntervalSince(sownDate)
        return min(1.0, max(0.0, elapsed / totalDuration))
    }

    /// Indique si la plante nécessite un arrosage aujourd'hui
    public var needsWateringToday: Bool {
        guard let nextWatering = Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWateredDate) else {
            return false
        }
        return Date() >= nextWatering
    }
}
