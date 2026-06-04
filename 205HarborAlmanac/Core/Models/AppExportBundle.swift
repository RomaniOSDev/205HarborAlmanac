import Foundation

struct AppExportBundle: Codable {
    let version: Int
    let exportedAt: Date
    let journalEntries: [JournalEntry]
    let breathingSessions: [BreathingSession]
    let mindfulnessEntries: [MindfulnessEntry]
    let gratitudeEntries: [GratitudeEntry]
    let bodyScanSessions: [BodyScanSession]
    let streakDays: Int
    let totalSessionsCompleted: Int
    let totalMinutesUsed: Int
    let achievementsUnlocked: [String: Date]
    let selectedBreathPatternId: String
    let customBreathPattern: BreathPattern?
}
