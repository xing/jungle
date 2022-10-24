import ArgumentParser
import Foundation
import Shell
import DependencyGraph
import DependencyModule

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

struct SPMCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "package",
        abstract: "Outputs the dependency graph in DOT format"
    )
    @Option(help: "The target in your Podfile file to be used")
    var target: String
    
    @Argument(help: "Path to the directory where Package.swift is located")
    var directoryPath: String = "."
    
    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
        let packageRaw = try shell("swift package describe --type json", at: directoryURL).data(using: .utf8)!
    
        
        let package = try JSONDecoder().decode(Package.self, from: packageRaw)
 
        
        guard let targetModules = package.targets.filter({ $0.name == target }).first else {
            throw CompareError.targetNotFound(target: target)
        }
 
        let dependencies = extractDependencies(from: package, on: target)
        let external = targetModules.productDependencies?.compactMap { Module(name: $0, dependencies: []) } ?? []
 
        let targetDependencies = targetModules.dependencies
        
        let graph = try Graph.make(rootTargetName: target, dependencies: dependencies + external, targetDependencies: targetDependencies)
        
        print(graph.uniqueEdgeDOT)
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
}
