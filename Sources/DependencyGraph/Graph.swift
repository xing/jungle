import Foundation

public struct Graph {
    public let nodes: Set<Node>
    public let multiEdges: [Edge]
    public var uniqueEdges: Set<Edge> { Set(multiEdges) }

    public init(nodes: Set<Node>, multiEdges: [Edge]) {
        self.nodes = nodes
        self.multiEdges = multiEdges
    }

    public struct Node: Hashable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    public struct Edge: Hashable {
        public let source: String
        public let target: String

        public init(source: String, target: String) {
            self.source = source
            self.target = target
        }
    }
}
