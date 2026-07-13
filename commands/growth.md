---
description: Audit an app's growth machinery against the 54-item P0–P9 playbook — score every lever from ASC + codebase evidence, write a .planning/GROWTH.md scorecard, and route every gap to the command that fixes it. Read-only on App Store Connect.
argument-hint: "[app-name-or-appId] [P0–P9] — defaults to the current .planning project, full audit; a phase (P1, or P1-P3) scopes the run; --new for pre-launch planning; --portfolio to triage all apps"
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Skill, mcp__asc-metadata__list_apps, mcp__asc-metadata__get_metadata, mcp__asc-metadata__list_locales, mcp__asc-metadata__get_app_pricing, mcp__asc-metadata__list_price_points, mcp__asc-metadata__get_availability, mcp__asc-metadata__list_iap, mcp__asc-metadata__list_subscription_groups, mcp__asc-metadata__list_subscriptions, mcp__asc-metadata__list_app_events, mcp__asc-metadata__list_experiments, mcp__asc-metadata__list_custom_pages, mcp__asc-metadata__get_analytics_report, mcp__asc-metadata__get_sales_report, mcp__asc-metadata__list_reviews
---

# Growth — is the machinery installed?

Walk the app through the full App Store growth playbook — day-one money toggles, on-metadata
ASO, conversion assets, localization, ratings machinery, experimentation, featuring, paid
traffic, earnings, retention ops — and produce a stage-by-stage scorecard with the next moves.

The companion to `/apple:learn-from-store`: that asks *are the numbers moving?* (monthly);
this asks *is the machinery even installed?* (quarterly, and before launch).

**Read-only on App Store Connect.** The audit never mutates anything — every gap is scored,
cited, and routed to the command that fixes it.

## When to Use

- A new app is approaching first submission — seed the growth plan, not just metadata (`--new`).
- A live app, quarterly — or after a launch that undershot expectations.
- Working one stage at a time — `/apple:growth P1` audits just that phase and hands you its worklist.
- Before spending on Apple Ads: is the free machinery done first?
- `--portfolio` — which of your live apps is leaving the most money on the table?

## Prerequisites

```
Read: .planning/STATE.md, .planning/APP.md, .planning/ASO.md
Read: .planning/GROWTH.md   # if present — enables re-audit deltas
```

- Existing mode needs an `appId` resolvable from `STATE.md`, else `list_apps` + confirm.
- Pre-launch mode needs only the `.planning/` docs and the codebase.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/growth/store-growth-audit/SKILL.md
Read: ~/.claude/swiftship-skills/growth/store-growth-audit/detection-playbook.md
Read: ~/.claude/swiftship-skills/growth/store-growth-audit/audit-checklist-p0-p4.md
Read: ~/.claude/swiftship-skills/growth/store-growth-audit/audit-checklist-p5-p9.md
```

`SKILL.md` owns process, scoring, and routing; `detection-playbook.md` owns evidence batching;
the two checklists carry all 54 item rules. The scorecard schema is `~/.claude/swiftship-templates/GROWTH.md`.

## Step 1: Resolve App, Mode + Scope

- Parse the argument/flags. Mode: `--new` → pre-launch; else `appId` from `STATE.md` resolves to
  a live app on `list_apps` → existing; no live app → pre-launch; ambiguous → `AskUserQuestion`.
- **Scope**: a phase argument (`P1`, bare `1`, or a range/list like `P1-P3`) runs a scoped audit
  per the skill's **Scoped Runs** section; no phase argument → full P0–P9.
- Read `.planning/GROWTH.md` if present — the prior scorecard is the diff baseline (re-audit is
  not a mode; it's automatic when a baseline exists).

## Step 2: Gather Evidence — one pass

Per `detection-playbook.md`, in this order, never interleaved with scoring (scoped runs subset
every batch to the rows feeding the in-scope items — fewer calls, fewer questions):

- **MCP batch** (read-only, ~14 calls): metadata, locales, pricing + price points, availability,
  IAPs, subscription groups/subs, events, PPO experiments, custom product pages, analytics,
  sales, reviews.
- **Codebase grep batch**: requestReview call sites, alternate icons, App Intents/Spotlight,
  widgets/Live Activities/notifications, onboarding, external-purchase entitlement, paywall,
  localization dirs, platform targets, ASC automation, new-OS API adoption.
- **One `AskUserQuestion` batch** for every MANUAL item the first two passes couldn't settle
  (SBP, billing grace/retry, benchmarks, ads, featuring nominations, deal sites, waitlist…).
  Ask once, batched. "Not sure" is always an option and scores 🟠 *unverified* — never guess.

## Step 3: Score All 54 Items

Apply each item's `rule:` against the evidence. Honor `applies-if:` guards (⚪ N/A) and
⏳ ANNOUNCED flags (recheck whether Apple shipped the feature; if live, apply the dormant rule).
Pre-launch mode: score `new-app: plan` items from the `.planning/` docs (planned → 🟠 `planned`),
`code` items normally, `defer` items ⚪ with their activation trigger noted. **Every status
carries a terse, citable evidence string** — the audit is citable or it is worthless.

## Step 4: Grade + Diff

- Phase scores (`✅ n/N applicable`), phase grades, and the **maturity level 0–9** per the skill.
- If a prior scorecard exists: per-item deltas — **fixed / regressed / new** since last audit.

## Step 5: Select the Top 5 Actions

From all applicable 🔴 + 🟠 items, order by compressed-priority tier — T1: P0 money toggles ·
T2: P1–P3 metadata/conversion/localization · T3: P8.4 web checkout + P8.6 volume purchasing ·
T4: P4–P6, rest of P8, P9 · T5: P7 paid traffic — then within a tier: `core`
first, 🔴 before 🟠, lowest effort first. Overrides: an **overdue Recurring Calendar row jumps
to the top**; always include at least one metadata-only quick win (no binary release needed).

## Step 6: Write Outputs (gated)

- Write `.planning/GROWTH.md` from `~/.claude/swiftship-templates/GROWTH.md`: full 54-row
  scorecard with evidence, watchlist, refreshed Recurring Calendar due-dates, baseline metrics
  snapshot, and an appended Audit History row. Item IDs are stable — never reorder or renumber.
- Then gate with `AskUserQuestion` before appending the top-5 as a dated section to
  `.planning/ROADMAP.md` (feeds `/apple:next-version` / `/apple:plan`).

## Output

`.planning/GROWTH.md` (the durable scorecard) and, on explicit OK, a dated top-5 section in
`.planning/ROADMAP.md`. The printed digest never dumps 54 rows: maturity level + phase bar,
top-5 with routes, deltas since last audit, unanswered MANUAL items, the next three calendar
due-dates, and the suggested next command.

## Completion Message

```
📈 Growth audit — [App] (Level 4/9, existing, re-audit)

