# Changelog

All notable changes to SwiftShip are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org).

For a prompt repo, "breaking" means: changes to the `.planning/` file schema or
template XML tags that existing projects depend on, renamed or removed
commands, or moved skill-reference paths.

## [Unreleased]

### Added

- **`/apple:accessibility` — the 52nd command.** Audits the app for accessibility and
  declares App Store **Accessibility Nutrition Labels**. Six phases: define common tasks
  (primary flows + first-launch/login/purchase/settings) → automated XCUITest audit
  (`performAccessibilityAudit` per screen, `continueAfterFailure`, issue-handler filtering)
  → static scan (icon-only buttons, `lineLimit(1)`, hardcoded sizes, color-only state) →
  the manual assistive-tech passes (VoiceOver, Voice Control, Larger Text at 200%/310%,
  contrast, Dark + Smart Invert, Reduced Motion) → Nutrition Label evaluation
  (fix-first-claim-after; N/A ≠ supported) → **gated** per-device-family declaration via
  `mcp__asc-metadata__update_accessibility` (`listOnly` → diff → confirm → `dryRun` →
  apply → `publish`). Writes `.planning/ACCESSIBILITY.md`. Backed by the new
  `ios/accessibility-audit` skill; the EU Accessibility Act has applied to consumer apps
  in the EU market since June 2025, and no command owned this ASC surface.

### Changed

- **Routing for the new `ios/accessibility-audit` skill.** `build.md`'s routing table had a
  row labelled "accessibility audit" that pointed at `ios/ui-review` — it now points at the
  real skill, and a11y *fixes* route to `generators/accessibility-generator`. Also wired
  into `review` (hig-reviewer's skill list), `visual-qa` (with a note that a full audit is
  `/apple:accessibility`), `walkthrough` (its UI test target is already up — audit each
  screen it drives), `test` (classification row), `plan` (Phase 3 Polish), `submit` +
  `ship` (Accessibility Nutrition Label as a distinct pre-flight item from the App Privacy
  label), and `swift-generalist`'s fallback list.
- **`CLAUDE.md` skills table refreshed.** It had rotted several harvest rounds behind —
  missing `ios/accessibility-audit`, `run-simulator`, `run-device`, `swiftui/data-flow`,
  `swiftui/layout`, `visionos/spatial-design`, four of the seven `design/` skills, and more.

### Fixed

- **`/apple:build` no longer grades its own homework — verification audit, part 1
  (build-loop integrity).** Four gaps closed:
  - **Orchestrator-run checks.** Step 4 now requires the orchestrator to execute
    every `<verify>` check itself after a spawn returns — build/test commands
    re-run, results recorded from those runs. The builder agent's ✅s are a
    claim, not evidence; the progress report says which it got.
  - **Baseline build check + generator tasks verified.** The `build` check runs
    after every `auto`/`generator` task even when `<verify>` omits it.
    Generator tasks previously ran **zero** checks (build.md's generator branch
    had no verification step, and the PLAN template's generator example carried
    no `<verify>` block — now it does, and `/apple:plan` requires one on every
    auto/generator task).
  - **Rendered-frame checks for UI tasks.** `simulator` checks — and any task
    touching views/layout — verify via RUN-AND-SHOT (screenshot Read back;
    blank/crashed frame = FAIL) instead of "user confirms in simulator".
    build.md never referenced RUN-AND-SHOT before; it was only wired into
    `/apple:verify`, which ledger evidence showed never runs.
    `/apple:autonomous` now defines unattended behavior: screenshot where
    possible, otherwise record `NOT RUN (unattended)` — never a silent pass.
  - **`/apple:verify` wired into the flow.** `/apple:build`'s completion
    messages routed straight to `/apple:plan [X+1]`, skipping the one command
    that checks deliverables actually *work* (review checks that work is
    *good* — different question). Both completion messages now route through
    `/apple:verify` first.

- **`/apple:autonomous` verifies with independent eyes (verification audit,
  part 3).** The per-phase verify step ran inline in the same context that had
  just built the phase — the self-grading gap `/apple:build` Step 4 closes for
  tasks, reopened at phase scope. The verify step now spawns a fresh
  `swift-generalist` that runs the build + test suite and the deliverables
  checklist itself and reports PASS/FAIL with command output as evidence;
  degraded environments fall back to inline verification, recorded as
  `verifier: inline (degraded)` in VERIFICATION.md.

