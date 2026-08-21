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

    public static func detect(stream: Terminal.Stream = .stdout) -> Self {

        if getEnvironment("NO_COLOR") != nil {
            return .none
        }

        let forceColor = getEnvironment("FORCE_COLOR") != nil

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
            let interactive = stream.interactive()
        #else

            let interactive = false
        #endif
        guard forceColor || interactive else {
            return .none
        }

        let isCI =
            getEnvironment("CI") != nil
            || getEnvironment("GITHUB_ACTIONS") != nil
            || getEnvironment("GITLAB_CI") != nil

        if let colorterm = getEnvironment("COLORTERM") {
            let value = colorterm.lowercased()
            if value == "truecolor" || value == "24bit" {
                return .full
            }
        }

        guard let term = getEnvironment("TERM"), !term.isEmpty else {

            if isCI || forceColor {
                return .basic
            }
            return .none
        }

        if term == "dumb" {
            return .none
        }

        if term.contains("256color") || term.contains("256-color") {
            return Console.Capability(
                color: .palette8,
                cursorControl: true,
                alternateScreen: true
            )
        }

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

        return .basic
    }
}

extension Console.Capability {

    private static func getEnvironment(_ name: Swift.String) -> Swift.String? {
        guard let ptr = unsafe getenv(name) else { return nil }
        return unsafe Swift.String(cString: ptr)
    }
}
