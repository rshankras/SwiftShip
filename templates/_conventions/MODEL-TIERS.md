# Model Tier Convention

Which **session model** each SwiftShip command should run on. This is separate
from agent pinning: subagents always run on the model in their frontmatter
(Sonnet) no matter what — the session model prices the **main loop**:
orchestration, planning text, and judgment.

**Principle:** strategy commands are cheap in tokens but expensive in
consequences — run them on the top model. Execution commands are the reverse —
run them on Sonnet, because the pinned agents do the real work and the main
loop only routes. Matching tier to command cuts cost with **no loss of
quality**; the risk runs in both directions (premium model wasted on routing,
small model gambling on a kill/build decision).

## Tiers

| Tier | Session model | Commands |
|------|---------------|----------|
| **Judgment** | Best available (Fable-class) | `brainstorm`, `validate`, `differentiate`, `new-app`, `roadmap`, `release`, `debug`, `rejection`, `learn-from-store`, `plan` (complex phases: architecture, data model, Phases 1–2) |
| **Analysis** | Opus-class | `map`, `security`, `perf`, `prototype`, `metadata`, `localize`, `spike`, `discuss`, `plan` (routine phases) |
| **Execution** | Sonnet-class | `build`, `autonomous`, `review`, `verify`, `test`, `bugfix`, `modernize`, `ship`, `submit`, `iap`, `privacy`, `deploy`, `testflight`, `screenshots`, `icon`, `visual-qa`, `walkthrough`, `release-notes`, `subscription`, `event`, `experiment`, `milestone`, `next-version`, and all session/info commands (`progress`, `idea`, `ideas`, `pause`, `resume`, `help`, `learn`) |

## The check (referenced by commands — never blocks)

1. Your system prompt names the model you are running on. Map it:
   Fable → Judgment · Opus → Analysis · Sonnet → Execution · Haiku → below all
   tiers.
2. Compare with this command's tier:
   - **Running above tier** (e.g. `build` on Fable or Opus): print one line —
     `💡 [command] is execution-tier; /model sonnet cuts cost with no quality
     loss (agents are pinned to Sonnet regardless). Continuing on [model].` —
     then continue. `/apple:autonomous` is the exception: before starting a
     long run, ask once (AskUserQuestion) — switch first, or continue on the
     current model.
   - **Running below tier** (e.g. `validate` on Sonnet or any command on
     Haiku): print one line noting the recommended tier and the quality risk,
     then continue.
3. **Never block. Never switch models yourself** — only the user can run
   `/model`. Mention it at most once per run.
4. Compliance is measured, not policed: the usage ledger records `model` on
   every outcome line (see `USAGE-LOG.md`), so `/apple:usage` can report tier
   adherence and what drift actually cost.

## Per-spawn overrides (task-level)

The frontmatter pin is the default, not a ceiling. A Task call may pass a
`model` parameter, which overrides the agent's frontmatter **for that spawn
only** (documented resolution order: `CLAUDE_CODE_SUBAGENT_MODEL` env var →
per-call parameter → agent frontmatter → session model). SwiftShip uses this
in exactly two places:

- `/apple:plan` tags at most 1–2 `type="auto"` foundation tasks per phase
  with `model="opus"` (architecture, data model, concurrency, migration —
  mistakes that propagate); `/apple:build` passes the attribute through at
  spawn time.
- `/apple:review` spawns its two Critical-finding verifiers with
  `model: "opus"` — a wrong verdict there pauses `/apple:autonomous` or
  ships a real bug, and a Sonnet verifier checking a Sonnet reviewer shares
  its blind spots.

Rules:

1. **Opus only.** Haiku downshift is deliberately not offered until the usage
   ledger shows mechanical tasks never fail verification.
2. Escalated spawns are recorded in the ledger's `agents` object under
   `"[agent]:opus"` keys (see `USAGE-LOG.md`), so `/apple:usage` can test
   whether escalation actually reduces review findings and verify failures.
3. If an escalated spawn fails, retry once without the parameter — the
   override must never block a task.
4. Debugging note: if subagents ignore pins and overrides alike, check the
   `CLAUDE_CODE_SUBAGENT_MODEL` env var — it silently outranks both.

Zero-install rule: if this file is absent, skip the check silently.
