import Foundation
import Core
import Networking
import DataLayer
import APIClient
import ImageService
import Feature1
import Feature2

public struct SPMSample {
    private let apiClient = APIClient()
    private let imageLoader = ImageLoader()
    private let feature1 = Feature1()
    private let feature2 = Feature2()
    private let logger = Logger()

    public init() {}

    public func run() async {
        logger.log("SPM Sample - Complex multi-module architecture")
        do {
            try await apiClient.fetchAndStore(endpoint: "/api/data")
            imageLoader.loadImage(from: URL(string: "https://example.com/image.png")!)

            await feature1.execute()
            await feature2.execute()

            logger.log("Application running successfully")
        } catch {
            logger.error("Error: \(error)")
        }
    }
}