- **USAGE-LOG.md pins down `blocked` vs `partial`.** Ledger data showed the
  two outcomes drifting for manual-task pauses. Now defined: stopped
  *waiting on something* → `blocked` + `blocked_on` (progress lives in
  `tasks_done`); *finished but below full capability* (e.g. degraded review)
  → `partial`. A build paused on a manual task is always `blocked`/`manual-task`.

- **Verification audit, part 2 (follow-ups).**
  - **Manual tasks are probed, not just trusted.** After the user replies
    "done", `/apple:build` read-only-verifies the machine-checkable `<done>`
    criteria — filesystem/git directly; ASC criteria via `list_apps` /
    `list_beta_groups` / `list_iap` when the asc-metadata MCP is detected
    (TOOL-HANDOFF; the three read tools join build's `allowed-tools`) — and a
    probe that contradicts the "done" re-opens the task instead of completing
    it. No probe available → trust the confirmation, as before.
  - **`/apple:bugfix` proves red instead of describing it.** Step 5.3 said the
    regression test should fail without the fix "(conceptually — describe
    this, don't actually revert)" — so a test that passes both ways (testing
    nothing) sailed through. Now: test-first when the order allows, else a
    pathspec-stash roundtrip (`git stash push -- [fix files]` → red →
    `stash pop` → green); if red genuinely can't be proven, the report says
    `red not proven` explicitly.
  - **TOOL-HANDOFF's ACT step gains a read-back.** After any write, re-read
    the value with the same tool PREVIEW used and confirm it stuck — ASC
    writes can partially apply per-locale; success is the read-back matching,
    not the API's 200.

- **`/apple:bugfix` carries the `general-purpose` guard.** The command has
  granted `Task` in its frontmatter since it was first added, but its body
  never mentioned agents — so a spawn would have defaulted to the built-in
  `general-purpose` agent, which has no pinned model and inherits the session
  model. Step 4 now routes multi-file fixes to `swift-generalist`
  (`swiftui-builder` for view-only fixes), names the plugin-namespaced retry,
  and falls back to the AGENT-VENDORING degraded guard. This is the same
  guard `build`, `review`, and `test` already carried. Completion now records
  spawn counts in the ledger's `agents` object.

- **Model-pin docs name the real failure mode: Skill-tool routing.** Ledger
  evidence (2026-07-05) showed 17/17 execution-tier runs above tier — with
  the `model: sonnet` pin present in a freshly installed plugin — because
  commands executed via the Skill tool run inside the already-running turn,
  which no frontmatter can switch. `build`/`review` model checks,
  MODEL-TIERS.md, and the `/apple:usage` recommendation rule now diagnose
  routing first (remedy: `/model sonnet` before execution-heavy stretches)
  instead of misdirecting to `./install.sh`, which only fixes stale symlink
  installs.

### Added

- **/apple:ratings — rating health + gated review replies (51st command).** Per-storefront health via list_reviews, a prioritized reply queue drafted from app-store/review-response-writer, every reply gated before posting via the previously unused respond_to_review MCP tool, and the never-reset guardrail from app-store/ratings-mechanics. learn-from-store now hands the reply backlog here instead of dead-ending at "replies are manual".

- **SwiftUI skill routing** — build routes state-management tasks to swiftui/data-flow and layout/scroll tasks to swiftui/layout; perf triage adds both to the jank and re-render rows.

- **visionOS routing** — build gains a visionOS task row (spatial UI -> visionos/spatial-design + visionos/widgets); review reads spatial-design for visionOS targets (eye-target sizes, motion comfort, hover rules).

- **Design-skill wiring** — the four new design skills route through the build process: plan (Phase 2/3 skill matching), build (task routing table rows for screen structure, copy, symbols, type), review (UX-quality + copy passes above HIG), visual-qa (wayfinding/typography layer), walkthrough (discoverability rubric). prototype and icon already read their upgraded skills.

- **Growth watchlist graduations** — Creative Assets, Retention Messaging, and Group/Volume Purchasing moved from announced to live scoring in templates/GROWTH.md (per WWDC26 transcripts; the skills-side rules updated in the library); watchlist now tracks only the new event badge types.

- **`/apple:growth` phase argument** — `/apple:growth P1` (or `P1-P3`) scopes
  the audit to one stage: evidence batches subset to that phase's items, only
  its scorecard rows update, and the output is the stage's worklist (core
  first, routes attached) with an offer to start the first fix. Backed by the
  skill's new Scoped Runs section.

