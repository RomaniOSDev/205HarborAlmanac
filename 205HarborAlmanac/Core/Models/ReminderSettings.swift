import Foundation

struct ReminderSettings: Codable, Equatable {
    var morningEnabled: Bool
    var eveningEnabled: Bool
    var morningHour: Int
    var morningMinute: Int
    var eveningHour: Int
    var eveningMinute: Int

    static let `default` = ReminderSettings(
        morningEnabled: false,
        eveningEnabled: false,
        morningHour: 9,
        morningMinute: 0,
        eveningHour: 20,
        eveningMinute: 0
    )
}
