import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor

struct GraphCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "graph",
        abstract: "Outputs the dependency graph in DOT format"
    )

    @Option(
        name: .customLong("of"),
        help: .init("A git object representing the version to draw the graph for. Eg: - 'main', 'my_branch', 'some_commit_hash'.", valueName: "git-object")
    )
    var gitObject: String?

    @Option(help: "The Pod to compare. If you specify something, target parameter will be ommited")
    var pod: String?

    @Option(help: "The target in your Podfile file to be used")
    var target: String    
    
    @Argument(help: "Path to the directory where Podfile.lock is located")
    var directoryPath: String = "."

    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)

        if let gitObject = gitObject {
            try print(
                makeDOT(
                    podfile: shell("git show \(gitObject):Podfile.lock", at: directoryURL),
                    label: gitObject
                )
            )
        } else {
            print(
                try makeDOT(
                    podfile: String(contentsOf: directoryURL.appendingPathComponent("Podfile.lock")),
                    label: "Current"
                )
            )
        }
    }
    
    private func makeDOT(podfile: String, label: String) throws -> String {
        let dependencies = try extractModulesFromPodfile(podfile)
        
        let graph: Graph
        if let pod = pod {
            graph = try Graph.makeForModule(name: pod, dependencies: dependencies)
        } else {
            graph = try Graph.make(rootTargetName: "App", dependencies: dependencies, targetDependencies: nil)
        }
        
        return graph.multiEdgeDOT
    }
}
