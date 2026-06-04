import SwiftUI

struct BreathRelaxView: View {
    @ObservedObject var viewModel: BreathRelaxViewModel
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                headerCard
                patternPicker
                breathingCircle
                controlSection
                historySection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .successCheckmark(trigger: $viewModel.successCheckmark)
        .sheet(isPresented: $viewModel.showPostSessionSheet) { postSessionSheet }
        .sheet(isPresented: $viewModel.showCustomPatternSheet) { customPatternSheet }
        .onChange(of: scenePhase) { phase in
            viewModel.handleScenePhase(phase)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            IconBadge(systemName: "lungs.fill", size: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.selectedPattern.title)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(viewModel.selectedPattern.subtitle) • \(Int(viewModel.selectedPattern.cycleDuration))s cycle")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .appCard(accent: .primary, elevated: true)
    }

    private var patternPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Patterns", subtitle: "Pick a rhythm that fits you")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BreathPattern.presets) { pattern in
                        BreathPatternChip(
                            pattern: pattern,
                            isSelected: store.selectedBreathPatternId == pattern.id
                        ) { viewModel.selectPattern(pattern) }
                    }
                    FilterChipButton(title: "Custom", isSelected: store.selectedBreathPatternId == "custom") {
                        viewModel.showCustomPatternSheet = true
                    }
                }
            }
        }
    }

    private var breathingCircle: some View {
        ZStack {
            Circle()
                .stroke(Color("AppPrimary").opacity(0.2), lineWidth: 3)
                .frame(width: 240, height: 240)

            Circle()
                .trim(from: 0, to: viewModel.isRunning ? viewModel.phaseProgress : 0)
                .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 240, height: 240)
                .animation(.linear(duration: 0.1), value: viewModel.phaseProgress)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppAccent").opacity(0.35), Color("AppSurface")],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(viewModel.circleScale)
                .animation(.easeInOut(duration: 0.15), value: viewModel.circleScale)

            if viewModel.isRunning {
                VStack(spacing: 8) {
                    Text(viewModel.currentPhase.label)
                        .font(.title2.bold())
                        .id(viewModel.currentPhase)
                    Text("Follow the rhythm")
                        .font(.caption)
                }
                .foregroundStyle(Color("AppTextPrimary"))
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentPhase)
            } else {
                VStack(spacing: 10) {
                    waveIllustration
                    Text("Tap start to begin calmness")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .frame(height: 270)
        .frame(maxWidth: .infinity)
    }

    private var waveIllustration: some View {
        Canvas { context, size in
            var path = Path()
            let midY = size.height * 0.55
            path.move(to: CGPoint(x: 0, y: midY))
            for x in stride(from: 0, through: size.width, by: 4) {
                let y = midY + sin((x / size.width) * .pi * 4) * 12
                path.addLine(to: CGPoint(x: x, y: y))
            }
            context.stroke(path, with: .color(Color("AppAccent").opacity(0.6)), lineWidth: 2)
        }
        .frame(width: 160, height: 80)
    }

    private var controlSection: some View {
        Button { viewModel.toggleSession() } label: {
            Label(viewModel.isRunning ? "Stop Session" : "Start Session", systemImage: viewModel.isRunning ? "stop.fill" : "play.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, 24)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Session History",
                subtitle: "\(viewModel.sessions.count) completed",
                actionTitle: (!viewModel.showHistory && viewModel.sessions.count > 3) ? "Show more" : nil,
                action: { viewModel.showHistory = true }
            )
            if viewModel.sessions.isEmpty {
                EmptyStateCell(
                    icon: "wind",
                    title: "No sessions yet",
                    message: "Complete one cycle to see your history here."
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.sessions.prefix(viewModel.showHistory ? 20 : 3)) { session in
                        SessionHistoryCell(session: session)
                    }
                }
            }
        }
    }

    private var postSessionSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                VStack(spacing: 20) {
                    SectionHeaderView(title: "How do you feel?", subtitle: "Optional reflection after breathing")
                    MoodPickerCell(title: "Post-session mood", moods: viewModel.postMoodOptions, selection: $viewModel.postSessionMood)
                    Stepper("Energy level: \(viewModel.postSessionRating)/5", value: $viewModel.postSessionRating, in: 1...5)
                        .padding()
                        .appCard()
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("After Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Skip") { viewModel.skipPostSession() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.completePostSession() }.foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.large])
    }

    private var customPatternSheet: some View {
        CustomBreathPatternSheet(viewModel: viewModel)
    }
}

private struct CustomBreathPatternSheet: View {
    @ObservedObject var viewModel: BreathRelaxViewModel
    @State private var inhale = 4.0
    @State private var hold = 2.0
    @State private var exhale = 4.0
    @State private var pause = 0.0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                VStack(spacing: 16) {
                    Stepper("Inhale: \(Int(inhale))s", value: $inhale, in: 2...10)
                    Stepper("Hold: \(Int(hold))s", value: $hold, in: 0...10)
                    Stepper("Exhale: \(Int(exhale))s", value: $exhale, in: 2...12)
                    Stepper("Pause: \(Int(pause))s", value: $pause, in: 0...8)
                }
                .padding()
                .appCard()
                .padding(16)
            }
            .navigationTitle("Custom Pattern")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveCustomPattern(inhale: inhale, hold: hold, exhale: exhale, pause: pause)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
