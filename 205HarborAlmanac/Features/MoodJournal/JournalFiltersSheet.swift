import SwiftUI

struct JournalFiltersSheet: View {
    @ObservedObject var viewModel: MoodJournalViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        filterCard(title: "Mood", icon: "face.smiling") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChipButton(title: "Any", isSelected: viewModel.filterMood == nil) {
                                        viewModel.filterMood = nil
                                    }
                                    ForEach(viewModel.moodOptions, id: \.self) { mood in
                                        FilterChipButton(title: mood, isSelected: viewModel.filterMood == mood) {
                                            viewModel.filterMood = mood
                                        }
                                    }
                                }
                            }
                        }
                        filterCard(title: "Tag", icon: "tag.fill") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterChipButton(title: "Any", isSelected: viewModel.filterTag == nil) {
                                        viewModel.filterTag = nil
                                    }
                                    ForEach(viewModel.availableTags, id: \.self) { tag in
                                        FilterChipButton(title: tag, isSelected: viewModel.filterTag == tag) {
                                            viewModel.filterTag = tag
                                        }
                                    }
                                }
                            }
                        }
                        filterCard(title: "Date range", icon: "calendar") {
                            DatePicker("From", selection: Binding(
                                get: { viewModel.filterStartDate ?? Date() },
                                set: { viewModel.filterStartDate = $0 }
                            ), displayedComponents: .date)
                            DatePicker("To", selection: Binding(
                                get: { viewModel.filterEndDate ?? Date() },
                                set: { viewModel.filterEndDate = $0 }
                            ), displayedComponents: .date)
                        }
                        Button {
                            viewModel.showAllEntries = true
                            dismiss()
                        } label: {
                            Label("Apply & Show All", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Clear") { viewModel.clearFilters() }
                }
            }
        }
    }

    private func filterCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                IconBadge(systemName: icon, size: 36)
                Text(title).font(.headline).foregroundStyle(Color("AppTextPrimary"))
            }
            content()
        }
        .appCard()
    }
}
