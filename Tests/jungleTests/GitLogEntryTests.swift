import XCTest
import DependencyModule
@testable import jungle

final class GitLogEntryTests: XCTestCase {
    func testParseYieldsGitLogEntry() throws {
        let entry = try GitLogEntry.parse(
            from: "abbd80e;2022-07-09T21:29:20+02:00;Shammi Didla;restructure something"
        )

        XCTAssertNotNil(entry)
    }

    func testParseRemovesNewLinesInMessage() throws {
        let entry = try GitLogEntry.parse(
            from: "abbd80e;2022-07-09T21:29:20+02:00;Shammi Didla;restructure \n something"
        )

        XCTAssertEqual(entry.message, "restructure . something")
    }
    
    func testMakeCSVRow() async throws  {
        let podfile = """
        PODS:
          - A (1.0.0):
            - B
            - C
          - D (1.0.0)
          - C
        """
        
        let entry: GitLogEntry = try .parse(
            from: "abbd80e;2022-07-09T21:29:20+02:00;Shammi Didla;restructure \n something"
        )
        
        let target: Module = .init(name: "T", dependencies: ["A", "C"])
        
        let row = try await entry.process(pod: nil, podfile: podfile, target: target).csv
        XCTAssertEqual(row.description, "2022-07-09T21:29:20+02:00;abbd80e;4;1;Shammi Didla;restructure . something")
    }
}


