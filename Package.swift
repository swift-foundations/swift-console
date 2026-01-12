// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-console",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Console",
            targets: ["Console"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-terminal-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-ecma-48.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Console",
            dependencies: [
                .product(name: "Terminal Primitives", package: "swift-terminal-primitives"),
                .product(name: "ECMA 48", package: "swift-ecma-48"),
            ]
        ),
        .testTarget(
            name: "Console Tests",
            dependencies: [
                "Console",
                .product(name: "Test Primitives", package: "swift-test-primitives"),
            ],
            path: "Tests/Console Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
