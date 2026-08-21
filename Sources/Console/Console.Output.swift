#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    @preconcurrency import Glibc
#elseif os(Windows)
    import CRT
#endif

extension Console {

    public enum Output {}
}

extension Console.Output {

    public static func flush() {
        unsafe fflush(stdout)
    }
}

extension Console.Output {

    public static func error(_ text: Swift.String) {
        text.withCString { pointer in
            _ = unsafe fputs(pointer, stderr)
        }
    }
}
