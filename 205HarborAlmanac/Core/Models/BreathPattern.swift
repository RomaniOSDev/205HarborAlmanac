import Foundation

struct BreathPattern: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let inhale: TimeInterval
    let hold: TimeInterval
    let exhale: TimeInterval
    let holdAfterExhale: TimeInterval

    var cycleDuration: TimeInterval {
        inhale + hold + exhale + holdAfterExhale
    }

    var subtitle: String {
        if holdAfterExhale > 0 {
            return "\(Int(inhale))-\(Int(hold))-\(Int(exhale))-\(Int(holdAfterExhale))"
        }
        if hold > 0 {
            return "\(Int(inhale))-\(Int(hold))-\(Int(exhale))"
        }
        return "\(Int(inhale))-\(Int(exhale))"
    }

    static let fourSevenEight = BreathPattern(
        id: "fourSevenEight",
        title: "4-7-8 Relax",
        inhale: 4,
        hold: 7,
        exhale: 8,
        holdAfterExhale: 0
    )

    static let box = BreathPattern(
        id: "box",
        title: "Box Breathing",
        inhale: 4,
        hold: 4,
        exhale: 4,
        holdAfterExhale: 4
    )

    static let calm = BreathPattern(
        id: "calm",
        title: "Calm 5-5",
        inhale: 5,
        hold: 0,
        exhale: 5,
        holdAfterExhale: 0
    )

    static let presets: [BreathPattern] = [.fourSevenEight, .box, .calm]
}
