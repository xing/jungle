import XCTest
@testable import Networking

final class NetworkClientTests: XCTestCase {
    func testNetworkClient() async throws {
        let client = NetworkClient()
        let result = try await client.request("/test")
        XCTAssertNotNil(result)
    }
}
