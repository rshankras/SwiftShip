---
description: Show current project status and next steps
allowed-tools: Read, Glob
---

# Project Progress

Display the current state of the project, what's been completed, what's in progress, and what's next.

## Step 1: Check for Planning Files

Look for the `.planning/` directory and read available files:

```bash
ls -la .planning/
```

If no `.planning/` directory exists:
```
No SwiftShip project found in this directory.

To get started:
1. Run /apple:validate "your app idea" to validate the idea
2. Run /apple:new-app AppName to define your app
```

## Step 2: Load Project State

Read available planning files:

```
Read: .planning/STATE.md      # Current state (if exists)
Read: .planning/APP.md        # App definition (if exists)
Read: .planning/ROADMAP.md    # Development phases (if exists)
Read: .planning/PLAN.md       # Current phase tasks (if exists)
```

## Step 3: Display Progress Report

Generate a concise status report:

```markdown
# [App Name] - Progress Report

## Current Status

**Milestone:** [milestone name/version]
**Phase:** [N] of [total] - [Phase Name]
**Status:** [Not Started / In Progress / Blocked / Completed]

## Phase Progress

[Current Phase Name]
━━━━━━━━━━━━━━━━━━━━ X% complete

Tasks:
✅ [Completed task 1]
✅ [Completed task 2]
🔄 [In progress task] ← YOU ARE HERE
⬚ [Pending task 1]
⬚ [Pending task 2]

## Completed Phases

✅ Phase 1: [Name] - [date completed]
✅ Phase 2: [Name] - [date completed]

## Upcoming Phases

⬚ Phase 4: [Name]
⬚ Phase 5: [Name]

## Blockers

[List any blockers from STATE.md, or "None"]

## Next Action

→ [Specific next step to take]
  Command: /apple:[suggested-command]
```

## Step 4: Suggest Next Action

Based on current state, recommend the next command:

| Current State | Next Action |
|---------------|-------------|
| No APP.md | `/apple:new-app` to define app |
| APP.md exists, no ROADMAP.md | `/apple:roadmap` to create phases |
| ROADMAP.md exists, no PLAN.md | `/apple:plan [N]` to plan current phase |
| PLAN.md exists, tasks pending | `/apple:build` to execute tasks |
| Tasks complete, not verified | `/apple:verify` to verify work |
| Verified, not reviewed | `/apple:review` for quality review |
| Reviewed, ready for beta | `/apple:testflight` to prepare beta |
| Beta complete | `/apple:submit` to submit to App Store |

## Quick Status Indicators

Use these symbols for visual clarity:

- ✅ Completed
- 🔄 In Progress
- ⬚ Not Started
- ❌ Failed/Blocked
- ⚠️ Needs Attention

## Example Output

```
# FocusBar - Progress Report

## Current Status

**Milestone:** v1.0.0
**Phase:** 2 of 7 - Core Features
**Status:** In Progress

## Phase Progress

Core Features
━━━━━━━━━━━━━━━━━━━━ 40% complete

Tasks:
✅ Set up HealthKit integration
✅ Create HealthKitManager
🔄 Implement grayscale overlay ← YOU ARE HERE
⬚ Add movement detection logic
⬚ Connect health data to overlay

## Completed Phases

✅ Phase 1: Foundation - Jan 15, 2026

## Upcoming Phases

⬚ Phase 3: Polish
⬚ Phase 4: Platform Integration
⬚ Phase 5: Quality
⬚ Phase 6: Pre-Release
⬚ Phase 7: Submission

## Blockers

None

## Next Action

→ Continue implementing grayscale overlay
  Currently working on: GrayscaleManager.swift
  Command: /apple:build (to continue current task)
```

## No Planning Files Found

If `.planning/` doesn't exist or is empty:

```
# No SwiftShip Project Found

This directory doesn't have a SwiftShip project set up.

## Quick Start

1. **Validate your idea first:**
   /apple:validate "your app idea here"

2. **Define your app:**
   /apple:new-app YourAppName

3. **Create development roadmap:**
   /apple:roadmap

4. **Start building:**
   /apple:plan 1
   /apple:build

## Available Commands

Run /apple:help to see all available commands.
```
