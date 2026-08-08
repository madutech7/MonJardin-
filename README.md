# Mon Jardin 🌿 - Application iOS Native SwiftUI & SwiftData

**Mon Jardin** est une application iOS moderne et haute performance conçue en **Swift 6** et **SwiftUI** selon les directives Apple Human Interface Guidelines (HIG). 

Elle répond parfaitement aux problématiques de suivi de potager et de plantation :
- 📅 **Suivi précis des dates de semis** (*date de semis*, calcul du délai de germination et compte à rebours interactif).
- 🌱 **Indicateur de progression de germination** : Jauge visuelle avec estimation automatique selon l'espèce (radis, tomates, basilic, carottes, etc.).
- 💧 **Gestion des arrosages** : Suivi des fréquences et rappels quotidiens avec action d'arrosage en 1 tap.
- 📸 **Journal de croissance & Photos** : Carnet de bord pour capturer des photos chronologiques, enregistrer la taille des plantes et ajouter des remarques.
- 📚 **Catalogue interactif d'espèces** : Fiches de culture pré-remplies avec conseils d'ensoleillement, périodes de semis et délais de récolte.

---

## 📱 Aperçu des Fonctionnalités

### 1. Tableau de bord (`DashboardView.swift`)
- Statistiques en temps réel (plantations actives, semis en germination, arrosages du jour).
- Carousel de suivi de germination avec jauges de progression circulaire.
- Liste des derniers semis enregistrés avec raccourci d'arrosage.

### 2. Mon Jardin (`GardenView.swift` & `PlantingDetailView.swift`)
- Liste et grille filtrables par état : *Semé*, *Germé*, *En croissance*, *En récolte*.
- Recherche instantanée par nom ou emplacement (*Potager Sud, Serre, Balcon*).
- Fiche détaillée pour chaque plante avec bouton d'avancement d'état (*Germé !*), tableau de bord des dates et journal de photos/notes.

### 3. Catalogue d'espèces (`PlantCatalogView.swift`)
- Encyclopédie des plantes du jardin avec filtres par catégorie (Légume, Herbe, Fruit, Fleur).
- Bouton d'action directe *"Semer cette espèce"* pré-remplissant automatiquement les durées de germination dans le formulaire.

### 4. Arrosage & Soins (`CareView.swift`)
- Dashboard dédié aux besoins en eau.
- Bouton *"Tout Arroser"* pour valider l'arrosage de l'ensemble des plantes assoiffées du jour.

---

## 🛠️ Architecture du Projet

```text
MonJardin/
├── MonJardinApp.swift           # Point d'entrée principal avec conteneur SwiftData
├── Info.plist                   # Permissions iOS (Appareil photo, Galerie)
├── Models/
│   ├── Planting.swift           # Modèle SwiftData principal pour une plantation
│   ├── PlantSpecies.swift       # Catalogue des espèces et durées de germination
│   ├── GardenLog.swift          # Journal de bord (photos, notes, hauteur)
│   └── SampleData.swift         # Données de démonstration réalistes au démarrage
├── Views/
│   ├── MainTabView.swift        # Barre de navigation à 4 onglets
│   ├── Dashboard/
│   │   └── DashboardView.swift  # Vue d'ensemble & jauges de germination
│   ├── Garden/
│   │   ├── GardenView.swift     # Liste filtrable et recherche
│   │   ├── PlantingDetailView.swift # Fiche détaillée & journal
│   │   └── AddPlantingView.swift # Formulaire de création de nouveau semis
│   ├── Catalog/
│   │   └── PlantCatalogView.swift # Encyclopédie des plantes
│   ├── Care/
│   │   └── CareView.swift       # Calendrier et planification d'arrosage
│   └── Components/              # Composants UI réutilisables (Jauges, Badges, Cartes)
├── MonJardin.xcodeproj/         # Fichier projet Xcode 15/16 prêt à l'emploi
└── codemagic.yaml               # Pipeline de compilation CI/CD Codemagic
```

---

## 🚀 Compilation & Déploiement

### Dans Xcode
1. Ouvrez `MonJardin.xcodeproj` dans Xcode (version 15.0 ou plus récente).
2. Sélectionnez un simulateur iOS (iPhone 15/16 Pro) ou votre appareil.
3. Appuyez sur `Cmd + R` pour lancer l'application.

### Sur Codemagic (CI/CD)
Un fichier `codemagic.yaml` est inclus à la racine du dépôt pour automatiser les builds et générer les exécutables `.ipa` dès que vous poussez le code sur GitHub :
1. Créez votre dépôt sur GitHub et poussez le code (`git push origin main`).
2. Connectez le dépôt dans Codemagic.
3. Lancez le workflow `ios-swiftui-workflow`. Codemagic compilera automatiquement le projet Xcode !

---

*Développé avec soin selon les standards Apple HIG.* 🌿
