import Foundation
import Core
import APIClient
import ImageService

public class Feature1 {
    private let apiClient = APIClient()
    private let imageLoader = ImageLoader()
    private let logger = Logger()

    public init() {}

    public func execute() async {
        logger.log("Feature1: Executing user profile feature")
        do {
            try await apiClient.fetchAndStore(endpoint: "/api/user/profile")
            imageLoader.loadImage(from: URL(string: "https://example.com/avatar.png")!)
            logger.log("Feature1: User profile loaded successfully")
        } catch {
            logger.error("Feature1: Error - \(error)")
        }
    }
}
