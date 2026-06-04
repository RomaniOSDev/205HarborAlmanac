import Foundation

enum AchievementEvaluator {
    static func newlyUnlocked(store: AppDataStore) -> [AchievementDefinition] {
        let now = Date()
        var unlocked: [AchievementDefinition] = []

        for achievement in AchievementDefinition.all {
            guard store.achievementsUnlocked[achievement.id] == nil else { continue }
            guard isConditionMet(achievement.id, store: store) else { continue }
            var updated = store.achievementsUnlocked
            updated[achievement.id] = now
            store.achievementsUnlocked = updated
            unlocked.append(achievement)
        }

        if !unlocked.isEmpty {
            store.persistAchievements()
        }

        return unlocked
    }

    static func isUnlockedOrEarned(_ id: String, store: AppDataStore) -> Bool {
        store.achievementsUnlocked[id] != nil || isConditionMet(id, store: store)
    }

    static func isConditionMet(_ id: String, store: AppDataStore) -> Bool {
        switch id {
        case "first_entry":
            return store.entriesCreated >= 1
        case "daily_commitment":
            return store.streakDays >= 7
        case "mindful_tracker":
            return store.entriesCreated >= 10
        case "insightful_moment":
            return store.longestStreak >= 30
        case "power_user":
            return store.entriesCreated >= 50
        case "active_user":
            return store.sessionsCompleted >= 10
        case "dedicated_user":
            return store.sessionsCompleted >= 50
        case "three_day_streak":
            return store.streakDays >= 3
        default:
            return false
        }
    }
}
