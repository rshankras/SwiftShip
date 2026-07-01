---
description: Drive each user flow in the Simulator (UI test + per-step screenshots), audit the nav graph for dead-ends, and run a human discoverability check
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: [flow-id | all]
---

# Walkthrough Flows

Verify UI **workflow** correctness — the transitions, return paths, dead-ends, and discoverability that a task list, the compiler, `/apple:review`, and static screenshots all miss. Use after building any phase or slice that adds/changes UI, or when "I could only figure out the flow by running it."

## Arguments

- `$ARGUMENTS` or `$1`: a specific flow id (e.g. `F1`) to walk, or `all` / empty for every flow in the current phase.

## Prerequisites

```
Read: .planning/APP.md
Read: .planning/PLAN.md      # provides the <flows> block
Read: .planning/STATE.md
```

If `PLAN.md` has **no `<flows>` block**, derive flows from the phase's views/`<mvp-features>` and **write them into PLAN.md first** (a flow that isn't written down can't be walked). Prefer running `/apple:plan [phase]` on an updated plan template that emits `<flows>`.

If there is no buildable Xcode project yet:
```
⚠️ Nothing to walk. Build the phase first with /apple:build.
```

## Load the Skill

Apply the full methodology (three layers, screenshot extraction, output format):
```
Read: ~/.claude/swiftship-skills/testing/flow-walkthrough/SKILL.md
```

## Process

Follow the skill. In short:

1. **Layer 1 — static nav-graph audit (no build).** Grep `NavigationStack`/`navigationDestination`/`NavigationLink`/`sheet`/`router.push`/`dismiss`/`popToRoot`/`@Query`. Assert every screen is reachable, every `Done`/`Back` lands intentionally, and every `@Model` with a Create path has a reopen/edit path. Report `DEAD-END` / `NO-EDIT-PATH` / `ORPHANS-ENTITY` with file:line.

2. **Layer 2 — drive each flow (XCUITest + screenshots).** Ensure a UITest target exists (add one if missing; keep it — it becomes the Phase 5 regression suite). Generate one test per `<flow>` from its `<steps>`, screenshot after each step (`XCTAttachment` `.keepAlways`), and **assert the destination** of each step — especially after `Done`/`Back`. Use a DEBUG `-uiTestSeed` launch arg to seed SwiftData and flip entitlement flags so gated/late-state flows are reachable. Run:
   ```bash
   xcodebuild test -project <App>.xcodeproj -scheme <App> \
     -destination 'platform=iOS Simulator,name=<device>' \
     -resultBundlePath .planning/walkthrough/<flowId>.xcresult
   ```
   Export the per-step screenshots (`xcrun xcresulttool export attachments …`; adapt the subcommand to the installed Xcode) into `.planning/walkthrough/<flowId>/`, then **Read them in order** to confirm each step lands where the flow says.

3. **Layer 3 — human discoverability checklist.** For the 2–4 flows that matter, emit a tap-script the user runs and rates (was each action findable? where did you hesitate?). This is the only layer that catches "how do I even do X" — a UI test taps hidden controls and passes.

## Output: `.planning/WALKTHROUGH.md`

Write the report in the skill's format: Layer 1 findings (with file:line), a Layer 2 table (flow → pass / dead-end, filmstrip path), and the Layer 3 checklist for the user to fill in. Store screenshots under `.planning/walkthrough/<flowId>/`.

**Gate:** fix all Layer-1 dead-ends and Layer-2 reachability failures before the phase is marked complete — same discipline as `/apple:visual-qa`. Discoverability items from Layer 3 are design decisions: surface them, let the user decide.

## Cadence

Run **per flow-slice, not per-phase** — right after building a create→edit→results loop, walk that loop. This is where the highest-value UX bugs surface, and they're cheapest to fix the minute they're introduced. Complements `/apple:visual-qa` (screens) — this command is about flow.

## Completion Message

```
🚶 Walkthrough complete!

Created: .planning/WALKTHROUGH.md  (+ screenshots in .planning/walkthrough/)

Layer 1 (nav graph):   🔴 [N] dead-ends / no-edit-paths
Layer 2 (driven):      ✅ [N] flows reach their targets / ❌ [N] failed
Layer 3 (human):       ⏳ discoverability checklist ready for you to run

[If dead-ends or failures:] Fix these before marking the phase complete.
[Else:] Flows are structurally sound — run the Layer 3 checklist on device to judge discoverability.
```
