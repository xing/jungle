// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DependencyStats",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "DependencyStats", targets: ["DependencyStats"]),
        .library(name: "PodExtractor", targets: ["PodExtractor"]),
        .library(name: "DependencyGraph", targets: ["DependencyGraph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1")
    ],
    targets: [
        
        // Executable
        .executableTarget(
            name: "DependencyStats",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "PodExtractor"),
                .target(name: "DependencyGraph")
            ]
        ),
        .testTarget(
            name: "DependencyStatsTests",
            dependencies: ["DependencyStats"]
        ),
        
        // PodExtractor
        .target(
            name: "PodExtractor",
            dependencies: [
                .target(name: "DependencyModule"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "PodExtractorTests",
            dependencies: ["PodExtractor"]
        ),

        // DependencyGraph
        .target(
            name: "DependencyGraph",
            dependencies: ["DependencyModule"]
        ),
        .testTarget(
            name: "DependencyGraphTests",
            dependencies: ["DependencyGraph"]
        ),

        // DependencyModule
        .target(
            name: "DependencyModule"
        )
    ]
)
