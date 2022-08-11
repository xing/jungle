import Foundation

public struct Module: Hashable {
    public let name: String
    public let dependencies: [String]

    public init(name: String, dependencies: [String]) {
        self.name = name
        self.dependencies = dependencies
    }
}

