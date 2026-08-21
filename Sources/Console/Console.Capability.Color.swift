extension Console.Capability {

    public enum Color: Sendable, Hashable, Comparable {

        case none

        case palette4

        case palette8

        case trueColor
    }
}

extension Console.Capability.Color {

    public var isSupported: Bool {
        self != .none
    }

    public var colorCount: Int {
        switch self {
        case .none: return 0
        case .palette4: return 16
        case .palette8: return 256
        case .trueColor: return 16_777_216
        }
    }
}
