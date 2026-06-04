import Foundation

struct JournalEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var mood: String
    var note: String
    var tags: [String]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: String = "🙂",
        note: String = "",
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.note = note
        self.tags = tags
    }
}
