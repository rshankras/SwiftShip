# TestFlight Feedback Template

Copy this file to your project's `.planning/FEEDBACK.md`.

```markdown
# TestFlight Feedback: [App Name]

## Current Build

- **Version**: [version]
- **Build**: [build number]
- **Uploaded**: [date]
- **Expires**: [date + 90 days]
- **Testers**: [internal count] internal, [external count] external

---

## Feedback Summary

| Category | Count | Status |
|----------|-------|--------|
| Crashes | X | ⬜ Investigating |
| Bugs | X | ⬜ Triaging |
| Feature Requests | X | ⬜ Reviewing |
| Positive | X | ✅ Noted |

---

## 🔴 Crashes

### Crash #1: [Brief Description]

**Build**: [build number]
**Device**: [iPhone 15, iOS 17.2]
**Frequency**: [1 report | Multiple reports]
**Reproduced**: ⬜ No | ✅ Yes

**User Report**:
> [Quoted feedback from TestFlight]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Crash occurs]

**Stack Trace** (if available):
```
[Crash log or symbolicated stack trace]
```

**Root Cause**: [Analysis after investigation]

**Fix**: [How it was fixed]

**Status**: ⬜ Investigating | 🔧 In Progress | ✅ Fixed in Build [X]

---

## 🟠 Bugs

### Bug #1: [Brief Description]

**Build**: [build number]
**Severity**: High | Medium | Low
**Device**: [Device and OS]

**User Report**:
> [Quoted feedback]

**Expected Behavior**: [What should happen]

**Actual Behavior**: [What actually happens]

**Status**: ⬜ Open | 🔧 In Progress | ✅ Fixed in Build [X] | ⏭️ Deferred

---

## 🟡 Feature Requests

### Request #1: [Feature Description]

**From**: [Tester type - internal/external]
**Votes**: [If multiple requests for same thing]

**User Request**:
> [Quoted feedback]

**Analysis**:
- Aligns with roadmap: ⬜ No | ✅ Yes
- Effort: Low | Medium | High
- Priority: [P0/P1/P2/P3]

**Decision**: ⬜ Considering | ✅ Planned for v[X] | ❌ Won't Do | ⏭️ Backlog

---

## 🟢 Positive Feedback

Quotes to use for App Store and motivation:

> "[Positive quote 1]" - [Tester type]

> "[Positive quote 2]" - [Tester type]

> "[Positive quote 3]" - [Tester type]

---

## Build History

| Build | Date | Testers | Crashes | Notes |
|-------|------|---------|---------|-------|
| [X] | [Date] | [Count] | [Count] | [Key changes] |
| [X-1] | [Date] | [Count] | [Count] | [Key changes] |

---

## Tester Engagement

### Internal Testers
- **Invited**: [count]
- **Installed**: [count]
- **Active (7 days)**: [count]

### External Testers
- **Groups**: [group names]
- **Invited**: [count]
- **Installed**: [count]
- **Active (7 days)**: [count]

---

## Action Items for Next Build

Based on feedback, prioritize for next build:

1. **[Critical]** [Crash fix or critical bug]
2. **[High]** [Important bug fix]
3. **[Medium]** [UX improvement based on feedback]
4. **[Low]** [Nice-to-have polish]

---

## Notes for App Store Release

Issues that MUST be fixed before public release:
- [ ] [Issue 1]
- [ ] [Issue 2]

Feedback to incorporate in App Store description:
- [Positive theme 1]
- [Positive theme 2]
```

## How to Use

1. Run `/apple:testflight` to initialize this file
2. Check TestFlight feedback in App Store Connect
3. Triage feedback into appropriate categories
4. Update status as issues are addressed
5. Use positive quotes for ASO and motivation
