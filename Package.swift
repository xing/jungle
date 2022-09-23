// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jungle",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "jungle", targets: ["jungle"]),
        .library(name: "PodExtractor", targets: ["PodExtractor"]),
        .library(name: "DependencyGraph", targets: ["DependencyGraph"]),
        .library(name: "Shell", targets: ["Shell"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1")
    ],
    targets: [
        
        // Executable
        .executableTarget(
            name: "jungle",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "PodExtractor"),
                .target(name: "DependencyGraph"),
                .target(name: "Shell")
            ]
        ),
        .testTarget(
            name: "jungleTests",
            dependencies: ["jungle"]
        ),
        
        // PodExtractor
        .target(
            name: "PodExtractor",
            dependencies: [
                .target(name: "DependencyModule"),
                .target(name: "Shell"),
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
        ),
        
        // Shell
        .target(
            name: "Shell"
        )
    ]
)
