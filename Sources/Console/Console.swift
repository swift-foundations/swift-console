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

/// Console output abstraction.
///
/// Provides capability detection and styled output for terminal applications.
/// Uses policy-based detection (NO_COLOR, TERM, COLORTERM) to determine
/// supported features.
public enum Console {}
