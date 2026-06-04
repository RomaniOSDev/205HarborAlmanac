import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 48)
            .background(AppGradients.primaryButton)
            .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous)
                    .strokeBorder(Color("AppTextPrimary").opacity(0.12), lineWidth: 1)
            }
            .appDepthShadow(
                radius: configuration.isPressed ? 4 : 8,
                y: configuration.isPressed ? 2 : 4,
                opacity: configuration.isPressed ? 0.2 : 0.4
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackService.lightTap() }
            }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(Color("AppAccent"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                AppSurfaceBackground(cornerRadius: AppDepth.cornerSmall, showTopGlow: false)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerSmall, style: .continuous))
            .appDepthShadow(radius: 4, y: 2, opacity: 0.3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
