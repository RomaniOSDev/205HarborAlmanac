import SwiftUI

struct ActionRowCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var showsChevron: Bool = true
    var destructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: AppDepth.cornerSmall, style: .continuous)
                    .fill(
                        destructive
                            ? LinearGradient(colors: [Color.red.opacity(0.2), Color.red.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : AppGradients.iconBadge
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(destructive ? Color.red : Color("AppAccent"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(destructive ? Color.red : Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer(minLength: 8)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .background { AppSurfaceBackground(cornerRadius: AppDepth.cornerMedium) }
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous))
        .appDepthShadow()
    }
}

struct ActionRowButton: View {
    let icon: String
    let title: String
    var subtitle: String?
    var showsChevron: Bool = true
    var destructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            ActionRowCell(
                icon: icon,
                title: title,
                subtitle: subtitle,
                showsChevron: showsChevron,
                destructive: destructive
            )
        }
        .buttonStyle(.plain)
    }
}
