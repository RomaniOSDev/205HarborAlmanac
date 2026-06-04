import SwiftUI

struct MoodJournalView: View {
    @ObservedObject var viewModel: MoodJournalViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 0) {
                    journalToolbar
                    DateNavigatorBar(
                        title: viewModel.formattedDate,
                        canGoBack: !viewModel.showAllEntries,
                        canGoForward: !viewModel.showAllEntries,
                        onPrevious: viewModel.goToPreviousDay,
                        onNext: viewModel.goToNextDay
                    )
                    if viewModel.isEmptyList {
                        emptyState
                    } else {
                        entriesList
                    }
                }
                .successCheckmark(trigger: $viewModel.successCheckmark)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton(icon: "plus", action: viewModel.openNewEntry)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showEditor, onDismiss: { viewModel.editingEntry = nil }) {
                JournalEntryEditorContainer(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showFilters) {
                JournalFiltersSheet(viewModel: viewModel)
            }
        }
    }

    private var journalToolbar: some View {
        VStack(spacing: 12) {
            CustomSearchBar(text: $viewModel.searchText, placeholder: "Search entries...") {
                viewModel.showFilters = true
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(JournalTemplate.all) { template in
                        FilterChipButton(
                            title: template.title,
                            isSelected: false
                        ) {
                            viewModel.openNewEntry(template: template)
                        }
                    }
                    FilterChipButton(
                        title: viewModel.showAllEntries ? "By Day" : "All Entries",
                        isSelected: viewModel.showAllEntries
                    ) {
                        FeedbackService.lightTap()
                        viewModel.showAllEntries.toggle()
                        if viewModel.showAllEntries { viewModel.clearFilters() }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var emptyState: some View {
        ScrollView {
            EmptyStateCell(
                icon: "scribble.variable",
                title: "No entries yet",
                message: "Tap '+' to add your first mood entry today.",
                buttonTitle: "Add Entry",
                action: viewModel.openNewEntry
            )
            .padding(16)
        }
    }

    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.displayedEntries) { entry in
                    JournalEntryCell(
                        entry: entry,
                        highlighted: viewModel.showSuccessPulse
                    )
                    .onTapGesture { viewModel.openEdit(entry) }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteEntry(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}
