import SwiftUI

struct EmptyStateCell: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppGradients.iconBadge)
                    .frame(width: 88, height: 88)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color("AppAccent"))
            }
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(message)
                .font(.body)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
            if let buttonTitle, let action {
                Button(action: action) {
                    Text(buttonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .appCard(elevated: true)
    }
}

struct InsightSectionCard<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeaderView(title: title, subtitle: subtitle)
            content
        }
        .appCard(accent: .primary, elevated: true)
    }
}

struct ChecklistStepCell: View {
    let index: Int
    let title: String
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.4), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                    } else {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
            }
            .padding(14)
            .background { AppSurfaceBackground(cornerRadius: AppDepth.cornerMedium, showTopGlow: isCompleted) }
            .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous))
            .overlay {
                if isCompleted {
                    RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous)
                        .strokeBorder(Color("AppAccent").opacity(0.45), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 58, height: 58)
                .background(AppGradients.primaryButton)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(Color("AppTextPrimary").opacity(0.15), lineWidth: 1)
                }
                .appElevatedShadow()
        }
        .buttonStyle(.plain)
    }
}

struct DateNavigatorBar: View {
    let title: String
    var canGoBack: Bool = true
    var canGoForward: Bool = true
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
            }
            .disabled(!canGoBack)
            .opacity(canGoBack ? 1 : 0.35)
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Button(action: onNext) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
            }
            .disabled(!canGoForward)
            .opacity(canGoForward ? 1 : 0.35)
        }
        .foregroundStyle(Color("AppPrimary"))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(AppGradients.cardSurface)
        }
        .overlay {
            Capsule().strokeBorder(AppGradients.cardBorder, lineWidth: 1)
        }
        .appDepthShadow(radius: 4, y: 2, opacity: 0.35)
    }
}

struct GratitudeFieldCell: View {
    let index: Int
    @Binding var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 24, height: 24)
                .background {
                    Circle().fill(AppGradients.primaryButton)
                }
            TextField("I am grateful for...", text: $text, axis: .vertical)
                .lineLimit(2...3)
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .appCard(accent: .accent, padding: 14)
    }
}
