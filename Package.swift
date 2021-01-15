// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TraktKit",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v12),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "TraktKit",
            targets: ["TraktKit"]),
    ],
    targets: [
        .target(
            name: "TraktKit",
            dependencies: [],
            path: "Common"
            )
    ],
    swiftLanguageVersions: [.v5]
)
