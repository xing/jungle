import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor
import SPMExtractor
import DependencyModule
import Shell

struct HistoryCommand: AsyncParsableCommand {
    
    enum OutputFormat: String, ExpressibleByArgument {
        case json
        case csv
    }
    
    static var configuration = CommandConfiguration(
        commandName: "history",
        abstract: "Displays historic complexity of the dependency graph"
    )

    @Option(help: "Equivalent to git-log --since: Eg: '6 months ago'")
    var since: String = "6 months ago"

    @Option(help: "The Module to compare. If you specify something, target parameter will be ommited")
    var module: String?

    @Option(help: "The target in your Podfile or Package.swift file to be used (this can be a Product name in SPM)")
    var target: String
    
    @Flag(help: "Use multi-edge or unique-edge configuration")
    var useMultiedge: Bool = false
    
    @Option(help: "csv or json")
    var outputFormat: OutputFormat = .csv

    @Argument(help: "Path to the directory where Podfile.lock is located")
    var directoryPath: String = "."

    func run() async throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
     
        // Check when this contains a Package.swift or a Podfile
        if FileManager.default.fileExists(atPath:  directoryURL.appendingPathComponent("Package.swift").path) {
            try await processPackage(at: directoryURL)
        } else {
            try await processPodfile(at: directoryURL)
        }
    }
    
    func processPackage(at directoryURL: URL) async throws {
        let packageRaw = try shell("swift package describe --type json", at: directoryURL)

        let first = try await GitLogEntry.current.process(package: packageRaw, target: target, usingMultiEdge: useMultiedge)

        let gitLog = "git log --since='\(since)' --first-parent --format='%h;%aI;%an;%s' -- Package.swift"
        let logs = try shell(gitLog, at: directoryURL)
            .split(separator: "\n")
            .reversed()
            .map(String.init)
            .map(GitLogEntry.parse)
        
     
        var previous: [HistoryStatsOutput] = []
        
        for entry in logs {
            if let result = try? await process(entry: entry, target: target, directoryURL: directoryURL) {
                previous.append(result)
            }
        }
        
        let output = previous + [first]

        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            let data = try encoder.encode(output)
            let string = String(data: data, encoding: .utf8)!
            print(string)
        case .csv:
            output.forEach { print($0.csv) }
        }
    }
    
    public func process(entry: GitLogEntry, target: String, directoryURL: URL) async throws -> HistoryStatsOutput? {
        guard let package = try? shell("git show \(entry.revision):./Package.swift", at: directoryURL), !package.isEmpty  else {
            return nil
        }
        try shell("git show \(entry.revision):./Package.swift > Package.swift.new", at: directoryURL)
        try shell("mv Package.swift Package.swift.current", at: directoryURL)
        try shell("mv Package.swift.new Package.swift", at: directoryURL)
        guard
            let packageRaw = try? shell("swift package describe --type json", at: directoryURL),
            !packageRaw.isEmpty
        else {
            try shell("mv Package.swift.current Package.swift", at: directoryURL)
            return nil
        }
  
        try shell("mv Package.swift.current Package.swift", at: directoryURL)
    
        return try await entry.process(package: packageRaw, target: target, usingMultiEdge: useMultiedge)
    }
    func processPodfile(at directoryURL: URL) async throws {
        
        let podfileURL = directoryURL.appendingPathComponent("Podfile.lock")
        
        // Choose the target to analyze
        let podfileJSON = try shell("pod ipc podfile-json Podfile --silent", at: directoryURL)
        
        guard let currentTargetDependencies = try moduleFromJSONPodfile(podfileJSON, onTarget: target) else {
            throw CompareError.targetNotFound(target: target)
        }
        
        // retrieve logs
        let gitLog = "git log --since='\(since)' --first-parent --format='%h;%aI;%an;%s' -- Podfile.lock"
        let logs = try shell(gitLog, at: directoryURL)
            .split(separator: "\n")
            .reversed()
            .map(String.init)
            .map(GitLogEntry.parse)

        // process Podfile.lock in current directory
        let current = try await GitLogEntry.current.process(pod: module, podfile: String(contentsOf: podfileURL), target: currentTargetDependencies, usingMultiEdge: useMultiedge)

        // process Podfile.lock for past commits

        let output = await withTaskGroup(of: HistoryStatsOutput?.self, returning: [HistoryStatsOutput].self) { group in

            for entry in logs.lazy {
                group.addTask {
                    
                    guard
                        let podfile = try? shell("git show \(entry.revision):./Podfile", at: directoryURL),
                        let entryTargetDependencies = try? moduleFromPodfile(podfile, on: target) ?? .init(name: target, dependencies: [])
                    else {
                        return nil
                    }

                    return try? await entry.process(
                        pod: module,
                        podfile: shell("git show \(entry.revision):./Podfile.lock", at: directoryURL),
                        target: entryTargetDependencies,
                        usingMultiEdge: useMultiedge
                    )
                }
            }

            var rows: [HistoryStatsOutput] = []
            for await row in group.compactMap({ $0 }) {
                rows.append(row)
            }
            return rows
        }
        .sorted { $0.timestamp < $1.timestamp }
        + [current]
        
        switch outputFormat {
        case .json:
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            let data = try encoder.encode(output)
            let string = String(data: data, encoding: .utf8)!
            print(string)
        case .csv:
            output.forEach { print($0.csv) }
        }
    }
}

extension GitLogEntry {
    func process(pod: String?, podfile: String, target: Module, usingMultiEdge: Bool) async throws -> HistoryStatsOutput {
        let dependencies = try extractModulesFromPodfileLock(podfile)
        
        let graph: Graph
        if let pod = pod {
            graph = try Graph.makeForModule(name: pod, dependencies: dependencies)
        } else {
            graph = try Graph.make(rootTargetName: target.name, modules: dependencies, targetDependencies: target.dependencies)
        }
        
        return HistoryStatsOutput(entry: self, graph: graph, usingMultiEdge: usingMultiEdge)
    }
    
    func process(package: String, target: String, usingMultiEdge: Bool) async throws -> HistoryStatsOutput {
        let (dependencies, targetDependencies) = try extracPackageModules(from: package, target: target)
        let graph = try Graph.make(rootTargetName: target, modules: dependencies, targetDependencies: targetDependencies)
        return HistoryStatsOutput(entry: self, graph: graph, usingMultiEdge: usingMultiEdge)
    }
}
