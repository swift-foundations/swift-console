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

import Testing

@testable import Console

extension Console.Input.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit

extension Console.Input.Error.Test.Unit {
    @Test
    func `Terminal case wraps Terminal.Error`() {
        let underlying = Terminal.Error(
            operation: .enterRaw,
            underlying: .unsupported
        )
        let error = Console.Input.Error.terminal(underlying)
        if case .terminal(let e) = error {
            #expect(e.operation == .enterRaw)
        } else {
            Issue.record("Expected .terminal case")
        }
    }

    @Test
    func `Parser case wraps Parser.Error`() {
        let error = Console.Input.Error.parser(.invalidUTF8)
        if case .parser(let e) = error {
            #expect(e == .invalidUTF8)
        } else {
            Issue.record("Expected .parser case")
        }
    }

    @Test
    func `Parser case wraps emptyInput`() {
        let error = Console.Input.Error.parser(.emptyInput)
        if case .parser(let e) = error {
            #expect(e == .emptyInput)
        } else {
            Issue.record("Expected .parser case")
        }
    }

    @Test
    func `Parser case wraps incompleteSequence`() {
        let error = Console.Input.Error.parser(.incompleteSequence)
        if case .parser(let e) = error {
            #expect(e == .incompleteSequence)
        } else {
            Issue.record("Expected .parser case")
        }
    }

    @Test
    func `Parser case wraps unrecognizedSequence`() {
        let error = Console.Input.Error.parser(.unrecognizedSequence)
        if case .parser(let e) = error {
            #expect(e == .unrecognizedSequence)
        } else {
            Issue.record("Expected .parser case")
        }
    }

    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
        @Test
        func `Read case wraps Kernel.IO.Read.Error`() {
            let error = Console.Input.Error.read(.handle(.invalid))
            if case .read(let e) = error {
                #expect(e == .handle(.invalid))
            } else {
                Issue.record("Expected .read case")
            }
        }
    #endif
}

// MARK: - EdgeCase

extension Console.Input.Error.Test.EdgeCase {
    @Test
    func `All three cases are distinct`() {
        let terminal = Console.Input.Error.terminal(
            Terminal.Error(operation: .enterRaw, underlying: .unsupported)
        )
        let parser = Console.Input.Error.parser(.invalidUTF8)
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
            let read = Console.Input.Error.read(.handle(.invalid))
        #endif

        // Verify each matches only its own case
        if case .terminal = terminal {} else { Issue.record("terminal mismatch") }
        if case .parser = parser {} else { Issue.record("parser mismatch") }
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
            if case .read = read {} else { Issue.record("read mismatch") }
        #endif
    }

    @Test
    func `Console.Input.Error conforms to Swift.Error`() {
        let error: any Swift.Error = Console.Input.Error.parser(.invalidUTF8)
        #expect(error is Console.Input.Error)
    }

    @Test
    func `Terminal error preserves all operation types`() {
        for operation in [Terminal.Error.Operation.enterRaw, .exitRaw, .querySize] {
            let error = Console.Input.Error.terminal(
                Terminal.Error(operation: operation, underlying: .unsupported)
            )
            if case .terminal(let e) = error {
                #expect(e.operation == operation)
            }
        }
    }
}
