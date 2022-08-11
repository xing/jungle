import Foundation

public extension Graph {
    
    var multiEdgeDOT: String {
        let edges = multiEdges
            .map { "\t \"\($0.source)\" -> \"\($0.target)\"" }
            .joined(separator: "\n")

        let stats = "# nodes: \(nodes.count), edges: \(multiEdges.count), complexity: \(multiGraphComplexity)"

        return "\(header) \(edges) \(footer) \(stats)"
    }

    var uniqueEdgeDOT: String {
        let edges = uniqueEdges
            .map { "\t \"\($0.source)\" -> \"\($0.target)\"" }
            .joined(separator: "\n")

        let stats = "# nodes: \(nodes.count), edges: \(uniqueEdges.count), complexity: \(multiGraphComplexity)"

        return "\(header) \(edges) \(footer) \(stats)"
    }

    private var header: String {
        """
        digraph DependencyGraph {

            graph [bgcolor=white,pad=2];
            node [style=filled,shape=box,fillcolor=white,color=grey10,fontname=helveticaNeue,fontcolor=grey10,penwidth=2];
            edge [dir=back,color=grey10,penwidth=1];

        
        """
    }

    private var footer: String {
        "\n}\n"
    }
}
