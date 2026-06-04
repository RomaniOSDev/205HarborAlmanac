import Foundation
import WidgetKit

enum WidgetSnapshotWriter {
    enum Keys {
        static let streakDays = "wg_streakDays"
        static let entriesThisWeek = "wg_entriesThisWeek"
        static let weeklyGoalProgress = "wg_weeklyGoalProgress"
        static let lastMood = "wg_lastMood"
    }

    static func sync(from store: AppDataStore) {
        let defaults = UserDefaults.standard
        defaults.set(store.streakDays, forKey: Keys.streakDays)
        defaults.set(store.entriesThisWeek(), forKey: Keys.entriesThisWeek)
        defaults.set(store.weeklyGoalProgress, forKey: Keys.weeklyGoalProgress)
        if let mood = store.journalEntries.first?.mood {
            defaults.set(mood, forKey: Keys.lastMood)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
