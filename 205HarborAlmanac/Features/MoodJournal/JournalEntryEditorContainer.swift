import SwiftUI

struct JournalEntryEditorContainer: View {
    @ObservedObject var viewModel: MoodJournalViewModel

    var body: some View {
        Group {
            if let entry = viewModel.editingEntry {
                JournalEntrySheet(
                    entry: Binding(
                        get: { viewModel.editingEntry ?? entry },
                        set: { viewModel.editingEntry = $0 }
                    ),
                    moodOptions: viewModel.moodOptions,
                    isNew: viewModel.isNewEntry(entry),
                    onSave: viewModel.saveEntry
                )
            } else {
                ProgressView()
                    .tint(Color("AppPrimary"))
            }
        }
    }
}
