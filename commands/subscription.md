---
description: Set up and manage auto-renewable subscriptions — groups, tiers, intro/promotional/win-back offers, and the StoreKit 2 lifecycle — for recurring-revenue apps (complements iap for one-time unlocks).
argument-hint: "[product name]"
allowed-tools: Read, Write, Edit, AskUserQuestion, Skill, mcp__asc-metadata__list_subscription_groups, mcp__asc-metadata__create_subscription_group, mcp__asc-metadata__list_subscriptions, mcp__asc-metadata__create_subscription, mcp__asc-metadata__update_subscription, mcp__asc-metadata__list_price_points
---

# Subscription — recurring revenue, done right

Create auto-renewable subscriptions (groups, tiers, offers) and wire the StoreKit 2 lifecycle. Use
when the value is ongoing; `/apple:iap` remains the tool for one-time unlocks.

## When to Use

- The app delivers continuous value (content, sync, ongoing updates) — not episodic use.
- Adding intro/win-back offers to an existing subscription.
- Skip if the value is one-and-done → use `/apple:iap`.

## Prerequisites

```
Read: .planning/POSITIONING.md, .planning/STATE.md
Read: .planning/MONETIZATION.md (or PLAN.md)   # the pricing/tier decision, if one exists
```

- App target builds; a bundle id with the In-App Purchase capability.
- ASC access (the `asc-metadata` MCP) for the subscription records — optional; falls back to the ASC UI.

## Load Skills

```
Read: ~/.claude/swiftship-skills/generators/subscription-lifecycle/SKILL.md
Read: ~/.claude/swiftship-skills/generators/subscription-offers/SKILL.md
Read: ~/.claude/swiftship-skills/generators/win-back-offers/SKILL.md
```

Also load reference files the skills mention (e.g. subscription-lifecycle's `patterns.md` /
`templates.md`) for the StoreKit 2 entitlement + offer code.

## Step 1: Model the offer

- Read `POSITIONING.md`. Justify recurring value honestly (Apple rejects thin subs — 3.1.2).
- Design the group + tier(s) (monthly/annual), free-trial/intro, and what's gated free vs paid.

## Step 2: Create in ASC — Optional handoff

Per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`, if the `asc-metadata` MCP is
available, create the records through it instead of the manual ASC UI:

- **DETECT** the `mcp__asc-metadata__create_subscription*` tools; missing → print the manual ASC UI steps.
- **PREVIEW** the group + subscription bodies and the price (from `list_price_points`) as a
  before→after; note ⚠️ these become live products in App Store Connect.
- **CONFIRM** via AskUserQuestion (manual default first).
- **ACT:** `create_subscription_group` → `create_subscription`; add localized copy; echo the ids.
- **FALL BACK:** the manual "create in ASC ▸ Subscriptions" checklist, unchanged.

Add review notes + the required paywall screenshot at submission.

## Step 3: Offers

- Intro (free trial / pay-as-you-go), promotional, and win-back offers (`update_subscription`) —
  same preview → confirm → apply gate.

## Step 4: StoreKit 2 code

- Products fetch, purchase, `Transaction.currentEntitlements`, renewal/expiry, grace period,
  restore. Gate features on the entitlement. Reuse the `subscription-lifecycle` skill's code.
- Local `.storekit` config for Simulator testing (`SKTestSession`).

## Step 5: Compliance

- Paywall discloses price / terms / auto-renew + Terms & Privacy links (Apple 3.1.2). Verify before submit.

## Output

Subscription group + tier(s) + offers created in ASC; StoreKit 2 entitlement wired in code; a local
`.storekit` for testing. Record products + the entitlement model in `STATE.md`; suggest `/apple:test`
for the entitlement path.

## Completion Message

```
🔁 Subscription set up — [group] / [product]

Tiers:   [monthly $X.XX] · [annual $Y.YY]
Offers:  [intro: 7-day free trial] [+ win-back]  (previewed → confirmed → applied)
Code:    StoreKit 2 entitlement gated; .storekit test config added
Paywall: price + auto-renew terms + Terms/Privacy links disclosed (3.1.2 ✓)

Next: /apple:test — verify purchase / restore / expiry, then /apple:submit.
```

## Principles

- Only for genuinely ongoing value; disclose terms fully on the paywall.
- Dry-run → confirm → apply; test purchase / restore / expiry before shipping.
