import Combine
import Foundation

enum MainTab: Int, CaseIterable {
    case today
    case journal
    case wellness
    case achievements
    case settings

    var title: String {
        switch self {
        case .today: return "Home"
        case .journal: return "Journal"
        case .wellness: return "Wellness"
        case .achievements: return "Badges"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .today: return "house.fill"
        case .journal: return "book.fill"
        case .wellness: return "wind"
        case .achievements: return "star.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@MainActor
final class AppNavigationState: ObservableObject {
    @Published var selectedTab: MainTab = .today
    @Published var wellnessSegment = 0
    @Published var openBreathOnWellness = false

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "haven" else { return }
        switch url.host {
        case "today", "home":
            selectedTab = .today
        case "journal":
            selectedTab = .journal
        case "breath":
            selectedTab = .wellness
            wellnessSegment = 0
            openBreathOnWellness = true
        case "insights":
            selectedTab = .wellness
            wellnessSegment = 1
        default:
            break
        }
    }
}
