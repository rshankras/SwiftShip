---
description: Turn a live app's App Store signals (reviews, analytics, sales, crashes) into a metric-tagged backlog for the next version — and verify whether last cycle's changes moved the numbers
argument-hint: "[app-name-or-appId] — defaults to the current .planning project; --portfolio for all apps"
allowed-tools: Read, Write, AskUserQuestion, Skill, mcp__asc-metadata__list_apps, mcp__asc-metadata__list_reviews, mcp__asc-metadata__get_review, mcp__asc-metadata__get_analytics_report, mcp__asc-metadata__setup_analytics_reports, mcp__asc-metadata__get_sales_report, mcp__asc-metadata__get_diagnostics, mcp__asc-metadata__get_perf_metrics, mcp__asc-metadata__list_beta_feedback_crashes, mcp__asc-metadata__list_beta_feedback_screenshots, mcp__asc-metadata__get_metadata
---

# Learn From Store — close the feedback loop

Pull what the *shipped* app is actually telling you (reviews, analytics, sales, crashes,
listing conversion) and convert it into the next `ROADMAP.md` / `PLAN.md` — then verify
whether last cycle's changes moved the metric they promised to move.

This is the missing arc that turns SwiftShip from **build → ship** into a loop:

```
ship → MEASURE → DIAGNOSE → next PLAN → build → ship → measure again…
```

**Read-only on App Store Connect.** Never responds to reviews or mutates metadata/pricing;
all changes are surfaced, gated, then handed to `/apple:next-version`, `/apple:bugfix`, etc.

## When to Use

- Before `/apple:next-version` or `/apple:release` — feed the plan evidence, not intuition.
- On a cadence for a live app (monthly), or `--portfolio` to decide *which* app to invest in next.
- ~1–2 weeks after shipping a change — to check if it actually worked (loop closure).

## Prerequisites

```
Read: .planning/STATE.md, .planning/APP.md, .planning/POSITIONING.md
Read: .planning/SIGNALS.md   # if present — the OPEN hypotheses from prior runs
```

