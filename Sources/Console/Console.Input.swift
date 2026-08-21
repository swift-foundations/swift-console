extension Console {

    public enum Input {}
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

    extension Console.Input {

        public static func withEvents(
            stream: Terminal.Stream = .stdin,
            configuration: Configuration = .default,
            _ body: (() throws(Error) -> Terminal.Input.Event?) throws(Error) -> Void
        ) throws(Error) {
            var reader = try Reader.start(stream: stream, configuration: configuration)

            defer {
                do throws(Self.Error) {
                    try reader.stop()
                } catch {

                }
            }

            try body { () throws(Error) -> Terminal.Input.Event? in
                try reader.nextEvent()
            }
        }
    }

#endif
