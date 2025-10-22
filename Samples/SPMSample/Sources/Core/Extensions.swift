import Foundation

public extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension Date {
    var timestamp: Int64 {
        Int64(timeIntervalSince1970)
    }
}
