---
description: Restore context from previous session
allowed-tools: Read, Write, Bash, Glob
---

# Resume Work

Restore context from a previous session and get back to work quickly.

## Step 1: Check for Handoff

Look for handoff documentation:

```bash
ls -la .planning/HANDOFF.md
```

**If HANDOFF.md exists:** Read it and restore context
**If no HANDOFF.md:** Reconstruct context from other planning files

## Step 2: Load Context

### If Handoff Exists

```
Read: .planning/HANDOFF.md
Read: .planning/STATE.md
Read: .planning/PLAN.md
```

### If No Handoff

Reconstruct from available files:

```
Read: .planning/STATE.md
Read: .planning/PLAN.md
Read: .planning/APP.md
Read: .planning/ROADMAP.md
```

Also check git state:
```bash
git status
git log --oneline -5
git diff --stat
```

## Step 3: Assess Current State

Determine:

1. **Last known position:**
   - Which phase?
   - Which task?
   - What was being worked on?

2. **Uncommitted work:**
   - Are there uncommitted changes?
   - Do they look complete or partial?

3. **Time since pause:**
   - Recent (same day): Full context likely remembered
   - Days ago: Need context refresh
   - Weeks ago: Need full re-orientation

## Step 4: Generate Resume Briefing

Present a concise briefing:

```markdown
# Resume Briefing

**Project:** [App Name]
**Last Active:** [timestamp from handoff or git]

---

## Where You Left Off

**Phase:** [N] - [Phase Name]
**Task:** [Current task description]

**You were working on:**
[Description from handoff or reconstructed]

**Files involved:**
- `path/to/file1.swift`
- `path/to/file2.swift`

---

## Current Code State

**Uncommitted changes:**
[git status summary]

**Last commit:**
[git log -1 summary]

---

## Blockers (if any)

[From handoff or STATE.md]

---

## Immediate Next Step

→ [Specific action to take]

**Open:** `path/to/file.swift`
**Do:** [Specific thing to do]

---

## Context Refresh

[Key points from handoff learnings/decisions, or brief summary from APP.md]

---

Ready to continue? Start with the immediate next step above, or run:
- `/apple:progress` for full status
- `/apple:build` to continue building
```

## Step 5: Update State

Update STATE.md to mark as resumed:

```markdown
## Session Status

**Status:** ACTIVE
**Resumed At:** [timestamp]
**Previous Pause:** [pause timestamp]
```

## Step 6: Offer Quick Actions

Based on state, offer relevant commands:

```
Quick Actions:

1. Continue building:     /apple:build
2. Check full progress:   /apple:progress
3. Verify completed work: /apple:verify
4. View current plan:     Read .planning/PLAN.md

What would you like to do?
```

## No Handoff Available

If no HANDOFF.md exists, reconstruct context:

```markdown
# Resume Briefing (Reconstructed)

**Note:** No handoff document found. Reconstructing from project state.

**Project:** [from APP.md or CLAUDE.md]
**Phase:** [from STATE.md]

## Current State

[Best guess from STATE.md and PLAN.md]

## Uncommitted Work

```
[git status output]
```

## Suggested Next Steps

Based on project state, you should:

1. [Suggested action based on STATE.md]

## Create Better Handoffs

Next time, run `/apple:pause` before stopping work.
This creates detailed handoff documentation for easier resume.
```

## Smart Context Restoration

If resuming after a long break, offer to:

1. **Re-read APP.md** for project context
2. **Summarize ROADMAP.md** for big picture
3. **Detail PLAN.md** for current tasks
4. **Show recent git history** for what changed

```
It's been [X days] since you last worked on this project.

Would you like a full context refresh?
- Quick refresh (current task only)
- Full refresh (project overview + current task)
- Skip (I remember everything)
```
