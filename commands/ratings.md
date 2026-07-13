---
description: Manage the rating as an asset — per-storefront rating health, a gated reply workflow for unanswered negative reviews (drafted from the library skill, posted via the ASC API on explicit OK), and the never-reset guardrail. Replies are the only mechanism that flips existing ratings.
argument-hint: "[app-name-or-appId] — defaults to the current .planning project; --portfolio for all apps"
allowed-tools: Read, Write, AskUserQuestion, Skill, mcp__asc-metadata__list_apps, mcp__asc-metadata__list_reviews, mcp__asc-metadata__get_review, mcp__asc-metadata__respond_to_review, mcp__asc-metadata__delete_review_response, mcp__asc-metadata__get_availability
---

# Ratings — manage the asset

Your rating is per-storefront social proof that converts (or kills) every impression. This
command runs the maintenance loop: check health per storefront, answer the negative reviews
that are recoverable stars, and protect the summary from the one irreversible mistake.

**Every reply is gated.** Drafts are shown and posted only on explicit OK — a reply is
public, permanent-ish, and speaks in the app's voice.

## When to Use

- Monthly (pairs with `/apple:learn-from-store` — that reads the signals; this answers them).
- After a bad launch window or a review-bomb.
- After entering new storefronts (`/apple:localize`) — fresh markets have fragile ratings.
- `--portfolio` — which of your live apps has unanswered negatives piling up?

## Prerequisites

```
Read: .planning/STATE.md, .planning/APP.md   # appId + the app's voice/positioning
```

- A live app; `appId` resolvable from `STATE.md`, else `list_apps` + confirm.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/app-store/ratings-mechanics/SKILL.md
Read: ~/.claude/swiftship-skills/app-store/review-response-writer/SKILL.md
```

`ratings-mechanics` is the strategy layer (per-storefront isolation, phased-release armor,
the never-reset rule); `review-response-writer` is the voice (templates, tone, when NOT to
respond).

## Step 1: Resolve the App

Resolve `appId` from `STATE.md`; if absent, `list_apps` and confirm with `AskUserQuestion`.
Read `get_availability` for the storefront list so health is framed per market.

## Step 2: Pull Rating Health (read-only)

- `list_reviews` — recent reviews, lowest-star first; collect per storefront: rating
  distribution, review counts, and **unanswered 1–3★ reviews from the last 90 days**
  (`get_review` for full text where needed).
- Flag **fragile storefronts**: few ratings where one negative dominates the average —
  ratings don't travel across storefronts, so each market is its own reputation.

## Step 3: Prioritize

Order the reply queue by leverage, not recency alone:

1. Fragile storefronts first (one flipped review moves the average most).
2. Fixable complaints (bug since fixed, misunderstanding, missing-feature-that-exists) —
   these convert to updated ratings; per `review-response-writer`, an updated rating
   **replaces** the old score.
3. Recent + detailed reviews over old drive-bys.
4. Skip where silence is better (rants with nothing actionable — the skill's
   when-not-to-respond rules).

## Step 4: Draft Replies

Draft each reply with `review-response-writer`: acknowledge the specific issue, state the fix
or workaround, invite the user back — in the app's voice from `APP.md`. No boilerplate blast:
identical replies on every review read worse than no reply.

## Step 5: Gate + Post

- Present the queue: review excerpt + draft reply, one `AskUserQuestion` per reply (or an
  explicit approve-all for a reviewed batch). Options: post / edit / skip.
- On OK: `respond_to_review`. Mistake in a posted reply? `delete_review_response` and repost.
- Never auto-post. Never respond to a review the user hasn't seen.

## Step 6: Guardrail Check

- **Never reset the ratings summary** — if a reset is being considered anywhere, stop and
  surface the math from `ratings-mechanics` (count loss almost never pays back).
- Cross-check the prompting posture: if unanswered negatives cluster where `requestReview`
  volume is low (fresh markets), suggest localizing the prompt moment — route to
  `generators/review-prompt` via `/apple:build`, and phased-release habits to `/apple:ship`.

## Output

No `.planning/` file of its own — replies live in App Store Connect. Print a digest: per-
storefront health table (rating, count, unanswered 1–3★), replies posted/skipped, guardrail
flags, and the suggested next command.

## Completion Message

```
⭐ Ratings pass — [App]

Health:   US 4.6 (2,341) · DE 4.2 (87, 3 unanswered) · JP 3.8 (12, 2 unanswered) ⚠ fragile
Replies:  5 posted · 2 skipped (nothing actionable)
Guardrail: no reset planned ✓ · JP prompt volume low → localize the success moment

Next: /apple:learn-from-store (monthly signals) · re-run after the next release
```

## Portfolio Mode (`--portfolio`)

Run Step 2 across every app in `list_apps`; print one line per app (rating, unanswered
negatives, most fragile storefront) ranked by unanswered count, and recommend which app gets
the full reply pass. Writes nothing, posts nothing.

## Principles

- **Every write is gated** — replies post only on explicit per-reply (or reviewed-batch) OK.
- **Replies are recoverable stars** — updated ratings replace old scores; prioritize flippable
  reviews, not the loudest ones.
- **Per-storefront thinking** — a 4.8★ home market says nothing about a 12-rating new market.
- **Never reset the ratings summary.**
- Voice consistency: the reply speaks as the app, per `APP.md` positioning.
