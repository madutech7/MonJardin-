import SwiftUI
import SwiftData

public struct PhotoGalleryView: View {
    @Query(sort: \GardenLog.timestamp, order: .reverse) private var logs: [GardenLog]

    private var logsWithPhotos: [GardenLog] {
        logs.filter { $0.photoData != nil }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter
    }

    public var body: some View {
        NavigationStack {
            Group {
                if logsWithPhotos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("Aucune photo pour le moment")
                            .font(.headline)
                        Text("Ajoutez des photos lors de la création d'un semis ou dans le suivi de croissance pour alimenter votre galerie.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 14)], spacing: 14) {
                            ForEach(logsWithPhotos) { log in
                                VStack(alignment: .leading, spacing: 8) {
                                    if let photoData = log.photoData, let uiImage = UIImage(data: photoData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 140)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.stageName)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                                        Text(dateFormatter.string(from: log.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 4)
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Galerie de Croissance")
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}
