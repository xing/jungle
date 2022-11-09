import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor
import SPMExtractor
import DependencyModule
import Shell

public enum CompareError: Error {
    case targetNotFound(target: String)
}

extension CompareError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .targetNotFound(let target):
            return "\"\(target)\" target not found!. Please, provide an existent target in your Podfile."
        }
    }
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

    @Option(help: "The Pod to compare. If you specify something, target parameter will be ommited")
    var pod: String?
    
    @Option(help: "The target in your Podfile or Package.swift file to be used")
    var target: String

    @Argument(help: "Path to the directory where Podfile.lock or Package.swift is located")
    var directoryPath: String = "."

    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
        // Check when this contains a Package.swift or a Podfile
        if FileManager.default.fileExists(atPath:  directoryURL.appendingPathComponent("Package.swift").path) {
            try processPackage(at: directoryURL)
        } else {
            try processPodfile(at: directoryURL)
        }
    }
    
    func processPackage(at directoryURL: URL) throws {
        
        let packageRaw = try shell("swift package describe --type json", at: directoryURL)
        let (dependencies, targetDependencies) = try extracPackageModules(from: packageRaw, target: target)
        let graph = try Graph.make(rootTargetName: target, dependencies: dependencies, targetDependencies: targetDependencies)
        
        let current = CompareStatsOutput(label: "Current", graph: graph)
        
        let outputs = try [current] + gitObjects.compactMap {
            guard let package = try? shell("git show \($0):Package.swift", at: directoryURL), !package.isEmpty  else {
                return nil
            }
            _ = try shell("git show \($0):Package.swift > Package.swift.new", at: directoryURL)
            _ = try shell("mv Package.swift Package.swift.current", at: directoryURL)
            _ = try shell("mv Package.swift.new Package.swift", at: directoryURL)
            guard
                let packageRaw = try? shell("swift package describe --type json", at: directoryURL),
                !packageRaw.isEmpty,
                let (dependencies, targetDependencies) = try? extracPackageModules(from: packageRaw, target: target)

            else {
                try shell("mv Package.swift.current Package.swift", at: directoryURL)
                return nil
            }

            let current = try Graph.make(rootTargetName: target, dependencies: dependencies, targetDependencies: targetDependencies)
            try shell("mv Package.swift.current Package.swift", at: directoryURL)
            return CompareStatsOutput(label: $0, graph: current)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let jsonData = try encoder.encode(outputs)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
    }
    
    func processPodfile(at directoryURL: URL) throws {
        // Choose the target to analyze
        let podfileJSON = try shell("pod ipc podfile-json Podfile --silent", at: directoryURL)

        guard let currentTargetDependencies = try moduleFromJSONPodfile(podfileJSON, onTarget: target) else {
            throw CompareError.targetNotFound(target: target)
        }

        let current = try process(
            label: "Current",
            pod: pod,
            podfile: String(contentsOf: directoryURL.appendingPathComponent("Podfile.lock")),
            target: currentTargetDependencies
        )

        let outputs = [current] + gitObjects.compactMap {
            guard
                let podfile = try? shell("git show \($0):Podfile", at: directoryURL),
                let entryTargetDependencies = try? moduleFromPodfile(podfile, on: target)
            else {
                return nil
            }
            
            return try? process(
                label: $0,
                pod: pod,
                podfile: shell("git show \($0):Podfile.lock", at: directoryURL),
                target: entryTargetDependencies
            )
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let jsonData = try encoder.encode(outputs)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
    }
}

func process(label: String, pod: String?, podfile: String, target: Module) throws -> CompareStatsOutput {
    let dependencies = try extractModulesFromPodfileLock(podfile)
    
    let graph: Graph
    if let pod = pod {
        graph = try Graph.makeForModule(name: pod, dependencies: dependencies)
    } else {
        graph = try Graph.make(rootTargetName: target.name, dependencies: dependencies, targetDependencies: target.dependencies)
    }
        
    return CompareStatsOutput(label: label, graph: graph)
}
