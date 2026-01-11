// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-console open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-console project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Console {
    /// Console capabilities.
    ///
    /// Represents the detected capabilities of the current console,
    /// including color support level and control features.
    public struct Capability: Sendable, Hashable {
        /// Color support level.
        public let color: Color

        /// Whether cursor movement is supported.
        public let cursorControl: Bool

        /// Whether alternate screen buffer is supported.
        public let alternateScreen: Bool

        /// Creates a capability set.
        public init(
            color: Color,
            cursorControl: Bool,
            alternateScreen: Bool
        ) {
            self.color = color
            self.cursorControl = cursorControl
            self.alternateScreen = alternateScreen
        }
    }
}

extension Console.Capability {
    /// No capabilities (plain text).
    public static let none = Console.Capability(
        color: .none,
        cursorControl: false,
        alternateScreen: false
    )

    /// Basic capabilities (4-bit color).
    public static let basic = Console.Capability(
        color: .palette4,
        cursorControl: true,
        alternateScreen: false
    )

    /// Full capabilities (24-bit color).
    public static let full = Console.Capability(
        color: .trueColor,
        cursorControl: true,
        alternateScreen: true
    )
}
