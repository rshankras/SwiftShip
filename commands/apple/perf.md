---
description: Profile and diagnose performance issues
argument-hint: [problem-description]
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Performance Profiling

Diagnose and resolve performance issues using Apple's profiling tools and SwiftUI-specific debugging techniques.

## Arguments

- `$ARGUMENTS`: Optional problem description (e.g., "slow launch", "scrolling jank", "high memory usage"). If omitted, runs a general performance audit.

## Prerequisites

Verify project has code to profile:
```
Glob: **/*.swift
```

If no Swift files found:
```
⚠️ No Swift files found. Build your app first with /apple:build
```

## Read Context

```
Read: .planning/APP.md (if exists)
Read: .planning/STATE.md (if exists)
```

## Load Performance Skills

```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/profiling/SKILL.md
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/swiftui-debugging/SKILL.md
```

## Problem Classification

If `$ARGUMENTS` is provided, classify the problem and load focused reference files:

| Problem Category | Keywords | Reference Files |
|-----------------|----------|-----------------|
| Slow launch | launch, startup, cold start | `profiling/launch-optimization.md` |
| UI jank / scrolling | scroll, jank, stutter, animation, lag | `profiling/time-profiler.md`, `swiftui-debugging/body-reevaluation.md` |
| High memory | memory, leak, OOM, crash | `profiling/memory-profiling.md`, `swiftui-debugging/common-pitfalls.md`, `swift/memory` |
| Battery drain | battery, energy, background | `profiling/energy-diagnostics.md` |
| SwiftUI re-renders | redraw, rebuild, slow view, @State | `swiftui-debugging/body-reevaluation.md`, `swiftui-debugging/view-identity.md` |
| General / unknown | (no match) | All reference files |

Load the relevant reference files:
```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/profiling/[relevant-file].md
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/swiftui-debugging/[relevant-file].md
```

For memory-related problems, also load:
```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/swift/memory/SKILL.md
```

## Analysis Process

### Step 1: Project Scan

- Identify app architecture (SwiftUI, UIKit, hybrid)
- Count views and view complexity
- Find heavy computations (sorting, filtering, image processing)
- Check for main thread violations
- Identify async/await and concurrency usage

### Step 2: SwiftUI-Specific Analysis

If SwiftUI imports are found (`Grep: import SwiftUI`):

Load additional references:
```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/swiftui-debugging/view-identity.md
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/swiftui-debugging/lazy-loading.md
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/performance/swiftui-debugging/common-pitfalls.md
```

Check for:
- Unnecessary `body` re-evaluations
- Missing `Equatable` conformance on view inputs
- Non-lazy containers with large datasets
- Complex view hierarchies in `@ViewBuilder`
- Expensive computed properties in view bodies
- Missing `.id()` or incorrect structural identity

### Step 3: Memory Analysis

Check for:
- Retain cycles (closures capturing `self`, delegate patterns)
- Large image allocations without downsampling
- Unbounded caches
- Missing `weak`/`unowned` references
- SwiftData/Core Data batch size issues

### Step 4: Launch Time Analysis

Check for:
- Heavy work in `init()` or `App.body`
- Synchronous network calls at launch
- Large asset loading at startup
- Unnecessary framework imports

### Step 5: Instruments Guidance

Based on findings, recommend specific Instruments templates:
- **Time Profiler**: For CPU bottlenecks
- **Allocations**: For memory growth
- **Leaks**: For retain cycles
- **SwiftUI Instrument**: For view body evaluations
- **App Launch**: For startup time
- **Energy Log**: For battery drain

Provide step-by-step instructions for running the relevant Instruments template.

## Output

Generate `.planning/PERFORMANCE.md`:

```markdown
# Performance Analysis: [App Name]

**Platform**: [from APP.md]
**Analysis Date**: [today]
**Problem**: [from $ARGUMENTS or "General audit"]

## Summary

| Category | Issues | Severity |
|----------|--------|----------|
| CPU/UI Thread | [count] | [High/Med/Low] |
| Memory | [count] | [High/Med/Low] |
| Launch Time | [count] | [High/Med/Low] |
| SwiftUI Efficiency | [count] | [High/Med/Low] |

---

## Findings

### 🔴 Critical Performance Issues
[Issues causing visible user impact]

### 🟠 High Priority
[Issues likely to cause problems at scale]

### 🟡 Medium Priority
[Optimization opportunities]

### 🟢 Suggestions
[Nice-to-have improvements]

---

## SwiftUI-Specific Findings
[Only if SwiftUI project]
- View re-evaluation issues
- Identity and lifetime problems
- Lazy loading opportunities

---

## Recommended Instruments Sessions

1. **[Template Name]**: [What to look for]
   - Open: Xcode → Product → Profile (⌘I)
   - Select template: [name]
   - Focus on: [specific area]

---

## Action Plan
[Prioritized fixes with expected impact]
```

## Completion Message

```
⚡ Performance analysis complete!

Created: .planning/PERFORMANCE.md

Summary:
- 🔴 Critical: [count]
- 🟠 High: [count]
- 🟡 Medium: [count]
- 🟢 Suggestions: [count]

[If critical issues:]
⚠️ Critical performance issues found.
Top issue: [brief description]

[If no critical issues:]
✅ No critical performance issues found.

Next steps:
- Review .planning/PERFORMANCE.md for detailed findings
- Run recommended Instruments sessions for precise measurements
- Fix issues by priority (critical first)
- Run /apple:perf again after fixes to verify improvement
```
