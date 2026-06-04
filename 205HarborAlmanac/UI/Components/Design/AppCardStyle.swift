import SwiftUI

enum AppCardAccent {
    case none
    case primary
    case accent
}

struct AppCardModifier: ViewModifier {
    var accent: AppCardAccent = .none
    var padding: CGFloat = 16
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                AppSurfaceBackground(cornerRadius: AppDepth.cornerLarge)
            }
            .overlay(alignment: .leading) {
                AppAccentStripe(accent: accent)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous))
            .modifier(ElevatedShadowModifier(elevated: elevated))
    }
}

private struct ElevatedShadowModifier: ViewModifier {
    let elevated: Bool

    func body(content: Content) -> some View {
        if elevated {
            content.appElevatedShadow()
        } else {
            content.appDepthShadow()
        }
    }
}

extension View {
    func appCard(accent: AppCardAccent = .none, padding: CGFloat = 16, elevated: Bool = false) -> some View {
        modifier(AppCardModifier(accent: accent, padding: padding, elevated: elevated))
    }

    func surfaceCard() -> some View {
        appCard()
    }
}

struct IconBadge: View {
    let systemName: String
    var size: CGFloat = 44
    var filled: Bool = true
    /// Standalone badges can cast a light shadow; inside cards leave false to avoid double shading.
    var elevated: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(filled ? AppGradients.iconBadge : LinearGradient(
                    colors: [Color("AppBackground").opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: size, height: size)
                .overlay {
                    Circle()
                        .strokeBorder(Color("AppAccent").opacity(filled ? 0.35 : 0.15), lineWidth: 1)
                }
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(filled ? Color("AppAccent") : Color("AppTextSecondary"))
        }
        .modifier(IconBadgeShadowModifier(elevated: elevated))
    }
}

private struct IconBadgeShadowModifier: ViewModifier {
    let elevated: Bool

    func body(content: Content) -> some View {
        if elevated {
            content.appDepthShadow(radius: 4, y: 2, opacity: 0.35)
        } else {
            content
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: {
                    FeedbackService.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
    }
}
