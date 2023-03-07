import Foundation

public struct Module: Hashable {
    public let name: String
    public let dependencies: [String]
    public let type: ModuleType
    public init(name: String, dependencies: [String], type: ModuleType = .library) {
        self.name = name
        self.dependencies = dependencies
        self.type = type
    }
    
    public enum ModuleType {
        case library
        case test
    }
}
