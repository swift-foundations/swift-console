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

extension Console.Capability {
    /// Color support level.
    public enum Color: Sendable, Hashable, Comparable {
        /// No color support.
        case none

        /// 4-bit color (16 colors).
        case palette4

        /// 8-bit color (256 colors).
        case palette8

        /// 24-bit true color (16 million colors).
        case trueColor
    }
}

extension Console.Capability.Color {
    /// Whether any color is supported.
    public var isSupported: Bool {
        self != .none
    }

    /// Number of supported colors.
    public var colorCount: Int {
        switch self {
        case .none: return 0
        case .palette4: return 16
        case .palette8: return 256
        case .trueColor: return 16_777_216
        }
    }
}
