---
description: Complete current version, archive docs, and create release tag
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# Complete Milestone

Archive the current milestone/version, create a git tag, and prepare for the next development cycle.

## When to Use

- App version is shipped to App Store
- Major milestone is complete
- Want to preserve current state before starting new work

## Step 1: Verify Completion

Check that the current milestone is actually complete:

```
Read: .planning/STATE.md
Read: .planning/ROADMAP.md
Read: .planning/VERIFICATION.md (if exists)
Read: .planning/REVIEW.md (if exists)
```

### Completion Checklist

```markdown
## Milestone Completion Check

**Version:** [from STATE.md or ask user]

### Phase Status
- [ ] All planned phases complete
- [ ] Or: Remaining phases deferred to next version

### Quality Gates
- [ ] /apple:verify passed
- [ ] /apple:review passed
- [ ] TestFlight feedback addressed
- [ ] App Store submission complete (or ready)

### Outstanding Issues
[List any unresolved items from REVIEW.md or VERIFICATION.md]
```

If not complete, warn user:

```
⚠️ Milestone may not be complete:

- Phase 6 still in progress
- 2 unresolved issues in REVIEW.md

Are you sure you want to complete this milestone?
- Yes, complete anyway (issues will carry to next version)
- No, let me finish first
```

## Step 2: Determine Version

Ask user for version if not in STATE.md:

```
What version is this milestone?

Examples:
- 1.0.0 (first release)
- 1.1.0 (feature update)
- 1.0.1 (bug fix)
- 2.0.0 (major update)
```

## Step 3: Create Archive

### Create Archive Directory

```bash
mkdir -p .planning/archive/v[VERSION]
```

### Copy Current Planning Files

```bash
# Archive all planning files
cp .planning/APP.md .planning/archive/v[VERSION]/
cp .planning/ROADMAP.md .planning/archive/v[VERSION]/
cp .planning/STATE.md .planning/archive/v[VERSION]/
cp .planning/PLAN.md .planning/archive/v[VERSION]/ 2>/dev/null
cp .planning/VERIFICATION.md .planning/archive/v[VERSION]/ 2>/dev/null
cp .planning/REVIEW.md .planning/archive/v[VERSION]/ 2>/dev/null
cp .planning/ASO.md .planning/archive/v[VERSION]/ 2>/dev/null
cp .planning/FEEDBACK.md .planning/archive/v[VERSION]/ 2>/dev/null
cp .planning/DEPLOY.md .planning/archive/v[VERSION]/ 2>/dev/null
```

### Create Milestone Summary

Create `.planning/archive/v[VERSION]/MILESTONE.md`:

```markdown
# Milestone Summary: v[VERSION]

**Completed:** [date]
**Duration:** [start date] → [end date]

---

## What Was Built

### Features Delivered
[List from ROADMAP.md completed phases]

1. **Phase 1: Foundation**
   - [Key deliverables]

2. **Phase 2: Core Features**
   - [Key deliverables]

[... etc]

### Key Metrics

| Metric | Value |
|--------|-------|
| Phases completed | X of Y |
| Tasks completed | X |
| Issues fixed | X |
| TestFlight builds | X |

---

## What Was Learned

### Technical Decisions
[Key architectural decisions made]

### Challenges Overcome
[Major problems solved]

### What Worked Well
[Patterns to repeat]

### What To Improve
[For next version]

---

## Deferred Items

These items were planned but deferred to future versions:

- [ ] [Item 1] - Reason: [why deferred]
- [ ] [Item 2] - Reason: [why deferred]

---

## Release Info

**App Store Version:** [VERSION]
**Build Number:** [BUILD]
**Release Date:** [DATE]
**Git Tag:** v[VERSION]

---

*Archived by SwiftShip /apple:milestone*
```

## Step 4: Create Git Tag

```bash
# Check git status
git status

# Create annotated tag
git tag -a "v[VERSION]" -m "Release v[VERSION]

[Brief description of what's in this release]

Completed phases:
- Phase 1: [Name]
- Phase 2: [Name]
...

Archived to: .planning/archive/v[VERSION]/"

# Show the tag
git show "v[VERSION]"
```

Ask user if they want to push the tag:

```
Git tag v[VERSION] created locally.

Push tag to remote?
- Yes, push now (git push origin v[VERSION])
- No, I'll push later
```

## Step 5: Update STATE.md

Reset STATE.md for next cycle:

```markdown
# Project State

## Current Status

**Milestone:** [NEXT VERSION - TBD]
**Phase:** Not started
**Status:** Planning

## Previous Milestone

**Version:** v[VERSION]
**Completed:** [date]
**Archive:** .planning/archive/v[VERSION]/

## Next Steps

1. Run /apple:next-version to plan next milestone
2. Or continue with current APP.md for updates
```

## Step 6: Completion

```
Milestone v[VERSION] completed!

Archived to: .planning/archive/v[VERSION]/
- MILESTONE.md (summary)
- APP.md, ROADMAP.md, STATE.md
- REVIEW.md, VERIFICATION.md
- ASO.md, FEEDBACK.md

Git tag: v[VERSION] created
[Pushed to remote / Not pushed]

STATE.md reset for next cycle.

Next steps:
- Run /apple:next-version [name] to start planning v[NEXT]
- Or take a break, you shipped! 🎉
```

## Archive Structure

After completing milestones:

```
.planning/
├── archive/
│   ├── v1.0.0/
│   │   ├── MILESTONE.md
│   │   ├── APP.md
│   │   ├── ROADMAP.md
│   │   └── ...
│   ├── v1.1.0/
│   │   └── ...
│   └── v2.0.0/
│       └── ...
├── APP.md          # Current (may be updated)
├── STATE.md        # Reset for next version
└── ...
```
