import Foundation

struct JournalTemplate: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let mood: String
    let tag: String
    let prompt: String

    static let all: [JournalTemplate] = [
        JournalTemplate(
            id: "morning",
            title: "Morning Check-in",
            mood: "🙂",
            tag: "morning",
            prompt: "How are you starting the day?"
        ),
        JournalTemplate(
            id: "after_work",
            title: "After Work",
            mood: "😌",
            tag: "work",
            prompt: "What are you carrying from today?"
        ),
        JournalTemplate(
            id: "before_sleep",
            title: "Before Sleep",
            mood: "😴",
            tag: "sleep",
            prompt: "What do you want to release before rest?"
        )
    ]
}
