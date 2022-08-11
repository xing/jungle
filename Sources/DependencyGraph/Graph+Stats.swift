import Foundation

public extension Graph {
    var multiGraphComplexity: Int {
        multiEdges.count - nodes.count + 1
    }

    var regularGraphComplexity: Int {
        uniqueEdges.count - nodes.count + 1
    }
}
