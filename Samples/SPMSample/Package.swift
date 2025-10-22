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
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.45.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.0"),
    ],
    targets: [
        .target(
            name: "SPMSample",
            dependencies: [
                "Alamofire",
                .product(name: "RealmSwift", package: "realm-swift"),
                "SwiftyJSON",
                "Kingfisher",
            ]),
        .testTarget(
            name: "SPMSampleTests",
            dependencies: ["SPMSample"]),
    ]
)
