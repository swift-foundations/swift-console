extension Console.Input {

    public struct Configuration: Sendable {

        public var mouse: Bool

        public var paste: Bool

        public var kitty: Bool

        public init(mouse: Bool, paste: Bool, kitty: Bool) {
            self.mouse = mouse
            self.paste = paste
            self.kitty = kitty
        }
    }
}

extension Console.Input.Configuration {

    public static let `default` = Self(mouse: false, paste: true, kitty: false)

    public static let full = Self(mouse: true, paste: true, kitty: true)
}
