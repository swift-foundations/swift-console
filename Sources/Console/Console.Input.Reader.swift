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

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#endif

import Standard_Library_Extensions
import Terminal_Primitives
import Terminal_Input_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives

/// Internal reader that manages raw mode lifecycle, stdin reads, and parser loop.
extension Console.Input {
    internal struct Reader: ~Copyable {
        let stream: Terminal.Stream
        let configuration: Configuration
        var token: Terminal.Mode.Raw.Token
        var parseBuffer: ContiguousArray<UInt8>

        /// Enter raw mode and enable configured terminal modes.
        static func start(
            stream: Terminal.Stream,
            configuration: Configuration
        ) throws(Console.Input.Error) -> Self {
            let token: Terminal.Mode.Raw.Token
            do {
                token = try stream.mode.raw.enter()
            } catch {
                throw .terminal(error)
            }

            let reader = Reader(
                stream: stream,
                configuration: configuration,
                token: token,
                parseBuffer: ContiguousArray()
            )

            reader.writeEnableSequences()

            return reader
        }

        /// Disable terminal modes and restore the previous mode.
        mutating func stop() throws(Console.Input.Error) {
            writeDisableSequences()
            do {
                try token.restore()
            } catch {
                throw .terminal(error)
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
                        let consumed = Int(bitPattern: input.consumedCount)
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
                    return nil // EOF
                }
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
        do {
            bytesRead = try unsafe withUnsafeTemporaryAllocation(
                byteCount: 4096,
                alignment: 1
            ) { (rawBuffer: UnsafeMutableRawBufferPointer) throws(Kernel.IO.Read.Error) -> Int in
                let n = try unsafe stream.read(into: rawBuffer)
                if n > 0 {
                    let typed = unsafe UnsafeBufferPointer(
                        start: rawBuffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
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
    /// Write enable sequences to stdout based on configuration.
    private func writeEnableSequences() {
        if configuration.mouse {
            writeToStdout(Terminal.Mode.Mouse.Any.enable)
            writeToStdout(Terminal.Mode.Mouse.SGR.enable)
        }
        if configuration.paste {
            writeToStdout(Terminal.Mode.Paste.enable)
        }
        if configuration.kitty {
            writeToStdout(Terminal.Mode.Keyboard.enable)
        }
    }

    /// Write disable sequences to stdout based on configuration.
    private func writeDisableSequences() {
        if configuration.kitty {
            writeToStdout(Terminal.Mode.Keyboard.disable)
        }
        if configuration.paste {
            writeToStdout(Terminal.Mode.Paste.disable)
        }
        if configuration.mouse {
            writeToStdout(Terminal.Mode.Mouse.SGR.disable)
            writeToStdout(Terminal.Mode.Mouse.Any.disable)
        }
    }

    /// Write a string to stdout using the POSIX write syscall.
    private func writeToStdout(_ string: Swift.String) {
        unsafe string.withCString { pointer in
            var remaining = unsafe strlen(pointer)
            var current = unsafe pointer
            while remaining > 0 {
                let written = unsafe write(
                    Terminal.Stream.stdout.rawValue,
                    current,
                    remaining
                )
                guard written > 0 else { return }
                remaining -= written
                unsafe (current = current.advanced(by: written))
            }
        }
    }
}

#endif
