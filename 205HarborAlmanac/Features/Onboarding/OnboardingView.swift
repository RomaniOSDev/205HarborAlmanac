import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var pageIndex = 0
    @State private var illustrationScale: CGFloat = 0.88
    @State private var illustrationOpacity: Double = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.fill",
            headline: "Welcome To Calm",
            description: "Track your daily mood and thoughts for improved self-awareness.",
            accent: .primary
        ),
        OnboardingPage(
            icon: "square.and.pencil",
            headline: "Capture Your Thoughts",
            description: "Tap the plus button to add a new journal entry or mood log.",
            accent: .accent
        ),
        OnboardingPage(
            icon: "sparkles",
            headline: "Begin Your Journey",
            description: "Start today by creating your first entry.",
            accent: .primary
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                onboardingHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                pageIndicator
                    .padding(.top, 8)

                footerActions
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
            }
        }
        .onAppear { animateIllustration() }
        .onChange(of: pageIndex) { _ in
            illustrationScale = 0.88
            illustrationOpacity = 0
            animateIllustration()
        }
    }

    private var onboardingHeader: some View {
        HStack {
            IconBadge(systemName: pages[pageIndex].icon, size: 40, elevated: true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Getting Started")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text("Step \(pageIndex + 1) of \(pages.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
            if pageIndex < pages.count - 1 {
                Button("Skip") { skipOnboarding() }
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(14)
        .background { AppSurfaceBackground(cornerRadius: AppDepth.cornerLarge) }
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous))
        .appDepthShadow()
    }

    @ViewBuilder
    private func onboardingPage(page: OnboardingPage, index: Int) -> some View {
        VStack(spacing: 22) {
            OnboardingIllustrationFrame {
                illustration(for: index)
                    .scaleEffect(illustrationScale)
                    .opacity(illustrationOpacity)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 12) {
                Text(page.headline)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .multilineTextAlignment(.center)
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .appCard(accent: page.accent, elevated: true)
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index == pageIndex
                            ? AnyShapeStyle(AppGradients.progressFill)
                            : AnyShapeStyle(Color("AppSurface"))
                    )
                    .frame(width: index == pageIndex ? 28 : 8, height: 8)
                    .overlay {
                        if index != pageIndex {
                            Capsule()
                                .strokeBorder(Color("AppAccent").opacity(0.2), lineWidth: 1)
                        }
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: pageIndex)
            }
        }
    }

    private var footerActions: some View {
        VStack(spacing: 12) {
            Button(action: advance) {
                Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            if pageIndex > 0 {
                Button("Back") {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        pageIndex -= 1
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }

    @ViewBuilder
    private func illustration(for index: Int) -> some View {
        switch index {
        case 0: OnboardingCalmIllustration()
        case 1: OnboardingJournalIllustration()
        default: OnboardingJourneyIllustration()
        }
    }

    private func animateIllustration() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            illustrationScale = 1
            illustrationOpacity = 1
        }
    }

    private func advance() {
        FeedbackService.lightTap()
        if pageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                pageIndex += 1
            }
        } else {
            finishOnboarding()
        }
    }

    private func skipOnboarding() {
        FeedbackService.lightTap()
        finishOnboarding()
    }

    private func finishOnboarding() {
        FeedbackService.mediumTap()
        store.completeOnboarding()
    }
}

private struct OnboardingPage {
    let icon: String
    let headline: String
    let description: String
    let accent: AppCardAccent
}

private struct OnboardingIllustrationFrame<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AppSurfaceBackground(cornerRadius: AppDepth.cornerLarge, showTopGlow: true)
            content
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDepth.cornerLarge, style: .continuous)
                .strokeBorder(AppGradients.cardBorder, lineWidth: 1)
        }
        .appElevatedShadow()
    }
}

private struct OnboardingCalmIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppAccent").opacity(0.25), lineWidth: 2)
                .frame(width: 160, height: 160)
            Circle()
                .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 2)
                .frame(width: 120, height: 120)

            ZStack {
                Circle()
                    .fill(AppGradients.iconBadge)
                    .frame(width: 88, height: 88)
                    .overlay {
                        Circle()
                            .strokeBorder(Color("AppAccent").opacity(0.4), lineWidth: 1)
                    }
                Image(systemName: "wind")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color("AppAccent"))
            }

            Path { path in
                path.move(to: CGPoint(x: 36, y: 108))
                path.addQuadCurve(to: CGPoint(x: 124, y: 108), control: CGPoint(x: 80, y: 58))
            }
            .stroke(
                LinearGradient(
                    colors: [Color("AppPrimary"), Color("AppAccent")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 160, height: 120)
            .offset(y: 28)
        }
    }
}

private struct OnboardingJournalIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppGradients.cardSurface)
                .frame(width: 110, height: 140)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(AppGradients.cardBorder, lineWidth: 1)
                }
                .appDepthShadow(radius: 6, y: 3, opacity: 0.4)

            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("AppPrimary").opacity(0.5))
                    .frame(width: 64, height: 6)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("AppTextSecondary").opacity(0.35))
                    .frame(width: 72, height: 6)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("AppTextSecondary").opacity(0.25))
                    .frame(width: 56, height: 6)
            }
            .offset(x: -8, y: -12)

            ZStack {
                Circle()
                    .fill(AppGradients.primaryButton)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle()
                            .strokeBorder(Color("AppTextPrimary").opacity(0.15), lineWidth: 1)
                    }
                    .appDepthShadow(radius: 5, y: 3, opacity: 0.35)
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .offset(x: 52, y: 48)
        }
    }
}

private struct OnboardingJourneyIllustration: View {
    var body: some View {
        ZStack {
            journeyPath
                .stroke(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 180, height: 130)

            Circle()
                .fill(AppGradients.primaryButton)
                .frame(width: 18, height: 18)
                .overlay {
                    Circle()
                        .strokeBorder(Color("AppTextPrimary").opacity(0.2), lineWidth: 1)
                }
                .offset(x: 62, y: -42)

            IconBadge(systemName: "flag.checkered", size: 44, elevated: true)
                .offset(x: -58, y: 48)
        }
    }

    private var journeyPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 24, y: 100))
            path.addCurve(
                to: CGPoint(x: 156, y: 36),
                control1: CGPoint(x: 56, y: 24),
                control2: CGPoint(x: 108, y: 108)
            )
        }
    }
}
