import Foundation
import DependencyModule
import DependencyGraph
import Shell

struct Package: Decodable {
    let targets: [Target]
    
    struct Target: Decodable {
        let name: String
        let targetDependencies: [String]?
        let productDependencies: [String]?
        
        var dependencies: [String] {
            (targetDependencies ?? []) + (productDependencies ?? [])
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

extension TargetError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .targetNotFound(let target):
            return "\"\(target)\" target not found in Package.swift!. Please, provide an existent target in your Package."
        }
    }
}


public func extractPackage(from directoryURL: URL, target: String, useMultiedge: Bool) throws {
 
    let packageRaw = try shell("swift package describe --type json", at: directoryURL).data(using: .utf8)!

    let package = try JSONDecoder().decode(Package.self, from: packageRaw)

    
    guard let targetModules = package.targets.filter({ $0.name == target }).first else {
        throw TargetError.targetNotFound(target: target)
    }

    let dependencies = extractDependencies(from: package, on: target)
    let external = targetModules.productDependencies?.compactMap { Module(name: $0, dependencies: []) } ?? []

    let targetDependencies = targetModules.dependencies
    
    let graph = try Graph.make(rootTargetName: target, dependencies: dependencies + external, targetDependencies: targetDependencies)
    
    print(useMultiedge ? graph.multiEdgeDOT : graph.uniqueEdgeDOT)
}


func extractDependencies(from package: Package, on target: String) -> [Module] {
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
