# Changelog

All notable changes to SwiftShip are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org).

For a prompt repo, "breaking" means: changes to the `.planning/` file schema or
template XML tags that existing projects depend on, renamed or removed
commands, or moved skill-reference paths.

## [Unreleased]

### Added

- `./install.sh --uninstall` — removes only SwiftShip's symlinks (commands,
  per-file agent links, templates, skills, hook script); never touches the
  user's own agents, `settings.json`, the usage ledger, or project
  `.planning/` files. README gains matching **Updating** and **Uninstall**
  sections plus a three-command from-zero quickstart (the committed
  `install.sh` is already executable — the `chmod` step was noise).

- Agent vendoring (`templates/_conventions/AGENT-VENDORING.md`): `/apple:new-app`
  and `/apple:map` offer to copy SwiftShip's six pinned agents into the target
  project's `.claude/agents/` — project-level agents outrank user-level and
  travel with git, so cloud/CI/remote-launched sessions keep the Sonnet pin
  and the full review gate. Includes a `.swiftship-agents` marker for
  stale-copy refresh, and a degraded-mode guard in `/apple:build` +
  `/apple:review`: when agents can't spawn, the command must say so, ask
  before proceeding, banner review output as DEGRADED, and log
  `"degraded":"no-agents"` (review: `outcome: "partial"`) — observed in the
  wild as a remote session silently substituting a 3-minute self-review for
  the 8-agent verified gate. Vendoring and the guard also call out that agent
  definitions load once at session start: copies vendored mid-session can't
  spawn until a restart, so `new-app`/`map` say so on acceptance (observed as
  a spike falling back to `general-purpose` right after vendoring).

- Model-tier convention (`templates/_conventions/MODEL-TIERS.md`): maps every
  command to a recommended session model tier — judgment (Fable-class:
  validate, roadmap, debug…), analysis (Opus-class: map, security, metadata…),
  execution (Sonnet-class: build, review, ship…) — on the principle that
  strategy is token-cheap but consequence-expensive while execution is the
  reverse (agents are Sonnet-pinned regardless). `plan`, `build`, `review`
  print a one-line note when the session model is off-tier (never blocking);
  `autonomous` asks once before a long run. Compliance is measured via the
  usage ledger's `model` field.

- Usage ledger: optional `model` field on `"outcome"` lines — records which
  session model a workflow command ran on (subagents are always Sonnet), so
  `/apple:usage` can analyze cost per command.

- Task-level model routing: `/apple:plan` may tag **at most 1–2** foundation
  `type="auto"` tasks per phase with `model="opus"` (architecture, data model,
  concurrency, migration — mistakes that propagate into everything built
  after them); `/apple:build` passes the tag through as the agent spawn's
  per-call `model` override. An absent tag means the Sonnet frontmatter pin,
  so existing PLAN.md files are unaffected (additive schema). Escalated
  spawns land in the usage ledger's `agents` object as `"agent:opus"` keys so
  `/apple:usage` can test whether escalation actually reduces review findings
  and verify failures. Haiku downshift is deliberately withheld pending that
  evidence. Mechanism + rules live in MODEL-TIERS.md ("Per-spawn overrides").

- `/apple:usage` — reads the local usage ledger into a report: command mix
  (invocations vs completed runs), outcome/blocker rates, model-tier
  adherence against MODEL-TIERS.md, and escalation economics (`agent:opus`
  spawns vs review findings). Rule-based recommendations only — including the
  explicit gate that Haiku downshift stays withheld until ≥10 datapoints show
  mechanical tasks never failing verification. Read-only, local-only, prints
  no dollar figures (prices drift; the command must not rot), and — as an
  info command — logs nothing itself.

### Changed

- Execution-tier hot-loop commands (`build`, `review`, `verify`, `test`,
  `bugfix`, `ship`) now pin `model: sonnet` in command frontmatter. The
  override is turn-scoped (documented Claude Code behavior: the command's
  turn runs on the pinned model, the session model resumes on the next user
  prompt), so it can never downgrade a later judgment-tier command, and
  per-spawn Opus escalation (Task-call `model` parameter) still outranks it.
  Replaces the "remember to `/model sonnet`" habit the first `/apple:usage`
  report showed wasn't happening: 10/10 execution-tier runs in the ledger
  billed premium main-loop rates (fable-5 ×5, opus-4-8 ×5) for routing work
  the Sonnet-pinned agents did anyway. The printed tier note remains as
  fallback for installs predating the pin and org model allowlists that
  exclude Sonnet; `/apple:autonomous` stays unpinned (its main loop includes
  plan-phase judgment work) and keeps its ask-once gate.

- `/apple:review` Critical-finding verifiers now escalate to Opus via a
  per-spawn `model` override (High verifiers stay on the Sonnet pin). A
  Sonnet verifier checking a Sonnet reviewer shares its blind spots, and a
  wrong verdict either pauses `/apple:autonomous` (false Critical) or ships a
  real bug (false confirm) — the few Opus spawns per review are the cheapest
  rigor in the pipeline. Falls back to the pin (with an audit note) if the
  escalated spawn fails.

### Fixed

- Degraded-mode guard now catches agent **substitution**, not just spawn
  failure: swapping the built-in `general-purpose` in for the named agents
  triggers the same ask + DEGRADED banner + `"degraded":"no-agents"` ledger
  fields — observed in the wild as a review that ran `general-purpose:sonnet`
  ×8 (no `hig-reviewer`/`app-store-reviewer`) yet logged a clean `completed`,
  indistinguishable from the full gate except via spawn keys. Per-call
  `model` overrides on substitute spawns are kept (they preserve the cost
  pin) but don't make a run non-degraded. `/apple:usage` now cross-checks
  spawn keys against the `degraded` field and reports bypassed guards.

