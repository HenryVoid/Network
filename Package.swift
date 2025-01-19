// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["NetworkKit"]
        ),
    ],
    swiftLanguageVersions: [.version("6")]
)
