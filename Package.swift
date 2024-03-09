// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TraktKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v15),
        .watchOS(.v8)
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
            ),
        .testTarget(
            name: "TraktKitTests",
            dependencies: ["TraktKit"],
            resources: [
                .process("Models")
            ]
        ),
    ],
    swiftLanguageVersions: [.version("5.7")]
)
