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

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif os(Windows)
    import CRT
#endif

extension Console.Capability {
    /// Detect console capabilities using environment conventions.
    ///
    /// Uses policy-based detection following common conventions:
    /// - `NO_COLOR`: Disables all color (https://no-color.org)
    /// - `FORCE_COLOR`: Forces color even for non-TTY
    /// - `COLORTERM=truecolor|24bit`: Enables 24-bit color
    /// - `TERM`: Determines basic capability level
    ///
    /// - Parameter stream: The stream to check (default: stdout)
    /// - Returns: Detected capabilities
    public static func detect(stream: Terminal.Stream = .stdout) -> Self {
        // NO_COLOR convention (highest priority)
        if getEnvironment("NO_COLOR") != nil {
            return .none
        }

        // FORCE_COLOR overrides TTY check
        let forceColor = getEnvironment("FORCE_COLOR") != nil

        // Check if stream is interactive (TTY)
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
            let interactive = stream.interactive()
        #else
            // Windows: Kernel Terminal witnesses (callAsFunction TTY detection) are not
            // composed on this platform (Package.swift conditions Kernel to POSIX), so
            // conservatively treat the stream as non-interactive; color requires
            // FORCE_COLOR. Real Windows detection lands with a Windows Kernel composition.
            let interactive = false
        #endif
        guard forceColor || interactive else {
            return .none
        }

        // CI environments often support color but aren't TTYs
        let isCI =
            getEnvironment("CI") != nil
            || getEnvironment("GITHUB_ACTIONS") != nil
            || getEnvironment("GITLAB_CI") != nil

        // COLORTERM convention for true color
        if let colorterm = getEnvironment("COLORTERM") {
            let value = colorterm.lowercased()
            if value == "truecolor" || value == "24bit" {
                return .full
            }
        }

        // TERM-based detection
        guard let term = getEnvironment("TERM"), !term.isEmpty else {
            // No TERM but CI environment often supports basic color
            if isCI || forceColor {
                return .basic
            }
            return .none
        }

        // "dumb" terminal has no capabilities
        if term == "dumb" {
            return .none
        }

        // 256-color detection
        if term.contains("256color") || term.contains("256-color") {
            return Console.Capability(
                color: .palette8,
                cursorControl: true,
                alternateScreen: true
            )
        }

        // Common terminals with true color support
        let trueColorTerminals = [
            "xterm-direct",
            "iterm2",
            "vte",
        ]

        for known in trueColorTerminals {
            if term.lowercased().contains(known) {
                return .full
            }
        }

        // Default: basic 16-color support for most terminals
        return .basic
    }
}

// MARK: - Environment Access

extension Console.Capability {
    /// Get environment variable value.
    private static func getEnvironment(_ name: Swift.String) -> Swift.String? {
        guard let ptr = unsafe getenv(name) else { return nil }
        return unsafe Swift.String(cString: ptr)
    }
}
