import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        summarySection
                        SectionHeaderView(
                            title: "Badges",
                            subtitle: "\(unlockedCount) of \(AchievementDefinition.all.count) unlocked"
                        )
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(AchievementDefinition.all) { achievement in
                                AchievementBadgeCell(
                                    achievement: achievement,
                                    isUnlocked: AchievementEvaluator.isUnlockedOrEarned(achievement.id, store: store)
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var unlockedCount: Int {
        AchievementDefinition.all.filter {
            AchievementEvaluator.isUnlockedOrEarned($0.id, store: store)
        }.count
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: "Your Progress", subtitle: "Real actions, no game points")
            MetricsGridRow(tiles: [
                ("book.fill", "Entries", "\(store.entriesCreated)"),
                ("wind", "Sessions", "\(store.sessionsCompleted)")
            ])
            MetricsGridRow(tiles: [
                ("flame.fill", "Streak", "\(store.streakDays)d"),
                ("clock.fill", "Minutes", "\(store.totalMinutesUsed)")
            ])
        }
    }
}
