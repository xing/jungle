import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor

public enum CompareError: Error {
    case targetNotFound
}

struct CompareCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "compare",
        abstract: "Compares the current complexity of the dependency graph to others versions in git"
    )

    @Option(
        name: .customLong("to"),
        parsing: .upToNextOption,
        help: .init("The git objects to compare the current graph to. Eg: - 'main', 'my_branch', 'some_commit_hash'.", valueName: "git-object")
    )
    var gitObjects: [String] = ["HEAD", "main", "master"]

    @Option(help: "The Pod to compare. Omitting this generates compares a virtual `App` target that imports all Pods")
    var pod: String?
    
    @Option(help: "The target to be used. Omitting this will take the first target as default")
    var target: String

    @Argument(help: "Path to the directory where Podfile.lock is located")
    var directoryPath: String = "."

    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)

        // Choose the target to analyze
        let podfileJSON = try shell("pod ipc podfile-json Podfile --silent", at: directoryURL)
        let allTargets = try extractTargetsFromPodfile(podfileJSON)
        guard let targetWithDependencies = allTargets.filter({ $0.name == target }).first else {
            throw CompareError.targetNotFound
        }

        let current = try process(
            label: "Current",
            pod: pod,
            podfile: String(contentsOf: directoryURL.appendingPathComponent("Podfile.lock")),
            target: targetWithDependencies
        )

        let outputs = [current] + gitObjects.compactMap {
            try? process(
                label: $0,
                pod: pod,
                podfile: shell("git show \($0):Podfile.lock", at: directoryURL),
                target: targetWithDependencies
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let jsonData = try encoder.encode(outputs)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
    }
}

func process(label: String, pod: String?, podfile: String, target: Target) throws -> CompareStatsOutput {
    let dependencies = try extractModulesFromPodfile(podfile)
    
    let graph: Graph
    if let pod = pod {
        graph = try Graph.makeForModule(name: pod, dependencies: dependencies)
    } else {
        graph = try Graph.makeForVirtualAppModule(name: target.name, dependencies: dependencies, targetDependencies: target.dependencies)
    }
        
    return CompareStatsOutput(label: label, graph: graph)
}
