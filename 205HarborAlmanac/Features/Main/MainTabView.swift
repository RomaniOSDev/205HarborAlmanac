import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var navigation: AppNavigationState
    @StateObject private var bannerManager: AchievementBannerManager

    @StateObject private var journalViewModel: MoodJournalViewModel
    @StateObject private var breathViewModel: BreathRelaxViewModel
    @StateObject private var insightsViewModel: MindfulnessInsightsViewModel

    init() {
        let store = AppDataStore.shared
        let banner = AchievementBannerManager()
        _bannerManager = StateObject(wrappedValue: banner)
        _journalViewModel = StateObject(wrappedValue: MoodJournalViewModel(store: store, bannerManager: banner))
        _breathViewModel = StateObject(wrappedValue: BreathRelaxViewModel(store: store, bannerManager: banner))
        _insightsViewModel = StateObject(wrappedValue: MindfulnessInsightsViewModel(store: store, bannerManager: banner))
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppBackgroundView()

            VStack(spacing: 0) {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                customTabBar
            }

            if let banner = bannerManager.currentBanner {
                AchievementBannerView(achievement: banner)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .environmentObject(bannerManager)
        .onAppear {
            NotificationScheduler.scheduleReminders(store.reminderSettings)
            bannerManager.enqueue(AchievementEvaluator.newlyUnlocked(store: store))
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            journalViewModel.selectedDate = Calendar.current.startOfDay(for: Date())
            journalViewModel.clearFilters()
            journalViewModel.showAllEntries = false
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch navigation.selectedTab {
        case .today: HomeView()
        case .journal: MoodJournalView(viewModel: journalViewModel)
        case .wellness:
            WellnessHubView(breathViewModel: breathViewModel, insightsViewModel: insightsViewModel)
        case .achievements: AchievementsView()
        case .settings: SettingsView()
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 4) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                TabBarItemCell(
                    tab: tab,
                    isSelected: navigation.selectedTab == tab
                ) {
                    FeedbackService.lightTap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        navigation.selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            AppSurfaceBackground(cornerRadius: 22)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .appDepthShadow(radius: 10, y: -3, opacity: 0.45)
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }
}

private struct TabBarItemCell: View {
    let tab: MainTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: isSelected ? 20 : 18, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppGradients.tabBarActive)
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: 52)
    }
}
