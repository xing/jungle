import ArgumentParser
import Foundation
import DependencyGraph
import PodExtractor

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

    @Option(help: "The Pod to generate a report for. Omitting this generates a report for a virtual `App` target that imports all Pods")
    var pod: String?
    
    @Option(help: "csv or json")
    var outputFormat: OutputFormat = .csv

    @Argument(help: "Path to the directory where Podfile.lock is located")
    var directoryPath: String = "."

    func run() async throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
        let podfileURL = directoryURL.appendingPathComponent("Podfile.lock")
        
        // retrieve logs
        let gitLog = "git log --since='\(since)' --first-parent --format='%h;%aI;%an;%s' -- Podfile.lock"
        let logs = try shell(gitLog, at: directoryURL)
            .split(separator: "\n")
            .reversed()
            .map(String.init)
            .map(GitLogEntry.parse)

        // process Podfile.lock in current directory
        let current = try await GitLogEntry.current.process(pod: pod, podfile: String(contentsOf: podfileURL))

        // process Podfile.lock for past commits
        let output = try await withThrowingTaskGroup(of: HistoryStatsOutput.self, returning: [HistoryStatsOutput].self) { group in

            for entry in logs.lazy {
                group.addTask {
                    try await entry.process(
                        pod: pod,
                        podfile: shell("git show \(entry.revision):Podfile.lock", at: directoryURL)
                    )
                }
            }

            var rows: [HistoryStatsOutput] = []
            for try await row in group {
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
    func process(pod: String?, podfile: String) async throws -> HistoryStatsOutput {
        let dependencies = try extractModulesFromPodfile(podfile)
        
        let graph: Graph
        if let pod = pod {
            graph = try Graph.makeForModule(name: pod, dependencies: dependencies)
        } else {
            graph = try Graph.makeForVirtualAppModule(name: "App", dependencies: dependencies, targetDependencies: nil)
        }
        
        return HistoryStatsOutput(entry: self, graph: graph)
    }
}
