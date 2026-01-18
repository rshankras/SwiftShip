---
description: Systematic debugging with state tracking
argument-hint: [issue-description]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Debug Issue

Systematic debugging approach that tracks state and attempts across sessions. Ensures no time is wasted repeating failed approaches.

## Step 1: Initialize Debug Session

Create or update `.planning/DEBUG.md` to track this debugging session:

```bash
ls .planning/DEBUG.md 2>/dev/null || echo "new session"
```

If new session, create the file. If exists, append to it.

## Step 2: Document the Issue

Ask user to describe the issue (if not provided as argument):

```markdown
## Debug Session: [timestamp]

### Issue Description

**Problem:** [User's description or $ARGUMENTS]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Reproduction Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Error Messages:**
```
[Any error messages, stack traces, logs]
```

**When did it start:**
[After what change, always, intermittent]
```

## Step 3: Gather Diagnostic Information

Collect relevant data:

### 3.1 Build State
```bash
# Check if project builds
xcodebuild -scheme [Scheme] build 2>&1 | tail -30
```

### 3.2 Test State
```bash
# Run tests to see failures
xcodebuild test -scheme [Scheme] 2>&1 | grep -A 5 "failed\|error"
```

### 3.3 Recent Changes
```bash
# What changed recently
git log --oneline -10
git diff HEAD~3 --stat
```

### 3.4 Related Code
Use Grep to find related code:
```
Grep: [relevant keyword] in *.swift files
```

## Step 4: Form Hypotheses

Based on information gathered, form hypotheses:

```markdown
### Hypotheses

**Hypothesis 1:** [Most likely cause]
- Evidence: [Why you think this]
- Test: [How to verify]
- Likelihood: High/Medium/Low

**Hypothesis 2:** [Second possibility]
- Evidence: [Why you think this]
- Test: [How to verify]
- Likelihood: High/Medium/Low

**Hypothesis 3:** [Third possibility]
- Evidence: [Why you think this]
- Test: [How to verify]
- Likelihood: High/Medium/Low
```

## Step 5: Test Hypotheses (Systematically)

For each hypothesis, starting with most likely:

### Testing Protocol

1. **State the hypothesis** being tested
2. **Describe the test** to perform
3. **Predict the outcome** if hypothesis is correct
4. **Perform the test**
5. **Record the result**
6. **Draw conclusion**

```markdown
### Testing Hypothesis 1

**Hypothesis:** [Description]

**Test:** [What we'll do]

**Prediction:** If correct, we should see [X]

**Result:**
```
[Output/observation]
```

**Conclusion:** [Confirmed/Rejected/Inconclusive]

**Next Step:** [What to do based on result]
```

## Step 6: Track Attempts

Keep a log of everything tried:

```markdown
### Attempts Log

| # | What Tried | Result | Learning |
|---|------------|--------|----------|
| 1 | [Action] | [Result] | [What we learned] |
| 2 | [Action] | [Result] | [What we learned] |
| 3 | [Action] | [Result] | [What we learned] |

### Ruled Out

These are NOT the cause:
- [x] [Thing 1] - Tested by [method], result was [X]
- [x] [Thing 2] - Tested by [method], result was [X]
```

## Step 7: Implement Fix

Once root cause is identified:

```markdown
### Root Cause

**Identified Cause:** [Description]

**Evidence:** [How we confirmed]

**Fix:**
[Description of the fix]

**Files to modify:**
- `path/to/file.swift` - [What change]

### Fix Implementation

[Code changes made]

### Verification

**Build:** ✅/❌
**Tests:** ✅/❌
**Manual Test:** ✅/❌
```

## Step 8: Document for Future

Add learnings to prevent recurrence:

```markdown
### Post-Mortem

**Root Cause Category:** [Logic error / Type error / State bug / Race condition / etc.]

**Why It Happened:**
[Explanation]

**How to Prevent:**
[What to do differently]

**Related Areas to Check:**
[Other code that might have similar issues]
```

## Debug File Structure

`.planning/DEBUG.md` accumulates debug sessions:

```markdown
# Debug Log

## Session 3 - [date] - RESOLVED
[Most recent first]

## Session 2 - [date] - RESOLVED
[Previous session]

## Session 1 - [date] - RESOLVED
[Oldest session]
```

## Quick Debug Checklist

Before deep debugging, check common issues:

### Swift/Xcode Common Issues

- [ ] Clean build folder (Cmd+Shift+K)
- [ ] Delete derived data
- [ ] Check for optional unwrapping issues
- [ ] Check for retain cycles (weak self in closures)
- [ ] Check for main thread violations
- [ ] Check for missing entitlements
- [ ] Check for missing Info.plist keys

### SwiftUI Common Issues

- [ ] Check @State/@Binding usage
- [ ] Check view identity (use .id() if needed)
- [ ] Check for infinite loops in body
- [ ] Check for missing @Published
- [ ] Check for @Observable vs ObservableObject mismatch

### Data Common Issues

- [ ] Check SwiftData model schema
- [ ] Check CloudKit container setup
- [ ] Check for migration issues
- [ ] Check for threading issues with context

## Completion

When bug is fixed:

```
Debug session complete!

Issue: [Brief description]
Root Cause: [What was wrong]
Fix: [What was changed]

Files modified:
- [file1.swift]
- [file2.swift]

Verified: Build ✅ | Tests ✅ | Manual ✅

Session logged to: .planning/DEBUG.md
```
