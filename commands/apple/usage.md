---
description: Report what the local usage ledger shows — command mix, outcomes, model-tier adherence, and escalation economics
allowed-tools: Read, Bash
argument-hint: [--since 30d]
---

# SwiftShip Usage Report

Turn `~/.claude/swiftship-usage.jsonl` into answers: which commands run, how
they end, whether sessions run on the right model tier, and whether per-spawn
Opus escalation is earning its rate. **Read-only** — never modify the ledger,
never write a `.planning/` file, and never append an outcome line for this
command (it is a one-shot info command per
`~/.claude/swiftship-templates/_conventions/USAGE-LOG.md`).

Everything here is local; the ledger contains no PII, code, or paths.

## Prerequisites

```
Bash: test -s ~/.claude/swiftship-usage.jsonl
```

If the ledger is missing or empty, print this and stop:

```
📊 No usage data yet.

The ledger (~/.claude/swiftship-usage.jsonl) is written two ways:
- Workflow commands (build, review, plan, …) append an outcome line when they finish — automatic.
- The opt-in hook records every /apple:* invocation — register hooks/swiftship-usage-log.sh
  on BOTH UserPromptSubmit and PostToolUse(Skill) in ~/.claude/settings.json
  (./install.sh prints the exact snippet).

Run a few commands and come back.
```

If `jq` is unavailable, say so and produce only the Command Mix section using
`grep -c` counts — do not attempt the rest without it.

## Arguments

`--since Nd` limits the window (e.g. `--since 30d`). ISO timestamps sort as
strings, so compute a cutoff and string-compare:

```bash
CUTOFF=$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d "-30 days" +%Y-%m-%dT%H:%M:%SZ)
jq -c --arg c "$CUTOFF" 'select(.ts >= $c)' ~/.claude/swiftship-usage.jsonl
```

No argument = all time.

## Build the Report

Read `~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md` for the tier
table (skip the adherence section silently if absent — zero-install rule).
Then compute each section with `jq` (one pass each; never rewrite the file):

### 1. Command mix

Per command: `invoke` events (typed or Claude-invoked) vs `outcome` events
(workflows that ran to a logged end), plus distinct projects. Example:

```bash
jq -rs 'group_by(.cmd) | map("\(.[0].cmd): \(map(select(.event=="invoke"))|length) invoked, \(map(select(.event=="outcome"))|length) completed runs") | .[]' ~/.claude/swiftship-usage.jsonl
```

### 2. Outcomes

For `outcome` events: counts by `outcome` (completed / blocked / partial /
cancelled), the `blocked_on` breakdown, and the number of `degraded` runs.
Flag any `degraded: "no-agents"` — those runs lost the pinned agents entirely
(point at AGENT-VENDORING.md if present).

Also cross-check for **bypassed guards**: a run whose `agents` object has any
`general-purpose*` key but no `degraded` field substituted the built-in agent
for the named ones without logging it — count it with the degraded runs and
say so explicitly (its findings/counts came from below the full gate).

### 3. Model-tier adherence

For each outcome line with a `model` field, map its `cmd` to the tier table
and classify: **on tier**, **above tier** (e.g. `build` on `fable-5` or
`opus-4-8`), **below tier** (e.g. `validate` on `sonnet-5`, anything on
Haiku). Report per command: `build: 4/6 runs above tier (fable-5 ×3,
opus-4-8 ×1)`.

Keep cost commentary **qualitative** — above-tier execution runs bill premium
rates for routing work the Sonnet-pinned agents do anyway; below-tier
judgment runs gamble kill/build decisions on a small model. Never print
dollar figures or per-token prices (they drift; this command must not rot).

### 4. Escalation economics

From the `agents` objects: total spawns, and spawns keyed `"agent:opus"`
(per-task overrides from tagged plan tasks — see MODEL-TIERS.md "Per-spawn
overrides"). Alongside, for `review` outcomes, the `findings` counts.

State plainly what the data can and cannot support: fewer than ~10 outcome
lines with both escalations and findings → print
`Not enough data yet to judge whether Opus escalation reduces findings — keep collecting.`
Do not fabricate a correlation from a handful of runs.

### 5. Recommendations (rule-based — only print rules that fire)

| Signal | Recommendation |
|---|---|
| >50% of execution-tier runs above tier | Pinned commands (`build`/`review`/`verify`/`test`/`bugfix`/`ship`) above tier means the frontmatter pin isn't applying — re-run `./install.sh`; for unpinned `autonomous`, `/model sonnet` before the run |
| Judgment-tier runs on Sonnet/Haiku | Run `validate`/`roadmap`/`plan` (complex phases) on the top model — token-cheap, consequence-expensive |
| `invoke` events = 0 but outcomes exist | The hook isn't registered — show the install.sh snippet |
| `model` field missing on most outcomes | Commands predate the model field — re-run `./install.sh` to refresh symlinks |
| `degraded` runs present | Vendor agents into the affected project (`/apple:map` or AGENT-VENDORING.md) |
| `general-purpose*` spawn keys on runs not flagged `degraded` | The degraded guard was bypassed — restart the session (agent definitions load at session start), vendor agents if needed, and read that run's output as below-gate |
| ≥10 datapoints and escalated phases show no fewer review findings | Revisit `/apple:plan` tagging criteria before adding more Opus tags |
| ≥10 datapoints and mechanical tasks never fail verification | Evidence now supports revisiting Haiku downshift (deliberately withheld until this fires) |

## Output

Print the report to the terminal — no file, no ledger write. Structure:

```
📊 SwiftShip Usage — [window] ([N] events, [M] projects)

Command mix:      [section 1]
Outcomes:         [section 2]
Tier adherence:   [section 3 — or "no model data yet"]
Escalation:       [section 4 — or the not-enough-data line]

Recommendations:
- [only fired rules; omit the section if none fire]
```

Keep it under ~40 lines for a typical ledger; expand a section only when the
user asks a follow-up.
