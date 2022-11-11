import Foundation
import ArgumentParser
import Shell
import PodExtractor
import DependencyGraph
import SPMExtractor

struct ModulesCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "modules",
        abstract: "Outputs a sorted list of modules dependencies count of your project"
    )

    @Option(help: "The target in your Podfile or Package.swift file to be used")
    var target: String

    @Argument(help: "Path to the directory where Podfile.lock or Package.swift is located")
    var directoryPath: String = "."

    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
    
        // Check when this contains a Package.swift or a Podfile
        if FileManager.default.fileExists(atPath: directoryURL.appendingPathComponent("Package.swift").path) {
            try processPackage(at: directoryURL)
        } else {
            try processPodfile(at: directoryURL)
        }
    }

    private func processPackage(at directoryURL: URL) throws {
        let packageRaw = try shell("swift package describe --type json", at: directoryURL)
        let (modules, targetDependencies) = try extracPackageModules(from: packageRaw, target: target)
        
        let modulesStats: [ModuleStats] = targetDependencies
            .compactMap {
                guard let graph = try? Graph.makeForModule(name: $0, dependencies: modules) else { return nil }
                return ModuleStats(name: "\($0)", numberOfDependencies: graph.nodes.count)
            }
            .sorted { $0.numberOfDependencies > $1.numberOfDependencies }

        let result = modulesStats
            .map { "\($0.numberOfDependencies) - \($0.name)" }
            .joined(separator: "\n")

        print(
            result
        )
    }

    private func processPodfile(at directoryURL: URL) throws {
        // Choose the target to analyze
        let podfileJSON = try shell("pod ipc podfile-json Podfile --silent", at: directoryURL)
        
        guard let currentTargetDependencies = try moduleFromJSONPodfile(podfileJSON, onTarget: target) else {
            throw CompareError.targetNotFound(target: target)
        }
        let targetDependencies = currentTargetDependencies.dependencies
        
        let podfileLock = try shell("git show HEAD:Podfile.lock", at: directoryURL)
        let allPodfileModules = try extractModulesFromPodfileLock(podfileLock)
        let realTargetDependencies = allPodfileModules.filter { targetDependencies.contains($0.name) }

        let modulesStats: [ModuleStats] = realTargetDependencies
            .compactMap {
                guard let graph = try? Graph.makeForModule(name: $0.name, dependencies: allPodfileModules) else { return nil }
                return ModuleStats(name: $0.name, numberOfDependencies: graph.nodes.count)
            }
            .sorted { $0.numberOfDependencies > $1.numberOfDependencies }

        let result = modulesStats
            .map { "\($0.numberOfDependencies) - \($0.name)" }
            .joined(separator: "\n")

        print(
            result
        )
    }
}