- `install.sh` no longer replaces the user's entire `~/.claude/agents/`
  directory with a symlink — the six agents are now linked **per-file**, so
  any agents the user already has keep loading alongside SwiftShip's.
  Previously an existing agents directory was shunted to `agents.backup` and
  silently deactivated — an adoption-killer for exactly the audience most
  likely to try SwiftShip. Legacy whole-directory installs are migrated
  automatically on the next `./install.sh` run (with a note when an
  `agents.backup` exists to restore from); `--uninstall` handles both layouts.

- `/apple:build` task→agent table gains an explicit catch-all row (anything
  unmatched → `swift-generalist`) and an in-command prohibition on the built-in
  `general-purpose` agent; the same guard added to `/apple:review` and
  `/apple:test`. The rule previously lived only in this repo's CLAUDE.md, which
  target projects never load — first day of ledger data showed Phase-1 builds
  spawning `general-purpose` at session-model rates.
- `/apple:ship` now uses the ASC MCP for steps it previously punted to the
  user: a new Step 2 creates the App Store version via `create_version` when
  missing (it was in `allowed-tools` but never referenced), Step 3 pushes
  What's New from `.planning/RELEASE-NOTES.md` via `update_whats_new`, and
  Step 7 offers a phased release via `create_phased_release` — all
  preview → confirm → apply.
- `TOOL-HANDOFF.md` clarifies that "manual is the default" means the manual
  path always exists — not that it's suggested first; a detected tool is the
  primary path.
- Usage hook now captures user-typed `/apple:*` commands. Slash commands are
  expanded client-side and never reach the Skill tool, so the previous
  `PostToolUse`-only registration missed them entirely; the hook is now also
  registered on `UserPromptSubmit` (same script handles both input shapes).
- `USAGE-LOG.md` outcome example now stamps `ts` via `$(date -u ...)` instead
  of a hardcoded literal — prevents placeholder timestamps (e.g. midnight)
  landing in the ledger when the model doesn't know the current time.

- Adversarial verification ("foreman") step in `/apple:review`: every
  Critical/High finding is verified against the actual code before it reaches
  `REVIEW.md` — 2 independent verifiers per Critical (both must confirm; a
  split verdict downgrades to High), 1 per High; findings without a
  `file:line` are downgraded to Medium as unverifiable. Refuted claims are
  preserved in a "Refuted During Verification" appendix for audit. Protects
  `/apple:autonomous` from pausing on false Criticals.

## [1.0.0] — 2026-07-02

First stable release. `main` remains the development channel; tags are the
stable channel.

### The workflow

- Spec-driven pipeline from idea to App Store: `/apple:brainstorm` →
  `/apple:validate` → `/apple:new-app` → `/apple:roadmap` → `/apple:plan` →
  `/apple:build` → `/apple:review` → `/apple:submit`
- Brownfield entry for existing apps: `/apple:map` → `/apple:release` →
  `plan → build` with intent-tagged phases (feature/bugfix/quality/release)
- Persistent project memory in `.planning/` (spec, roadmap, plan, state,
  reviews) — stop today, resume tomorrow with context intact
- `/apple:autonomous` drives plan → build → verify across phases unattended,
  pausing on manual tasks, blockers, or Critical findings

### 48 commands

- **Build & quality**: build, review, verify, test, bugfix, debug, security,
  perf, visual-qa, walkthrough, prototype, spike, modernize
- **Planning & product**: brainstorm, validate, new-app, map, roadmap, release,
  plan, discuss, next-version, milestone, idea/ideas, progress, pause/resume
- **App Store & growth**: metadata, screenshots, icon, testflight, deploy,
  submit, ship, iap, privacy, subscription, rejection, localize, differentiate,
  learn-from-store, experiment, event, release-notes
- **Meta**: help, learn, autonomous

### 6 specialist agents

- `swiftui-builder`, `storekit-expert`, `cloudkit-expert`, plus read-only
  `hig-reviewer` and `app-store-reviewer`
- `swift-generalist` — handles the long tail with `model: sonnet` enforced in
  frontmatter, so workers never silently inherit expensive session-model rates

### Skills integration

- 140+ skills from [claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills)
  wired into commands via `~/.claude/swiftship-skills/` references
- Portable installer: home-relative symlinks only, no machine-specific paths

### Optional tool handoffs

- One shared convention (detect → preview → confirm → act → fall back) lets
  commands act on external services when tools are connected: App Store
  Connect metadata/TestFlight via MCP, simulator run & screenshot, read-only
  sales/analytics feeds
- Manual path is always the default; outward actions are confirm-first;
  everything degrades gracefully with zero tools installed

### Quality & infrastructure

- `scripts/validate.sh` + GitHub Actions: every PR checks that all skill and
  template references resolve, documented counts match reality, every command
  is registered in help.md, and frontmatter is well-formed
- Local-only usage ledger (opt-in hook + per-command outcome lines) for
  data-driven improvement — nothing leaves the machine

### Compatibility

- Tested against claude-code-apple-skills `main` @ `25a618b` (2026-07-02),
  which includes the `macos/*/SKILL.md` case fix required on case-sensitive
  filesystems (claude-code-apple-skills#15)

[Unreleased]: https://github.com/rshankras/SwiftShip/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/rshankras/SwiftShip/releases/tag/v1.0.0
