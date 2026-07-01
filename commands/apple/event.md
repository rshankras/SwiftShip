---
description: Create and manage App Store in-app events — promotable cards that surface in Search & Today for discovery and re-engagement (e.g. a themed challenge or seasonal contest).
argument-hint: "[event name]"
allowed-tools: Read, Write, AskUserQuestion, Skill, mcp__asc-metadata__list_app_events, mcp__asc-metadata__create_app_event, mcp__asc-metadata__update_app_event, mcp__asc-metadata__delete_app_event, mcp__asc-metadata__update_event_localization
---

# Event — in-app events for discovery & re-engagement

Author an App Store in-app event: a time-boxed, promotable moment (challenge, premiere,
competition, seasonal push) that appears in Search, the app page, and can be featured — free
discovery plus a reason for lapsed users to return.

## Arguments

- `$ARGUMENTS` or `$1`: the event name/idea (e.g. `Weekend Open-Mic Challenge`). Empty → propose in Step 1.

## When to Use

- A recurring/seasonal hook the app's job supports (e.g. Crowdroar: "Weekend Open-Mic Challenge").
- Re-engagement pushes and coordinated launch/marketing beats.
- NOT for permanent features — events are time-boxed by design.

## Prerequisites

```
Read: .planning/POSITIONING.md, .planning/STATE.md
```

- A live app; ASC access (optional) for the event record; event art/video staged (or handed off to assets).

## Load the Skill

```
Read: ~/.claude/swiftship-skills/generators/in-app-events/SKILL.md
```

Apply for event type/badge selection, copy limits, art specs, and the ASC event metadata rules.

## Step 1: Fit-check against positioning

- Read `POSITIONING.md`. The event must serve the app's job, not bait installs (Apple rejects
  off-topic events). Pick the type (challenge / competition / new content / special) + the window.

## Step 2: Author the card

- Name (≤30), short + long description, the in-app deep-link destination, badge type.
- Guardrail-clean copy (carry the app's guardrails, e.g. no decibel/hearing-health).
- Event art/video (note the required sizes; stage or hand off to assets).

## Step 3: Create + localize — Optional handoff

Per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`:

- **DETECT** `create_app_event` / `update_event_localization`; missing → manual "In-App Events" steps in ASC.
- **PREVIEW** the card (name, descriptions, badge, dates, deep link) as before→after; ⚠️ it goes
  through App Review and becomes publicly visible.
- **CONFIRM** (manual default) → **ACT** `create_app_event`, then `update_event_localization` per
  locale (pair with `/apple:localize`) → **FALL BACK** to the manual ASC checklist.

## Step 4: Schedule + submit

- Set publish/start/end dates; events go through review — submit ahead of the window.

## Step 5: Measure

- After it runs, use `/apple:learn-from-store` to pull impressions/opens and feed the re-engagement
  lift into the backlog (that command owns analytics; keep this one's tool surface minimal).

## Output

An in-app event created + localized in ASC, scheduled and submitted for review ahead of its window.
Note the event + window in `STATE.md`; route measurement to `/apple:learn-from-store`.

## Completion Message

```
🎉 In-app event authored — [name]

Type:    [challenge]   Window: [start → end]
Card:    name/short/long + badge + deep-link set (guardrail-clean)
Locales: [en-US, …] localized
Status:  submitted for review (ahead of the window)

Next: /apple:localize for more markets · /apple:learn-from-store after it runs.
```

## Principles

- On-strategy only; time-boxed; guardrail-clean.
- Dry-run → confirm → apply; submit with lead time for review.
