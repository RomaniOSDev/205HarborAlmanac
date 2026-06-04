import SwiftUI

struct AchievementBadgeCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppGradients.iconBadge : LinearGradient(
                        colors: [Color("AppBackground")],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 56, height: 56)
                Image(systemName: achievement.systemImage)
                    .font(.title2)
                    .foregroundStyle(
                        isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.35)
                    )
                if isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color("AppPrimary"))
                        .offset(x: 22, y: -22)
                }
            }
            Text(achievement.title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(14)
        .frame(minHeight: 160)
        .frame(maxWidth: .infinity)
        .background { AppSurfaceBackground() }
        .overlay {
            if isUnlocked {
                RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous)
                    .strokeBorder(AppGradients.cardBorder, lineWidth: 2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous))
        .appDepthShadow()
        .opacity(isUnlocked ? 1 : 0.82)
    }
}
