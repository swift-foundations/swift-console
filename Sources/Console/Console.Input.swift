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

extension Console {
    /// Terminal input event reading.
    public enum Input {}
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

    extension Console.Input {
        /// Run a closure with terminal input event reading.
        ///
        /// Enters raw mode, enables configured features (mouse, paste, etc.),
        /// reads and parses input events, then restores the terminal on exit.
        ///
        /// ```swift
        /// try Console.Input.withEvents { next in
        ///     while let event = try next() {
        ///         switch event {
        ///         case .key(let key) where key.code == .character("q"):
        ///             return  // exit
        ///         default:
        ///             break
        ///         }
        ///     }
        /// }
        /// ```
        ///
        /// - Parameters:
        ///   - stream: Terminal stream to read from (default: stdin).
        ///   - configuration: Which modes to enable (default: `.default`).
        ///   - body: Closure receiving a `next()` function that returns the next event,
        ///     or `nil` on EOF.
        /// - Throws: ``Console.Input.Error`` on terminal, parser, or read failure.
        public static func withEvents(
            stream: Terminal.Stream = .stdin,
            configuration: Configuration = .default,
            _ body: ( /* next: */() throws(Error) -> Terminal.Input.Event?) throws(Error) -> Void
        ) throws(Error) {
            var reader = try Reader.start(stream: stream, configuration: configuration)

            defer {
                do throws(Self.Error) {
                    try reader.stop()
                } catch {
                    // Best-effort terminal restoration. If this fails, the terminal
                    // may be left in raw mode. Nothing more we can do here.
                }
            }

            try body { () throws(Error) -> Terminal.Input.Event? in
                try reader.nextEvent()
            }
        }
    }

#endif
