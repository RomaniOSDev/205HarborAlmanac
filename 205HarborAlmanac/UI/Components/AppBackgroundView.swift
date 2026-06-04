import SwiftUI

/// Lightweight background: gradients only (no Canvas loop). Safe for scroll-heavy screens.
struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            AppGradients.screenBackground

            // Static top glow — one radial layer, not redrawn per cell
            RadialGradient(
                colors: [
                    Color("AppPrimary").opacity(0.12),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 280
            )

            RadialGradient(
                colors: [
                    Color("AppAccent").opacity(0.08),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 220
            )
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
