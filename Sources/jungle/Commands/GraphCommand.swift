import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor
import DependencyModule
import Shell
import SPMExtractor

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

    @Option(help: "The Module to compare. If you specify something, target parameter will be ommited")
    var module: String?

    @Option(help: "The target in your Podfile file to be used")
    var target: String
    
    @Flag(help: "Use multi-edge or unique-edge configuration")
    var useMultiedge: Bool = false
    
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
    func processPackage(at directoryURL: URL) throws {
        try extractPackage(from: directoryURL, target: target)
    }

    func processPodfile(at directoryURL: URL) throws {
        if let gitObject = gitObject {
            guard
                let podfile = try? shell("git show \(gitObject):Podfile", at: directoryURL),
                let gitObjectTargetDependencies = try? moduleFromPodfile(podfile, on: target)
            else {
                throw CompareError.targetNotFound(target: target)
            }
            
            try print(
                makeDOT(
                    podfile: shell("git show \(gitObject):Podfile.lock", at: directoryURL),
                    label: gitObject,
                    target: gitObjectTargetDependencies
                )
            )
        } else {
            // Choose the target to analyze
            let podfileJSON = try shell("pod ipc podfile-json Podfile --silent", at: directoryURL)
            
            guard let targetWithDependencies = try moduleFromJSONPodfile(podfileJSON, onTarget: target) else {
                throw CompareError.targetNotFound(target: target)
            }
            
            print(
                try makeDOT(
                    podfile: String(contentsOf: directoryURL.appendingPathComponent("Podfile.lock")),
                    label: "Current",
                    target: targetWithDependencies
                )
            )
        }
    }
    
    private func makeDOT(podfile: String, label: String, target: Module) throws -> String {
        let dependencies = try extractModulesFromPodfileLock(podfile)
        
        let graph: Graph
        if let module = module {
            graph = try Graph.makeForModule(name: module, dependencies: dependencies)
        } else {
            graph = try Graph.make(rootTargetName: target.name, dependencies: dependencies, targetDependencies: target.dependencies)
        }
        
        return useMultiedge ? graph.multiEdgeDOT : graph.uniqueEdgeDOT
    }
}
