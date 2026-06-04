import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var navigation: AppNavigationState
    @EnvironmentObject private var bannerManager: AchievementBannerManager

    @State private var quickMood = "🙂"
    @State private var showCheckInSheet = false
    @State private var showSuccess = false

    private let quickMoods = ["😄", "🙂", "😐", "😔", "😌"]
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HomeHeroBanner(greeting: greetingText, dateText: formattedToday)
                        widgetGrid
                        HomeWideActionWidget(
                            icon: "square.and.pencil",
                            title: "Full Check-in",
                            subtitle: "Mood, thought, and optional breathing session",
                            buttonTitle: "Open Check-in"
                        ) {
                            showCheckInSheet = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollContentBackground(.hidden)
                .successCheckmark(trigger: $showSuccess)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCheckInSheet) {
                HomeCheckInSheet()
            }
            .onAppear {
                WidgetSnapshotWriter.sync(from: store)
            }
        }
    }

    private var widgetGrid: some View {
        VStack(spacing: 12) {
            HomeStatWidget(
                icon: "flame.fill",
                value: "\(store.streakDays)",
                title: "Day Streak",
                subtitle: "Keep logging to grow your streak",
                accent: .primary,
                elevated: true
            )

            LazyVGrid(columns: gridColumns, spacing: 12) {
                HomeStatWidget(
                    icon: "target",
                    value: "\(store.entriesThisWeek())/\(AppDataStore.weeklyGoalTarget)",
                    title: "Weekly Goal",
                    subtitle: "Journal entries this week",
                    accent: .accent
                )
                HomeStatWidget(
                    icon: "book.fill",
                    value: "\(store.entriesCreated)",
                    title: "Total Entries",
                    subtitle: "All-time journal logs",
                    accent: .none
                )
            }

            HomeQuickMoodWidget(
                selectedMood: $quickMood,
                moods: quickMoods,
                onSave: saveQuickMood
            )

            LazyVGrid(columns: gridColumns, spacing: 12) {
                imageWidgetButton(image: "HomeBreath", title: "Breath", subtitle: "Start a cycle", icon: "wind") {
                    openBreath()
                }
                imageWidgetButton(image: "HomeJournal", title: "Journal", subtitle: "Add entry", icon: "book.fill") {
                    navigation.selectedTab = .journal
                }
            }

            insightsWidget
        }
    }

    private func imageWidgetButton(
        image: String,
        title: String,
        subtitle: String,
        icon: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            FeedbackService.lightTap()
            action()
        }) {
            HomeImageWidget(
                imageName: image,
                title: title,
                subtitle: subtitle,
                systemIcon: icon
            )
        }
        .buttonStyle(.plain)
    }

    private var insightsWidget: some View {
        Button {
            FeedbackService.lightTap()
            navigation.selectedTab = .wellness
            navigation.wellnessSegment = 1
        } label: {
            HStack(spacing: 14) {
                IconBadge(systemName: "chart.xyaxis.line", size: 48)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mindfulness Insights")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    if let avg = averageMoodThisWeek {
                        Text(String(format: "Avg mood this week: %.1f / 5", avg))
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    } else {
                        Text("Track moments to unlock trends")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Text("\(store.sessionsCompleted) breath sessions completed")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .appCard(accent: .primary, elevated: true)
        }
        .buttonStyle(.plain)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var formattedToday: String {
        Date().formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    private var averageMoodThisWeek: Double? {
        let data = store.weeklyMoodAverages()
        guard !data.isEmpty else { return nil }
        let sum = data.reduce(0.0) { $0 + $1.average }
        return sum / Double(data.count)
    }

    private func saveQuickMood() {
        let entry = JournalEntry(
            date: Date(),
            mood: quickMood,
            note: "Quick mood check from Home",
            tags: ["quick", "home"]
        )
        store.saveJournalEntry(entry, isNew: true)
        FeedbackService.mediumTap()
        FeedbackService.playSystemSound(1104)
        showSuccess = true
        bannerManager.enqueue(AchievementEvaluator.newlyUnlocked(store: store))
    }

    private func openBreath() {
        navigation.selectedTab = .wellness
        navigation.wellnessSegment = 0
        navigation.openBreathOnWellness = true
    }
}

private struct HomeCheckInSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    DailyCheckInContent()
                        .padding(16)
                }
            }
            .navigationTitle("Daily Check-in")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.large])
    }
}

/// Reusable check-in body shared by Home sheet and legacy Today flow.
struct DailyCheckInContent: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var navigation: AppNavigationState
    @EnvironmentObject private var bannerManager: AchievementBannerManager
    @State private var mood = "🙂"
    @State private var note = ""
    @State private var startBreathAfterSave = false
    @State private var showSuccess = false

    private let moods = ["😄", "🙂", "😐", "😔", "😌", "😴"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ProgressGoalCell(
                title: "Weekly Goal",
                subtitle: "\(store.entriesThisWeek()) of \(AppDataStore.weeklyGoalTarget) journal entries",
                progress: store.weeklyGoalProgress,
                icon: "calendar.badge.checkmark"
            )
            MoodPickerCell(title: "How do you feel?", moods: moods, selection: $mood)
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "One line thought", subtitle: "Capture a moment from today")
                TextField("Write a short reflection...", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(14)
                    .background(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .appCard(accent: .primary)
            Toggle(isOn: $startBreathAfterSave) {
                Text("Open breathing after save")
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .tint(Color("AppPrimary"))
            .appCard()
            Button(action: saveCheckIn) {
                Label("Save Check-in", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .successCheckmark(trigger: $showSuccess)
    }

    private func saveCheckIn() {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            FeedbackService.warning()
            return
        }
        store.saveJournalEntry(
            JournalEntry(date: Date(), mood: mood, note: trimmed, tags: ["check-in"]),
            isNew: true
        )
        FeedbackService.mediumTap()
        FeedbackService.playSystemSound(1104)
        showSuccess = true
        note = ""
        bannerManager.enqueue(AchievementEvaluator.newlyUnlocked(store: store))
        if startBreathAfterSave {
            navigation.selectedTab = .wellness
            navigation.wellnessSegment = 0
            navigation.openBreathOnWellness = true
        }
    }
}
