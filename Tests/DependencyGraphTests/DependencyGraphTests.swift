import XCTest
import DependencyModule
@testable import DependencyGraph

final class DependencyGraphTests: XCTestCase {

    func testSimpleTreeYieldsNodesAndEdges() throws {
        let top = Module(name: "Top", dependencies: ["A", "B", "C"])
        let a = Module(name: "A", dependencies: ["A1", "A2"])
        let b = Module(name: "B", dependencies: ["B1", "B2"])

        let graph = try Graph.makeForModule(name: "Top", dependencies: [top, a, b])
        XCTAssertEqual(graph.multiEdges.count, 7)
        XCTAssertEqual(graph.uniqueEdges.count, 7)
        XCTAssertEqual(graph.nodes.count, 8)
        XCTAssertEqual(graph.regularGraphComplexity, 0)
        XCTAssertEqual(graph.multiGraphComplexity, 0)
    }

    func testComplexTreeYieldsNodesAndEdges() throws {
        let top = Module(name: "Top", dependencies: ["A", "B", "C"])
        let a = Module(name: "A", dependencies: ["A1", "A2", "C"])
        let b = Module(name: "B", dependencies: ["B1", "B2", "C"])
        let c = Module(name: "C", dependencies: ["C1", "C2"])

        let graph = try Graph.makeForModule(name: "Top", dependencies: [top, a, b, c])
        XCTAssertEqual(graph.multiEdges.count, 15)
        XCTAssertEqual(graph.uniqueEdges.count, 11)
        XCTAssertEqual(graph.nodes.count, 10)
        XCTAssertEqual(graph.regularGraphComplexity, 2)
        XCTAssertEqual(graph.multiGraphComplexity, 6)
    }

    func testGraphWithVirtualNode() throws {
        let a = Module(name: "A", dependencies: ["A1", "A2", "C"])
        let b = Module(name: "B", dependencies: ["B1", "B2", "C"])
        let c = Module(name: "C", dependencies: ["C1", "C2"])

        let graph = try Graph.make(rootTargetName: "Top", modules: [a, b, c], targetDependencies: nil)
        XCTAssertEqual(graph.multiEdges.count, 15)
        XCTAssertEqual(graph.uniqueEdges.count, 11)
        XCTAssertEqual(graph.nodes.count, 10)
        XCTAssertEqual(graph.regularGraphComplexity, 2)
        XCTAssertEqual(graph.multiGraphComplexity, 6)
    }
}
