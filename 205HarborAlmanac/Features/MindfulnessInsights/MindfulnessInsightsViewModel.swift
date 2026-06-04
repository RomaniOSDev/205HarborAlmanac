import Combine
import Foundation

@MainActor
final class MindfulnessInsightsViewModel: ObservableObject {
    @Published var selectedIntensity = 3
    @Published var showAddSheet = false
    @Published var highlightNewEntry = false
    @Published var successCheckmark = false

    private let store: AppDataStore
    private let bannerManager: AchievementBannerManager

    init(store: AppDataStore, bannerManager: AchievementBannerManager) {
        self.store = store
        self.bannerManager = bannerManager
    }

    var weeklyCounts: [Int] {
        store.weeklyActivityCounts()
    }

    var streakCount: Int {
        store.streakCount
    }

    var hasActivity: Bool {
        !store.journalEntries.isEmpty || !store.mindfulnessEntries.isEmpty || !store.breathingSessions.isEmpty
    }

    var heatmapDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<35).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }

    func recordMoment() {
        store.addMindfulnessEntry(intensity: selectedIntensity)
        FeedbackService.mediumTap()
        FeedbackService.playSystemSound(1104)
        highlightNewEntry = true
        successCheckmark = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.highlightNewEntry = false
        }
        let unlocked = AchievementEvaluator.newlyUnlocked(store: store)
        bannerManager.enqueue(unlocked)
    }

    func intensity(for day: Date) -> Int {
        store.activityLevel(on: day)
    }
}
