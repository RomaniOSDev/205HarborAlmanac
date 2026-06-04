import SwiftUI

struct JournalEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entry: JournalEntry
    let moodOptions: [String]
    let isNew: Bool
    let onSave: (JournalEntry, Bool) -> Void

    @State private var tagText = ""
    @State private var validationShake = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        MoodPickerCell(title: "Mood", moods: moodOptions, selection: $entry.mood)
                        noteSection
                        tagsSection
                        Button(action: save) {
                            Label("Save Entry", systemImage: "square.and.arrow.down.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(16)
                }
            }
            .navigationTitle(isNew ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Note", subtitle: "What is on your mind?")
            TextField("Your thoughts...", text: $entry.note, axis: .vertical)
                .lineLimit(4...10)
                .foregroundStyle(Color("AppTextPrimary"))
                .padding(14)
                .background(Color("AppBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shake(trigger: validationShake)
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .appCard(accent: .accent)
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Tags", subtitle: "Optional labels for filtering")
            HStack(spacing: 8) {
                TextField("Add tag", text: $tagText)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .onSubmit { addTag() }
                Button("Add") { addTag() }
                    .buttonStyle(SecondaryButtonStyle())
            }
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            HStack(spacing: 4) {
                                TagChipView(text: tag, selected: true)
                                Button {
                                    FeedbackService.lightTap()
                                    entry.tags.removeAll { $0 == tag }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }
                    }
                }
            }
        }
        .appCard()
    }

    private func addTag() {
        let trimmed = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !entry.tags.contains(trimmed) { entry.tags.append(trimmed) }
        tagText = ""
        FeedbackService.lightTap()
    }

    private func save() {
        let trimmed = entry.note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please write a short thought before saving."
            validationShake += 1
            FeedbackService.warning()
            return
        }
        entry.note = trimmed
        onSave(entry, isNew)
        dismiss()
    }
}
