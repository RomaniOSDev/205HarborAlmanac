import Foundation

struct MindfulnessEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var intensity: Int

    init(id: UUID = UUID(), date: Date = Date(), intensity: Int = 3) {
        self.id = id
        self.date = date
        self.intensity = min(5, max(1, intensity))
    }
}
