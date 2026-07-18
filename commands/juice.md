---
description: Game-feel audit + fix pass — celebrations, haptics, sound, motion polish
argument-hint: [audit | fix 1|2|3]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
---

# Juice (Game Feel)

Audit whether every meaningful event in the app actually reaches its audience — across screen motion, haptics, and sound — then fix the gaps in tiers. Catches the failure `/apple:visual-qa` can't see in a screenshot: the app *looks* right but its big moments fall flat.

## Arguments

- `$ARGUMENTS`: `audit` (default), or `fix 1|2|3` to execute a tier from an existing `.planning/JUICE.md`, or a scope hint (e.g. a mode/screen name) to narrow the audit.

## Step 1: Load Context

```
Read: .planning/APP.md (if exists)
Read: .planning/STATE.md (if exists)
Read: CLAUDE.md (if exists)
```

Determine:
- Platform (iOS/macOS) and whether haptics hardware is even in scope (macOS: no)
- **Audience model** — single-user in-hand, or room-facing/shared-phone (party games, timers, presentations)? This decides which channels are mandatory (see the reach table in the skill).
- The app's modes/flows, so the audit enumerates events per mode.

## Step 2: Load Skills

```
Read: ~/.claude/swiftship-skills/design/game-feel/SKILL.md
Read: ~/.claude/swiftship-skills/design/game-feel/feedback-audit.md
Read: ~/.claude/swiftship-skills/design/game-feel/haptic-design.md
Read: ~/.claude/swiftship-skills/design/game-feel/sound-design.md
Read: ~/.claude/swiftship-skills/design/animation-patterns/SKILL.md
```

## Step 3: Audit (default mode)

Run the **three-lens sweep** from `feedback-audit.md`. Spawn three `swift-generalist` agents **in parallel, review mode — findings only, no edits**, one per lens:

1. **Haptics + sound inventory** — mechanism/architecture, every fire-site mapped to its event per mode, audio assets + session handling, user toggles, silent events
2. **Motion inventory** — every animation API use, celebration moments, timer visualizations, Reduce Motion gates, loading states, vocabulary consistency
3. **Cohesion + reach** — design-system coverage vs stock chrome, room-facing readout sizes, cross-channel escalation agreement, double-fire owners

Each agent returns raw facts with `file:line` evidence and explicit "NOT FOUND" statements (prompt outlines are in `feedback-audit.md`). Then synthesize **inline** (do not delegate judgment):

- Build the **event×channel matrix**, worst rows first
- Score the six rubric dimensions
- Route every finding into 🔴/🟠/🟡/🟢 and the three fix tiers

## Step 4: Write .planning/JUICE.md

Use the output format from `feedback-audit.md`: scorecard, matrix, findings by severity, fix tiers with per-item file targets and effort. End with the **device-pass note** — haptic tuning, loudness balance, and torch visibility cannot be verified in the Simulator; list what needs a physical device.

Update `.planning/STATE.md` current-task notes with a one-line pointer to JUICE.md (do not restructure STATE.md).

## Step 5: Fix Mode (`fix N`)

Requires `.planning/JUICE.md` (run the audit first if missing). Execute one tier per invocation — tiers are ordered by risk, and each ends with the full test suite green before the next is offered.

**Tier 1 — Wiring (hours, no design decisions):**
Missing haptic events + vocabulary gaps (new semantic events per `haptic-design.md`), `.contentTransition(.numericText())` on scores/counters, `.symbolEffect` on feedback glyphs, double-fire fixes, haptics user toggle if missing. Route to `swift-generalist`.

**Tier 2 — Celebration moments (about a day):**
Confetti burst + winner reveals (use `generators/milestone-celebration`; respect the rarity gradient — the burst fires **only** at the rarest events), signature reveals (deal/flip/land animations per `design/animation-patterns`), phase-change transitions replacing hard cuts, minimum durations on anticipation moments (spins, draws). Route to `swiftui-builder`. Every new effect gets a Reduce Motion static equivalent.

**Tier 3 — Sound layer (a day + assets + policy):**
Never start Tier 3 without user decisions. Ask first:

```
AskUserQuestion:
  1. "Silent-switch policy: play SFX through the ringer switch during active
     sessions (room-facing default), or respect the switch (utility default)?"
  2. "Asset sourcing: generate placeholder tones now (afconvert), or wait for
     licensed/designed sounds?"
```

Then implement per `sound-design.md`: minimal kit (tick/buzzer/ding/reveal/fanfare), preloaded `.caf` players in a service mirroring the haptics architecture, session category per the coexistence table (never kill the user's music), in-app mute toggle, VoiceOver announcements alongside room-critical sounds.

After each tier: run the project's tests (respect any offline-guarantee or grep-contract tests — SFX assets and audio session code may need allowlisting the same way music code did), mark the tier done in JUICE.md, and report what changed.

## Step 6: Report

Scorecard before → projected after, the matrix rows that changed, what remains in later tiers, and the standing device-pass checklist. If scores were previously recorded in JUICE.md, show the delta instead of re-auditing from scratch.

## Notes

- **Never widen scope mid-tier** — a juice pass is polish, not a feature phase; it must not push scheduled phases (check STATE.md for calendar constraints before proposing Tier 2/3 work).
- Paywall/lock moments are **not** celebration moments — never attach juice to monetization surfaces beyond what the purchase flow already has.
- macOS targets: skip haptic tiers; motion + sound rules still apply.
