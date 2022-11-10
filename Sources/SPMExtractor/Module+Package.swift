import Foundation
import DependencyModule
import Shell

public struct Package: Decodable {
    public let targets: [Target]
    
    public struct Target: Decodable {
        let name: String
        let targetDependencies: [String]?
        let productDependencies: [String]?
        
        var dependencies: [String] {
            [targetDependencies, productDependencies].compactMap { $0 }.flatMap { $0 }
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case targetDependencies = "target_dependencies"
            case productDependencies = "product_dependencies"
        }
    }
}

public enum TargetError: Error {
    case targetNotFound(target: String)
}

public enum PackageError: Error {
    case nonDecodable(raw: String)
}

extension TargetError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .targetNotFound(let target):
            return "\"\(target)\" target not found in Package.swift!. Please, provide an existent target in your Package."
        }
    }
}

public func extracPackageModules(from packageRaw: String, target: String) throws -> ([Module], [String]) {
    
    guard
        let data = packageRaw.data(using: .utf8)
    else {
        throw PackageError.nonDecodable(raw: packageRaw)
    }
    
    let package = try JSONDecoder().decode(Package.self, from: data)
    
    guard let targetModules = package.targets.filter({ $0.name == target }).first else {
        throw TargetError.targetNotFound(target: target)
    }

    let dependencies = extractDependencies(from: package, on: target)
    let external = targetModules.productDependencies?.compactMap { Module(name: $0, dependencies: []) } ?? []

    let targetDependencies = targetModules.dependencies
    return (dependencies + external, targetDependencies)
}


public func extractDependencies(from package: Package, on target: String) -> [Module] {
    guard
        let targetModules = package.targets.filter({ $0.name == target }).first
    else {
        return []
    }
    
    var dependencies: Set<Module> = Set()
    
    for dependency in targetModules.dependencies {
        let modules = extractDependencies(from: package, on: dependency)
        for module in modules {
            dependencies.insert(module)
        }
    }
    return [Module(name: target, dependencies: targetModules.dependencies)] + Array(dependencies)
}
