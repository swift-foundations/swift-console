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
    @preconcurrency import Glibc
#elseif os(Windows)
    import CRT
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
            unsafe fflush(stdout)
        }
    }
}
