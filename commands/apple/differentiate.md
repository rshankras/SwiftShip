---
description: Originality / 4.3-spam guardrail — check that an app (and each portfolio addition) is meaningfully distinct in function, content, and metadata before you invest or submit. Protects the whole developer account.
argument-hint: "[app path | idea]"
allowed-tools: Read, Write, WebSearch, Glob, Grep, AskUserQuestion, Skill, mcp__asc-metadata__list_apps, mcp__asc-metadata__get_metadata
---

# Differentiate — the anti-spam guardrail

At portfolio scale, shipping many similar small apps is exactly what triggers Guideline 4.3
(spam / duplicate) rejections — and repeated 4.3s put the *whole account* at risk. This gate checks
real distinctiveness before you build or submit.

## Arguments

- `$ARGUMENTS` or `$1`: the app path (existing) or the idea (a sentence). Empty → ask which app/idea to check.

## When to Use

- At `/apple:validate` / `/apple:new-app` time (don't build a dup).
- Before `/apple:submit` (don't trip 4.3).
- Periodically across the portfolio (internal cannibalization / template-sameness).

## Prerequisites

```
Read: .planning/VALIDATION.md, .planning/APP.md   # if present — market + positioning context
```

- The app/idea to evaluate. Optional ASC access to read your existing portfolio.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/app-store/originality-check/SKILL.md
```

Apply for the internal/external checks, the 4-dimension distinctness scorecard, and the verdict + remedy playbook.

## Step 1: Internal check (your own portfolio)

- `list_apps` + read each app's positioning (`get_metadata`). Does this overlap an app you already
  ship in function, code template, or metadata? Two apps that differ only in theme = 4.3 risk.

## Step 2: External check (the market)

- If `VALIDATION.md` is missing or stale, run `/apple:validate` (via Skill) to pull fresh competitor +
  market data; otherwise read it. Add a `WebSearch` for close look-alikes.
- Judge: is the core function a thin reskin of an existing app, or a genuine wedge?

## Step 3: Distinctiveness scorecard

Score each dimension — meaningful difference vs cosmetic (flag any that's only skin-deep):

- **Function** — does it do something materially different?
- **Content/data** — unique, not a generic wrapper.
- **Metadata** — name/keywords/screenshots not near-identical to siblings/competitors.
- **UX/value** — a real reason to choose it.

## Step 4: Verdict + remedy

- **Distinct** → proceed. **Borderline** → concrete ways to differentiate (merge into one
  configurable app, add the unique wedge, or drop it). **Duplicate** → recommend not shipping.
- If several thin apps already exist, suggest consolidating into one strong app (better for ranking + review).

## Step 5: Record

- Write the verdict + reasoning to `.planning/` (VALIDATION or STATE). If borderline-approved, note
  the specific wedge that must be built to clear 4.3.

## Output

A written verdict (distinct / borderline+wedge / duplicate) with per-dimension reasoning, recorded in
`.planning/` (VALIDATION or STATE). For a borderline-approved app, the specific wedge is captured as a
build requirement.

## Completion Message

```
🛡️ Originality check — [app/idea]

Verdict:  DISTINCT | BORDERLINE | DUPLICATE
Scorecard: function ✓ · content ✓ · metadata ⚠ near a sibling · UX ✓
Remedy:   [proceed | build wedge "X" before submit | consolidate into one app]
Recorded: .planning/VALIDATION.md (or STATE.md)

Next: proceed to /apple:new-app — or address the 4.3 risk first.
```

## Principles

- Cosmetic theming ≠ differentiation; Apple judges function + metadata similarity.
- Protect the account: one 4.3 is a warning, repeated 4.3s are existential.
- Prefer one strong app over several thin ones.
