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

@_exported public import ECMA_48
@_exported public import Terminal_Input_Primitives

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)
// Kernel (L3-unifier) composes POSIX Kernel which re-exports Terminal_Primitives
// with callAsFunction implementations. Per [PLAT-ARCH-008e], compose the
// L3-unifier rather than reaching directly into the L3-policy tier.
@_exported public import Kernel
#endif
