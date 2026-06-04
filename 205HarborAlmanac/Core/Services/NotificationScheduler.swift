import Foundation
import UserNotifications

enum NotificationScheduler {
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    static func scheduleReminders(_ settings: ReminderSettings) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["hg.morning", "hg.evening"])

        if settings.morningEnabled {
            center.add(makeRequest(
                id: "hg.morning",
                title: "Morning Check-in",
                body: "Log your mood and start the day mindfully.",
                hour: settings.morningHour,
                minute: settings.morningMinute
            ))
        }

        if settings.eveningEnabled {
            center.add(makeRequest(
                id: "hg.evening",
                title: "Evening Wind-down",
                body: "Take one breath cycle or log how you feel.",
                hour: settings.eveningHour,
                minute: settings.eveningMinute
            ))
        }
    }

    private static func makeRequest(
        id: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) -> UNNotificationRequest {
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
}