- **`/apple:growth` — stage-by-stage growth audit (50th command).** Walks an
  app (live, `--new` pre-launch, or `--portfolio`) through the 54-item P0–P9
  growth playbook from `growth/store-growth-audit`: one read-only ASC MCP
  batch + one codebase grep pass + one batched question round, every item
  scored with citable evidence, graded into a 0–9 maturity level, and routed
  to the command that fixes it. Writes the `.planning/GROWTH.md` scorecard
  (new `templates/GROWTH.md`; stable item IDs make re-audits diff cleanly)
  and, gated, a dated top-5 into `ROADMAP.md`. Companion to
  `/apple:learn-from-store`: that asks *are the numbers moving* (monthly),
  this asks *is the machinery installed* (quarterly). Cross-linked from
  `new-app`/`roadmap` (`--new` seed), `release`/`next-version` (quarterly
  re-audit tip), `ship` (phased-release default + never-reset-ratings
  guardrail), and `learn-from-store`.

- **`via` field on invoke lines** — the usage hook now records which shape
  matched (`"typed"` = UserPromptSubmit, `"skill"` = PostToolUse on Skill),
  so `/apple:usage` can measure the routing split and attribute tier drift
  on pinned commands to it with data instead of inference. Older lines
  without the field remain valid (schema addition only).

## [2.0.0] — 2026-07-04

Distribution milestone: SwiftShip installs as a Claude Code plugin. **No
breaking changes** — every `/apple:*` command name, template tag, and
`.planning/` schema is unchanged (the major version marks the
distribution-model shift, not a compatibility break; strict semver would
call this 1.2.0). Manual clone + `install.sh` remains fully supported.

### Added

- **Plugin distribution** — SwiftShip is now a Claude Code plugin
  (`apple@indie-apple-stack`), installable with three slash commands (add the
  marketplace, install `apple-skills`, install `apple`) and updatable via
  `/plugin marketplace update`. Command names are preserved **byte-identical**:
  the plugin is named `apple`, and `commands/apple/*.md` moved to flat
  `commands/*.md`, so the plugin namespace supplies the same `/apple:*` prefix
  the directory name used to (verified by experiment before converting). The
  manual clone + `install.sh` path is unchanged and remains the
  contributor/dev channel.
- Plugin `hooks/hooks.json` (auto-registers for plugin installs only):
  a SessionStart glue script (`hooks/swiftship-glue.sh`) maintains the
  `~/.claude/swiftship-templates` and `~/.claude/swiftship-skills` symlinks —
  guarded so a symlink pointing at a real git checkout is never overwritten
  (manual installs always win) — and the usage-log hook, making the
  local-only ledger on-by-default for plugin installs (disclosed in the
  README; `/plugin disable apple` turns it off; manual installs stay opt-in).
- Agent types are namespaced in plugin installs (`apple:swift-generalist`):
  spawning commands (`build`, `review`, `submit`, `test`, `autonomous`) and
  the AGENT-VENDORING degraded-mode guard document the bare-name →
  `apple:`-prefixed retry, so agent spawns work in all three install modes
  (manual symlinks, vendored, plugin).
- `scripts/validate.sh` gains plugin checks: `plugin.json`/`hooks.json` must
  parse and the plugin name must be exactly `apple` (it IS the command
  namespace — a rename would silently rename all 49 commands). CI gains a
  `plugin-validate` job running `claude plugin validate .` (non-strict: the
  no-version and CLAUDE.md-at-root warnings are deliberate; errors still
  fail). Fixing plugin validation also surfaced real YAML defects the lenient
  runtime parser had masked: all six agents' multi-line descriptions weren't
  valid block scalars (now `description: |`), and `autonomous.md`'s
  `argument-hint` needed quoting.

## [1.1.0] — 2026-07-04

Model right-sizing and resilience: the first release shaped by the usage
ledger — every change below traces to a measured finding, not a hunch.

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

### Compatibility

- Tested against claude-code-apple-skills `main` @ `a0226e8` (2026-07-04,
  plugin-marketplace distribution); all skill references resolve via
  `~/.claude/swiftship-skills/` unchanged — CI validates against this repo
  on every PR.

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

[Unreleased]: https://github.com/rshankras/SwiftShip/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/rshankras/SwiftShip/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/rshankras/SwiftShip/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/rshankras/SwiftShip/releases/tag/v1.0.0
