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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

    import Byte_Primitive
    import Standard_Library_Extensions
    import Terminal_Input_Primitives
    import Kernel
    // Terminal Primitives symbols (Terminal.Mode/Stream/Input) reach here via Kernel Terminal's
    // @_exported re-export — compose the L3-unifier, not the L3-policy tier [PLAT-ARCH-008e].
    import Kernel_Terminal

    /// Internal reader that manages raw mode lifecycle, stdin reads, and parser loop.
    extension Console.Input {
        internal struct Reader: ~Copyable {
            let stream: Terminal.Stream
            let configuration: Configuration
            var token: Terminal.Mode.Raw.Token
            var parseBuffer: ContiguousArray<Byte>
        }
    }

    extension Console.Input.Reader {
        /// Enter raw mode and enable configured terminal modes.
        static func start(
            stream: Terminal.Stream,
            configuration: Console.Input.Configuration
        ) throws(Console.Input.Error) -> Self {
            let token: Terminal.Mode.Raw.Token
            do throws(Terminal.Error) {
                token = try stream.mode.raw.enter()
            } catch {
                throw .terminal(error)
            }

            var reader = Self(
                stream: stream,
                configuration: configuration,
                token: token,
                parseBuffer: ContiguousArray()
            )

            do throws(Console.Input.Error) {
                try reader.writeEnableSequences()
            } catch {
                // Best-effort: don't leave the terminal stuck in raw mode just
                // because an enable sequence failed to write.
                try? reader.token.restore()
                throw error
            }

            return reader
        }

        /// Disable terminal modes and restore the previous mode.
        mutating func stop() throws(Console.Input.Error) {
            var writeError: Console.Input.Error?
            do throws(Console.Input.Error) {
                try writeDisableSequences()
            } catch {
                writeError = error
            }

            do throws(Terminal.Error) {
                try token.restore()
            } catch {
                // Mode restoration failure is the more serious of the two —
                // a terminal stuck in raw mode outranks an unset feature
                // mode — so it takes priority if both failed.
                throw .terminal(error)
            }

            if let writeError {
                throw writeError
            }
        }

        /// Read bytes and parse the next input event.
        ///
        /// Returns `nil` on EOF (zero bytes read).
        mutating func nextEvent() throws(Console.Input.Error) -> Terminal.Input.Event? {
            while true {
                // Try parsing from accumulated bytes first.
                if !parseBuffer.isEmpty {
                    var input = Input.Buffer(parseBuffer)

                    do {
                        let event = try Terminal.Input.Parser.parse(&input)
                        // Remove consumed bytes from the front.
                        let consumed = Int(bitPattern: input.consumed)
                        parseBuffer.removeFirst(consumed)
                        return event
                    } catch Terminal.Input.Parser.Error.incompleteSequence {
                        // Need more bytes — fall through to read.
                    } catch Terminal.Input.Parser.Error.emptyInput {
                        // Buffer was empty — fall through to read.
                    } catch {
                        throw .parser(error)
                    }
                }

                // Read more bytes from the terminal.
                let bytesRead = try readBytes()
                if bytesRead == 0 {
                    return nil  // EOF
                }
            }
        }
    }

    // MARK: - Read

    extension Console.Input.Reader {
        /// Read bytes from stdin into the parse buffer.
        ///
        /// Returns the number of bytes read.
        private mutating func readBytes() throws(Console.Input.Error) -> Int {
            let bytesRead: Int
            do throws(Kernel.IO.Read.Error) {
                bytesRead = try unsafe withUnsafeTemporaryAllocation(
                    byteCount: 4096,
                    alignment: 1
                ) { (rawBuffer: UnsafeMutableRawBufferPointer) throws(Kernel.IO.Read.Error) -> Int in
                    let n = try unsafe stream.read(into: rawBuffer)
                    if n > 0 {
                        let typed = unsafe UnsafeBufferPointer(
                            start: rawBuffer.baseAddress!.assumingMemoryBound(to: Byte.self),
                            count: n
                        )
                        unsafe self.parseBuffer.append(contentsOf: typed)
                    }
                    return n
                }
            } catch {
                throw .read(error)
            }
            return bytesRead
        }
    }

    // MARK: - Mode Sequences

    extension Console.Input.Reader {
        /// Write enable sequences to the raw-mode stream based on configuration.
        private func writeEnableSequences() throws(Console.Input.Error) {
            if configuration.mouse {
                try write(Terminal.Mode.Mouse.Any.enable)
                try write(Terminal.Mode.Mouse.SGR.enable)
            }
            if configuration.paste {
                try write(Terminal.Mode.Paste.enable)
            }
            if configuration.kitty {
                try write(Terminal.Mode.Keyboard.enable)
            }
        }

        /// Write disable sequences to the raw-mode stream based on configuration.
        private func writeDisableSequences() throws(Console.Input.Error) {
            if configuration.kitty {
                try write(Terminal.Mode.Keyboard.disable)
            }
            if configuration.paste {
                try write(Terminal.Mode.Paste.disable)
            }
            if configuration.mouse {
                try write(Terminal.Mode.Mouse.SGR.disable)
                try write(Terminal.Mode.Mouse.Any.disable)
            }
        }

        /// Write a control sequence to the terminal device associated with
        /// this reader's raw-mode stream.
        ///
        /// Goes through the `Terminal.Stream.Write` Kernel witness bound to
        /// `self.stream` — the same stream raw mode was entered on — instead
        /// of a raw `write(2)` call hard-coded to stdout. The witness retries
        /// on EINTR and loops over partial writes internally. Unlike the
        /// previous implementation, a failure here is no longer silently
        /// swallowed: it surfaces as ``Console.Input.Error/write(_:)``.
        private func write(_ string: Swift.String) throws(Console.Input.Error) {
            do throws(Kernel.IO.Write.Error) {
                try stream.write(string.utf8.map(Byte.init))
            } catch {
                throw .write(error)
            }
        }
    }

#endif
