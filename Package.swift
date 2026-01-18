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
        .package(path: "../swift-posix"),
        .package(path: "../../swift-standards/swift-ecma-48"),
        .package(path: "../../swift-primitives/swift-test-primitives"),
    ],
    targets: [
        .target(
            name: "Console",
            dependencies: [
                // POSIX Kernel re-exports Terminal Primitives with callAsFunction implementations
                .product(name: "POSIX Kernel", package: "swift-posix", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
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
