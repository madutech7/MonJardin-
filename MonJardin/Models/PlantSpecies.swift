import Foundation
import SwiftData

/// Modèle représentant une espèce de plante dans le catalogue d'apprentissage
@Model
public final class PlantSpecies {
    public var id: UUID
    public var name: String
    public var category: String // Légume, Herbe, Fruit, Fleur
    public var iconName: String // Nom SF Symbol ou emoji
    public var minGerminationDays: Int
    public var maxGerminationDays: Int
    public var averageHarvestDays: Int
    public var defaultWateringDays: Int
    public var idealSowingMonths: String
    public var sunlightRequirement: String // Plein soleil, Mi-ombre, Ombre
    public var careTips: String

    public init(
        id: UUID = UUID(),
        name: String,
        category: String,
        iconName: String,
        minGerminationDays: Int,
        maxGerminationDays: Int,
        averageHarvestDays: Int,
        defaultWateringDays: Int,
        idealSowingMonths: String,
        sunlightRequirement: String,
        careTips: String
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.iconName = iconName
        self.minGerminationDays = minGerminationDays
        self.maxGerminationDays = maxGerminationDays
        self.averageHarvestDays = averageHarvestDays
        self.defaultWateringDays = defaultWateringDays
        self.idealSowingMonths = idealSowingMonths
        self.sunlightRequirement = sunlightRequirement
        self.careTips = careTips
    }

    /// Exemples prédéfinis pour le catalogue initial du jardin
    public static var defaultCatalog: [PlantSpecies] {
        [
            PlantSpecies(
                name: "Tomate Cerise",
                category: "Légume",
                iconName: "leaf.fill",
                minGerminationDays: 7,
                maxGerminationDays: 12,
                averageHarvestDays: 75,
                defaultWateringDays: 2,
                idealSowingMonths: "Mars - Mai",
                sunlightRequirement: "Plein soleil",
                careTips: "Maintenir la terre humide sans détremper. Tuteurer la tige dès que la plante atteint 20 cm."
            ),
            PlantSpecies(
                name: "Basilic Grand Vert",
                category: "Herbe",
                iconName: "drop.degreesign.fill",
                minGerminationDays: 5,
                maxGerminationDays: 10,
                averageHarvestDays: 45,
                defaultWateringDays: 1,
                idealSowingMonths: "Avril - Juin",
                sunlightRequirement: "Plein soleil",
                careTips: "Pincer la tête des tiges pour favoriser un feuillage dense et empêcher la floraison précoce."
            ),
            PlantSpecies(
                name: "Radis 18 Jours",
                category: "Légume",
                iconName: "circle.grid.cross.fill",
                minGerminationDays: 3,
                maxGerminationDays: 6,
                averageHarvestDays: 20,
                defaultWateringDays: 1,
                idealSowingMonths: "Mars - Septembre",
                sunlightRequirement: "Mi-ombre / Soleil",
                careTips: "Arroser régulièrement pour éviter que les radis ne deviennent trop piquants."
            ),
            PlantSpecies(
                name: "Carotte Nantaise",
                category: "Légume",
                iconName: "carrot.fill",
                minGerminationDays: 10,
                maxGerminationDays: 18,
                averageHarvestDays: 90,
                defaultWateringDays: 3,
                idealSowingMonths: "Mars - Juillet",
                sunlightRequirement: "Plein soleil",
                careTips: "Semer dans une terre meuble et sans cailloux. Conserver un terreau humide pendant la germination."
            ),
            PlantSpecies(
                name: "Courgette Verte",
                category: "Légume",
                iconName: "oval.portrait.fill",
                minGerminationDays: 6,
                maxGerminationDays: 10,
                averageHarvestDays: 60,
                defaultWateringDays: 2,
                idealSowingMonths: "Avril - Juin",
                sunlightRequirement: "Plein soleil",
                careTips: "Planter dans un sol très riche en compost. Arroser au pied sans mouiller les feuilles."
            ),
            PlantSpecies(
                name: "Fraise des Bois",
                category: "Fruit",
                iconName: "heart.fill",
                minGerminationDays: 14,
                maxGerminationDays: 25,
                averageHarvestDays: 120,
                defaultWateringDays: 2,
                idealSowingMonths: "Février - Avril",
                sunlightRequirement: "Mi-ombre",
                careTips: "Pailler le pied pour conserver l'humidité et protéger les fruits de la terre."
            ),
            PlantSpecies(
                name: "Salade Laitue",
                category: "Légume",
                iconName: "square.stack.3d.up.fill",
                minGerminationDays: 4,
                maxGerminationDays: 8,
                averageHarvestDays: 50,
                defaultWateringDays: 2,
                idealSowingMonths: "Février - Août",
                sunlightRequirement: "Mi-ombre",
                careTips: "Ombrager en cas de forte chaleur pour éviter que les salades ne montent en graine."
            ),
            PlantSpecies(
                name: "Menthe Poivrée",
                category: "Herbe",
                iconName: "sparkles",
                minGerminationDays: 10,
                maxGerminationDays: 15,
                averageHarvestDays: 60,
                defaultWateringDays: 2,
                idealSowingMonths: "Mars - Mai",
                sunlightRequirement: "Mi-ombre",
                careTips: "Planter de préférence en pot car la menthe a tendance à devenir très envahissante."
            )
        ]
    }
}
