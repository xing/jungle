import Foundation

public struct Logger {
    public init() {}

    public func log(_ message: String) {
        print("[LOG] \(message)")
    }

    public func error(_ message: String) {
        print("[ERROR] \(message)")
    }
}
