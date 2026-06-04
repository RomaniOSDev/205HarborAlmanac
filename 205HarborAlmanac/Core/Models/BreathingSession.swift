import Foundation

struct BreathingSession: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var patternId: String
    var postSessionMood: String?
    var postSessionRating: Int?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        patternId: String = BreathPattern.fourSevenEight.id,
        postSessionMood: String? = nil,
        postSessionRating: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.patternId = patternId
        self.postSessionMood = postSessionMood
        self.postSessionRating = postSessionRating
    }

    enum CodingKeys: String, CodingKey {
        case id, date, duration, patternId, postSessionMood, postSessionRating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        patternId = try container.decodeIfPresent(String.self, forKey: .patternId) ?? BreathPattern.fourSevenEight.id
        postSessionMood = try container.decodeIfPresent(String.self, forKey: .postSessionMood)
        postSessionRating = try container.decodeIfPresent(Int.self, forKey: .postSessionRating)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(duration, forKey: .duration)
        try container.encode(patternId, forKey: .patternId)
        try container.encodeIfPresent(postSessionMood, forKey: .postSessionMood)
        try container.encodeIfPresent(postSessionRating, forKey: .postSessionRating)
    }
}
