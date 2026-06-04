import Combine
import Foundation

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    enum Keys {
        static let hasSeenOnboarding = "hg_hasSeenOnboarding"
        static let totalSessionsCompleted = "hg_totalSessionsCompleted"
        static let totalMinutesUsed = "hg_totalMinutesUsed"
        static let streakDays = "hg_streakDays"
        static let longestStreak = "hg_longestStreak"
        static let lastActivityDate = "hg_lastActivityDate"
        static let achievementsUnlocked = "hg_achievementsUnlocked"
        static let journalEntries = "hg_journalEntries"
        static let lastViewedDate = "hg_lastViewedDate"
        static let breathingSessions = "hg_breathingSessions"
        static let lastSessionTimestamp = "hg_lastSessionTimestamp"
        static let mindfulnessEntries = "hg_mindfulnessEntries"
        static let streakCount = "hg_streakCount"
        static let lastEntryDate = "hg_lastEntryDate"
        static let gratitudeEntries = "hg_gratitudeEntries"
        static let bodyScanSessions = "hg_bodyScanSessions"
        static let reminderSettings = "hg_reminderSettings"
        static let selectedBreathPatternId = "hg_selectedBreathPatternId"
        static let customBreathPattern = "hg_customBreathPattern"
    }

    let defaults: UserDefaults
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool
    @Published var totalSessionsCompleted: Int
    @Published var totalMinutesUsed: Int
    @Published var streakDays: Int
    @Published var longestStreak: Int
    @Published var lastActivityDate: Date?
    @Published var achievementsUnlocked: [String: Date]
    @Published var journalEntries: [JournalEntry]
    @Published var lastViewedDate: Date
    @Published var breathingSessions: [BreathingSession]
    @Published var lastSessionTimestamp: Date?
    @Published var mindfulnessEntries: [MindfulnessEntry]
    @Published var streakCount: Int
    @Published var lastEntryDate: Date?
    @Published var gratitudeEntries: [GratitudeEntry]
    @Published var bodyScanSessions: [BodyScanSession]
    @Published var reminderSettings: ReminderSettings
    @Published var selectedBreathPatternId: String
    @Published var customBreathPattern: BreathPattern?

    var entriesCreated: Int { journalEntries.count }
    var sessionsCompleted: Int { totalSessionsCompleted }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        lastActivityDate = Self.decodeDate(defaults, key: Keys.lastActivityDate)
        achievementsUnlocked = Self.decodeDictionary(defaults.data(forKey: Keys.achievementsUnlocked), decoder: JSONDecoder()) ?? [:]
        journalEntries = Self.decode(defaults.data(forKey: Keys.journalEntries), as: [JournalEntry].self) ?? []
        lastViewedDate = Self.decodeDate(defaults, key: Keys.lastViewedDate) ?? Calendar.current.startOfDay(for: Date())
        breathingSessions = Self.decode(defaults.data(forKey: Keys.breathingSessions), as: [BreathingSession].self) ?? []
        lastSessionTimestamp = Self.decodeDate(defaults, key: Keys.lastSessionTimestamp)
        mindfulnessEntries = Self.decode(defaults.data(forKey: Keys.mindfulnessEntries), as: [MindfulnessEntry].self) ?? []
        streakCount = defaults.integer(forKey: Keys.streakCount)
        lastEntryDate = Self.decodeDate(defaults, key: Keys.lastEntryDate)
        gratitudeEntries = Self.decode(defaults.data(forKey: Keys.gratitudeEntries), as: [GratitudeEntry].self) ?? []
        bodyScanSessions = Self.decode(defaults.data(forKey: Keys.bodyScanSessions), as: [BodyScanSession].self) ?? []
        reminderSettings = Self.decode(defaults.data(forKey: Keys.reminderSettings), as: ReminderSettings.self) ?? .default
        selectedBreathPatternId = defaults.string(forKey: Keys.selectedBreathPatternId) ?? BreathPattern.fourSevenEight.id
        customBreathPattern = Self.decode(defaults.data(forKey: Keys.customBreathPattern), as: BreathPattern.self)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
        WidgetSnapshotWriter.sync(from: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
    }

    func persistAchievements() {
        if let data = try? encoder.encode(achievementsUnlocked) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    func saveJournalEntry(_ entry: JournalEntry, isNew: Bool) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
        } else {
            journalEntries.insert(entry, at: 0)
        }
        journalEntries.sort { $0.date > $1.date }
        persistJournalEntries()
        if isNew {
            recordMeaningfulActivity(on: entry.date)
            updateMindfulnessStreak(on: entry.date)
        }
        syncMindfulnessFromJournal()
        WidgetSnapshotWriter.sync(from: self)
    }

    func deleteJournalEntry(id: UUID) {
        journalEntries.removeAll { $0.id == id }
        persistJournalEntries()
        syncMindfulnessFromJournal()
        WidgetSnapshotWriter.sync(from: self)
    }

    func entries(for day: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return journalEntries
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date > $1.date }
    }

    func setLastViewedDate(_ date: Date) {
        lastViewedDate = date
        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastViewedDate)
    }

    func addBreathingSession(
        duration: TimeInterval,
        patternId: String,
        postSessionMood: String?,
        postSessionRating: Int?
    ) {
        let session = BreathingSession(
            duration: duration,
            patternId: patternId,
            postSessionMood: postSessionMood,
            postSessionRating: postSessionRating
        )
        breathingSessions.insert(session, at: 0)
        totalSessionsCompleted += 1
        totalMinutesUsed += max(1, Int(duration / 60))
        lastSessionTimestamp = session.date
        defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted)
        defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed)
        defaults.set(session.date.timeIntervalSince1970, forKey: Keys.lastSessionTimestamp)
        persistBreathingSessions()
        recordMeaningfulActivity(on: session.date)
        WidgetSnapshotWriter.sync(from: self)
    }

    func addMindfulnessEntry(intensity: Int, date: Date = Date()) {
        let entry = MindfulnessEntry(date: date, intensity: intensity)
        mindfulnessEntries.insert(entry, at: 0)
        persistMindfulnessEntries()
        lastEntryDate = date
        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastEntryDate)
        updateMindfulnessStreak(on: date)
        recordMeaningfulActivity(on: date)
        WidgetSnapshotWriter.sync(from: self)
    }

    func activityLevel(on day: Date) -> Int {
        let calendar = Calendar.current
        var score = 0
        if journalEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) { score += 2 }
        if breathingSessions.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) { score += 2 }
        if mindfulnessEntries.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) { score += 1 }
        return min(4, score)
    }

    func weeklyActivityCounts(endingOn endDate: Date = Date()) -> [Int] {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: endDate)
        return (0..<7).reversed().map { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: end) else { return 0 }
            return activityLevel(on: day)
        }
    }

    func resetAllData() {
        let keys = [
            Keys.hasSeenOnboarding,
            Keys.totalSessionsCompleted,
            Keys.totalMinutesUsed,
            Keys.streakDays,
            Keys.longestStreak,
            Keys.lastActivityDate,
            Keys.achievementsUnlocked,
            Keys.journalEntries,
            Keys.lastViewedDate,
            Keys.breathingSessions,
            Keys.lastSessionTimestamp,
            Keys.mindfulnessEntries,
            Keys.streakCount,
            Keys.lastEntryDate,
            Keys.gratitudeEntries,
            Keys.bodyScanSessions,
            Keys.reminderSettings,
            Keys.selectedBreathPatternId,
            Keys.customBreathPattern
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        NotificationScheduler.scheduleReminders(.default)
        reloadFromDefaults()
        WidgetSnapshotWriter.sync(from: self)
    }

    @objc private func handleDataReset() {
        reloadFromDefaults()
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        longestStreak = defaults.integer(forKey: Keys.longestStreak)
        lastActivityDate = Self.decodeDate(defaults, key: Keys.lastActivityDate)
        achievementsUnlocked = Self.decodeDictionary(defaults.data(forKey: Keys.achievementsUnlocked), decoder: decoder) ?? [:]
        journalEntries = Self.decode(defaults.data(forKey: Keys.journalEntries), as: [JournalEntry].self) ?? []
        lastViewedDate = Self.decodeDate(defaults, key: Keys.lastViewedDate) ?? Calendar.current.startOfDay(for: Date())
        breathingSessions = Self.decode(defaults.data(forKey: Keys.breathingSessions), as: [BreathingSession].self) ?? []
        lastSessionTimestamp = Self.decodeDate(defaults, key: Keys.lastSessionTimestamp)
        mindfulnessEntries = Self.decode(defaults.data(forKey: Keys.mindfulnessEntries), as: [MindfulnessEntry].self) ?? []
        streakCount = defaults.integer(forKey: Keys.streakCount)
        lastEntryDate = Self.decodeDate(defaults, key: Keys.lastEntryDate)
        gratitudeEntries = Self.decode(defaults.data(forKey: Keys.gratitudeEntries), as: [GratitudeEntry].self) ?? []
        bodyScanSessions = Self.decode(defaults.data(forKey: Keys.bodyScanSessions), as: [BodyScanSession].self) ?? []
        reminderSettings = Self.decode(defaults.data(forKey: Keys.reminderSettings), as: ReminderSettings.self) ?? .default
        selectedBreathPatternId = defaults.string(forKey: Keys.selectedBreathPatternId) ?? BreathPattern.fourSevenEight.id
        customBreathPattern = Self.decode(defaults.data(forKey: Keys.customBreathPattern), as: BreathPattern.self)
    }

    func recordMeaningfulActivity(on date: Date) {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(day, inSameDayAs: lastDay) { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        longestStreak = max(longestStreak, streakDays)
        lastActivityDate = day
        defaults.set(streakDays, forKey: Keys.streakDays)
        defaults.set(longestStreak, forKey: Keys.longestStreak)
        defaults.set(day.timeIntervalSince1970, forKey: Keys.lastActivityDate)
        WidgetSnapshotWriter.sync(from: self)
    }

    private func updateMindfulnessStreak(on date: Date) {
        let calendar = Calendar.current
        let day = calendar.startOfDay(for: date)
        if let last = lastEntryDate {
            let lastDay = calendar.startOfDay(for: last)
            if calendar.isDate(day, inSameDayAs: lastDay) { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
               calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streakCount += 1
            } else {
                streakCount = 1
            }
        } else {
            streakCount = 1
        }
        lastEntryDate = day
        defaults.set(streakCount, forKey: Keys.streakCount)
        defaults.set(day.timeIntervalSince1970, forKey: Keys.lastEntryDate)
    }

    private func syncMindfulnessFromJournal() {
        let calendar = Calendar.current
        var derived = mindfulnessEntries.filter { entry in
            !journalEntries.contains { calendar.isDate($0.date, inSameDayAs: entry.date) }
        }
        for journal in journalEntries {
            let intensity = min(5, max(1, journal.note.count / 40 + 1))
            if let idx = derived.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: journal.date) }) {
                derived[idx] = MindfulnessEntry(id: derived[idx].id, date: journal.date, intensity: intensity)
            } else {
                derived.append(MindfulnessEntry(date: journal.date, intensity: intensity))
            }
        }
        mindfulnessEntries = derived.sorted { $0.date > $1.date }
        persistMindfulnessEntries()
    }

    func persistJournalEntries() {
        if let data = try? encoder.encode(journalEntries) {
            defaults.set(data, forKey: Keys.journalEntries)
        }
    }

    func persistBreathingSessions() {
        if let data = try? encoder.encode(breathingSessions) {
            defaults.set(data, forKey: Keys.breathingSessions)
        }
    }

    func persistMindfulnessEntries() {
        if let data = try? encoder.encode(mindfulnessEntries) {
            defaults.set(data, forKey: Keys.mindfulnessEntries)
        }
    }

    func persistGratitudeEntries() {
        if let data = try? encoder.encode(gratitudeEntries) {
            defaults.set(data, forKey: Keys.gratitudeEntries)
        }
    }

    func persistBodyScanSessions() {
        if let data = try? encoder.encode(bodyScanSessions) {
            defaults.set(data, forKey: Keys.bodyScanSessions)
        }
    }

    private static func decode<T: Decodable>(_ data: Data?, as type: T.Type) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private static func decodeDictionary(_ data: Data?, decoder: JSONDecoder) -> [String: Date]? {
        guard let data else { return nil }
        return try? decoder.decode([String: Date].self, from: data)
    }

    private static func decodeDate(_ defaults: UserDefaults, key: String) -> Date? {
        guard let interval = defaults.object(forKey: key) as? TimeInterval else { return nil }
        return Date(timeIntervalSince1970: interval)
    }
}
