import Foundation
import Networking
import DataLayer

public class APIClient {
    private let networkClient = NetworkClient()
    private let databaseManager = DatabaseManager()

    public init() {}

    public func fetchAndStore(endpoint: String) async throws {
        let data = try await networkClient.request(endpoint)
        // Process and store data
        print("Fetched and stored data from \(endpoint)")
    }
}
