#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
    public import Kernel
#endif

extension Console.Input {

    public enum Error: Swift.Error, Sendable {

        case terminal(Terminal.Error)

        case parser(Terminal.Input.Parser.Error)

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

            case read(Kernel.IO.Read.Error)

            case write(Kernel.IO.Write.Error)
        #endif
    }
}
