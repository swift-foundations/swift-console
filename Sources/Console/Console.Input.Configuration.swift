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

extension Console.Input {
    /// Configuration for which terminal modes to enable during input reading.
    public struct Configuration: Sendable {
        /// Enable mouse tracking (SGR any-event mode).
        public var mouse: Bool

        /// Enable bracketed paste mode.
        public var paste: Bool

        /// Enable Kitty keyboard protocol.
        public var kitty: Bool

        /// Creates a configuration with explicit settings.
        public init(mouse: Bool, paste: Bool, kitty: Bool) {
            self.mouse = mouse
            self.paste = paste
            self.kitty = kitty
        }
    }
}

extension Console.Input.Configuration {
    /// Default configuration: bracketed paste only.
    public static let `default` = Self(mouse: false, paste: true, kitty: false)

    /// Full configuration: all modes enabled.
    public static let full = Self(mouse: true, paste: true, kitty: true)
}
