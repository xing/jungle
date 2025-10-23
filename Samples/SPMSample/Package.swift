// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SPMSample",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SPMSample",
            targets: ["SPMSample"]),
        .library(
            name: "Networking",
            targets: ["Networking"]),
        .library(
            name: "DataLayer",
            targets: ["DataLayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.45.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
    ],
    targets: [
        // Core utilities module (no dependencies)
        .target(
            name: "Core",
            dependencies: []),

        // Networking layer (depends on Core and Alamofire)
        .target(
            name: "Networking",
            dependencies: [
                "Core",
                "Alamofire",
                "SwiftyJSON",
            ]),

        // Data persistence layer (depends on Core and RealmSwift)
        .target(
            name: "DataLayer",
            dependencies: [
                "Core",
                .product(name: "RealmSwift", package: "realm-swift"),
            ]),

        // API client (depends on Networking and DataLayer)
        .target(
            name: "APIClient",
            dependencies: [
                "Networking",
                "DataLayer",
            ]),

        // Image loading service (depends on Core and Kingfisher)
        .target(
            name: "ImageService",
            dependencies: [
                "Core",
                "Kingfisher",
            ]),

        // Feature 1 (depends on APIClient and ImageService)
        .target(
            name: "Feature1",
            dependencies: [
                "Core",
                "APIClient",
                "ImageService",
            ]),

        // Feature 2 (depends on Networking and DataLayer)
        .target(
            name: "Feature2",
            dependencies: [
                "Core",
                "Networking",
                "DataLayer",
            ]),

        // Main app module (depends on everything)
        .target(
            name: "SPMSample",
            dependencies: [
                "Core",
                "Networking",
                "DataLayer",
                "APIClient",
                "ImageService",
                "Feature1",
                "Feature2",
            ]),

        // Tests
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]),
        .testTarget(
            name: "SPMSampleTests",
            dependencies: ["SPMSample"]),
    ]
)
