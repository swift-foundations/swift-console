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

extension Console.Input {
    @Suite
    struct Test {
        @Suite struct Integration {}
    }
}

// MARK: - Integration
//
// These tests exercise the parse-accumulate pattern used by Console.Input.Reader.
// They feed byte sequences through Terminal.Input.Parser.parse to verify correct
// event production, including partial sequence handling (accumulation).

extension Console.Input.Test.Integration {
    @Test
    func `Single ASCII character produces key event`() throws {
        let bytes: [UInt8] = [0x61] // 'a'
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .character("a"))))
    }

    @Test
    func `Up arrow escape sequence produces key event`() throws {
        let bytes: [UInt8] = [0x1B, 0x5B, 0x41] // ESC[A
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .up)))
    }

    @Test
    func `Down arrow escape sequence produces key event`() throws {
        let bytes: [UInt8] = [0x1B, 0x5B, 0x42] // ESC[B
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .down)))
    }

    @Test
    func `Right arrow escape sequence produces key event`() throws {
        let bytes: [UInt8] = [0x1B, 0x5B, 0x43] // ESC[C
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .right)))
    }

    @Test
    func `Left arrow escape sequence produces key event`() throws {
        let bytes: [UInt8] = [0x1B, 0x5B, 0x44] // ESC[D
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .left)))
    }

    @Test
    func `Carriage return produces enter key event`() throws {
        let bytes: [UInt8] = [0x0D] // CR
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .enter)))
    }

    @Test
    func `Tab byte produces tab key event`() throws {
        let bytes: [UInt8] = [0x09] // HT
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .tab)))
    }

    @Test
    func `Empty input throws emptyInput error`() {
        let bytes: [UInt8] = []
        var input = Input.Buffer(bytes)

        do {
            _ = try Terminal.Input.Parser.parse(&input)
            Issue.record("Expected emptyInput error")
        } catch {
            #expect(error == .emptyInput)
        }
    }

    @Test
    func `Incomplete escape sequence throws incompleteSequence`() {
        let bytes: [UInt8] = [0x1B] // ESC alone
        var input = Input.Buffer(bytes)

        do {
            _ = try Terminal.Input.Parser.parse(&input)
            Issue.record("Expected incompleteSequence error")
        } catch {
            #expect(error == .incompleteSequence)
        }
    }

    @Test
    func `Partial CSI sequence throws incompleteSequence`() {
        let bytes: [UInt8] = [0x1B, 0x5B] // ESC[ without final byte
        var input = Input.Buffer(bytes)

        do {
            _ = try Terminal.Input.Parser.parse(&input)
            Issue.record("Expected incompleteSequence error")
        } catch {
            #expect(error == .incompleteSequence)
        }
    }

    @Test
    func `Accumulated bytes parse after completing escape sequence`() throws {
        // Simulates Reader accumulation: ESC arrives alone, then [A arrives
        var parseBuffer: [UInt8] = [0x1B]

        // Phase 1: ESC alone → incomplete
        var input1 = Input.Buffer(parseBuffer)
        do {
            _ = try Terminal.Input.Parser.parse(&input1)
            Issue.record("Expected incompleteSequence for partial ESC")
        } catch {
            #expect(error == .incompleteSequence)
        }

        // Phase 2: Append remaining bytes → full sequence parses
        parseBuffer.append(contentsOf: [0x5B, 0x41] as [UInt8])
        var input2 = Input.Buffer(parseBuffer)
        let event = try Terminal.Input.Parser.parse(&input2)
        #expect(event == .key(Terminal.Input.Key(code: .up)))
    }

    @Test
    func `Sequential parsing from shared buffer`() throws {
        // Two characters in one buffer, parsed sequentially
        let bytes: [UInt8] = [0x61, 0x62] // 'a', 'b'
        var input = Input.Buffer(bytes)

        let event1 = try Terminal.Input.Parser.parse(&input)
        #expect(event1 == .key(Terminal.Input.Key(code: .character("a"))))

        let event2 = try Terminal.Input.Parser.parse(&input)
        #expect(event2 == .key(Terminal.Input.Key(code: .character("b"))))
    }

    @Test
    func `Home key escape sequence`() throws {
        let bytes: [UInt8] = [0x1B, 0x5B, 0x48] // ESC[H
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .home)))
    }

    @Test
    func `End key escape sequence`() throws {
        let bytes: [UInt8] = [0x1B, 0x5B, 0x46] // ESC[F
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .end)))
    }

    @Test
    func `Delete key escape sequence`() throws {
        // Delete: ESC[3~
        let bytes: [UInt8] = [0x1B, 0x5B, 0x33, 0x7E] // ESC[3~
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .delete)))
    }
}
