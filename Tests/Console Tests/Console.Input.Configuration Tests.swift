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

extension Console.Input.Configuration {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit

extension Console.Input.Configuration.Test.Unit {
    @Test
    func `Default enables paste only`() {
        let config = Console.Input.Configuration.default
        #expect(config.mouse == false)
        #expect(config.paste == true)
        #expect(config.kitty == false)
    }

    @Test
    func `Full enables all modes`() {
        let config = Console.Input.Configuration.full
        #expect(config.mouse == true)
        #expect(config.paste == true)
        #expect(config.kitty == true)
    }

    @Test
    func `Custom init preserves all values`() {
        let config = Console.Input.Configuration(mouse: true, paste: false, kitty: true)
        #expect(config.mouse == true)
        #expect(config.paste == false)
        #expect(config.kitty == true)
    }

    @Test
    func `All-false configuration`() {
        let config = Console.Input.Configuration(mouse: false, paste: false, kitty: false)
        #expect(config.mouse == false)
        #expect(config.paste == false)
        #expect(config.kitty == false)
    }
}

// MARK: - EdgeCase

extension Console.Input.Configuration.Test.EdgeCase {
    @Test
    func `Properties are independently mutable`() {
        var config = Console.Input.Configuration.default
        config.mouse = true
        #expect(config.mouse == true)
        #expect(config.paste == true)
        #expect(config.kitty == false)
    }

    @Test
    func `Mutating one property does not affect others`() {
        var config = Console.Input.Configuration.full
        config.paste = false
        #expect(config.mouse == true)
        #expect(config.paste == false)
        #expect(config.kitty == true)
    }

    @Test
    func `Default and full differ`() {
        let def = Console.Input.Configuration.default
        let full = Console.Input.Configuration.full
        #expect(def.mouse != full.mouse || def.kitty != full.kitty)
    }
}
