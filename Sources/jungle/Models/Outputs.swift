import ArgumentParser
import DependencyGraph
import Foundation

struct HistoryStatsOutput: Codable {
    let timestamp: String
    let revision: String
    let moduleCount: Int
    let complexity: Int
    let author: String?
    let message: String?
    
    init(entry: GitLogEntry, graph: Graph) {
        timestamp = entry.timestamp
        revision = entry.revision
        moduleCount = graph.nodes.count
        complexity = graph.multiGraphComplexity
        author = entry.author
        message = entry.message
    }

    var csv: String {
        [
            timestamp,
            revision,
            moduleCount.formatted(.number.grouping(.never)),
            complexity.formatted(.number.grouping(.never)),
            author ?? "",
            message ?? ""
        ].joined(separator: ";")
    }
}

public struct CompareStatsOutput: Codable {
    public let name: String
    public let moduleCount: Int
    public let complexity: Int
    
    init(label: String, graph: Graph) {
        name = label
        moduleCount = graph.nodes.count
        complexity = graph.multiGraphComplexity
    }
}
