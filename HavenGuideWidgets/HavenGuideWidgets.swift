import SwiftUI
import WidgetKit

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let entriesThisWeek: Int
    let progress: Double
    let lastMood: String
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 3, entriesThisWeek: 2, progress: 0.66, lastMood: "🙂")
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = loadEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }

    private func loadEntry() -> StreakEntry {
        let defaults = UserDefaults.standard
        return StreakEntry(
            date: Date(),
            streak: defaults.integer(forKey: "wg_streakDays"),
            entriesThisWeek: defaults.integer(forKey: "wg_entriesThisWeek"),
            progress: defaults.double(forKey: "wg_weeklyGoalProgress"),
            lastMood: defaults.string(forKey: "wg_lastMood") ?? "🙂"
        )
    }
}

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mindful Streak")
                .font(.caption)
            Text("\(entry.streak) days")
                .font(.title2.bold())
            Text("Week \(entry.entriesThisWeek)/3 \(entry.lastMood)")
                .font(.caption2)
            Text("Tap to log mood")
                .font(.caption)
        }
        .padding()
        .widgetURL(URL(string: "haven://journal"))
    }
}

struct BreathWidgetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "wind")
                .font(.title)
            Text("Breath Cycle")
                .font(.headline)
            Text("Tap to start")
                .font(.caption)
        }
        .padding()
        .widgetURL(URL(string: "haven://breath"))
    }
}

struct StreakWidget: Widget {
    let kind = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Mindful Streak")
        .description("Streak and weekly journal progress.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

struct BreathWidget: Widget {
    let kind = "BreathWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { _ in
            BreathWidgetView()
        }
        .configurationDisplayName("Breath Cycle")
        .description("Open a guided breath session.")
        .supportedFamilies([.systemSmall, .accessoryCircular])
    }
}

@main
struct HavenGuideWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        BreathWidget()
    }
}
