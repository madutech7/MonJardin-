import Foundation
import SwiftData

/// Journal d'observation pour consigner la croissance, des notes et des photos
@Model
public final class GardenLog {
    public var id: UUID
    public var timestamp: Date
    public var noteText: String
    public var photoData: Data?
    public var heightCm: Double?

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        noteText: String,
        photoData: Data? = nil,
        heightCm: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.noteText = noteText
        self.photoData = photoData
        self.heightCm = heightCm
    }
}
