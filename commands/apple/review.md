---
description: Run comprehensive code, HIG, and App Store review
allowed-tools: Read, Glob, Grep, Task
---

# Comprehensive Apple Review

Run parallel reviews covering code quality, HIG compliance, App Store guidelines, and performance.

## Prerequisites

Verify project has code to review:
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
Read: .planning/ROADMAP.md (if exists)
Read: .planning/STATE.md (if exists)
```

## Spawn Review Agents in Parallel

Launch all 5 review agents simultaneously for efficiency:

### Agent 1: Code Quality Review

```
Task({
  subagent_type: "general-purpose",
  prompt: `
    Review Swift code quality for this Apple app.

    Reference skills: swift/concurrency-patterns (for async/await and actor patterns), swift/memory (for retain cycle and memory analysis), testing/test-contract (for protocol conformance testing)

    Examine:
    1. **Swift Patterns**
       - Modern Swift (async/await, actors, @Observable)
       - Proper use of optionals (no force unwraps without good reason)
       - Value types vs reference types
       - Protocol-oriented design

    2. **Memory Management**
       - Potential retain cycles (closures, delegates)
       - Proper use of weak/unowned
       - Large allocations

    3. **Error Handling**
       - Proper error propagation
       - User-facing error messages
       - Recovery strategies

    4. **SwiftUI Patterns**
       - @Observable vs ObservableObject
       - Proper state management
       - View composition
       - Environment usage

    5. **SwiftData/Persistence**
       - Model design
       - Query efficiency
       - Relationship handling

    6. **Test Coverage**
       - Existing test quality and coverage gaps
       - Protocol contracts without test suites
       - Missing regression tests for critical paths

    Output findings in this format:

    ## Code Quality Review

    ### 🔴 Critical
    [Issues that could cause crashes or data loss]

    ### 🟠 High
    [Significant issues affecting reliability]

    ### 🟡 Medium
    [Code smells and improvements]

    ### 🟢 Suggestions
    [Nice-to-have improvements]
  `
})
```

### Agent 2: HIG Compliance Review

```
Task({
  subagent_type: "hig-reviewer",
  prompt: `
    Review Human Interface Guidelines compliance for this Apple app.

    Reference existing skills:
    - ios/ui-review
    - macos/ui-review-tahoe
    - ios/assistive-access
    - ios/navigation-patterns

    Check:
    1. **Navigation**
       - Platform-appropriate patterns
       - Back button behavior
       - Tab bar usage (3-5 items)
       - Modal presentation

    2. **Layout & Spacing**
       - Standard margins (16pt iOS)
       - Touch targets (≥44pt)
       - Safe area handling
       - Responsive design

    3. **Typography**
       - Dynamic Type support
       - System fonts
       - Proper hierarchy

    4. **Color**
       - System colors for Dark Mode
       - Contrast ratios (4.5:1 text)
       - Color not sole indicator

    5. **Accessibility**
       - VoiceOver labels
       - Accessibility traits
       - Reduce Motion support

    Output findings with specific HIG references.
  `
})
```

### Agent 3: App Store Guidelines Review

```
Task({
  subagent_type: "app-store-reviewer",
  prompt: `
    Review App Store Review Guidelines compliance.

    Reference existing skill: release-review/, growth/analytics-interpretation

    Check:
    1. **Safety (1.x)**
       - Objectionable content
       - User-generated content moderation
       - Physical harm prevention

    2. **Performance (2.x)**
       - App completeness
       - Beta/test/demo references
       - Accurate metadata
       - Hardware compatibility

    3. **Business (3.x)**
       - In-app purchase rules
       - Subscription requirements
       - Advertising guidelines

    4. **Design (4.x)**
       - Copycat concerns
       - Minimum functionality
       - Apple branding usage

    5. **Legal (5.x)**
       - Privacy requirements
       - Data collection disclosure
       - Intellectual property
       - Gambling regulations

    Flag anything that could cause rejection.
  `
})
```

### Agent 4: Performance Review

```
Task({
  subagent_type: "general-purpose",
  prompt: `
    Review performance concerns for this Apple app.

    Reference skill: performance/profiling (for Instruments-based analysis)

    Check:
    1. **Main Thread**
       - UI updates on main thread
       - Heavy work off main thread
       - Potential blocking calls

    2. **Memory**
       - Large image handling
       - Cache management
       - Memory warnings handling

    3. **Launch Time**
       - App delegate/scene delegate work
       - Lazy initialization
       - Async startup tasks

    4. **SwiftUI Efficiency**
       - Unnecessary redraws
       - Complex view hierarchies
       - Proper use of @State vs @Binding

    5. **Network**
       - Efficient API calls
       - Proper caching
       - Offline handling

    Identify specific performance concerns with file:line references.
  `
})
```

### Agent 5: Security Quick-Check

```
Task({
  subagent_type: "general-purpose",
  prompt: `
    Quick security scan for this Apple app.

    Reference skills:
    - security/ (secure storage, biometric auth, network security, platform specifics)
    - security/privacy-manifests/ (privacy manifest audit)

    Quick checks:
    1. **Sensitive Data Storage**
       - Secrets in source code (API keys, tokens)
       - UserDefaults used for sensitive data
       - Proper Keychain usage

    2. **Network Security**
       - ATS configuration
       - HTTP vs HTTPS usage
       - API key exposure in URLs

    3. **Privacy Manifest**
       - PrivacyInfo.xcprivacy presence
       - Required Reason APIs declared

    4. **Common Vulnerabilities**
       - SQL injection (if using raw queries)
       - Insecure deserialization
       - URL scheme hijacking

    This is a quick scan — for full audit, recommend /apple:security.

    Output findings with severity levels and specific file:line references.
  `
})
```

## Compile Results

After all agents complete, compile findings into `.planning/REVIEW.md`:

```markdown
# Release Review: [App Name]

**Platform**: [from APP.md]
**Review Date**: [today]
**Reviewers**: Claude (code-quality, hig-reviewer, app-store-reviewer, performance, security)

## Summary

| Priority | Count | Status |
|----------|-------|--------|
| Critical | [count] | ⬜ Pending |
| High | [count] | ⬜ Pending |
| Medium | [count] | ⬜ Pending |
| Low | [count] | ⬜ Pending |

**Overall Status:** [Ready / Issues Found / Not Ready]

---

## 🔴 Critical Issues

[Compiled from all agents]

---

## 🟠 High Priority

[Compiled from all agents]

---

## 🟡 Medium Priority

[Compiled from all agents]

---

## 🟢 Suggestions

[Compiled from all agents]

---

## ✅ Strengths

[Positive findings from review]

---

## Recommended Action Plan

[Prioritized list of fixes]
```

## Completion Message

```
📋 Review complete!

Created: .planning/REVIEW.md

Summary:
- 🔴 Critical: [count]
- 🟠 High: [count]
- 🟡 Medium: [count]
- 🟢 Low: [count]

[If critical issues exist:]
⚠️ Critical issues found - must fix before release.
Review .planning/REVIEW.md for details.

[If no critical issues:]
✅ No critical issues! Ready for TestFlight.
Run /apple:testflight to prepare beta release.
```
