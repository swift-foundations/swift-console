public import ECMA_48

extension Console {

    public struct Style: Sendable, Hashable {

        public var foreground: ECMA_48.SGR.Color?

        public var background: ECMA_48.SGR.Color?

        public var attributes: Set<ECMA_48.SGR.Attribute>

        public init(
            foreground: ECMA_48.SGR.Color? = nil,
            background: ECMA_48.SGR.Color? = nil,
            attributes: Set<ECMA_48.SGR.Attribute> = []
        ) {
            self.foreground = foreground
            self.background = background
            self.attributes = attributes
        }
    }
}

extension Console.Style {

    public static let plain = Console.Style()

    public static let bold = Console.Style(attributes: [.bold])

    public static let dim = Console.Style(attributes: [.dim])

    public static let error = Console.Style(
        foreground: .palette(.red),
        attributes: [.bold]
    )

    public static let warning = Console.Style(
        foreground: .palette(.yellow)
    )

    public static let success = Console.Style(
        foreground: .palette(.green)
    )

    public static let info = Console.Style(
        foreground: .palette(.blue)
    )
}

extension Console.Style {

    public func sequence(for capability: Console.Capability) -> Swift.String {
        guard capability.color.isSupported else { return "" }

        var codes: [Swift.String] = []

        for attr in attributes.sorted(by: { $0.rawValue < $1.rawValue }) {
            codes.append("\(attr.rawValue)")
        }

        if let fg = foreground {
            codes.append(contentsOf: fg.foregroundCodes(for: capability.color))
        }

        if let bg = background {
            codes.append(contentsOf: bg.backgroundCodes(for: capability.color))
        }

        guard !codes.isEmpty else { return "" }
        return "\(ECMA_48.csi)\(codes.joined(separator: ";"))m"
    }

    public static func resetSequence(for capability: Console.Capability) -> Swift.String {
        guard capability.color.isSupported else { return "" }
        return ECMA_48.SGR.Attribute.reset.sequence
    }
}

extension Console.Style {

    public func apply(to text: Swift.String, capability: Console.Capability) -> Swift.String {
        let start = sequence(for: capability)
        guard !start.isEmpty else { return text }
        let end = Self.resetSequence(for: capability)
        return start + text + end
    }
}

extension ECMA_48.SGR.Color {

    internal func foregroundCodes(for capability: Console.Capability.Color) -> [Swift.String] {
        switch self {
        case .palette(let p):

            if p.rawValue < 8 {
                return ["\(30 + p.rawValue)"]
            } else {
                return ["\(90 + p.rawValue - 8)"]
            }

        case .extended(let index):
            guard capability >= .palette8 else {

                return ["\(30 + (Int(index) % 8))"]
            }
            return ["38", "5", "\(index)"]

        case .rgb(let r, let g, let b):
            guard capability >= .trueColor else {

                if capability >= .palette8 {
                    let index = rgbTo256(r: r, g: g, b: b)
                    return ["38", "5", "\(index)"]
                }
                let index = rgbTo16(r: r, g: g, b: b)
                if index < 8 {
                    return ["\(30 + index)"]
                } else {
                    return ["\(90 + index - 8)"]
                }
            }
            return ["38", "2", "\(r)", "\(g)", "\(b)"]
        }
    }

    internal func backgroundCodes(for capability: Console.Capability.Color) -> [Swift.String] {
        switch self {
        case .palette(let p):
            if p.rawValue < 8 {
                return ["\(40 + p.rawValue)"]
            } else {
                return ["\(100 + p.rawValue - 8)"]
            }

        case .extended(let index):
            guard capability >= .palette8 else {
                return ["\(40 + (Int(index) % 8))"]
            }
            return ["48", "5", "\(index)"]

        case .rgb(let r, let g, let b):
            guard capability >= .trueColor else {
                if capability >= .palette8 {
                    let index = rgbTo256(r: r, g: g, b: b)
                    return ["48", "5", "\(index)"]
                }
                let index = rgbTo16(r: r, g: g, b: b)
                if index < 8 {
                    return ["\(40 + index)"]
                } else {
                    return ["\(100 + index - 8)"]
                }
            }
            return ["48", "2", "\(r)", "\(g)", "\(b)"]
        }
    }

    private func rgbTo256(r: UInt8, g: UInt8, b: UInt8) -> UInt8 {

        let ri = Int(r) * 5 / 255
        let gi = Int(g) * 5 / 255
        let bi = Int(b) * 5 / 255
        return UInt8(16 + 36 * ri + 6 * gi + bi)
    }

    private func rgbTo16(r: UInt8, g: UInt8, b: UInt8) -> Int {

        let luminance = (Int(r) + Int(g) + Int(b)) / 3
        let bright = luminance > 127

        let maxC = max(r, g, b)
        if maxC < 64 {
            return bright ? 8 : 0
        }

        var index = 0
        if r > 127 { index |= 1 }
        if g > 127 { index |= 2 }
        if b > 127 { index |= 4 }

        return bright ? index + 8 : index
    }
}
