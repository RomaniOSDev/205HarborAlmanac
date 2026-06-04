import SwiftUI

/// Centralized visuals — single shadow pass, static gradients, no per-frame Canvas on scroll content.
enum AppDepth {
    static let cornerLarge: CGFloat = 18
    static let cornerMedium: CGFloat = 14
    static let cornerSmall: CGFloat = 12

    static func shadowColor(opacity: Double = 0.5) -> Color {
        Color("AppBackground").opacity(opacity)
    }
}

enum AppGradients {
    static var screenBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground"),
                Color("AppSurface").opacity(0.38),
                Color("AppBackground")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var cardSurface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(0.98),
                Color("AppSurface")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var cardTopGlow: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.14),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var cardBorder: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.35),
                Color("AppPrimary").opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var iconBadge: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppPrimary").opacity(0.35),
                Color("AppAccent").opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var progressFill: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var tabBarActive: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// One composited shadow — cheaper than shadow on nested backgrounds.
    func appDepthShadow(radius: CGFloat = 6, y: CGFloat = 3, opacity: Double = 0.5) -> some View {
        compositingGroup()
            .shadow(color: AppDepth.shadowColor(opacity: opacity), radius: radius, x: 0, y: y)
    }

    func appElevatedShadow() -> some View {
        appDepthShadow(radius: 10, y: 5, opacity: 0.55)
    }
}

struct AppSurfaceBackground: View {
    var cornerRadius: CGFloat = AppDepth.cornerLarge
    var showTopGlow: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppGradients.cardSurface)
            .overlay {
                if showTopGlow {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppGradients.cardTopGlow)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(AppGradients.cardBorder, lineWidth: 1)
            }
    }
}

struct AppAccentStripe: View {
    var accent: AppCardAccent

    var body: some View {
        if accent != .none {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(accent == .primary ? Color("AppPrimary") : Color("AppAccent"))
                .frame(width: 4)
                .padding(.vertical, 12)
                .padding(.leading, 4)
        }
    }
}
