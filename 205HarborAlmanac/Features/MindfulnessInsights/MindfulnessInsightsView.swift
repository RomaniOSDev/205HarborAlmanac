import SwiftUI

struct MindfulnessInsightsView: View {
    @ObservedObject var viewModel: MindfulnessInsightsViewModel
    @EnvironmentObject private var store: AppDataStore

    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if !viewModel.hasActivity { emptyState }
                ProgressGoalCell(
                    title: "Soft Weekly Goal",
                    subtitle: "\(store.entriesThisWeek()) of \(AppDataStore.weeklyGoalTarget) entries",
                    progress: store.weeklyGoalProgress,
                    icon: "chart.line.uptrend.xyaxis"
                )
                moodTrendSection
                topTagsSection
                breathComparisonSection
                weeklyActivitySection
                heatmapSection
                streakCard
                addMomentButton
            }
            .padding(16)
        }
        .successCheckmark(trigger: $viewModel.successCheckmark)
        .sheet(isPresented: $viewModel.showAddSheet) { addMomentSheet }
    }

    private var emptyState: some View {
        EmptyStateCell(
            icon: "sunrise.fill",
            title: "Your journey starts here",
            message: "Track your first mindful moment to unlock insights.",
            buttonTitle: "Record Moment",
            action: { viewModel.showAddSheet = true }
        )
    }

    private var moodTrendSection: some View {
        InsightSectionCard(title: "Mood Trend", subtitle: "6-week average from journal") {
            let data = store.weeklyMoodAverages()
            if data.isEmpty {
                Text("Add journal entries to see trends.")
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(AppGradients.progressFill)
                                .frame(height: CGFloat(item.average / 5.0 * 80))
                            Text(item.label)
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
            }
        }
    }

    private var topTagsSection: some View {
        InsightSectionCard(title: "Top Tags", subtitle: "This month") {
            let tags = store.topTagsThisMonth()
            if tags.isEmpty {
                Text("No tags yet.").foregroundStyle(Color("AppTextSecondary"))
            } else {
                ForEach(tags, id: \.tag) { item in
                    HStack {
                        TagChipView(text: item.tag)
                        Spacer()
                        Text("\(item.count)")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
            }
        }
    }

    private var breathComparisonSection: some View {
        InsightSectionCard(title: "Breath & Mood", subtitle: "Days with sessions vs without") {
            if let c = store.moodComparisonBreathDays() {
                HStack(spacing: 12) {
                    MetricTileCell(icon: "wind", title: "With breath", value: String(format: "%.1f", c.withBreath), compact: true)
                    MetricTileCell(icon: "book.closed", title: "Without", value: String(format: "%.1f", c.withoutBreath), compact: true)
                }
            } else {
                Text("Log moods and complete breath sessions to compare.")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }

    private var weeklyActivitySection: some View {
        InsightSectionCard(title: "Weekly Activity", subtitle: "Combined actions per day") {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(viewModel.weeklyCounts.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(AppGradients.progressFill)
                            .frame(height: max(8, CGFloat(value) / 4 * 80))
                        Text(weekdayLabels[index % 7])
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
    }

    private var heatmapSection: some View {
        InsightSectionCard(title: "Monthly Heatmap", subtitle: "Darker = more activity") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(viewModel.heatmapDays, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(heatmapColor(level: viewModel.intensity(for: day)))
                        .frame(height: 28)
                }
            }
        }
    }

    private var streakCard: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: "flame.fill", size: 52, elevated: true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Mindful Streak")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(viewModel.streakCount) consecutive days")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
        }
        .appCard(accent: .accent, elevated: true)
    }

    private var addMomentButton: some View {
        Button {
            FeedbackService.lightTap()
            viewModel.showAddSheet = true
        } label: {
            Label("Record Mindful Moment", systemImage: "plus.circle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var addMomentSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                VStack(spacing: 16) {
                    SectionHeaderView(title: "Mindful Moment", subtitle: "Rate your presence right now")
                    Stepper("Intensity: \(viewModel.selectedIntensity)/5", value: $viewModel.selectedIntensity, in: 1...5)
                        .padding()
                        .appCard()
                    Spacer()
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { viewModel.showAddSheet = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.recordMoment()
                        viewModel.showAddSheet = false
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func heatmapColor(level: Int) -> Color {
        switch level {
        case 0: return Color("AppBackground")
        case 1: return Color("AppSurface")
        case 2: return Color("AppPrimary").opacity(0.5)
        case 3: return Color("AppPrimary").opacity(0.75)
        default: return Color("AppAccent")
        }
    }
}
