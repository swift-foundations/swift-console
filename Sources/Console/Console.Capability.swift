extension Console {

    public struct Capability: Sendable, Hashable {

        public let color: Color

        public let cursorControl: Bool

        public let alternateScreen: Bool

        public init(
            color: Color,
            cursorControl: Bool,
            alternateScreen: Bool
        ) {
            self.color = color
            self.cursorControl = cursorControl
            self.alternateScreen = alternateScreen
        }
    }
}

extension Console.Capability {

    public static let none = Console.Capability(
        color: .none,
        cursorControl: false,
        alternateScreen: false
    )

    public static let basic = Console.Capability(
        color: .palette4,
        cursorControl: true,
        alternateScreen: false
    )

    public static let full = Console.Capability(
        color: .trueColor,
        cursorControl: true,
        alternateScreen: true
    )
}