- A live (or TestFlight) app; `appId` resolvable from `STATE.md`, else `list_apps` + confirm.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/growth/store-signals/SKILL.md
Read: ~/.claude/swiftship-skills/growth/store-signals/signals-ledger.md
```

`store-signals` drives the whole loop (gather → cluster → diagnose → backlog → close last cycle);
`signals-ledger.md` is the `SIGNALS.md` + backlog format. Pull benchmarks from
`growth/analytics-interpretation` when judging whether a metric is good/bad.

## Step 1: Resolve the App + Load Prior Hypotheses

- Read `.planning/STATE.md`, `APP.md`, `POSITIONING.md` (the app's job-to-be-done + guardrails).
- Resolve `appId` from STATE.md; if absent, `list_apps` and confirm with `AskUserQuestion`.
- Read `.planning/SIGNALS.md` if present → the OPEN hypotheses from prior runs (each carries a
  target metric + recorded baseline + a "check-after" date). These get verified in Step 5.

## Step 2: Pull the Signals (ASC MCP, read-only)

Fetch for the app across a comparison window (this period vs trailing):

- **Reviews / ratings** — `list_reviews` (recent, lowest-star first; flag unanswered). `get_review` for detail.
- **Analytics** — `get_analytics_report`: retention curve, funnel/conversion, acquisition source,
  impression→download, units. If no report is configured yet → `setup_analytics_reports` and note
  **"retention/funnel data lands next cycle"** (Apple delivers on its own schedule).
- **Sales trend** — `get_sales_report`: proceeds/units vs trailing 7/30-day (reuse `daily-sales-pulse` logic).
- **Stability / performance** — `get_diagnostics` (crash/hang signatures) + `get_perf_metrics` (launch, memory, energy).
- **Beta** — `list_beta_feedback_crashes` / `list_beta_feedback_screenshots` if in TestFlight.
- **Listing** — `get_metadata` to spot ASO conversion problems against the current copy.

## Step 3: Normalize & Cluster

- Dedupe reviews into recurring **themes** (requests vs complaints vs praise); count frequency.
- Attach **magnitude** to each signal: how many users / how much revenue or retention is implicated.
- Separate signal from noise: weight by **frequency × revenue impact**, NOT by how loud one reviewer is.

## Step 4: Diagnose, Filter, Prioritize

For each cluster:

- Map it to the **core metric** it moves (rating · D7 retention · Pro conversion · crash-free rate · ASO conversion · proceeds).
- Score = **impact × confidence ÷ effort**.
- **Strategy filter** — cross-check `POSITIONING.md`. On-strategy → backlog. Off-strategy (doesn't serve
  the app's job) → list separately under **"Declined (why)"**; never silently drop, never silently build.
- **Guardrail check** — carry the app's specific guardrails forward (e.g. Crowdroar: *no decibel/SPL/hearing-health*).
- **Small-N honesty** — if data is thin (new app), say so; lean on qualitative reviews / TestFlight; flag low confidence.

## Step 5: Close the Prior Loop

For each OPEN hypothesis in `SIGNALS.md` whose change has shipped and whose "check-after" date has passed:

- Compare the target metric now vs its recorded baseline → **WIN / REGRESSION / NEUTRAL**.
- WIN → mark resolved. REGRESSION → open a revert/rethink task. NEUTRAL → keep watching or retire.

This is what makes it a loop, not a monthly report.

## Step 6: Write the Backlog (metric-tagged)

Append a dated section to `.planning/ROADMAP.md` (feeds `/apple:next-version`) and update `.planning/SIGNALS.md`.
Every backlog item carries: **signal**, **evidence**, **type**, **hypothesis**, **target metric + baseline**,
**effort**, **check-after** (see `signals-ledger.md` for the exact table). `SIGNALS.md` is the ledger:
one row per hypothesis with `status: open|shipped|win|regression|neutral`, `baseline`, `shipped-in`
(version), and `check-after`. Step 1 reads it; Step 5 resolves it; Step 6 appends to it.

## Output

Appended to `.planning/ROADMAP.md` (dated, metric-tagged backlog) and `.planning/SIGNALS.md` (updated
ledger). Plus a printed digest: (1) ranked top 3–5 "what's hurting most, why, the proposed move";
(2) the Step-5 loop-closure results (what worked / regressed); (3) a suggested next command
(`/apple:next-version`, `/apple:bugfix` for a hot crash signature, or `/apple:metadata` for an ASO fix).

**Never** auto-apply pricing, metadata, or review responses — surface, gate on explicit OK, then route to the right command.

## Completion Message

```
📊 Store signals digested — [App] ([window])

Top moves:   1) [signal → metric] 2) […] 3) […]
Loop closure: S2 crash-free 95.9%→99.4% WIN · S3 TTR 3.2%→3.1% NEUTRAL
Written:     ROADMAP.md backlog (+SIGNALS.md ledger updated)
Declined:    [N] off-strategy requests logged (not dropped)

Next: /apple:next-version — plan against the evidence.
```

## Portfolio Mode (`--portfolio`, or no app arg with multiple live apps)

Run Steps 2–4 across every app in `list_apps`, then **rank which app to invest in next** —
biggest fixable revenue/retention/rating gap first (pairs with `portfolio-health-monitor`).
Output one line per app + the single highest-ROI move across the whole portfolio.

## Principles

- **Evidence over vibes** — every item cites its signal + magnitude.
- **Respect the positioning** — filter off-strategy requests explicitly; the loudest reviewer isn't the roadmap.
- **Weight by revenue + frequency**, not volume of complaints.
- **Read-only on ASC** — all changes are gated and routed to an existing command.
- **It's a loop** — always verify last cycle (Step 5) before planning the next.
