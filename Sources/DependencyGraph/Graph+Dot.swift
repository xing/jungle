import Foundation

public extension Graph {

    var multiEdgeDOT: String {
        let edges = multiEdges
            .map { "\t \"\($0.source)\" -> \"\($0.target)\"" }
            .joined(separator: "\n")

        return "\(header(usingUniqueEdges: false)) \(edges) \(footer)"
    }

    var multiEdgeStats: String {
        "nodes: \(nodes.count), edges: \(multiEdges.count), complexity: \(multiGraphComplexity)"
    }
    
    var uniqueEdgeStats: String {
        "nodes: \(nodes.count), edges: \(uniqueEdges.count), complexity: \(regularGraphComplexity)"
    }
    
    var uniqueEdgeDOT: String {
        let edges = uniqueEdges
            .map { "\t \"\($0.source)\" -> \"\($0.target)\"" }
            .joined(separator: "\n")


        return "\(header(usingUniqueEdges: true)) \(edges) \(footer)"
    }

    private func header(usingUniqueEdges: Bool) -> String {
        """
        digraph DependencyGraph {
            labelloc=b
            fontsize=20
            label = "\(usingUniqueEdges ? uniqueEdgeStats : multiEdgeStats)"
            graph [bgcolor=white,pad=2];
            node [style=filled,shape=box,fillcolor=white,color=grey10,fontname=helveticaNeue,fontcolor=grey10,penwidth=2];
            edge [dir=back,color=grey10,penwidth=1];
        
        """
    }

    private var footer: String {
        "\n}\n"
    }
}
