import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor

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

    @Argument(help: "Path to the directory where Podfile.lock is located")
    var directoryPath: String = "."

    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)

        let current = try process(
            label: "Current",
            pod: pod,
            podfile: String(contentsOf: directoryURL.appendingPathComponent("Podfile.lock"))
        )

        let outputs = [current] + gitObjects.compactMap {
            try? process(
                label: $0,
                pod: pod,
                podfile: shell("git show \($0):Podfile.lock", at: directoryURL)
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let jsonData = try encoder.encode(outputs)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
    }
}

func process(label: String, pod: String?, podfile: String) throws -> CompareStatsOutput {
    let dependencies = try extractModulesFromPodfile(podfile)
    
    let graph: Graph
    if let pod = pod {
        graph = try Graph.makeForModule(name: pod, dependencies: dependencies)
    } else {
        graph = try Graph.makeForVirtualAppModule(name: "App", dependencies: dependencies)
    }
        
    return CompareStatsOutput(label: label, graph: graph)
}
