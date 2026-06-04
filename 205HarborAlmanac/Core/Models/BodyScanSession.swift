import Foundation

struct BodyScanSession: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var completedSteps: Set<Int>

    init(id: UUID = UUID(), date: Date = Date(), completedSteps: Set<Int> = []) {
        self.id = id
        self.date = date
        self.completedSteps = completedSteps
    }

    static let stepTitles: [String] = [
        "Feet and legs",
        "Hips and lower back",
        "Belly and chest",
        "Hands and arms",
        "Shoulders and neck",
        "Face and jaw",
        "Breath awareness",
        "Whole body calm"
    ]
}
