import SwiftUI

struct MoodPickerCell: View {
    let title: String
    let moods: [String]
    @Binding var selection: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(moods, id: \.self) { mood in
                        MoodEmojiButton(emoji: mood, isSelected: selection == mood) {
                            FeedbackService.lightTap()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selection = mood
                            }
                        }
                    }
                }
            }
        }
        .appCard(accent: .accent)
    }
}

struct MoodEmojiButton: View {
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 34))
                .frame(width: 58, height: 58)
                .background {
                    Circle()
                        .fill(isSelected ? AnyShapeStyle(AppGradients.primaryButton) : AnyShapeStyle(Color("AppBackground")))
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color("AppAccent") : Color("AppPrimary").opacity(0.2),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
                .scaleEffect(isSelected ? 1.06 : 1)
        }
        .buttonStyle(.plain)
    }
}
