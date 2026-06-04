import Foundation
import UniformTypeIdentifiers

enum DataTransferService {
    static func makeJSONExport(from store: AppDataStore) throws -> Data {
        let bundle = store.makeExportBundle()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .useDefaultKeys
        return try encoder.encode(bundle)
    }

    static func makeCSVExport(from store: AppDataStore) -> String {
        var lines = ["id,date,mood,note,tags"]
        let formatter = ISO8601DateFormatter()
        for entry in store.journalEntries {
            let tags = entry.tags.joined(separator: "|")
            let note = entry.note.replacingOccurrences(of: "\"", with: "\"\"")
            let row = [
                entry.id.uuidString,
                formatter.string(from: entry.date),
                entry.mood,
                "\"\(note)\"",
                "\"\(tags)\""
            ].joined(separator: ",")
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }

    static func importJSON(_ data: Data, into store: AppDataStore) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let bundle = try decoder.decode(AppExportBundle.self, from: data)
        store.applyImport(bundle)
    }
}
