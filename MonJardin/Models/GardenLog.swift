import Foundation
import SwiftData

/// Entrée du journal de suivi avec photo et étape de croissance
@Model
public final class GardenLog {
    public var id: UUID
    public var timestamp: Date
    public var stageName: String
    public var noteText: String
    public var photoData: Data?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        stageName: String = "Observation",
        noteText: String = "",
        photoData: Data? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.stageName = stageName
        self.noteText = noteText
        self.photoData = photoData
    }
}
