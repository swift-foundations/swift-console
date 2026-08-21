internal import Byte_Primitive
import Testing

@testable import Console

extension Console.Input {
    @Suite
    struct Test {
        @Suite struct Integration {}
    }
}

extension Console.Input.Test.Integration {
    @Test
    func `Single ASCII character produces key event`() throws {
        let bytes: [Byte] = [0x61]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .character("a"))))
    }

    @Test
    func `Up arrow escape sequence produces key event`() throws {
        let bytes: [Byte] = [0x1B, 0x5B, 0x41]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .up)))
    }

    @Test
    func `Down arrow escape sequence produces key event`() throws {
        let bytes: [Byte] = [0x1B, 0x5B, 0x42]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .down)))
    }

    @Test
    func `Right arrow escape sequence produces key event`() throws {
        let bytes: [Byte] = [0x1B, 0x5B, 0x43]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .right)))
    }

    @Test
    func `Left arrow escape sequence produces key event`() throws {
        let bytes: [Byte] = [0x1B, 0x5B, 0x44]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .left)))
    }

    @Test
    func `Carriage return produces enter key event`() throws {
        let bytes: [Byte] = [0x0D]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .enter)))
    }

    @Test
    func `Tab byte produces tab key event`() throws {
        let bytes: [Byte] = [0x09]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .tab)))
    }

    @Test
    func `Empty input throws emptyInput error`() {
        let bytes: [Byte] = []
        var input = Input.Buffer(bytes)

        do throws(Terminal.Input.Parser.Error) {
            _ = try Terminal.Input.Parser.parse(&input)
            Issue.record("Expected emptyInput error")
        } catch {
            #expect(error == .emptyInput)
        }
    }

    @Test
    func `Incomplete escape sequence throws incompleteSequence`() {
        let bytes: [Byte] = [0x1B]
        var input = Input.Buffer(bytes)

        do throws(Terminal.Input.Parser.Error) {
            _ = try Terminal.Input.Parser.parse(&input)
            Issue.record("Expected incompleteSequence error")
        } catch {
            #expect(error == .incompleteSequence)
        }
    }

    @Test
    func `Partial CSI sequence throws incompleteSequence`() {
        let bytes: [Byte] = [0x1B, 0x5B]
        var input = Input.Buffer(bytes)

        do throws(Terminal.Input.Parser.Error) {
            _ = try Terminal.Input.Parser.parse(&input)
            Issue.record("Expected incompleteSequence error")
        } catch {
            #expect(error == .incompleteSequence)
        }
    }

    @Test
    func `Accumulated bytes parse after completing escape sequence`() throws {

        var parseBuffer: [Byte] = [0x1B]

        var input1 = Input.Buffer(parseBuffer)
        do throws(Terminal.Input.Parser.Error) {
            _ = try Terminal.Input.Parser.parse(&input1)
            Issue.record("Expected incompleteSequence for partial ESC")
        } catch {
            #expect(error == .incompleteSequence)
        }

        parseBuffer.append(contentsOf: [0x5B, 0x41] as [Byte])
        var input2 = Input.Buffer(parseBuffer)
        let event = try Terminal.Input.Parser.parse(&input2)
        #expect(event == .key(Terminal.Input.Key(code: .up)))
    }

    @Test
    func `Sequential parsing from shared buffer`() throws {

        let bytes: [Byte] = [0x61, 0x62]
        var input = Input.Buffer(bytes)

        let event1 = try Terminal.Input.Parser.parse(&input)
        #expect(event1 == .key(Terminal.Input.Key(code: .character("a"))))

        let event2 = try Terminal.Input.Parser.parse(&input)
        #expect(event2 == .key(Terminal.Input.Key(code: .character("b"))))
    }

    @Test
    func `Home key escape sequence`() throws {
        let bytes: [Byte] = [0x1B, 0x5B, 0x48]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .home)))
    }

    @Test
    func `End key escape sequence`() throws {
        let bytes: [Byte] = [0x1B, 0x5B, 0x46]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .end)))
    }

    @Test
    func `Delete key escape sequence`() throws {

        let bytes: [Byte] = [0x1B, 0x5B, 0x33, 0x7E]
        var input = Input.Buffer(bytes)
        let event = try Terminal.Input.Parser.parse(&input)
        #expect(event == .key(Terminal.Input.Key(code: .delete)))
    }
}
