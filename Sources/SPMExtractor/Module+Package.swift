import Foundation
import DependencyModule
import Shell

public struct Package: Decodable {
    public let targets: [Target]
    public let products: [Product]
    
    public struct Product: Decodable {
        let name: String
        let targets: [String]
    }
    public struct Target: Decodable {
        let name: String
        let targetDependencies: [String]?
        let productDependencies: [String]?
        let type: TargetType
        
        var dependencies: [String] {
            [targetDependencies, productDependencies].compactMap { $0 }.flatMap { $0 }
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case targetDependencies = "target_dependencies"
            case productDependencies = "product_dependencies"
            case type
        }
        
        public enum TargetType: String, Decodable {
            case library
            case test
            case executable
            case binary
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

public func extracPackageModules(from packageRaw: String, target: String, onProduct: String? = nil) throws -> ([Module], [String]) {
    
    guard
        let data = packageRaw.data(using: .utf8)
    else {
        throw PackageError.nonDecodable(raw: packageRaw)
    }
    
    let package = try JSONDecoder().decode(Package.self, from: data)
    
    if let targetModules = package.targets.filter({ $0.name == target }).first {
        let dependencies = extractDependencies(from: package, on: target)
        let external = targetModules.productDependencies?.compactMap { Module(name: $0, dependencies: []) } ?? []
        let targetDependencies = targetModules.dependencies
        return (dependencies + external, targetDependencies)
    } else if let product = package.products.filter({ $0.name == target }).first, onProduct == nil {
        let result = try product.targets.compactMap { try extracPackageModules(from: packageRaw, target: $0, onProduct: product.name)}
        let modules = Set(result.flatMap(\.0))
        return (Array(modules), product.targets)
    } else {
        throw TargetError.targetNotFound(target: target)
    }
}

public func extractDependantTargets(from packageRaw: String, target: String) throws -> [Module] {
    guard
        let data = packageRaw.data(using: .utf8)
    else {
        throw PackageError.nonDecodable(raw: packageRaw)
    }
    
    let package = try JSONDecoder().decode(Package.self, from: data)
    
    guard let target = package.targets.filter({ $0.name == target }).first else {
        throw TargetError.targetNotFound(target: target)
    }
    
    let dependantTargets: [Module] = package.targets
        .filter { $0.dependencies.contains(target.name)  }
        .compactMap { .init(name: $0.name, dependencies: $0.dependencies, type: $0.type == .library ? .library : .test ) }
    
    guard !dependantTargets.isEmpty else {
        return dependantTargets
    }
    
    var indirectTargets: [Module] = []
    
    try dependantTargets.forEach { target in
        indirectTargets += try extractDependantTargets(from: packageRaw, target: target.name)
    }
    
    return dependantTargets + indirectTargets
}

public func extractDependantTargets(from modules: [Module], for target: String) throws -> [Module] {

    let dependantTargets: [Module] = modules
        .filter { $0.dependencies.contains(target) || $0.name.components(separatedBy: "/").count == 2 && $0.name.components(separatedBy: "/").first == target }
    
    guard !dependantTargets.isEmpty else {
        return dependantTargets
    }
    
    var indirectTargets: [Module] = []
    
    try dependantTargets.forEach {
        indirectTargets += try extractDependantTargets(from: modules, for: $0.name)
    }
    
    return dependantTargets + indirectTargets
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
