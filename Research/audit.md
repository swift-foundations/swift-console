# Audit: swift-console

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/modularization-audit-foundations-single-target.md (2026-03-20)

**Modularization audit — single-target packages**

#### MOD-006: Unused Dependency — buffer-primitives

| Dependency | Product | Used In Source |
|------------|---------|:--------------:|
| `swift-buffer-primitives` | `Buffer Linear Inline Primitives` | N |

The `Buffer Linear Inline Primitives` product is declared as a target dependency but never imported in any source file. `Console.Input.Reader` uses `ContiguousArray` (stdlib) and `Input.Buffer` (from Terminal Input Primitives), not buffer-primitives types.

**Action**: Remove `swift-buffer-primitives` from Package.swift dependencies and `Buffer Linear Inline Primitives` from the target's dependency list.

#### MOD-011: No Test Support Product

| Files | External Deps | Has Test Support |
|------:|:-------------:|:----------------:|
| 10 | 5 | N |

Package meets the criteria for a test support product (10+ files, 3+ external deps) but does not provide one.

---

### From: swift-institute/Research/platform-compliance-audit.md (2026-03-19)

**Skill**: platform — [PLAT-ARCH-001-010], [PATTERN-001], [PATTERN-004a], [PATTERN-005]

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| C-5 | CRITICAL | [PLAT-ARCH-008] | Console.Capability+Detect.swift:16-21 | Imports Darwin/Glibc/CRT for `isatty()`, `getenv()`, terminal capability detection. Fix: Replace with `import Kernel`. | OPEN — Missing `Kernel.Terminal.isInteractive` and `Kernel.Environment.get` |
| C-6 | CRITICAL | [PLAT-ARCH-008] | Console.Input.Reader.swift:14-19 | Imports Darwin/Glibc/Musl for POSIX read operations on stdin. Fix: Replace with `import Kernel`; use Kernel file descriptor read operations. | OPEN — Verify Kernel.Descriptor read operations suffice |
| H-35 | HIGH | [PLAT-ARCH-008] | exports.swift:15 | `#if os(macOS) \|\| ... \|\| os(Linux)` gating POSIX imports. Fix: Use `import Kernel` unconditionally. | OPEN |
| H-36 | HIGH | [PLAT-ARCH-008] | Console.Input.swift:17 | `#if os(macOS) \|\| ... \|\| os(Linux)` gating functionality. Fix: Use `import Kernel` unconditionally. | OPEN |
