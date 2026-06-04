import Foundation

struct GratitudeEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var items: [String]

    init(id: UUID = UUID(), date: Date = Date(), items: [String] = ["", "", ""]) {
        self.id = id
        self.date = date
        self.items = items
    }
}
