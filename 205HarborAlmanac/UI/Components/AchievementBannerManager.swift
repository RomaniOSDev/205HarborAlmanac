import Combine
import SwiftUI

@MainActor
final class AchievementBannerManager: ObservableObject {
    @Published var currentBanner: AchievementDefinition?
    private var queue: [AchievementDefinition] = []
    private var isShowing = false

    func enqueue(_ achievements: [AchievementDefinition]) {
        guard !achievements.isEmpty else { return }
        queue.append(contentsOf: achievements)
        showNextIfNeeded()
    }

    private func showNextIfNeeded() {
        guard !isShowing, let next = queue.first else { return }
        queue.removeFirst()
        isShowing = true
        FeedbackService.achievementUnlocked()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentBanner = next
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }
            withAnimation(.easeInOut(duration: 0.3)) { self.currentBanner = nil }
            self.isShowing = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { self.showNextIfNeeded() }
        }
    }
}

struct AchievementBannerView: View {
    let achievement: AchievementDefinition

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: achievement.systemImage, size: 44, elevated: true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background { AppSurfaceBackground(cornerRadius: AppDepth.cornerMedium) }
        .overlay {
            RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous)
                .strokeBorder(AppGradients.cardBorder, lineWidth: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous))
        .appElevatedShadow()
        .padding(.horizontal, 16)
    }
}
