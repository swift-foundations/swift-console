# swift-console

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Terminal capability detection, capability-adaptive ANSI styling, and raw-mode input event reading for Swift command-line programs.

---

## Key Features

- **Policy-based capability detection** — `Console.Capability.detect()` combines the `NO_COLOR` and `FORCE_COLOR` conventions, `COLORTERM`/`TERM` inspection, TTY checks, and CI-environment heuristics into one call.
- **Graceful color downgrade** — declare a style once with an RGB color; the emitted escape sequence is truecolor, 256-color, or 16-color to match the detected terminal — or nothing at all when color is unsupported.
- **Raw-mode input with guaranteed restore** — `Console.Input.withEvents` enters raw mode, enables the configured modes (bracketed paste, SGR mouse tracking, Kitty keyboard protocol), and restores the terminal on every exit path, including thrown errors.
- **Typed throws end-to-end** — input failures surface as `Console.Input.Error` with distinct terminal, parser, and read cases; no `any Error` escapes the API.
- **ECMA-48 grounded** — styles are expressed in `ECMA_48.SGR` types (re-exported by this package), not raw escape-string literals.

---

## Quick Start

### Styled output

Hand-rolled ANSI coloring breaks in pipes, in `NO_COLOR` environments, and on 16-color terminals. Styles applied through a detected `Console.Capability` degrade correctly in all three cases:

```swift
import Console

let capability = Console.Capability.detect()

print(Console.Style.error.apply(to: "error:", capability: capability) + " missing input file")
print(Console.Style.success.apply(to: "ok", capability: capability) + " 42 tests passed")

// An RGB style downgrades by itself: truecolor where supported,
// nearest 256- or 16-color code otherwise, plain text when piped.
let accent = Console.Style(
    foreground: .rgb(r: 255, g: 128, b: 0),
    attributes: [.bold]
)
print(accent.apply(to: "1.2 MB written", capability: capability))
```

### Input events

Reading keys directly from a terminal requires entering raw mode, decoding escape sequences, and — critically — restoring the terminal afterwards, or the user's shell is left unusable. `withEvents` owns that whole lifecycle:

```swift
import Console

try Console.Input.withEvents(configuration: .full) { next in
    while let event = try next() {
        switch event {
        case .key(let key) where key.code == .character("q"):
            return  // terminal mode is restored on exit
        default:
            break
        }
    }
}
```

`Configuration.default` enables bracketed paste only; `.full` adds SGR mouse tracking and the Kitty keyboard protocol.

---

## Installation

Add swift-console to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-console.git", branch: "main")
]
```

Add the product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Console", package: "swift-console")
    ]
)
```

### Requirements

- Swift 6.3+
- macOS 26.0+, iOS 26.0+, tvOS 26.0+, watchOS 26.0+, visionOS 26.0+
- `Console.Input` (raw-mode event reading) is compiled for Apple platforms and Linux; `Console.Capability`, `Console.Style`, and `Console.Output` have no platform condition.

---

## Architecture

Single module (`Console`), organized around four nested namespaces:

| Type | Purpose |
|------|---------|
| `Console.Capability` | Detected terminal feature set: color level, cursor control, alternate screen. Presets `.none`, `.basic`, `.full`; runtime `.detect(stream:)`. |
| `Console.Capability.Color` | Comparable color-support level: `.none`, `.palette4` (16), `.palette8` (256), `.trueColor` (16.7M). |
| `Console.Style` | Foreground/background color plus attribute set; presets `.plain`, `.bold`, `.dim`, `.error`, `.warning`, `.success`, `.info`; renders via `sequence(for:)` and `apply(to:capability:)`. |
| `Console.Input` | Raw-mode event loop via `withEvents(stream:configuration:_:)`, yielding parsed `Terminal.Input.Event` values. |
| `Console.Output` | `flush()` for buffered stdout (visible progress output when stdout is piped). |

Importing `Console` re-exports `ECMA_48` (SGR colors and attributes) and the terminal input event types, so one import suffices for the examples above.

---

## Error Handling

`Console.Input.withEvents` throws `Console.Input.Error`:

```
Console.Input.Error
├── .terminal(Terminal.Error)             // entering or restoring raw mode failed
├── .parser(Terminal.Input.Parser.Error)  // invalid input byte sequence
└── .read(Kernel.IO.Read.Error)           // reading from the stream failed
```

Exhaustive handling:

```swift
do {
    try Console.Input.withEvents { next in
        while let event = try next() { /* handle event */ }
    }
} catch .terminal(let error) {
    // Raw-mode entry/exit failed; the stream may not be a TTY.
} catch .parser(let error) {
    // The terminal sent a byte sequence the parser rejects.
} catch .read(let error) {
    // The underlying read syscall failed.
}
```

Capability detection and style rendering do not throw.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE](LICENSE.md) for details.
