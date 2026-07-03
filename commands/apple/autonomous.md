---
description: Autonomously run plan→build→verify across remaining phases
allowed-tools: Read, Write, Edit, Bash, Task, Glob, Grep, AskUserQuestion
argument-hint: [start-phase] [--to N] [--yes]
---

# Autonomous Multi-Phase Build

Drive the project forward by running the full **plan → build → verify** cycle
across multiple roadmap phases without stopping after every one. This is the
unattended counterpart to running `/apple:plan`, `/apple:build`, and
`/apple:verify` by hand for each phase.

It is deliberately conservative: it pauses for anything that needs a human
decision (manual tasks, blockers, Critical review findings, failed
verification) and stops before the irreversible release phases unless you tell
it otherwise.

## Arguments

- `$1` / start-phase — phase number to start from. Default: current phase from `STATE.md`.
- `--to N` — last phase to run (inclusive). Default: **Phase 5 (Testing)**. Phases 6–7 (Pre-Release, Submission) are heavily manual and irreversible, so they are excluded unless explicitly requested with `--to 6` / `--to 7`.
- `--yes` — skip the between-phase confirmation checkpoints and run straight through to the end boundary. Manual-task and blocker pauses still apply.

## Prerequisites

**Model check (execution tier):** apply
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md`. This is the
longest-running command in SwiftShip, so it is the one place the check asks
instead of just noting: if the session is on a premium model, AskUserQuestion
**once** before starting — recommend switching (`/model sonnet`, then re-run)
or continue on the current model. Skip silently if the file is absent; `--yes`
does not skip this question (it is a cost gate, not a phase checkpoint).

Read required files:
```
Read: .planning/APP.md
Read: .planning/ROADMAP.md
Read: .planning/STATE.md
```

Optional (applied if present):
```
Read: .planning/PREFERENCES.md
```

If `ROADMAP.md` or `STATE.md` is missing:
```
⚠️ No roadmap found. Run /apple:roadmap first to create the phase plan.
```

## Safety Model — When Autonomous PAUSES

Stop and hand control back to the user whenever any of these occur. Always
explain why, then wait.

| Trigger | Action |
|---------|--------|
| A `manual` task is reached during build | Surface the task instructions, wait for the user to reply "done" before continuing (same as `/apple:build`). |
| A task fails verification or the build breaks | Stop. Report the failure and the failing output. Do not advance phases. |
| The phase-end quality gate finds **Critical** issues that can't be auto-fixed | Stop. Summarize the findings from `.planning/REVIEW.md`. |
| A blocker is written to `STATE.md` | Stop and surface it. |
| `PREFERENCES.md` is missing for a phase that has meaningful architecture choices (typically Phase 1) | Pause and recommend `/apple:discuss [phase]`, or proceed on SwiftShip defaults if the user says so. |
| End boundary reached (`--to N`, or default Phase 5) | Stop with the wrap-up message. |
| About to enter Phase 6 or 7 without explicit `--to` | Stop. These are release phases — require explicit opt-in. |

Never auto-run `/apple:submit`, never push, and never make irreversible App
Store Connect changes from this command.

## Process

### 1. Determine the Phase Range

- Start phase = `$1` if provided, else the current phase from `STATE.md`.
- End phase = the `--to N` value if provided, else `min(5, last phase in ROADMAP.md)`.
- Build the ordered list of phases to run. If start > end, report nothing to do.

Show the plan before starting:
```
🤖 Autonomous run

Phases queued: [start] → [end]
  Phase [start]: [name]
  ...
  Phase [end]: [name]

Mode: [checkpoint between phases | --yes straight-through]
Pauses for: manual tasks, blockers, Critical review issues, failed verification.
Stops before: Phase 6+ (release) unless --to says otherwise.
```

If not `--yes`, confirm with `AskUserQuestion` ("Start autonomous run?") before proceeding.

### 2. For Each Phase in Range

Run this cycle. Treat each step as if the user had invoked the corresponding
command — follow that command's logic exactly.

1. **Preferences check.** If `PREFERENCES.md` covers this phase, apply it. If the
   phase has significant architecture decisions and no preferences exist, follow
   the Safety Model (pause or use defaults).

2. **Plan** — execute the `/apple:plan [N]` logic. Generate `.planning/PLAN.md`
   for this phase, applying preferences and the conditional generator selection.

3. **Build** — execute the `/apple:build` logic. Work through every pending task
   in order, spawning the matched agents, running per-task verification, updating
   `STATE.md`, and committing after each task. This includes the **phase-end
   quality gate** (`/apple:review`): fix Critical/High inline; backlog
   Medium/Low. If a `manual` task is hit, pause per the Safety Model.

4. **Verify** — execute the `/apple:verify [N]` logic. Run the build + test
   suite and the deliverables checklist. Write `.planning/VERIFICATION.md`. If
   the result is FAIL, stop per the Safety Model.

5. **Phase summary** — print a short recap (tasks completed, files changed,
   quality-gate counts, verification result) and update `STATE.md` to mark the
   phase completed.

### 3. Between-Phase Checkpoint

Unless `--yes` was passed, after each phase ask with `AskUserQuestion`:
```
✅ Phase [N] complete: [name]
   Tasks: [n] · Files: [n] · Critical: 0 · Verification: PASS

Continue to Phase [N+1]: [next-name]?
```
Options: **Continue** / **Pause here** / **Stop run**. With `--yes`, continue
automatically but still print the recap.

### 4. Stop Conditions

End the run when any of these is true:
- All queued phases complete (reached the end boundary).
- A Safety-Model pause was triggered and the user chose to stop.
- The user selects "Pause here" / "Stop run" at a checkpoint.

## Output

This command does not create a new planning file — it drives the existing ones:
- `.planning/PLAN.md` (regenerated per phase)
- `.planning/STATE.md` (progress, decisions, blockers)
- `.planning/REVIEW.md` (quality gate per phase)
- `.planning/VERIFICATION.md` (per-phase UAT)
- Git commits per completed task

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent).

```
🎉 Autonomous run finished

Phases completed: [start] → [last-completed]
  ✅ Phase [n]: [name] — [tasks] tasks, Verification: PASS
  ...

Totals:
- Tasks completed: [count]
- Files created/modified: [count] / [count]
- Commits: [count]
- Quality gate: 🔴 [crit] 🟠 [high] 🟡 [med] 🟢 [low]

Stopped because: [reached end boundary | manual task | blocker | Critical issue | user paused]

Next steps:
- [If stopped early] Resolve the item above, then re-run /apple:autonomous to continue.
- [If reached Phase 5] Run /apple:plan 6 to begin Pre-Release, or /apple:testflight.
```
