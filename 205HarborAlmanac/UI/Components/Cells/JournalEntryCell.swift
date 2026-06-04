import SwiftUI

struct JournalEntryCell: View {
    let entry: JournalEntry
    var highlighted: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppGradients.iconBadge)
                    .frame(width: 56, height: 56)
                Text(entry.mood)
                    .font(.system(size: 30))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.note)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                if !entry.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(entry.tags, id: \.self) { tag in
                                TagChipView(text: tag)
                            }
                        }
                    }
                }
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                }
                .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary").opacity(0.7))
        }
        .appCard(accent: highlighted ? .accent : .none, elevated: highlighted)
    }
}

struct TagChipView: View {
    let text: String
    var selected: Bool = false

    var body: some View {
        Text("#\(text)")
            .font(.caption.bold())
            .foregroundStyle(selected ? Color("AppTextPrimary") : Color("AppAccent"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule()
                    .fill(selected ? AnyShapeStyle(AppGradients.primaryButton) : AnyShapeStyle(Color("AppPrimary").opacity(0.15)))
            }
    }
}

struct FilterChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(AppGradients.primaryButton) : AnyShapeStyle(Color("AppSurface")))
                }
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color("AppAccent").opacity(0.45) : Color("AppPrimary").opacity(0.15),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }
}

struct CustomSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onFilterTap: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppAccent"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
            if !text.isEmpty {
                Button {
                    FeedbackService.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Button(action: onFilterTap) {
                Image(systemName: "slider.horizontal.3")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 40, height: 40)
                    .background {
                        RoundedRectangle(cornerRadius: AppDepth.cornerSmall, style: .continuous)
                            .fill(AppGradients.iconBadge)
                    }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background { AppSurfaceBackground(cornerRadius: AppDepth.cornerMedium) }
        .clipShape(RoundedRectangle(cornerRadius: AppDepth.cornerMedium, style: .continuous))
        .appDepthShadow(radius: 4, y: 2, opacity: 0.35)
    }
}
