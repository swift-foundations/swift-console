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

import Testing
@testable import Console

@Suite("Console.Capability Tests")
struct CapabilityTests {
    @Test("Color levels are comparable")
    func colorComparable() {
        #expect(Console.Capability.Color.none < .palette4)
        #expect(Console.Capability.Color.palette4 < .palette8)
        #expect(Console.Capability.Color.palette8 < .trueColor)
    }

    @Test("Color count is correct")
    func colorCount() {
        #expect(Console.Capability.Color.none.colorCount == 0)
        #expect(Console.Capability.Color.palette4.colorCount == 16)
        #expect(Console.Capability.Color.palette8.colorCount == 256)
        #expect(Console.Capability.Color.trueColor.colorCount == 16_777_216)
    }

    @Test("Static capabilities are correct")
    func staticCapabilities() {
        #expect(Console.Capability.none.color == .none)
        #expect(Console.Capability.basic.color == .palette4)
        #expect(Console.Capability.full.color == .trueColor)
    }
}

@Suite("Console.Style Tests")
struct StyleTests {
    @Test("Plain style produces no sequence")
    func plainStyle() {
        let style = Console.Style.plain
        let seq = style.sequence(for: .full)
        #expect(seq.isEmpty)
    }

    @Test("Bold style produces correct sequence")
    func boldStyle() {
        let style = Console.Style.bold
        let seq = style.sequence(for: .full)
        #expect(seq == "\u{001B}[1m")
    }

    @Test("Error style produces correct sequence")
    func errorStyle() {
        let style = Console.Style.error
        let seq = style.sequence(for: .full)
        // Bold (1) + red foreground (31)
        #expect(seq.contains("1"))
        #expect(seq.contains("31"))
    }

    @Test("Style respects capability level")
    func styleRespectsCapability() {
        let style = Console.Style.error
        let noColorSeq = style.sequence(for: .none)
        #expect(noColorSeq.isEmpty)
    }

    @Test("Apply adds reset at end")
    func applyAddsReset() {
        let style = Console.Style.bold
        let result = style.apply(to: "test", capability: .full)
        #expect(result.hasSuffix("\u{001B}[0m"))
    }
}

@Suite("ECMA_48 Color Sequence Tests")
struct ColorSequenceTests {
    @Test("Palette color foreground sequence")
    func paletteColorForeground() {
        let color = ECMA_48.SGR.Color.palette(.red)
        let codes = color.foregroundCodes(for: .palette4)
        #expect(codes == ["31"])
    }

    @Test("Bright palette color foreground sequence")
    func brightPaletteForeground() {
        let color = ECMA_48.SGR.Color.palette(.brightRed)
        let codes = color.foregroundCodes(for: .palette4)
        #expect(codes == ["91"])
    }

    @Test("Extended color sequence")
    func extendedColorSequence() {
        let color = ECMA_48.SGR.Color.extended(196)
        let codes = color.foregroundCodes(for: .palette8)
        #expect(codes == ["38", "5", "196"])
    }

    @Test("RGB color sequence")
    func rgbColorSequence() {
        let color = ECMA_48.SGR.Color.rgb(r: 255, g: 128, b: 64)
        let codes = color.foregroundCodes(for: .trueColor)
        #expect(codes == ["38", "2", "255", "128", "64"])
    }

    @Test("RGB downgrades to 256-color")
    func rgbDowngradeTo256() {
        let color = ECMA_48.SGR.Color.rgb(r: 255, g: 0, b: 0)
        let codes = color.foregroundCodes(for: .palette8)
        #expect(codes[0] == "38")
        #expect(codes[1] == "5")
    }
}
