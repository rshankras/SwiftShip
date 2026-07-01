---
description: Run App Store Product Page Optimization A/B tests (icon, screenshots, subtitle), read the results, and promote the winner — measurable conversion lift wired back into learn-from-store.
argument-hint: "[what to test: icon | screenshots | subtitle]"
allowed-tools: Read, Write, AskUserQuestion, Skill, mcp__asc-metadata__list_experiments, mcp__asc-metadata__create_experiment, mcp__asc-metadata__create_experiment_treatment, mcp__asc-metadata__update_experiment, mcp__asc-metadata__delete_experiment, mcp__asc-metadata__get_analytics_report, mcp__asc-metadata__get_metadata
---

# Experiment — A/B the product page

Test the highest-impact conversion levers (app icon, screenshot set, subtitle) with Apple's
Product Page Optimization, measure the winner, and promote it. Conversion is the cheapest growth
lever an indie has — this makes it evidence-driven instead of a guess.

## Arguments

- `$ARGUMENTS` or `$1`: the lever to test — `icon`, `screenshots`, or `subtitle`. Empty → pick in Step 1.

## When to Use

- The app has enough traffic for a readable test (else grow installs first).
- After a screenshot/icon refresh you want to validate before committing.
- Its results feed `/apple:learn-from-store` (a conversion signal with a baseline).

## Prerequisites

```
Read: .planning/POSITIONING.md, .planning/ASO.md, .planning/SIGNALS.md
```

- A live app with a configured Product Page; ASC access (optional) for the experiment records.
- Staged treatment assets (or run `/apple:screenshots` / `/apple:icon` first).

## Load the Skill

```
Read: ~/.claude/swiftship-skills/generators/product-page-optimization/SKILL.md
```

Apply for test design (one variable, sample size, duration), significance reading, and promote-the-winner mechanics.

## Step 1: Pick the lever + hypothesis

- Read `POSITIONING.md`, `ASO.md`, current `get_metadata`.
- Choose ONE variable (don't confound). Write a hypothesis + the metric (impression→download).

## Step 2: Prepare treatments

- 1–3 treatments vs the baseline. For screenshots/icon, stage assets (reuse `/apple:screenshots`
  / `/apple:icon`). Keep everything else constant.

## Step 3: Create the experiment — Optional handoff

Per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`:

- **DETECT** `create_experiment` / `create_experiment_treatment`; missing → manual "Product Page
  Optimization" steps in ASC.
- **PREVIEW** the experiment (lever, treatments, traffic proportion, duration) and the recorded
  start-baseline conversion; ⚠️ this becomes a live test visible to a share of real traffic.
- **CONFIRM** (manual default first) → **ACT** create the experiment + treatments → **FALL BACK** to
  the manual ASC checklist.

## Step 4: Monitor

- `list_experiments` / `get_analytics_report` over the run; **don't peek-and-stop early.**
- Record improvement per treatment with confidence.

## Step 5: Decide + promote

- Winner beats control with confidence → promote it (make it default via `/apple:metadata`
  / `/apple:icon`), then `update_experiment` to stop. No winner → keep control, log the learning.

## Step 6: Record

- Append to `SIGNALS.md`: lever, winner, lift, new baseline. Suggest the next lever to test.

## Output

A live (then concluded) Product Page experiment; a promoted winner (or retained control); and a
`SIGNALS.md` row recording lever · winner · lift · new baseline — a conversion signal for
`/apple:learn-from-store`.

## Completion Message

```
🧪 Experiment concluded — [lever]

Treatments: [B, C] vs control
Winner:     [B]  +[X]% impression→download  (confidence [Y]%)   |  or: no winner → control kept
Promoted:   made default via /apple:[metadata|icon]
Logged:     SIGNALS.md — new baseline [Z]%

Next: /apple:learn-from-store to fold the lift in, or test the next lever.
```

## Principles

- One variable per test; no confounding.
- Respect statistical significance — no early stops.
- Promote only a confident winner; every result (win or null) is logged for `learn-from-store`.
