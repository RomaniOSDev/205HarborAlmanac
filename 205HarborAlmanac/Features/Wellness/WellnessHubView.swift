import SwiftUI

struct WellnessHubView: View {
    @ObservedObject var breathViewModel: BreathRelaxViewModel
    @ObservedObject var insightsViewModel: MindfulnessInsightsViewModel
    @EnvironmentObject private var navigation: AppNavigationState
    @State private var segment = 0

    private let segments = ["Breath", "Insights", "Practice"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 0) {
                    segmentPicker
                    Group {
                        switch segment {
                        case 0: BreathRelaxView(viewModel: breathViewModel)
                        case 1: MindfulnessInsightsView(viewModel: insightsViewModel)
                        default: MicroPracticesHubView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Wellness")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                segment = navigation.wellnessSegment
                if navigation.openBreathOnWellness {
                    segment = 0
                    navigation.openBreathOnWellness = false
                }
            }
            .onChange(of: segment) { navigation.wellnessSegment = $0 }
            .onChange(of: navigation.wellnessSegment) { segment = $0 }
        }
    }

    private var segmentPicker: some View {
        HStack(spacing: 8) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, title in
                FilterChipButton(title: title, isSelected: segment == index) {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) { segment = index }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct MicroPracticesHubView: View {
    @State private var practice = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                FilterChipButton(title: "Gratitude", isSelected: practice == 0) {
                    FeedbackService.lightTap()
                    practice = 0
                }
                FilterChipButton(title: "Body Scan", isSelected: practice == 1) {
                    FeedbackService.lightTap()
                    practice = 1
                }
            }
            .padding(16)

            if practice == 0 { GratitudeView() } else { BodyScanView() }
        }
    }
}
