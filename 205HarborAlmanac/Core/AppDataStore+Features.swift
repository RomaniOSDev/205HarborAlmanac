import Foundation

extension AppDataStore {
    static let weeklyGoalTarget = 3

    func makeExportBundle() -> AppExportBundle {
        AppExportBundle(
            version: 1,
            exportedAt: Date(),
            journalEntries: journalEntries,
            breathingSessions: breathingSessions,
            mindfulnessEntries: mindfulnessEntries,
            gratitudeEntries: gratitudeEntries,
            bodyScanSessions: bodyScanSessions,
            streakDays: streakDays,
            totalSessionsCompleted: totalSessionsCompleted,
            totalMinutesUsed: totalMinutesUsed,
            achievementsUnlocked: achievementsUnlocked,
            selectedBreathPatternId: selectedBreathPatternId,
            customBreathPattern: customBreathPattern
        )
    }

    func applyImport(_ bundle: AppExportBundle) {
        journalEntries = bundle.journalEntries
        breathingSessions = bundle.breathingSessions
        mindfulnessEntries = bundle.mindfulnessEntries
        gratitudeEntries = bundle.gratitudeEntries
        bodyScanSessions = bundle.bodyScanSessions
        streakDays = bundle.streakDays
        totalSessionsCompleted = bundle.totalSessionsCompleted
        totalMinutesUsed = bundle.totalMinutesUsed
        achievementsUnlocked = bundle.achievementsUnlocked
        selectedBreathPatternId = bundle.selectedBreathPatternId
        customBreathPattern = bundle.customBreathPattern
        persistAll()
        WidgetSnapshotWriter.sync(from: self)
    }

    func entriesThisWeek(reference: Date = Date()) -> Int {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: reference) else { return 0 }
        return journalEntries.filter { interval.contains($0.date) }.count
    }

    var weeklyGoalProgress: Double {
        min(1, Double(entriesThisWeek()) / Double(Self.weeklyGoalTarget))
    }

    func filteredJournalEntries(
        searchText: String,
        mood: String?,
        tag: String?,
        startDate: Date?,
        endDate: Date?
    ) -> [JournalEntry] {
        journalEntries.filter { entry in
            if let mood, entry.mood != mood { return false }
            if let tag, !entry.tags.contains(tag) { return false }
            if let startDate, entry.date < Calendar.current.startOfDay(for: startDate) { return false }
            if let endDate {
                let end = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: endDate)) ?? endDate
                if entry.date >= end { return false }
            }
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if query.isEmpty { return true }
            return entry.note.lowercased().contains(query)
                || entry.tags.joined(separator: " ").lowercased().contains(query)
        }
    }

    func weeklyMoodAverages(weekCount: Int = 6) -> [(label: String, average: Double)] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return (0..<weekCount).reversed().compactMap { offset -> (String, Double)? in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offset, to: Date()),
                  let interval = calendar.dateInterval(of: .weekOfYear, for: weekStart) else { return nil }
            let weekEntries = journalEntries.filter { interval.contains($0.date) }
            guard let avg = MoodScoreMapper.averageScore(for: weekEntries) else { return nil }
            return (formatter.string(from: interval.start), avg)
        }
    }

    func topTagsThisMonth(limit: Int = 5) -> [(tag: String, count: Int)] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: Date()) else { return [] }
        var counts: [String: Int] = [:]
        for entry in journalEntries where interval.contains(entry.date) {
            for tag in entry.tags {
                counts[tag, default: 0] += 1
            }
        }
        return Array(
            counts
                .map { (tag: $0.key, count: $0.value) }
                .sorted { $0.count > $1.count }
                .prefix(limit)
        )
    }

    func moodComparisonBreathDays() -> (withBreath: Double, withoutBreath: Double)? {
        let calendar = Calendar.current
        var withScores: [Int] = []
        var withoutScores: [Int] = []
        let daysWithJournal = Set(journalEntries.map { calendar.startOfDay(for: $0.date) })
        for day in daysWithJournal {
            let dayEntries = journalEntries.filter { calendar.isDate($0.date, inSameDayAs: day) }
            guard let avg = MoodScoreMapper.averageScore(for: dayEntries) else { continue }
            let hasBreath = breathingSessions.contains { calendar.isDate($0.date, inSameDayAs: day) }
            if hasBreath {
                withScores.append(Int(avg.rounded()))
            } else {
                withoutScores.append(Int(avg.rounded()))
            }
        }
        guard !withScores.isEmpty, !withoutScores.isEmpty else { return nil }
        let withAvg = Double(withScores.reduce(0, +)) / Double(withScores.count)
        let withoutAvg = Double(withoutScores.reduce(0, +)) / Double(withoutScores.count)
        return (withAvg, withoutAvg)
    }

    func saveGratitude(items: [String]) {
        let trimmed = items.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard trimmed.count == 3 else { return }
        let entry = GratitudeEntry(items: trimmed)
        gratitudeEntries.insert(entry, at: 0)
        persistGratitudeEntries()
        recordMeaningfulActivity(on: entry.date)
        WidgetSnapshotWriter.sync(from: self)
    }

    func saveBodyScan(completedSteps: Set<Int>) {
        let entry = BodyScanSession(completedSteps: completedSteps)
        bodyScanSessions.insert(entry, at: 0)
        persistBodyScanSessions()
        if completedSteps.count == BodyScanSession.stepTitles.count {
            recordMeaningfulActivity(on: entry.date)
        }
        WidgetSnapshotWriter.sync(from: self)
    }

    func updateReminderSettings(_ settings: ReminderSettings) {
        reminderSettings = settings
        if let data = try? encoder.encode(settings) {
            defaults.set(data, forKey: Keys.reminderSettings)
        }
        NotificationScheduler.scheduleReminders(settings)
    }

    func setBreathPattern(_ pattern: BreathPattern) {
        selectedBreathPatternId = pattern.id
        defaults.set(pattern.id, forKey: Keys.selectedBreathPatternId)
        if BreathPattern.presets.contains(where: { $0.id == pattern.id }) {
            customBreathPattern = nil
            defaults.removeObject(forKey: Keys.customBreathPattern)
        }
    }

    func setCustomBreathPattern(_ pattern: BreathPattern) {
        customBreathPattern = pattern
        selectedBreathPatternId = pattern.id
        defaults.set(pattern.id, forKey: Keys.selectedBreathPatternId)
        if let data = try? encoder.encode(pattern) {
            defaults.set(data, forKey: Keys.customBreathPattern)
        }
    }

    var activeBreathPattern: BreathPattern {
        if let customBreathPattern, customBreathPattern.id == selectedBreathPatternId {
            return customBreathPattern
        }
        return BreathPattern.presets.first { $0.id == selectedBreathPatternId } ?? .fourSevenEight
    }

    func persistAll() {
        persistJournalEntries()
        persistBreathingSessions()
        persistMindfulnessEntries()
        persistGratitudeEntries()
        persistBodyScanSessions()
        defaults.set(streakDays, forKey: Keys.streakDays)
        defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted)
        defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed)
        persistAchievements()
        WidgetSnapshotWriter.sync(from: self)
    }
}
