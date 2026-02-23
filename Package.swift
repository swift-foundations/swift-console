// swift-tools-version: 6.2

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
        .package(path: "../swift-posix"),
        .package(path: "../../swift-standards/swift-ecma-48")
    ],
    targets: [
        .target(
            name: "Console",
            dependencies: [
                // POSIX Kernel re-exports Terminal Primitives with callAsFunction implementations
                .product(name: "POSIX Kernel", package: "swift-posix", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])),
                .product(name: "ECMA 48", package: "swift-ecma-48")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
