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

@Suite("Console.Input.Configuration Tests")
struct ConfigurationTests {
    @Test("Default configuration enables paste only")
    func defaultConfiguration() {
        let config = Console.Input.Configuration.default
        #expect(config.mouse == false)
        #expect(config.paste == true)
        #expect(config.kitty == false)
    }

    @Test("Full configuration enables all modes")
    func fullConfiguration() {
        let config = Console.Input.Configuration.full
        #expect(config.mouse == true)
        #expect(config.paste == true)
        #expect(config.kitty == true)
    }

    @Test("Custom configuration preserves values")
    func customConfiguration() {
        let config = Console.Input.Configuration(mouse: true, paste: false, kitty: true)
        #expect(config.mouse == true)
        #expect(config.paste == false)
        #expect(config.kitty == true)
    }

    @Test("Configuration is mutable")
    func mutableConfiguration() {
        var config = Console.Input.Configuration.default
        config.mouse = true
        #expect(config.mouse == true)
        #expect(config.paste == true)
    }
}

@Suite("Console.Input.Error Tests")
struct InputErrorTests {
    @Test("Terminal error wraps correctly")
    func terminalError() {
        let underlying = Terminal.Error(
            operation: .enterRaw,
            underlying: .unsupported
        )
        let error = Console.Input.Error.terminal(underlying)
        if case .terminal(let e) = error {
            #expect(e.operation == .enterRaw)
        } else {
            Issue.record("Expected .terminal case")
        }
    }

    @Test("Parser error wraps correctly")
    func parserError() {
        let error = Console.Input.Error.parser(.invalidUTF8)
        if case .parser(let e) = error {
            #expect(e == .invalidUTF8)
        } else {
            Issue.record("Expected .parser case")
        }
    }
}

@Suite("Terminal.Mode Sequence Tests")
struct ModeSequenceTests {
    @Test("Mouse normal mode sequences")
    func mouseNormal() {
        #expect(Terminal.Mode.Mouse.Normal.enable == "\u{1B}[?1000h")
        #expect(Terminal.Mode.Mouse.Normal.disable == "\u{1B}[?1000l")
    }

    @Test("Mouse button mode sequences")
    func mouseButton() {
        #expect(Terminal.Mode.Mouse.Button.enable == "\u{1B}[?1002h")
        #expect(Terminal.Mode.Mouse.Button.disable == "\u{1B}[?1002l")
    }

    @Test("Mouse any-event mode sequences")
    func mouseAny() {
        #expect(Terminal.Mode.Mouse.Any.enable == "\u{1B}[?1003h")
        #expect(Terminal.Mode.Mouse.Any.disable == "\u{1B}[?1003l")
    }

    @Test("Mouse SGR encoding sequences")
    func mouseSGR() {
        #expect(Terminal.Mode.Mouse.SGR.enable == "\u{1B}[?1006h")
        #expect(Terminal.Mode.Mouse.SGR.disable == "\u{1B}[?1006l")
    }

    @Test("Bracketed paste mode sequences")
    func paste() {
        #expect(Terminal.Mode.Paste.enable == "\u{1B}[?2004h")
        #expect(Terminal.Mode.Paste.disable == "\u{1B}[?2004l")
    }

    @Test("Alternate screen mode sequences")
    func screen() {
        #expect(Terminal.Mode.Screen.enable == "\u{1B}[?1049h")
        #expect(Terminal.Mode.Screen.disable == "\u{1B}[?1049l")
    }

    @Test("Kitty keyboard protocol sequences")
    func keyboard() {
        #expect(Terminal.Mode.Keyboard.enable == "\u{1B}[>1u")
        #expect(Terminal.Mode.Keyboard.disable == "\u{1B}[<u")
    }
}
