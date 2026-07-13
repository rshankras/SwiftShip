---
description: Plan a phased release for an existing app — scope features + bug fixes into a structured plan
argument-hint: [what this release includes]
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion, Skill, mcp__asc-metadata__get_sales_report, mcp__asc-metadata__get_analytics_report
---

# Plan an Existing-App Release

Give an app that already exists the same phase → plan → build structure that
`/apple:new-app` + `/apple:roadmap` give a new app — but scoped to an **update**:
one release that bundles new features **and** bug fixes into a single tracked
plan, grounded in what the code already does.

This is the existing-app counterpart to `/apple:roadmap`. Use it instead of
`/apple:roadmap` (which assumes a greenfield v1.0) whenever you're shipping an
update to a shipped app.

## When to Use

- Adding a feature and/or fixing bugs in an app that already exists
- Planning a point release (patch / minor / major) of a shipped app
- The app was **not** originally built with SwiftShip (no prior milestone)
- You've run `/apple:map` and want to turn that analysis into a real plan

For a single known bug with no feature work, `/apple:bugfix` is faster — it
skips the plan. Use `/apple:release` when there's more than one thing to ship.

## Prerequisites — Load Context

Read what already exists (all optional — the command degrades if a file is absent):

```
Read: .planning/CODEBASE.md    # From /apple:map — architecture, tech debt, gaps
Read: .planning/APP.md         # App spec, if the app ever ran new-app
Read: CLAUDE.md                # Project conventions
Read: .planning/STATE.md       # Prior state, if any
Read: .planning/IDEAS.md       # Captured ideas to pull from
```

**If `CODEBASE.md` is missing**, strongly recommend mapping first — the release
plan is only as good as its picture of the current code:

```
⚠️ No codebase map found. Run /apple:map first so this release plan knows what
   already exists (and can skip re-building it). Continue without it? (y/n)
```

If the user continues without a map, infer structure by scanning directly
(`Glob: **/*.swift`, `Grep` for `@Observable` / `@Model` / `NavigationStack`).

## Step 1: Detect the Current Version

Find the shipped version so the next version is proposed from reality, not v1.0:

```bash
# Marketing version from the Xcode project
grep -m1 "MARKETING_VERSION" *.xcodeproj/project.pbxproj 2>/dev/null
# Fallback: Info.plist
/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" **/Info.plist 2>/dev/null
# Latest release tag, if the repo is tagged
git tag --list 'v*' --sort=-v:refname | head -1
```

Record the detected current version. If none is found, ask the user what version
is currently live.

## Step 2: Gather Release Scope

Parse `$ARGUMENTS` if provided (e.g. `"add Search, fix the settings crash"`) and
sort items into **features**, **bugs**, and **improvements**. Then fill gaps by
asking — keep it light, a release is smaller than a whole app:

1. **Features** — what new capability ships in this release? (0 or more)
2. **Bugs** — what's broken that this release fixes? Paste crash logs, review
   quotes, or descriptions. (0 or more)
3. **Improvements** — anything to clean up while you're in here?

**Seed candidates from the map.** If `CODEBASE.md` has a *Technical Debt* or
*Areas for Improvement* section, surface the top items as optional additions:

```
From your codebase map, these came up — fold any into this release?
- [ ] [Tech-debt item 1]
- [ ] [Force unwraps in PaymentManager]
```

**Optional handoff: inform scope with live numbers** — per
`~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`:
- **DETECT:** are the `portfolio-health-monitor` / `daily-sales-pulse` skills and
  the `asc-metadata` MCP available? If not, skip this and use only what the user
  provided.
- **ACT (read-only — no write, no confirm needed):** pull this app's week-over-week
  crashes, rating deltas, and any new ≤2★ reviews. Fold anomalies into scope — a
  crash-rate spike argues for a bug in the Fix phase; a rating dip on a named
  feature argues for an improvement.
- **FALL BACK:** unavailable or errored → use only the user-provided scope.

This is read-only telemetry; it changes nothing on App Store Connect.

## Step 3: Determine the Next Version

Propose the next version from the scope and the detected current version:

| Scope | Bump | Example |
|-------|------|---------|
| Bug fixes only | Patch | 1.3.2 → 1.3.3 |
| New features, backwards compatible | Minor | 1.3.2 → 1.4.0 |
| Breaking changes / major overhaul | Major | 1.3.2 → 2.0.0 |

Confirm the proposed version with the user before writing files.

## Step 4: Create `.planning/RELEASE.md`

This is the release **scope manifest** — the single container that unifies
features + bugs (what neither the greenfield roadmap nor the bugfix lane give
you). Read the template and fill it in:

```
Read: ~/.claude/swiftship-templates/RELEASE.md
```

