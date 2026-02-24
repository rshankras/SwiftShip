---
description: Quick bug fix with regression test and structured commit
argument-hint: [bug-description or crash log or issue URL]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

# Bug Fix

Fast-lane bug fix for known issues. Use this when the bug is clear (crash report, error message, user feedback, GitHub issue). For mystery bugs where you don't know the cause, use `/apple:debug` instead.

## Step 1: Understand the Bug

Parse the input (`$ARGUMENTS`). Determine the source type:

| Input Type | How to Parse |
|-----------|--------------|
| Error message / crash log | Extract the crash symbol, file, and line number |
| User report / description | Extract keywords, affected feature area |
| GitHub issue URL | Fetch issue details via `gh issue view` |
| Stack trace | Map frames to source files |

If no argument provided, ask the user:

```
What's the bug? Provide one of:
- Error message or crash log
- Description of what's broken
- GitHub issue number or URL
```

## Step 2: Read App Context

Check for project context:

```
Read: .planning/APP.md (if exists — for platform, min OS, architecture)
Read: CLAUDE.md (if exists — for project conventions)
```

Determine platform (iOS / macOS / both) to select the right skill references later.

## Step 3: Locate the Bug

Based on the input, search the codebase:

### 3.1 From Crash Log / Stack Trace

```
Extract file names and symbols from the trace.
Glob: **/*.swift to find the files.
Read the relevant files around the crash point.
```

### 3.2 From Description / Keywords

```
Grep: [keyword] in *.swift files
Grep: [feature area] in *.swift files
```

### 3.3 Narrow Down

Use `git log` to check recent changes in the affected area:

```bash
git log --oneline -10 -- [affected-files]
```

Check if this is a regression:

```bash
git log --all --oneline --grep="[keyword]" -- [affected-files]
```

### 3.4 Report Findings

Before making changes, report to the user:

```
Bug located:

File(s): [file:line]
Root cause: [one-sentence explanation]
Impact: [what's affected]
Regression: [yes/no — if yes, which commit introduced it]

Proposed fix: [brief description of the change]

Proceed with fix?
```

Wait for user confirmation.

## Step 4: Apply the Fix

Make the minimal change needed to fix the bug. Follow platform best practices:

**For iOS bugs:** Reference patterns from `ios/coding-best-practices`
**For macOS bugs:** Reference patterns from `macos/coding-best-practices`
**For SwiftUI rendering/performance bugs:** Reference `performance/swiftui-debugging`

Rules for the fix:
- Minimal change — fix the bug, don't refactor surrounding code
- Match existing code style
- Don't introduce new dependencies unless absolutely necessary
- If the fix requires a choice between approaches, ask the user

## Step 5: Write Regression Test

Generate a test that would have caught this bug. Use the TDD bug fix workflow:

```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/testing/tdd-bug-fix/SKILL.md
```

Also reference `generators/test-generator` for test boilerplate patterns:

### 5.1 Determine Test Type

| Bug Category | Test Type |
|-------------|-----------|
| Logic error / wrong output | Unit test with `@Test` (Swift Testing) |
| Crash / nil unwrap | Unit test with boundary inputs |
| UI state bug | Unit test on the ViewModel/Store |
| Data corruption | Integration test with SwiftData in-memory container |
| Race condition | Test with async expectations |

### 5.2 Create the Test

Place the test in the existing test target. Match the project's testing framework:

- If project uses Swift Testing (`@Test`, `#expect`) → use Swift Testing
- If project uses XCTest (`XCTestCase`) → use XCTest
- If no tests exist → use Swift Testing, create the test file

Name the test clearly:

```swift
// Swift Testing
@Test("Description of what was broken and is now fixed")
func bugDescriptionIsFixed() { ... }

// XCTest
func test_bugDescription_isFixed() { ... }
```

### 5.3 Verify the Test

The test should:
1. **Fail** without the fix (conceptually — describe this, don't actually revert)
2. **Pass** with the fix applied

## Step 6: Verify

Run verification in order:

### 6.1 Build

```bash
xcodebuild -scheme [Scheme] build 2>&1 | tail -20
```

If build fails, fix the issue before proceeding.

### 6.2 Run Tests

```bash
# Run just the new test first
xcodebuild test -scheme [Scheme] -only-testing:[TestTarget]/[TestClass]/[testMethod] 2>&1 | tail -20

# Then run full test suite
xcodebuild test -scheme [Scheme] 2>&1 | tail -30
```

If using Swift Package:

```bash
swift test --filter [TestName]
swift test
```

### 6.3 Report

```
Verification:
- Build: [pass/fail]
- New regression test: [pass/fail]
- Full test suite: [pass/fail] ([N] tests, [F] failures)
```

If any verification fails, fix and re-run before proceeding.

## Step 7: Commit

Create a structured commit:

```bash
git add [specific-files-changed]
git add [test-file]
git commit -m "fix([area]): [brief description]

- [What was broken]
- [What caused it]
- [What the fix does]
- Added regression test

[Fixes #issue-number if applicable]"
```

## Completion

```
Bug fixed!

Bug: [one-line description]
Cause: [root cause]
Fix: [what changed]

Files modified:
- [source-file.swift] — [what changed]
- [test-file.swift] — regression test added

Verified: Build [pass/fail] | Tests [pass/fail] | Regression test [pass/fail]

Committed: [commit hash] fix([area]): [description]
```

## Escalation

If during any step the bug turns out to be more complex than expected (unclear root cause, multiple interacting issues, no obvious fix), suggest:

```
This bug is more complex than a quick fix. I recommend:
- /apple:debug [issue] — for systematic investigation with hypothesis tracking
```
