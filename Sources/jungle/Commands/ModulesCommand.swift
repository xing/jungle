import Foundation
import ArgumentParser
import Shell
import PodExtractor
import DependencyGraph

struct ModulesCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "modules",
        abstract: "Outputs a sorted list of modules dependencies count of your project"
    )

    @Option(help: "The target in your Podfile file to be used")
    var target: String

    @Argument(help: "Path to the directory where Podfile.lock is located")
    var directoryPath: String = "."

    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)

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
