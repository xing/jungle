// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "jungle",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "jungle", targets: ["jungle"]),
        .library(name: "PodExtractor", targets: ["PodExtractor"]),
        .library(name: "SPMExtractor", targets: ["SPMExtractor"]),
        .library(name: "DependencyGraph", targets: ["DependencyGraph"]),
        .library(name: "Shell", targets: ["Shell"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1")
    ],
    targets: [
        
        // Executable
        .executableTarget(
            name: "jungle",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "PodExtractor"),
                .target(name: "SPMExtractor"),
                .target(name: "DependencyGraph"),
                .target(name: "Shell")
            ]
        ),
        .testTarget(
            name: "jungleTests",
            dependencies: ["jungle"]
        ),
        
        // Pod Extractor
        .target(
            name: "PodExtractor",
            dependencies: [
                "DependencyModule",
                "Shell",
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .testTarget(
            name: "PodExtractorTests",
            dependencies: ["PodExtractor"]
        ),
        // SPM Extractor
        .target(
            name: "SPMExtractor",
            dependencies: [
                "DependencyModule",
                "Shell"
            ]
        ),
        .testTarget(
            name: "SPMExtractorTests",
            dependencies: ["SPMExtractor"]
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
