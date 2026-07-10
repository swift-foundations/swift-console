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

extension Console.Capability {
    @Suite
    struct Test {
        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Color levels are comparable`() {
            #expect(Console.Capability.Color.none < .palette4)
            #expect(Console.Capability.Color.palette4 < .palette8)
            #expect(Console.Capability.Color.palette8 < .trueColor)
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Color count is correct`() {
            #expect(Console.Capability.Color.none.colorCount == 0)
            #expect(Console.Capability.Color.palette4.colorCount == 16)
            #expect(Console.Capability.Color.palette8.colorCount == 256)
            #expect(Console.Capability.Color.trueColor.colorCount == 16_777_216)
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Static capabilities are correct`() {
            #expect(Console.Capability.none.color == .none)
            #expect(Console.Capability.basic.color == .palette4)
            #expect(Console.Capability.full.color == .trueColor)
        }
    }
}

extension Console.Style {
    @Suite
    struct Test {
        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Plain style produces no sequence`() {
            let style = Console.Style.plain
            let seq = style.sequence(for: .full)
            #expect(seq.isEmpty)
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Bold style produces correct sequence`() {
            let style = Console.Style.bold
            let seq = style.sequence(for: .full)
            #expect(seq == "\u{001B}[1m")
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Console.Style.error produces correct sequence`() {
            let style = Console.Style.error
            let seq = style.sequence(for: .full)
            // Bold (1) + red foreground (31)
            #expect(seq.contains("1"))
            #expect(seq.contains("31"))
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Style respects capability level`() {
            let style = Console.Style.error
            let noColorSeq = style.sequence(for: .none)
            #expect(noColorSeq.isEmpty)
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Apply adds reset at end`() {
            let style = Console.Style.bold
            let result = style.apply(to: "test", capability: .full)
            #expect(result.hasSuffix("\u{001B}[0m"))
        }
    }
}

extension ECMA_48.SGR.Color {
    @Suite
    struct Test {
        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Palette color foreground sequence`() {
            let color = ECMA_48.SGR.Color.palette(.red)
            let codes = color.foregroundCodes(for: .palette4)
            #expect(codes == ["31"])
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Bright palette color foreground sequence`() {
            let color = ECMA_48.SGR.Color.palette(.brightRed)
            let codes = color.foregroundCodes(for: .palette4)
            #expect(codes == ["91"])
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `Extended color sequence`() {
            let color = ECMA_48.SGR.Color.extended(196)
            let codes = color.foregroundCodes(for: .palette8)
            #expect(codes == ["38", "5", "196"])
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `RGB color sequence`() {
            let color = ECMA_48.SGR.Color.rgb(r: 255, g: 128, b: 64)
            let codes = color.foregroundCodes(for: .trueColor)
            #expect(codes == ["38", "2", "255", "128", "64"])
        }

        // swiftlint:disable:next prefer_self_in_static_references - reason: `@Test` is the swift-testing attribute macro, not a reference to the enclosing `struct Test`; the rule's token-matching false-positives on the name collision (verified via swiftlint --fix, which incorrectly rewrites `@Test` to `@Self`).
        @Test
        func `RGB downgrades to 256-color`() {
            let color = ECMA_48.SGR.Color.rgb(r: 255, g: 0, b: 0)
            let codes = color.foregroundCodes(for: .palette8)
            #expect(codes[0] == "38")
            #expect(codes[1] == "5")
        }
    }
}
