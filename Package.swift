// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-console",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Console",
            targets: ["Console"]
        )
    ],
    dependencies: [
        .package(path: "../swift-kernel"),
        .package(path: "../../swift-ecma/swift-ecma-48"),
        .package(path: "../../swift-primitives/swift-terminal-primitives"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
    ],
    targets: [
        .target(
            name: "Console",
            dependencies: [
                // Kernel (L3-unifier) composes POSIX Kernel which re-exports Terminal Primitives
                // with callAsFunction implementations. Per [PLAT-ARCH-008e], swift-console
                // composes the L3-unifier, not the L3-policy directly.
                .product(name: "Kernel", package: "swift-kernel", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "Kernel Terminal", package: "swift-kernel", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "ECMA 48", package: "swift-ecma-48"),
                .product(name: "Terminal Input Primitives", package: "swift-terminal-primitives"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
            ]
        ),
        .testTarget(
            name: "Console Tests",
            dependencies: [
                "Console",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
