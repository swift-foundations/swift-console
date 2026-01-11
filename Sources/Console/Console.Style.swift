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

public import ECMA_48

extension Console {
    /// Text style for console output.
    ///
    /// Combines foreground color, background color, and text attributes
    /// into a single style that can be applied to text.
    public struct Style: Sendable, Hashable {
        /// Foreground color.
        public var foreground: ECMA_48.SGR.Color?

        /// Background color.
        public var background: ECMA_48.SGR.Color?

        /// Text attributes (bold, italic, etc).
        public var attributes: Set<ECMA_48.SGR.Attribute>

        /// Creates a style.
        public init(
            foreground: ECMA_48.SGR.Color? = nil,
            background: ECMA_48.SGR.Color? = nil,
            attributes: Set<ECMA_48.SGR.Attribute> = []
        ) {
            self.foreground = foreground
            self.background = background
            self.attributes = attributes
        }
    }
}

// MARK: - Common Styles

extension Console.Style {
    /// No styling (plain text).
    public static let plain = Console.Style()

    /// Bold text.
    public static let bold = Console.Style(attributes: [.bold])

    /// Dim text.
    public static let dim = Console.Style(attributes: [.dim])

    /// Error style (red).
    public static let error = Console.Style(
        foreground: .palette(.red),
        attributes: [.bold]
    )

    /// Warning style (yellow).
    public static let warning = Console.Style(
        foreground: .palette(.yellow)
    )

    /// Success style (green).
    public static let success = Console.Style(
        foreground: .palette(.green)
    )

    /// Info style (blue).
    public static let info = Console.Style(
        foreground: .palette(.blue)
    )
}

// MARK: - Sequence Generation

extension Console.Style {
    /// Generate ANSI escape sequence for this style.
    ///
    /// - Parameter capability: Console capability to respect
    /// - Returns: ANSI escape sequence, or empty string if no color support
    public func sequence(for capability: Console.Capability) -> String {
        guard capability.color.isSupported else { return "" }

        var codes: [String] = []

        // Add attributes
        for attr in attributes.sorted(by: { $0.rawValue < $1.rawValue }) {
            codes.append("\(attr.rawValue)")
        }

        // Add foreground color
        if let fg = foreground {
            codes.append(contentsOf: fg.foregroundCodes(for: capability.color))
        }

        // Add background color
        if let bg = background {
            codes.append(contentsOf: bg.backgroundCodes(for: capability.color))
        }

        guard !codes.isEmpty else { return "" }
        return "\(ECMA_48.csi)\(codes.joined(separator: ";"))m"
    }

    /// Reset sequence.
    public static func resetSequence(for capability: Console.Capability) -> String {
        guard capability.color.isSupported else { return "" }
        return ECMA_48.SGR.Attribute.reset.sequence
    }
}

// MARK: - Text Application

extension Console.Style {
    /// Apply this style to text.
    ///
    /// - Parameters:
    ///   - text: Text to style
    ///   - capability: Console capability to respect
    /// - Returns: Styled text (with reset at end)
    public func apply(to text: String, capability: Console.Capability) -> String {
        let start = sequence(for: capability)
        guard !start.isEmpty else { return text }
        let end = Self.resetSequence(for: capability)
        return start + text + end
    }
}

// MARK: - Color Code Generation

extension ECMA_48.SGR.Color {
    /// Get foreground color codes for given capability.
    internal func foregroundCodes(for capability: Console.Capability.Color) -> [String] {
        switch self {
        case .palette(let p):
            // 4-bit colors: 30-37 (normal), 90-97 (bright)
            if p.rawValue < 8 {
                return ["\(30 + p.rawValue)"]
            } else {
                return ["\(90 + p.rawValue - 8)"]
            }

        case .extended(let index):
            guard capability >= .palette8 else {
                // Downgrade to nearest 4-bit color
                return ["\(30 + (Int(index) % 8))"]
            }
            return ["38", "5", "\(index)"]

        case .rgb(let r, let g, let b):
            guard capability >= .trueColor else {
                // Downgrade: try 256-color first, then 16-color
                if capability >= .palette8 {
                    let index = rgbTo256(r: r, g: g, b: b)
                    return ["38", "5", "\(index)"]
                }
                let index = rgbTo16(r: r, g: g, b: b)
                if index < 8 {
                    return ["\(30 + index)"]
                } else {
                    return ["\(90 + index - 8)"]
                }
            }
            return ["38", "2", "\(r)", "\(g)", "\(b)"]
        }
    }

    /// Get background color codes for given capability.
    internal func backgroundCodes(for capability: Console.Capability.Color) -> [String] {
        switch self {
        case .palette(let p):
            if p.rawValue < 8 {
                return ["\(40 + p.rawValue)"]
            } else {
                return ["\(100 + p.rawValue - 8)"]
            }

        case .extended(let index):
            guard capability >= .palette8 else {
                return ["\(40 + (Int(index) % 8))"]
            }
            return ["48", "5", "\(index)"]

        case .rgb(let r, let g, let b):
            guard capability >= .trueColor else {
                if capability >= .palette8 {
                    let index = rgbTo256(r: r, g: g, b: b)
                    return ["48", "5", "\(index)"]
                }
                let index = rgbTo16(r: r, g: g, b: b)
                if index < 8 {
                    return ["\(40 + index)"]
                } else {
                    return ["\(100 + index - 8)"]
                }
            }
            return ["48", "2", "\(r)", "\(g)", "\(b)"]
        }
    }

    /// Convert RGB to nearest 256-color palette index.
    private func rgbTo256(r: UInt8, g: UInt8, b: UInt8) -> UInt8 {
        // Use 6x6x6 color cube (indices 16-231)
        let ri = Int(r) * 5 / 255
        let gi = Int(g) * 5 / 255
        let bi = Int(b) * 5 / 255
        return UInt8(16 + 36 * ri + 6 * gi + bi)
    }

    /// Convert RGB to nearest 16-color palette index.
    private func rgbTo16(r: UInt8, g: UInt8, b: UInt8) -> Int {
        // Simple luminance-based mapping
        let luminance = (Int(r) + Int(g) + Int(b)) / 3
        let bright = luminance > 127

        // Find dominant color
        let maxC = max(r, g, b)
        if maxC < 64 {
            return bright ? 8 : 0  // black/bright black
        }

        var index = 0
        if r > 127 { index |= 1 }
        if g > 127 { index |= 2 }
        if b > 127 { index |= 4 }

        return bright ? index + 8 : index
    }
}