P0 ▓▓▓░ 3/4 · P1 ▓▓▓▓▓░░ 5/7 · P2 ▓▓▓░░ 3/5 · P3 ▓░░░░ 1/5 · P4 ▓▓▓▓ 4/4
P5 ▓▓░░ 2/3 · P6 ▓▓▓░░░ 3/6 · P7 ▓░░░░░░ 1/7 · P8 ▓▓░░░ 2/5 · P9 ▓▓▓░ 3/4

Top 5:  1) P0.1 Apply to Small Business Program        → ASC (indie-business)
        2) P3.1 Localize metadata for the big seven    → /apple:localize
        3) P2.5 Ship alternate icons for icon PPO      → /apple:icon
        4) P4.3 Turn on phased + manual release        → /apple:ship
        5) P9.2 Keyword refresh (OVERDUE)              → /apple:metadata

Since last audit: 3 fixed · 1 regressed (P9.3 update freshness)
Calendar: featuring nomination due in 12 days · keyword refresh overdue

Written: GROWTH.md (+ ROADMAP.md top-5, on your OK)
Next: /apple:localize
```

## Phase-Scoped Runs (`/apple:growth P1`)

Work the playbook one stage at a time. A scoped run gathers only that phase's evidence, updates
only that phase's scorecard rows (+ its Phase Scores row; Audit History tagged `scope: P1`), and
replaces the top-5 with the **phase worklist** — every applicable item, `core` first, 🔴 before 🟠,
each with its route. Ends by offering to start the first route (gated). Maturity is recomputed
from the refreshed rows plus the untouched remainder — flagged `(est.)` until a full audit exists.

```
📈 Growth audit — [App] (scope: P1 · on-metadata ASO)

P1 ▓▓▓░░░░ 3/7

Worklist:  1) P1.1 Keyword field wastes 41 chars, subtitle repeats title  → /apple:metadata
           2) P1.2 en-GB/es-MX locales unused (0 extra indexed chars)     → /apple:localize
           3) P1.4 3 IAPs, none promoted, names generic                   → /apple:iap
           4) P1.7 Description leads with a metaphor — poor AI tagging    → /apple:metadata

Written: GROWTH.md (P1 rows only) · maturity 3/9 (est.)
Start with P1.1 now? → /apple:metadata
```

## Portfolio Mode (`--portfolio`)

Reduced, MCP-only audit (the `core` items + P0) across every app in `list_apps` — no codebase
greps, and the account-level questions (SBP, benchmarks, brand defense, nominations) asked once
for all apps. Prints a matrix: app × estimated maturity × biggest gap, the single
highest-leverage move portfolio-wide, and which app deserves the next full audit. Writes nothing.

## Principles

- **Read-only on ASC** — even analytics-report setup routes to `/apple:learn-from-store`.
- **Evidence over vibes** — every status cites an MCP read, a grep hit, or a dated user answer.
- **Route, don't fix** — Apple Ads work goes to `/apple:aso` if installed, else the
  `app-store/apple-search-ads` skill + `/apple:metadata`; every other gap has a named command.
- **MANUAL honesty** — unknown is 🟠 *unverified*, never assumed ✅.
- **Never reset the ratings summary** (P4.4) — a guardrail, not a task.
- **Stable IDs** — scorecards diff by item ID across audits; never renumber.
