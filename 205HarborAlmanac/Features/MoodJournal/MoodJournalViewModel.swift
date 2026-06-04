import Combine
import Foundation

@MainActor
final class MoodJournalViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var showEditor = false
    @Published var editingEntry: JournalEntry?
    @Published var showSuccessPulse = false
    @Published var successCheckmark = false
    @Published var searchText = ""
    @Published var showAllEntries = false
    @Published var showFilters = false
    @Published var filterMood: String?
    @Published var filterTag: String?
    @Published var filterStartDate: Date?
    @Published var filterEndDate: Date?

    private let store: AppDataStore
    private let bannerManager: AchievementBannerManager

    let moodOptions = ["😄", "🙂", "😐", "😔", "😢", "😌", "🤔", "😴"]

    init(store: AppDataStore, bannerManager: AchievementBannerManager) {
        self.store = store
        self.bannerManager = bannerManager
        selectedDate = store.lastViewedDate
    }

    var displayedEntries: [JournalEntry] {
        if showAllEntries || !searchText.isEmpty || filterMood != nil || filterTag != nil || filterStartDate != nil || filterEndDate != nil {
            return store.filteredJournalEntries(
                searchText: searchText,
                mood: filterMood,
                tag: filterTag,
                startDate: filterStartDate,
                endDate: filterEndDate
            )
        }
        return store.entries(for: selectedDate)
    }

    var isEmptyList: Bool { displayedEntries.isEmpty }

    var formattedDate: String {
        showAllEntries ? "All Entries" : selectedDate.formatted(date: .complete, time: .omitted)
    }

    var availableTags: [String] {
        Array(Set(store.journalEntries.flatMap(\.tags))).sorted()
    }

    func goToPreviousDay() {
        guard !showAllEntries else { return }
        FeedbackService.lightTap()
        if let previous = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = Calendar.current.startOfDay(for: previous)
            store.setLastViewedDate(selectedDate)
        }
    }

    func goToNextDay() {
        guard !showAllEntries else { return }
        FeedbackService.lightTap()
        let today = Calendar.current.startOfDay(for: Date())
        let nextStart = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        guard nextStart <= today else { return }
        selectedDate = nextStart
        store.setLastViewedDate(selectedDate)
    }

    func openNewEntry() {
        FeedbackService.lightTap()
        editingEntry = JournalEntry(date: mergeTimeIntoSelectedDay(Date()))
        showEditor = true
    }

    func openNewEntry(template: JournalTemplate) {
        FeedbackService.lightTap()
        editingEntry = JournalEntry(
            date: mergeTimeIntoSelectedDay(Date()),
            mood: template.mood,
            note: "",
            tags: [template.tag]
        )
        showEditor = true
    }

    func openEdit(_ entry: JournalEntry) {
        FeedbackService.lightTap()
        editingEntry = entry
        showEditor = true
    }

    func isNewEntry(_ entry: JournalEntry) -> Bool {
        !store.journalEntries.contains { $0.id == entry.id }
    }

    func saveEntry(_ entry: JournalEntry, isNew: Bool) {
        guard !entry.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        store.saveJournalEntry(entry, isNew: isNew)
        FeedbackService.mediumTap()
        FeedbackService.playSystemSound(1104)
        showSuccessPulse = true
        successCheckmark = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.showSuccessPulse = false
        }
        bannerManager.enqueue(AchievementEvaluator.newlyUnlocked(store: store))
    }

    func deleteEntry(_ entry: JournalEntry) {
        FeedbackService.lightTap()
        store.deleteJournalEntry(id: entry.id)
    }

    func clearFilters() {
        filterMood = nil
        filterTag = nil
        filterStartDate = nil
        filterEndDate = nil
        searchText = ""
    }

    private func mergeTimeIntoSelectedDay(_ reference: Date) -> Date {
        let calendar = Calendar.current
        let time = calendar.dateComponents([.hour, .minute, .second], from: reference)
        var day = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        day.hour = time.hour
        day.minute = time.minute
        day.second = time.second
        return calendar.date(from: day) ?? selectedDate
    }
}
