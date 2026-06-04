import SwiftUI

struct SessionHistoryCell: View {
    let session: BreathingSession

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: "wind", size: 48)
            VStack(alignment: .leading, spacing: 6) {
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Duration \(Int(session.duration))s • \(patternLabel)")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                if let mood = session.postSessionMood {
                    HStack(spacing: 4) {
                        Text("After:")
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text(mood)
                        if let rating = session.postSessionRating {
                            Text("(\(rating)/5)")
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                }
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color("AppPrimary"))
        }
        .appCard()
    }

    private var patternLabel: String {
        BreathPattern.presets.first { $0.id == session.patternId }?.title ?? session.patternId
    }
}

struct BreathPatternChip: View {
    let pattern: BreathPattern
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(pattern.title)
                    .font(.caption.bold())
                Text(pattern.subtitle)
                    .font(.caption2)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(AppGradients.primaryButton) : AnyShapeStyle(Color("AppSurface")))
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous)
                    .strokeBorder(isSelected ? Color("AppAccent").opacity(0.5) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}
