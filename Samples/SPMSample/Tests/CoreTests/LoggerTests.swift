import XCTest
@testable import Core

final class LoggerTests: XCTestCase {
    func testLogger() {
        let logger = Logger()
        logger.log("Test message")
        logger.error("Test error")
    }
}
