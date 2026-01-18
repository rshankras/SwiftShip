# Code Review Template

Copy this file to your project's `.planning/REVIEW.md`.

```markdown
# Release Review: [App Name]

**Platform**: iOS | macOS | Universal
**Distribution**: App Store | Direct Download | TestFlight
**Review Date**: [Date]
**Reviewer**: Claude (hig-reviewer, app-store-reviewer agents)

## Summary

| Priority | Count | Status |
|----------|-------|--------|
| Critical | X | ⬜ Pending |
| High | X | ⬜ Pending |
| Medium | X | ⬜ Pending |
| Low | X | ⬜ Pending |

**Overall Status:** ⬜ Not Ready | ⚠️ Issues Found | ✅ Ready for Release

---

## 🔴 Critical Issues (Must Fix Before Release)

Issues that will cause rejection, crashes, or security vulnerabilities.

### [Category]: [Issue Title]

**File**: `path/to/file.swift:123`
**Impact**: [Why this matters - crash, rejection, security]
**Guideline**: [Apple guideline reference if applicable]

**Current Code**:
```swift
// problematic code
```

**Suggested Fix**:
```swift
// fixed code
```

**Status**: ⬜ Open | ✅ Fixed

---

## 🟠 High Priority (Should Fix)

Issues that significantly impact user experience or trust.

### [Category]: [Issue Title]

**File**: `path/to/file.swift:123`
**Impact**: [Why this matters]

**Issue**: [Description of the problem]

**Suggested Fix**: [How to fix it]

**Status**: ⬜ Open | ✅ Fixed

---

## 🟡 Medium Priority (Fix Soon)

Issues that should be addressed but won't block release.

### [Category]: [Issue Title]

**File**: `path/to/file.swift:123`
**Impact**: [Why this matters]

**Issue**: [Description]

**Status**: ⬜ Open | ✅ Fixed | ⏭️ Deferred to v1.1

---

## 🟢 Low Priority / Suggestions

Nice-to-have improvements and polish.

- [ ] [Suggestion 1]
- [ ] [Suggestion 2]
- [ ] [Suggestion 3]

---

## ✅ Strengths

What the app does well:

- [Strength 1 - e.g., "Clean navigation following HIG"]
- [Strength 2 - e.g., "Proper Dark Mode support"]
- [Strength 3 - e.g., "Good accessibility labels"]

---

## Review Categories Covered

- [ ] **Code Quality**: Swift patterns, memory management, error handling
- [ ] **HIG Compliance**: Navigation, typography, spacing, colors, accessibility
- [ ] **App Store Guidelines**: Privacy, IAP rules, content policies
- [ ] **Performance**: Main thread, memory, launch time
- [ ] **Security**: Credential storage, data transmission, input validation

---

## Recommended Action Plan

Priority order for fixes:

1. **[Critical]** [First thing to fix]
2. **[Critical]** [Second thing to fix]
3. **[High]** [Third thing to fix]
4. **[High]** [Fourth thing to fix]
5. **[Medium]** [Fifth thing to fix]

---

## Re-Review Checklist

After fixing issues, verify:

- [ ] All Critical issues resolved
- [ ] All High issues resolved or documented
- [ ] App builds without warnings
- [ ] All tests pass
- [ ] Manual QA completed
- [ ] Ready for TestFlight / Submission
```

## How to Use

1. Run `/apple:review` to generate this file
2. Address issues in priority order (Critical → High → Medium → Low)
3. Mark issues as Fixed or Deferred
4. Re-run `/apple:review` after fixes to verify
