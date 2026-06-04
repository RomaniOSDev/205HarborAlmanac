import Foundation

enum MoodScoreMapper {
    private static let scores: [String: Int] = [
        "😄": 5, "🙂": 4, "😐": 3, "😔": 2, "😢": 1,
        "😌": 4, "🤔": 3, "😴": 3, "😡": 2, "🥰": 5
    ]

    static func score(for mood: String) -> Int {
        scores[mood] ?? 3
    }

    static func averageScore(for entries: [JournalEntry]) -> Double? {
        guard !entries.isEmpty else { return nil }
        let total = entries.reduce(0) { $0 + score(for: $1.mood) }
        return Double(total) / Double(entries.count)
    }
}
