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
    public import Kernel
#endif

extension Console.Input {
    /// Errors that can occur during console input reading.
    public enum Error: Swift.Error, Sendable {
        /// Terminal mode operation failed (entering/exiting raw mode).
        case terminal(Terminal.Error)

        /// Input parser encountered invalid data.
        case parser(Terminal.Input.Parser.Error)

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
            /// Reading from the terminal stream failed.
            case read(Kernel.IO.Read.Error)
        #endif
    }
}
