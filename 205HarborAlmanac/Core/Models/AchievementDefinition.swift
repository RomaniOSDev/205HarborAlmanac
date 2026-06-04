import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_entry",
            title: "First Entry",
            description: "Created your first journal entry.",
            systemImage: "book.fill"
        ),
        AchievementDefinition(
            id: "daily_commitment",
            title: "Daily Commitment",
            description: "Logged entries for seven consecutive days.",
            systemImage: "calendar"
        ),
        AchievementDefinition(
            id: "mindful_tracker",
            title: "Mindful Tracker",
            description: "Created ten journal entries.",
            systemImage: "heart.text.square.fill"
        ),
        AchievementDefinition(
            id: "insightful_moment",
            title: "Insightful Moment",
            description: "Thirty days of continuous journaling.",
            systemImage: "sparkles"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 journal items.",
            systemImage: "star.fill"
        ),
        AchievementDefinition(
            id: "active_user",
            title: "Active User",
            description: "Completed 10 breathing sessions.",
            systemImage: "wind"
        ),
        AchievementDefinition(
            id: "dedicated_user",
            title: "Dedicated User",
            description: "Completed 50 breathing sessions.",
            systemImage: "leaf.fill"
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            systemImage: "flame.fill"
        )
    ]
}
