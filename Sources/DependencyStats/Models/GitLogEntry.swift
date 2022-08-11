import Foundation

enum GitLogError: Error {
    case invalidFormat
}

struct GitLogEntry {
    var revision: String
    var timestamp: String
    var author: String?
    var message: String?

    static var current: GitLogEntry {
        .init(revision: "Current", timestamp: "Now")
    }

    static func parse(from rawEntry: String) throws -> GitLogEntry {
        let items = rawEntry
            .split(separator: ";")
            .map(String.init)

        if items.count != 4 {
            throw GitLogError.invalidFormat
        }

        let revision = items[0]
        let timestamp = items[1]
        let author = items[2]
        let message = items[3].replacingOccurrences(of: "\n", with: ".")

        return .init(revision: revision, timestamp: timestamp, author: author, message: message)
    }
}
