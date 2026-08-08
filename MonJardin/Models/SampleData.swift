import Foundation
import SwiftData

/// Utilitaire pour alimenter l'application avec des données de démonstration réalistes
public struct SampleData {
    public static func populate(context: ModelContext) {
        // Ajouter le catalogue d'espèces si vide
        let speciesFetch = FetchDescriptor<PlantSpecies>()
        if (try? context.fetch(speciesFetch))?.isEmpty ?? true {
            for species in PlantSpecies.defaultCatalog {
                context.insert(species)
            }
        }

        // Ajouter des plantations de démonstration si vide
        let plantingFetch = FetchDescriptor<Planting>()
        if (try? context.fetch(plantingFetch))?.isEmpty ?? true {
            let calendar = Calendar.current
            let now = Date()

            // 1. Radis 18 Jours - Semés hier, germination très proche
            let sownRadish = calendar.date(byAdding: .day, value: -3, to: now)!
            let expRadishGerm = calendar.date(byAdding: .day, value: 2, to: now)!
            let radish = Planting(
                customName: "Radis de Printemps",
                speciesName: "Radis 18 Jours",
                category: "Légume",
                bedName: "Potager Rectangle #1",
                status: .sown,
                sownDate: sownRadish,
                expectedGerminationDate: expRadishGerm,
                wateringIntervalDays: 1,
                lastWateredDate: calendar.date(byAdding: .hour, value: -12, to: now)!,
                notes: "Terreau bien tamisé, graines espacées de 2 cm."
            )
            radish.logs.append(GardenLog(timestamp: sownRadish, noteText: "Semis effectué au matin sous un soleil doux."))

            // 2. Tomates Cerises - Germées il y a 2 jours
            let sownTomato = calendar.date(byAdding: .day, value: -10, to: now)!
            let germTomato = calendar.date(byAdding: .day, value: -2, to: now)!
            let expTomatoGerm = calendar.date(byAdding: .day, value: -2, to: now)!
            let expTomatoHarvest = calendar.date(byAdding: .day, value: 65, to: now)!
            let tomato = Planting(
                customName: "Tomates Cerises Sweet",
                speciesName: "Tomate Cerise",
                category: "Légume",
                bedName: "Serre Chaude",
                status: .germinated,
                sownDate: sownTomato,
                expectedGerminationDate: expTomatoGerm,
                actualGerminationDate: germTomato,
                expectedHarvestDate: expTomatoHarvest,
                wateringIntervalDays: 2,
                lastWateredDate: calendar.date(byAdding: .day, value: -3, to: now)!, // Arrosage nécessaire!
                notes: "Germination réussie, apparition de deux petites cotylédons."
            )
            tomato.logs.append(GardenLog(timestamp: sownTomato, noteText: "Mise en godet dans la serre."))
            tomato.logs.append(GardenLog(timestamp: germTomato, noteText: "Première pousse visible ! Tige fine verte.", heightCm: 1.5))

            // 3. Basilic Grand Vert - En croissance
            let sownBasil = calendar.date(byAdding: .day, value: -25, to: now)!
            let expBasilGerm = calendar.date(byAdding: .day, value: -18, to: now)!
            let basil = Planting(
                customName: "Basilic du Balcon",
                speciesName: "Basilic Grand Vert",
                category: "Herbe",
                bedName: "Jardinière Balcon",
                status: .growing,
                sownDate: sownBasil,
                expectedGerminationDate: expBasilGerm,
                actualGerminationDate: expBasilGerm,
                wateringIntervalDays: 1,
                lastWateredDate: calendar.date(byAdding: .day, value: -1, to: now)!,
                notes: "Feuillage très odorant, 4 vraies feuilles développées."
            )
            basil.logs.append(GardenLog(timestamp: sownBasil, noteText: "Semis en surface."))
            basil.logs.append(GardenLog(timestamp: calendar.date(byAdding: .day, value: -5, to: now)!, noteText: "Repiquage en jardinière individuelle.", heightCm: 8.0))

            context.insert(radish)
            context.insert(tomato)
            context.insert(basil)
        }

        try? context.save()
    }
}
