---
description: Generate or expand tests on demand using SwiftShip's testing skills
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
argument-hint: [phase-number | path | "recent"]
---

# Test — On-Demand Test Generation

Generate or expand tests for a target **without** running the full Phase 5
roadmap flow. This is a thin wrapper over the testing skills SwiftShip already
ships — it picks the right skill per file, honors your existing test framework,
and writes tests RED → GREEN.

The test *engine* already exists (the `testing/*` skills and the
`test-generator` generator); this command just lets you invoke it ad-hoc against
any target, any time.

## Arguments

- A **phase number** → test that phase's deliverables (from `PLAN.md` / `VERIFICATION.md`).
- A **file or directory path** → test exactly that.
- `"recent"` or **no argument** → test source files changed since the last commit/tag.

## Prerequisites

Read for context if present:
```
Read: .planning/APP.md      # Platform, min OS
Read: .planning/PLAN.md      # If a phase number was given
```

## Process

### 1. Resolve the Target Files

| Argument | Resolve to |
|----------|-----------|
| Phase number | Files listed in that phase's `<files>` in `PLAN.md` (or described in `VERIFICATION.md`). |
| Path | The given file(s)/directory. |
| `recent` / none | `git diff --name-only` since last commit; if clean, since the last tag. |

```bash
# For "recent":
git diff --name-only HEAD 2>/dev/null || git diff --name-only $(git describe --tags --abbrev=0)..HEAD
```
Limit to source files; exclude files that already have a sibling test.

### 2. Detect the Test Framework Already in Use

Do not impose a framework — match the project.
```
Grep: "import Testing"  → Swift Testing (@Test / #expect) is in use
Grep: "import XCTest"   → XCTest is in use
```
- If **Swift Testing** is present (or the project targets iOS 18+/macOS 15+ with a recent Xcode), prefer it for new tests.
- If only **XCTest** is present, generate XCTest to stay consistent.
- If there is no test target yet, set one up (or recommend `testing/snapshot-test-setup` / a test target) before generating.

### 3. Classify Each File → Pick the Skill

| File looks like… | Test type | Skill to load |
|------------------|-----------|---------------|
| Business logic, models, services | Unit (TDD) | `testing/tdd-feature` |
| Model/SwiftData layer needing fixtures | Unit + factories | `testing/test-data-factory` |
| Custom SwiftUI views/components | Snapshot / visual regression | `testing/snapshot-test-setup` |
| Networking **and** persistence together | Integration | `testing/integration-test-scaffold` |
| Protocol-based abstractions | Contract | `testing/test-contract` |
| Legacy/untested code being changed | Characterization | `testing/characterization-test-generator` |
| Trivial (pure boilerplate, generated) | Skip | — |

Load the matched skill from
`/Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/[skill]/SKILL.md`
and apply its patterns. The `generators/test-generator` generator can scaffold
the test target/boilerplate when none exists.

### 4. Confirm the Plan

Show the classification and ask with `AskUserQuestion` before writing:
```
Test plan for [target]:

  [File A]  → Unit (Swift Testing)      via testing/tdd-feature
  [File B]  → Snapshot                  via testing/snapshot-test-setup
  [File C]  → Skip (trivial)

Framework: Swift Testing (detected)
Generate these tests?
```
Options: **Generate all** / **Choose subset** / **Cancel**.

### 5. Generate RED → GREEN

For each approved file (inline, or via a `general-purpose`/`swiftui-builder`
agent for larger batches):
1. **RED** — write the failing test(s) first; confirm they fail for the *right*
   reason (not a compile error).
2. **GREEN** — confirm the code under test makes them pass; if a test reveals a
   real gap, surface it rather than weakening the test.
3. Use the project's existing naming, helpers, and fixtures.

### 6. Run the Suite & Report

```bash
swift test 2>&1 | tail -30
# or:
xcodebuild test -scheme [Scheme] -destination '[platform=…]' 2>&1 | tail -30
```
Report pass/fail counts and any **coverage gaps** — code paths, error cases, or
UAT items from `VERIFICATION.md` still untested.

### 7. Commit

```bash
git add -A
git commit -m "test([area]): add tests for [target]

- [N] unit / [N] snapshot / [N] integration tests
- Framework: [Swift Testing / XCTest]

🤖 Generated with Apple GSD"
```

## Output

- Test files written into the project's test target(s).
- An inline coverage report (no separate planning file — the tests are the deliverable).

## Completion Message

```
🧪 Tests generated for [target]

Framework: [Swift Testing / XCTest]
Added:
- [N] unit tests       (testing/tdd-feature)
- [N] snapshot tests   (testing/snapshot-test-setup)
- [N] integration tests (testing/integration-test-scaffold)

Suite: [pass]/[total] passing

Coverage gaps still open:
- [path / case still untested]

Next:
- Run /apple:verify to check phase deliverables, or
- Address the gaps above with another /apple:test pass.
```
