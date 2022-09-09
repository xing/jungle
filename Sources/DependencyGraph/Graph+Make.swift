import Foundation
import DependencyModule

public enum GraphError: Error {
    case moduleNotFound
}

public extension Graph {
    static func makeForVirtualAppModule(name: String, dependencies: [Module], targetDependencies: [String]?) throws -> Graph {
        
        let dependencies = dependencies
            .filter { targetDependencies?.contains($0.name) ?? true }
 
        let appModule = Module(name: name, dependencies: dependencies.map(\.name))

        return try makeForModule(name: name, dependencies: [appModule] + dependencies)
    }
    
    static func makeForModule(name: String, dependencies: [Module]) throws -> Graph  {
        let lookup = Dictionary(uniqueKeysWithValues: dependencies.map { ($0.name, $0) })

        guard lookup.keys.contains(name) else { throw GraphError.moduleNotFound }
        
        let edges = collectEdges(rootDependencyName: name, lookup: lookup)
        let nodes = edges.flatMap {
            [Graph.Node(name: $0.source), Graph.Node(name: $0.target)]
        }

        return .init(nodes: Set(nodes), multiEdges: edges)
    }
}

private func collectEdges(rootDependencyName: String, lookup: [String: Module]) -> [Graph.Edge] {
    guard let module = lookup[rootDependencyName] else { return [] }

    let currentEdges = module.dependencies.map {
        Graph.Edge(source: rootDependencyName, target: $0)
    }

    return currentEdges + module.dependencies.flatMap {
        collectEdges(rootDependencyName: $0, lookup: lookup)
    }
}
