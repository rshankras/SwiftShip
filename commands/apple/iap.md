---
description: Finalize a one-time in-app purchase in App Store Connect — set its price + localized name/description (dry-run first). Not for subscriptions; not the same as promoted-iap.
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion, mcp__asc-metadata__list_iap, mcp__asc-metadata__get_iap
argument-hint: [iap-name]
---

# Finalize In-App Purchase (ASC metadata)

Take a one-time IAP from `MISSING_METADATA` → `READY_TO_SUBMIT` in App Store Connect by setting its **price** + **localized display name/description** — the two fields the `asc-metadata` MCP can't set. A Phase-6 pre-submit step; also invoked from `/apple:submit`.

**Scope (important):** one-time IAPs only. This is **not** the `promoted-iap` generator (that's in-app code to *display* IAPs on the product page), and it does **not** define the product — the product + price come from **Phase 4 (Monetization/StoreKit)**; this finalizes the existing ASC record.

## Arguments

- `$ARGUMENTS` or `$1`: which IAP (display name or product id). Empty → list IAPs and ask.

## Prerequisites

```
Read: .planning/APP.md
Read: .planning/MONETIZATION.md (or PLAN.md)   # the PRICE decision — read it, don't re-invent
```

- The ASC IAP record must **already exist** — `mcp__asc-metadata__list_iap` to find its id.
- `_shared/asc-api/` set up (one-time ASC API key — the skill's README walks §0).

## Load the Skill

```
Read: ~/.claude/swiftship-skills/app-store/iap-finalizer/SKILL.md
```

## Process

Follow the skill. In short: confirm the IAP + **price read from `.planning/`** (not a fresh prompt) → find the price point → set the price schedule → set the en-US localization → verify the state advanced. **Every ASC write is dry-run → show the body → confirm → `--apply`.**

## Output

IAP priced + localized in ASC, state `READY_TO_SUBMIT`. No `.planning/` file — the change lives in App Store Connect. Feeds `/apple:submit`.

## Completion Message

```
💰 IAP finalized!

IAP:    [name] ([productId])
Price:  [price]  (Phase-4 decision, confirmed — not re-elicited)
Locale: en-US name + description set
State:  MISSING_METADATA → READY_TO_SUBMIT

Next: /apple:submit — the IAP ships with the build.
```
