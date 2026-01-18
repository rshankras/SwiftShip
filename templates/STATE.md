# Project State Template

Copy this file to your project's `.planning/STATE.md`.

```markdown
# Project State

## Current Position
- **Milestone:** v1.0 MVP
- **Phase:** 1 (Foundation)
- **Phase Status:** in_progress
- **Last Updated:** [date]

## Environment
- **Xcode:** [version, e.g., 16.2]
- **Swift:** [version, e.g., 6.0]
- **Target iOS:** [version, e.g., 17.0]
- **Target macOS:** [version, e.g., 14.0]
- **Simulator:** [primary test device]

## Current Task
- **Task ID:** [from PLAN.md]
- **Description:** [what's being worked on]
- **Started:** [timestamp]

## Key Decisions Made
<!-- Document important architectural/design decisions -->
| Decision | Rationale | Date |
|----------|-----------|------|
| [Decision 1] | [Why we chose this] | [Date] |
| [Decision 2] | [Why we chose this] | [Date] |

## Blockers
<!-- List anything blocking progress -->
- [ ] [Blocker 1 - who can unblock]
- [ ] [Blocker 2 - who can unblock]

## Questions for User
<!-- Questions that need user input -->
- [ ] [Question 1]
- [ ] [Question 2]

## TestFlight Status
- **Latest Build:** [build number] | Not started
- **Upload Date:** [date]
- **Status:** Processing | Ready | In Review | Live
- **Internal Testers:** [count]
- **External Testers:** [count]
- **Expires:** [date + 90 days]

## App Store Status
- **Version:** [version]
- **Submitted:** [date] | Not submitted
- **Status:** Not Started | Waiting for Review | In Review | Approved | Rejected
- **Review Notes:** [any notes from Apple]

## Session History
<!-- Brief log of what was accomplished -->
| Date | Phase | Accomplishments |
|------|-------|-----------------|
| [Date] | 1 | [What was done] |
| [Date] | 1 | [What was done] |
```

## How to Use

1. This file is automatically created by `/apple:roadmap`
2. Updated by `/apple:build` after each task completion
3. Updated by `/apple:testflight` with build status
4. Updated by `/apple:submit` with submission status
5. Check this file to understand current project state at a glance