Populate `<baseline>` from `CODEBASE.md` (architecture, shipped version, test
coverage), and enumerate `<features>`, `<bugs>`, `<improvements>`, and a
`<regression-scope>` — the existing flows adjacent to your changes that must
still work after this release.

## Step 5: Create the Release `ROADMAP.md`

Generate `.planning/ROADMAP.md` scoped to **this release only** — a small set of
**intent-tagged** phases that scale to the scope (not the fixed 7). Each phase
carries an `intent` attribute so `/apple:plan` routes the right skills (features
get build skills, bugs get the regression-test workflow) instead of assuming
greenfield phase meanings.

> If a prior version's `ROADMAP.md`/`PLAN.md` is still active, run
> `/apple:milestone` first to archive it. This command regenerates them for the
> new release.

```markdown
# Release Roadmap: v[NEW_VERSION]

**App:** [name]  ·  **Previous:** v[CURRENT_VERSION]  ·  **Type:** [patch|minor|major]
**Started:** [date]

## Release Goal
[One or two sentences: what this update delivers.]

## Phases
<!-- Include only the phases this release needs. A patch is often just Fix + Ship. -->

### Phase 1: Build   (intent: feature)
**Status:** pending
**Objective:** Implement the new features
Tasks:
- [ ] [Feature 1] — [screens/models touched]
- [ ] [Feature 2]

### Phase 2: Fix   (intent: bugfix)
**Status:** pending
**Objective:** Fix the bugs in scope, each with a regression test
Tasks:
- [ ] [Bug 1] — [symptom] — regression test required
- [ ] [Bug 2]

### Phase 3: Harden   (intent: quality)
**Status:** pending
**Objective:** Confirm new work is sound and existing flows still work
Tasks:
- [ ] Regression walkthrough of adjacent flows (from RELEASE.md <regression-scope>)
- [ ] Tests / review / security / perf as warranted by scope

### Phase 4: Ship   (intent: release)
**Status:** pending
**Objective:** Prepare and submit the update
Tasks:
- [ ] What's New screen + release notes (/apple:release-notes)
- [ ] Refresh screenshots if UI changed
- [ ] TestFlight, then submit

## Out of Scope
- [Explicitly not in this release]

## Success Criteria
v[NEW_VERSION] is done when:
- [ ] All in-scope features + bugs complete
- [ ] Regression scope re-verified (no adjacent flow broke)
- [ ] /apple:verify and /apple:review pass
```

Scale the phases to scope: **drop Build** for a pure bugfix patch; **drop Fix**
for a pure feature release.

## Step 6: Update STATE.md

Write `.planning/STATE.md` (create if absent) so `/apple:plan` and `/apple:build`
pick up where this leaves off:

```markdown
# Project State

## Current Position
- **Milestone:** v[NEW_VERSION] ([patch|minor|major] release)
- **Previous:** v[CURRENT_VERSION] (shipped)
- **Phase:** 1
- **Phase Status:** pending
- **Last Updated:** [date]

## Release Scope
- Features: [N]  ·  Bugs: [N]  ·  Improvements: [N]
- Scope manifest: .planning/RELEASE.md

## Next Action
Run /apple:discuss 1, then /apple:plan 1 to detail Phase 1.
```

## Completion Message

```
✅ Release v[NEW_VERSION] planned!

Created:
- .planning/RELEASE.md   - Release scope (features + bugs + regression scope)
- .planning/ROADMAP.md   - [N] intent-tagged phases for this release
- .planning/STATE.md      - Reset for this release

Scope:
- Features: [N]   Bugs: [N]   Improvements: [N]
- v[CURRENT] → v[NEW] ([patch|minor|major])

Next steps:
1. Review .planning/RELEASE.md and ROADMAP.md
2. Run /apple:discuss 1 to set implementation preferences
3. Run /apple:plan 1 to detail Phase 1 tasks
4. Run /apple:build to implement

Tip: /apple:growth (quarterly) and /apple:learn-from-store (monthly) feed this
scope — the audit finds missing levers, the signals loop finds what to fix.

Ship it! 🚀
```

## Workflow Integration

**Existing-app release flow:**
```
/apple:map → /apple:release → /apple:discuss → /apple:plan → /apple:build
           → /apple:verify → /apple:review → /apple:release-notes → /apple:milestone
```

`/apple:release` reuses the same `plan → build` engine as the greenfield flow —
it only replaces the roadmap-generation step with an update-scoped, existing-code-aware one.

**Files this command creates:**
- `.planning/RELEASE.md` - Release scope manifest
- `.planning/ROADMAP.md` - Intent-tagged phase plan for the release
- `.planning/STATE.md` - Project state (created or reset for this release)
