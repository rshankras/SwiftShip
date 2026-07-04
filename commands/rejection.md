---
description: Work an App Review rejection to resolution — parse the reason, map it to the exact guideline, produce a fix + a Resolution Center reply, and re-submit. Turns a rejection into a checklist, not a panic.
argument-hint: "[paste the rejection message or guideline number]"
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Skill, mcp__asc-metadata__get_metadata, mcp__asc-metadata__get_age_rating, mcp__asc-metadata__get_iap
---

# Rejection — from "no" to resubmit

Systematically resolve an App Store review rejection: identify the guideline, diagnose the real
cause, apply the fix (code / metadata / privacy / paywall), and draft a professional Resolution
Center response.

## Arguments

- `$ARGUMENTS` or `$1`: the rejection message text or a guideline number (e.g. `4.3`). Empty → ask
  the user to paste the Resolution Center message.

## When to Use

- A rejection or metadata-rejection from App Review.
- A pre-submit self-audit against the guidelines most likely to bite this app.

## Prerequisites

```
Read: .planning/STATE.md, .planning/REVIEW.md   # context: what shipped, prior findings
```

- The rejection text (Resolution Center) or the guideline number in `$ARGUMENTS`.
- ASC read access (optional) to inspect the flagged artifact.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/app-store/rejection-handler/SKILL.md
Read: ~/.claude/swiftship-skills/app-store/rejection-handler/common-rejections.md
```

Apply for the guideline map, per-guideline fix playbooks, and Resolution Center reply templates.

## Step 1: Parse the rejection

- Map to the exact guideline (e.g. 2.1 crash, 3.1.1 IAP, 4.3 spam, 5.1.1 privacy, 2.3.x metadata).
- For a **4.3 (spam/duplicate)** flag, pair with `/apple:differentiate` to prove distinctness.

## Step 2: Diagnose the real cause

- Reproduce if functional (`/apple:debug`); inspect the specific artifact
  (`get_metadata` / `get_iap` / `get_age_rating`, `PrivacyInfo.xcprivacy`, permission strings, paywall).
- Distinguish a genuine issue from a reviewer misunderstanding.

## Step 3: Fix

- Genuine → apply the minimal correct fix; rebuild green; `/apple:verify`.
- Misunderstanding → prepare a clear demo path / review notes (don't just re-submit unchanged).

## Step 4: Draft the Resolution Center reply

- Professional and specific: what changed or why it complies, with steps to reproduce the intended behavior.
- Carry the app's guardrail framing (e.g. Crowdroar: relative reaction score, not a decibel/hearing device).

## Step 5: Resubmit + record

- Re-submit via `/apple:ship` / `/apple:submit`.
- Log the rejection + fix in `STATE.md`, and if it's a reusable lesson, `/apple:learn` it into a skill.

## Output

The identified guideline, the applied fix (code/metadata/privacy), and a ready-to-paste Resolution
Center reply. `STATE.md` updated with the rejection + resolution; optionally a captured lesson.

## Completion Message

```
✅ Rejection resolved — Guideline [N.N.N]

Cause:   [genuine issue | reviewer misunderstanding]
Fix:     [what changed]  → rebuilt green, /apple:verify passed
Reply:   Resolution Center response drafted (specific + reproduction steps)
Logged:  STATE.md  [+ /apple:learn lesson if reusable]

Next: /apple:ship (or /apple:submit) to resubmit.
```

## Principles

- Fix the cause, don't just re-roll the dice.
- Reply respectfully and concretely; give the reviewer a path.
- Every rejection becomes a captured lesson so it doesn't recur across the portfolio.
