import SwiftUI

struct HomeHeroBanner: View {
    let greeting: String
    let dateText: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [Color.clear, Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(dateText)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(AppGradients.cardBorder, lineWidth: 1)
        }
        .appElevatedShadow()
    }
}

struct HomeStatWidget: View {
    let icon: String
    let value: String
    let title: String
    let subtitle: String
    var accent: AppCardAccent = .accent
    var elevated: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            IconBadge(systemName: icon, size: 40)
            Text(value)
                .font(.title.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(accent: accent, padding: 14, elevated: elevated)
    }
}

struct HomeImageWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let systemIcon: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(minHeight: 150)
                .clipped()

            LinearGradient(
                colors: [Color.clear, Color("AppBackground").opacity(0.88)],
                startPoint: .center,
                endPoint: .bottom
            )

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: systemIcon)
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent"))
                    .padding(10)
                    .background {
                        Circle().fill(AppGradients.iconBadge)
                    }
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous)
                .strokeBorder(AppGradients.cardBorder, lineWidth: 1)
        }
        .appDepthShadow()
    }
}

struct HomeQuickMoodWidget: View {
    @Binding var selectedMood: String
    let moods: [String]
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Mood", subtitle: "Log how you feel in one tap")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(moods, id: \.self) { mood in
                        MoodEmojiButton(emoji: mood, isSelected: selectedMood == mood) {
                            selectedMood = mood
                        }
                    }
                }
            }
            Button(action: onSave) {
                Label("Save Quick Mood", systemImage: "heart.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .appCard(accent: .primary, elevated: true)
    }
}

struct HomeWideActionWidget: View {
    let icon: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: icon, size: 52, elevated: true)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Button(action: action) {
                    Text(buttonTitle)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .appCard(accent: .accent, elevated: true)
    }
}
