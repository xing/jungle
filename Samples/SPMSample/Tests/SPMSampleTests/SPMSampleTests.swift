import XCTest
@testable import SPMSample

final class SPMSampleTests: XCTestCase {
    func testSample() async throws {
        let sample = SPMSample()
        await sample.run()
    }
}
