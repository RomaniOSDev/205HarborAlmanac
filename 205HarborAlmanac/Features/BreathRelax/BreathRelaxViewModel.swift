import Combine
import Foundation
import SwiftUI

enum BreathPhase: String {
    case idle
    case inhale
    case hold
    case exhale
    case holdAfterExhale

    var label: String {
        switch self {
        case .idle: return "Ready"
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .holdAfterExhale: return "Hold"
        }
    }
}

@MainActor
final class BreathRelaxViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var currentPhase: BreathPhase = .idle
    @Published var circleScale: CGFloat = 0.65
    @Published var showHistory = false
    @Published var sessionCountPulse = false
    @Published var successCheckmark = false
    @Published var showPostSessionSheet = false
    @Published var showCustomPatternSheet = false
    @Published var pendingDuration: TimeInterval = 0
    @Published var postSessionMood = "🙂"
    @Published var postSessionRating = 3
    @Published var phaseProgress: Double = 0

    private let store: AppDataStore
    private let bannerManager: AchievementBannerManager
    private var sessionStart: Date?
    private var cycleAnchor: Date?
    private var rhythmCancellable: AnyCancellable?

    let postMoodOptions = ["😄", "🙂", "😐", "😔", "😌"]

    init(store: AppDataStore, bannerManager: AchievementBannerManager) {
        self.store = store
        self.bannerManager = bannerManager
    }

    deinit {
        rhythmCancellable?.cancel()
    }

    var sessions: [BreathingSession] { store.breathingSessions }
    var selectedPattern: BreathPattern { store.activeBreathPattern }

    func phase(at date: Date, pattern: BreathPattern) -> (BreathPhase, progress: Double, scale: CGFloat) {
        guard isRunning, let start = cycleAnchor else {
            return (.idle, 0, 0.65)
        }
        let cycleDuration = max(pattern.cycleDuration, 0.1)
        let elapsed = date.timeIntervalSince(start)
        let position = elapsed.truncatingRemainder(dividingBy: cycleDuration)
        var accumulated: TimeInterval = 0
        let phases: [(BreathPhase, TimeInterval)] = [
            (.inhale, pattern.inhale),
            (.hold, pattern.hold),
            (.exhale, pattern.exhale),
            (.holdAfterExhale, pattern.holdAfterExhale)
        ].filter { $0.1 > 0 }

        for item in phases {
            if position < accumulated + item.1 {
                let local = position - accumulated
                let progress = local / item.1
                return (item.0, progress, scaleFor(phase: item.0, progress: progress))
            }
            accumulated += item.1
        }
        return (.inhale, 0, 0.65)
    }

    func toggleSession() {
        if isRunning {
            stopSession()
        } else {
            startSession()
        }
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            stopRhythmTimer()
        case .active:
            if isRunning {
                startRhythmTimer()
                applyPhase(at: Date())
            }
        default:
            break
        }
    }

    func startSession() {
        FeedbackService.mediumTap()
        let now = Date()
        isRunning = true
        sessionStart = now
        cycleAnchor = now
        currentPhase = .inhale
        startRhythmTimer()
        applyPhase(at: now)
    }

    func stopSession() {
        FeedbackService.lightTap()
        stopRhythmTimer()
        isRunning = false
        currentPhase = .idle
        cycleAnchor = nil
        phaseProgress = 0
        circleScale = 0.65
        guard let start = sessionStart else { return }
        let duration = Date().timeIntervalSince(start)
        sessionStart = nil
        guard duration >= 5 else { return }
        pendingDuration = duration
        showPostSessionSheet = true
    }

    func completePostSession() {
        store.addBreathingSession(
            duration: pendingDuration,
            patternId: selectedPattern.id,
            postSessionMood: postSessionMood,
            postSessionRating: postSessionRating
        )
        FeedbackService.mediumTap()
        FeedbackService.playSystemSound(1103)
        sessionCountPulse = true
        successCheckmark = true
        showPostSessionSheet = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.sessionCountPulse = false
        }
        let unlocked = AchievementEvaluator.newlyUnlocked(store: store)
        bannerManager.enqueue(unlocked)
    }

    func skipPostSession() {
        store.addBreathingSession(
            duration: pendingDuration,
            patternId: selectedPattern.id,
            postSessionMood: nil,
            postSessionRating: nil
        )
        showPostSessionSheet = false
        FeedbackService.lightTap()
    }

    func selectPattern(_ pattern: BreathPattern) {
        FeedbackService.lightTap()
        store.setBreathPattern(pattern)
    }

    func saveCustomPattern(inhale: Double, hold: Double, exhale: Double, pause: Double) {
        let pattern = BreathPattern(
            id: "custom",
            title: "Custom",
            inhale: inhale,
            hold: hold,
            exhale: exhale,
            holdAfterExhale: pause
        )
        store.setCustomBreathPattern(pattern)
        FeedbackService.mediumTap()
        showCustomPatternSheet = false
    }

    private func startRhythmTimer() {
        stopRhythmTimer()
        rhythmCancellable = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                guard let self, self.isRunning else { return }
                self.applyPhase(at: date)
            }
    }

    private func stopRhythmTimer() {
        rhythmCancellable?.cancel()
        rhythmCancellable = nil
    }

    private func applyPhase(at date: Date) {
        let result = phase(at: date, pattern: selectedPattern)
        currentPhase = result.0
        phaseProgress = result.1
        circleScale = result.2
    }

    private func scaleFor(phase: BreathPhase, progress: Double) -> CGFloat {
        switch phase {
        case .inhale:
            return CGFloat(0.65 + 0.35 * progress)
        case .hold, .holdAfterExhale:
            return 1
        case .exhale:
            return CGFloat(1 - 0.35 * progress)
        case .idle:
            return 0.65
        }
    }
}
