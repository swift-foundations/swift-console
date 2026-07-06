// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-console open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-console project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif os(Windows)
    import CRT
#endif

#if canImport(Glibc)
    // Glibc imports `stdout` as a mutable global `var`, which is not
    // concurrency-safe under Swift 6 strict concurrency ("reference to var
    // 'stdout' is not concurrency-safe because it involves shared mutable
    // state"). The underlying `FILE *` handle is process-global and stable
    // for the process lifetime, so bind it once at file scope. Darwin and
    // CRT expose `stdout` in a concurrency-safe form and use it directly.
    nonisolated(unsafe) private let systemStdout = unsafe stdout
#endif

extension Console {
    /// Output stream operations.
    public enum Output {
        /// Flushes buffered standard output.
        ///
        /// Ensures `print()` output is visible immediately when stdout
        /// is piped. SwiftPM's test harness pipes stdout, making it fully
        /// buffered instead of line-buffered — without an explicit flush,
        /// progress output sits invisibly in the buffer.
        public static func flush() {
            #if canImport(Glibc)
                unsafe fflush(systemStdout)
            #else
                unsafe fflush(stdout)
            #endif
        }
    }
}
