# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SwiftShip is a spec-driven workflow system for iOS/macOS app development with Claude Code. It provides slash commands (`/apple:*`) that guide you from app idea validation through App Store submission. It is **not** an app itself — it's a set of commands, agents, and templates that get symlinked into `~/.claude/`.

## Installation & Testing

```bash
./install.sh              # Symlinks commands/ (dir) + agents (per-file) into ~/.claude/
./install.sh --uninstall  # Removes only SwiftShip's symlinks
./scripts/validate.sh     # Static checks — run after any edit to commands/agents/README
```

There are no build steps. Command *behavior* is tested by invoking the command (e.g. `/apple:help`) in a real target project; static *integrity* is checked by `scripts/validate.sh` — every skill/template reference resolves, documented counts match reality, every command is registered in help.md, frontmatter is well-formed. CI runs the validator on every PR (`.github/workflows/validate.yml`), cloning the skills repo to resolve references against.

## Architecture

```
Commands (user invokes /apple:*)
    → Read/write .planning/ files in the TARGET project
    → Spawn Agents for specialized execution
    → Reference Skills from claude-code-apple-skills
```

**Three-layer system:**

1. **Commands** (`commands/*.md`, flat) — Slash command definitions. Each is a markdown prompt with YAML frontmatter that Claude Code executes. The `/apple:` prefix comes from the *plugin name* (`apple` in `.claude-plugin/plugin.json`) for plugin installs, and from the symlink name (`~/.claude/commands/apple`) for manual installs — the files themselves are unprefixed.

2. **Agents** (`agents/*.md`) — Specialized subagents spawned by commands (primarily `/apple:build`). All agents run on Sonnet for cost efficiency. Agents have their own tool permissions defined in frontmatter.

3. **Templates** (`templates/*.md`) — XML-structured templates copied into target projects as `.planning/` files. These are the persistent context that survives across sessions.

**Key constant — skills path:**
```
~/.claude/swiftship-skills/
```

`~/.claude/swiftship-skills` is a **symlink created by `install.sh`** that points
to the `skills/` directory of the `claude-code-apple-skills` repo wherever it
lives on the machine. `install.sh` resolves the real location in this order:
`$SWIFTSHIP_SKILLS_DIR` env var → first script argument → a sibling
`../claude-code-apple-skills` next to this repo. Likewise
`~/.claude/swiftship-templates` symlinks this repo's `templates/`. Using these
home-relative paths (the `~` expands per-user) is what makes SwiftShip portable
across machines — **never hardcode an absolute `/Users/...` path in a command.**

All skill references in commands use this base path. When adding new skill references, use the pattern:
```
Read: ~/.claude/swiftship-skills/[category]/[skill-name]/SKILL.md
```

## Key Workflow

The canonical flow is:
```
/apple:brainstorm → /apple:validate → /apple:new-app → /apple:roadmap → /apple:plan [phase] → /apple:build → /apple:review → /apple:submit
```

For an **existing app** (already shipped, or brownfield), the entry differs:
```
/apple:map → /apple:release → /apple:plan [phase] → /apple:build → /apple:review → /apple:milestone
```
`/apple:release` replaces `new-app` + `roadmap` for updates — it reads the
`/apple:map` analysis, detects the shipped version, and scopes one release's
features **and** bug fixes into an intent-tagged `ROADMAP.md` + `RELEASE.md`
that the same `plan → build` engine executes. For release roadmaps, `/apple:plan`
routes skills by each phase's `intent` (feature/bugfix/quality/release) rather
than by phase number.

- `/apple:build` is the main execution engine — reads `.planning/PLAN.md`, finds pending tasks, matches them to agents via a task-content-to-agent table (honoring per-task `model="opus"` tags as spawn overrides), and executes sequentially
- `/apple:autonomous` drives the full `plan → build → verify` cycle across multiple phases unattended. It pauses for manual tasks, blockers, Critical review findings, or failed verification, and stops before the release phases (6–7) unless `--to N` says otherwise. Both `/apple:plan` and `/apple:build` read `.planning/PREFERENCES.md` (from `/apple:discuss`) and apply those choices
- `/apple:spike` runs a time-boxed experiment to validate an Apple API before planning around it — checks OS availability, device/simulator gating, and required capabilities, then records a finding in `.planning/spikes/[topic].md`. De-risks Apple's annual beta-API churn
- `/apple:prototype` explores *divergent* UI directions for a screen as named SwiftUI `#Preview`s — go wide, remix the strongest elements, fill with lived-in content + edge cases, then tune key animations — **before** `/apple:plan` commits to one layout. Novice-friendly (interviews you for features + mood); outputs `.planning/PROTOTYPE.md` and real Swift the winning variation carries into `/apple:plan` and `/apple:build`. Implements Apple's WWDC prototyping-with-coding-agents method. Delegates to `design/ui-prototyping`, reusing `generators/preview-data-generator`, the `swiftui-builder` agent, and `design/animation-patterns`
- `/apple:icon` generates or re-rolls the app icon on demand at any phase — a fast **placeholder** + light/dark/tinted variants, plus flat layered source to finish in **Icon Composer** (the Liquid Glass / iOS 26+ standard; a script can't author the layered `.icon`, so the command hands off to the GUI tool) — via `generators/app-icon-generator`. Phase 6 (Pre-Release) + `/apple:submit` gate the final icon
- `/apple:test` generates or expands tests on demand (Swift Testing or XCTest, plus snapshot/integration/contract) over the existing `testing/*` skills — a thin wrapper that works against a phase, a path, or recent changes without running the full Phase 5 flow
- `/apple:bugfix` is the fast lane for known bugs — locate, fix, regression test, commit. Escalates to `/apple:debug` for mystery bugs
- `/apple:security` runs a comprehensive security audit (secure storage, auth, network, privacy manifests) — outputs `.planning/SECURITY.md`
- `/apple:perf` profiles and diagnoses performance issues using Instruments guidance and SwiftUI debugging — outputs `.planning/PERFORMANCE.md`
- `/apple:review` spawns 5 parallel review agents (code quality, HIG, App Store, performance, security), then adversarially **verifies** every Critical/High finding before compiling `REVIEW.md` — 2 independent verifiers per Critical, each escalated to Opus via a per-spawn `model` override (both must confirm; split → High), 1 Sonnet verifier per High; findings without a `file:line` are downgraded to Medium; refuted claims land in an audit appendix, not the counts. This protects `/apple:autonomous`, which pauses on Critical findings
- `/apple:release-notes` generates release text for App Store, TestFlight, changelog, and social from git history + planning files — outputs `.planning/RELEASE-NOTES.md`
- `/apple:iap` and `/apple:privacy` are Phase-6 App Store Connect finalizers (also invoked from `/apple:submit`): `iap` sets a one-time IAP's price + localized name/description; `privacy` publishes the legal pages and sets the ASC Privacy/Support URLs — filling the gaps the `asc-metadata` MCP can't (IAP price/localization, app URLs). Both call the ASC REST API through a shared `_shared/asc-api/` helper (the user's own `.p8` key) with **dry-run → confirm → apply**; delegate to `app-store/iap-finalizer` + `legal/privacy-publish`. `iap` reads the price from the Phase-4 monetization decision (it does not re-price) and is distinct from `generators/promoted-iap`
- `/apple:visual-qa` analyzes screenshots or scans SwiftUI code for visual issues — outputs `.planning/VISUAL-QA.md`
- `/apple:walkthrough` drives each user flow in the Simulator (XCUITest + per-step screenshots), statically audits the nav graph for dead-ends/missing edit paths, and emits a human discoverability checklist — the UI-*flow* counterpart to `/apple:visual-qa` (screens). Outputs `.planning/WALKTHROUGH.md`; delegates to `testing/flow-walkthrough`
- `/apple:ship` is the one-command final mile — takes a reviewed build to "Waiting for Review": media + build upload, IAP price, category/URLs, submission — backed by Fastlane (`deliver`/`pilot`) and/or the `asc` CLI (asccli.sh) for what the ASC MCP can't do, every mutating step **dry-run → confirm → apply** and the final submission gated. `--testflight` stops at a TestFlight upload. Reuses `generators/ci-cd-setup`, `screenshot-automation`, `app-store-assets`
- `/apple:subscription` sets up auto-renewable subscriptions (groups, tiers, intro/promotional/win-back offers) + the StoreKit 2 lifecycle for recurring-revenue apps — complements `/apple:iap` (one-time unlocks); delegates to `generators/subscription-lifecycle` (+ `subscription-offers`, `win-back-offers`)
- `/apple:rejection` works an App Review rejection to resolution — maps the message to the exact guideline, diagnoses the real cause, applies the fix, and drafts a Resolution Center reply; wraps `app-store/rejection-handler`. A 4.3 flag pairs with `/apple:differentiate`
- `/apple:localize` expands the app into new markets — translates App Store metadata + in-app strings, adds/manages locales, and localizes IAPs/events, with keywords re-optimized per market (not transliterated); delegates to `product/localization-strategy` + `generators/localization-setup`
- `/apple:differentiate` is the originality / Guideline-4.3 anti-spam guardrail — scores an app's function/content/metadata distinctness vs your own portfolio and the market before you build or submit; protects the whole developer account. Delegates to `app-store/originality-check`
- `/apple:modernize` sweeps the app (or `--portfolio`) for deprecations + new-OS API adoption each cycle — fixes warnings and adopts current SwiftUI/OS APIs (Liquid Glass, new toolbars) in small verified steps; reuses `ios/migration-patterns`, `macos/macos-tahoe-apis`, `design/liquid-glass`, `swift/concurrency`
- `/apple:learn-from-store` closes the post-launch loop — turns live App Store signals (reviews, analytics, sales, crashes, listing conversion) into a metric-tagged next-version backlog **and** verifies whether last cycle's changes moved the metric they promised. Read-only on ASC (surfaces → gates → routes to `/apple:next-version`, `/apple:bugfix`, etc.); writes `.planning/SIGNALS.md`; delegates to `growth/store-signals`. `--portfolio` ranks which app to invest in next
- `/apple:experiment` runs App Store Product Page Optimization A/B tests (icon, screenshots, subtitle), reads significance without early stops, and promotes the confident winner — a conversion signal logged to `SIGNALS.md` for `/apple:learn-from-store`; delegates to `generators/product-page-optimization`
- `/apple:event` creates and manages App Store in-app events — time-boxed, promotable cards (challenges, seasonal moments) that surface in Search & Today for discovery + re-engagement; delegates to `generators/in-app-events`, pairs with `/apple:localize`
- `/apple:learn` captures mistakes and patterns into skills or CLAUDE.md so they never recur — the feedback loop that compounds session quality
- `/apple:usage` reads the local usage ledger into a report: command mix, outcome/blocker rates, model-tier adherence (which commands ran above/below their MODEL-TIERS tier), and escalation economics (`agent:opus` spawns vs review findings) — the evidence loop that gates right-sizing changes like Haiku downshift. Read-only; prints no dollar figures (prices drift); logs nothing itself
- Tasks have three types: `auto` (agent-executed), `generator` (skill-invoked), `manual` (user action required)
- State is tracked in `.planning/STATE.md` and task status in `.planning/PLAN.md`

## External Dependency: claude-code-apple-skills

Commands reference skills from `claude-code-apple-skills` (140+ skills across 23 categories):
- **Referenced as:** `~/.claude/swiftship-skills/` (symlink created by `install.sh`)
- **Real location:** the `skills/` dir of a separate `claude-code-apple-skills` checkout — set `$SWIFTSHIP_SKILLS_DIR`, pass it as `install.sh`'s first arg, or place it as a sibling `../claude-code-apple-skills`

| Category | Skills |
|----------|--------|
| `app-store/` (12) | ad-attribution, app-description-writer, apple-search-ads, iap-finalizer, keyword-optimizer, marketing-strategy, originality-check, ratings-mechanics, rejection-handler, review-response-writer, screenshot-planner, web-presence |
| `apple-intelligence/` | app-intents, foundation-models, visual-intelligence |
| `design/` (6) | animation-patterns, liquid-glass, sf-symbols, typography, ui-prototyping, ux-writing |
| `core-ml/` | (Core ML, Vision, NaturalLanguage framework patterns) |
| `foundation/` | attributed-string |
| `generators/` (63) | accessibility-generator, account-deletion, analytics-setup, announcement-banner, app-clip, app-extensions, app-icon-generator, app-store-assets, auth-flow, background-processing, ci-cd-setup, cloudkit-sync, consent-flow, custom-product-pages, data-export, debug-menu, deep-linking, error-monitoring, feature-flags, featuring-nomination, feedback-form, force-update, http-cache, image-loading, in-app-events, lapsed-user, live-activity-generator, localization-setup, logging-setup, milestone-celebration, networking-layer, offer-codes-setup, offline-queue, onboarding-generator, pagination, paywall-generator, permission-priming, persistence-setup, pre-orders, preview-data-generator, product-page-optimization, promoted-iap, push-notifications, quick-win-session, referral-system, review-prompt, screenshot-automation, settings-screen, share-card, social-export, spotlight-indexing, state-restoration, streak-tracker, subscription-lifecycle, subscription-offers, test-generator, tipkit-generator, usage-insights, variable-rewards, watermark-engine, whats-new, widget-generator, win-back-offers |
| `growth/` (6) | analytics-interpretation, community-building, indie-business, press-media, store-growth-audit, store-signals |
| `legal/` | privacy-policy, privacy-publish |
| `monetization/` | (strategy, pricing-models, app-type-guides) + bundles-and-licensing, external-purchases |
| `ios/` (10) | accessibility-audit, app-planner, assistive-access, coding-best-practices, ipad-patterns, migration-patterns, navigation-patterns, run-device, run-simulator, ui-review |
| `macos/` | app-planner, appkit-swiftui-bridge, architecture-patterns, coding-best-practices, macos-capabilities, macos-tahoe-apis, swiftdata-architecture, ui-review-tahoe |
| `mapkit/` | geotoolbox |
| `performance/` | profiling, swiftui-debugging |
| `product/` (14) | app-namer, architecture-spec, beta-testing, competitive-analysis, idea-generator, implementation-guide, implementation-spec, localization-strategy, market-research, prd-generator, product-agent, release-spec, test-spec, ux-spec |
| `release-review/` | (release readiness checks) |
| `security/` | privacy-manifests |
| `swift/` | concurrency, concurrency-patterns, memory |
| `testing/` (9) | characterization-test-generator, tdd-bug-fix, tdd-feature, test-contract, tdd-refactor-guard, snapshot-test-setup, test-data-factory, integration-test-scaffold, flow-walkthrough |
| `swiftdata/` | inheritance |
| `swiftui/` (7) | alarmkit, charts-3d, data-flow, layout, text-editing, toolbars, webkit |
| `visionos/` | spatial-design, widgets |
| `watchos/` | (watch development) |
| `shared/` | skill-creator, skill-auditor |

## When Editing This Repo

### Command Frontmatter Format
```yaml
---
description: Brief one-line description shown in /apple:help
allowed-tools: Read, Write, Glob, Grep    # comma-separated
argument-hint: [optional-arg]              # optional, shows in help
---
```
The body is a markdown prompt with sections: Prerequisites → Process Steps → Output → Completion Message. Commands read/write `.planning/` files in the **target project**, not this repo.

### Agent Frontmatter Format
```yaml
---
name: agent-id-kebab-case
description: |
  When to use this agent (with examples)
model: sonnet
color: green
tools: Read, Write, Edit, Glob, Grep, Bash
---
```
The body defines expertise, code patterns, best practices, and a verification checklist. Review-only agents (hig-reviewer, app-store-reviewer) have `tools: Read, Glob, Grep` — no write access.

### Template XML Structure
Templates in `templates/` use XML tags that commands parse. Key tags in PLAN.md tasks:
```xml
<task id="N" type="auto|manual|generator" status="pending|in_progress|completed">
  <name>, <files>, <apple-patterns>, <action>, <verify>, <hig-compliance>, <done>
</task>
```
Generator tasks add `<generator>` and `<customization>` tags. `type="auto"` tasks may carry an optional `model="opus"` attribute (set by `/apple:plan`, max 1–2 foundation tasks per phase) that `/apple:build` passes through as the spawn's per-call `model` override. Maintain tag consistency — commands match on these exact tag names.

### Adding a New Command
1. Create `commands/[name].md` with frontmatter
2. Add to `commands/help.md` ASCII box (match column alignment), Quick Reference table, and Planning Files table if it creates an output file
3. Add to this CLAUDE.md if it's part of the main workflow
4. Update the command count in `README.md` (two places: the **Highlights** bullet and the **Directory structure** comment)
5. Run `./scripts/validate.sh` (catches missed registration, count drift, broken skill refs)
6. Run `./install.sh` to re-symlink, then test in a real project

### Adding a New Agent
1. Create `agents/[name].md` with frontmatter
2. Add matching row to the task-content-to-agent table in `commands/build.md`
3. Add to `commands/help.md` Specialized Agents table
4. Update the agent count in `README.md` (Directory structure comment), then run `./scripts/validate.sh`

### Plugin Packaging
The repo is also a Claude Code **plugin** (`apple@indie-apple-stack`, listed in the skills repo's marketplace):
- `.claude-plugin/plugin.json` — **`name: "apple"` IS the `/apple:*` command namespace. Never rename it**; that would silently rename all 49 commands for plugin users. No `version` field on purpose: git-SHA versioning, `main` is the release channel.
- `hooks/hooks.json` — auto-registers for plugin installs only: a SessionStart glue hook (`hooks/swiftship-glue.sh`) that maintains the `~/.claude/swiftship-templates` and `~/.claude/swiftship-skills` symlinks (guarded — it never overwrites a symlink to a real checkout, so manual installs always win), plus the usage-log hook on UserPromptSubmit + PostToolUse(Skill). `${CLAUDE_PLUGIN_ROOT}` in hooks.json/command markdown is a **textual substitution**, not an env var.
- Plugin agents spawn namespaced (`apple:swift-generalist`); spawning commands and the AGENT-VENDORING degraded guard document the bare-name-then-prefixed retry.
- Keep `install.sh` working — it is the contributor/dev path and the fallback when plugins aren't available.

### Cutting a Release
1. Move the `[Unreleased]` items in `CHANGELOG.md` into a new `[X.Y.Z] — date` section (update the compare links at the bottom)
2. Merge via PR, then tag the merge commit on main: `git tag -a vX.Y.Z && git push origin vX.Y.Z`
3. `gh release create vX.Y.Z` with the changelog section as notes; record the claude-code-apple-skills commit it was tested against (Compatibility note)
4. Semver for a prompt repo: MAJOR = `.planning/` schema / template-tag / command renames that break existing projects; MINOR = new commands/agents/handoffs; PATCH = fixes and doc corrections

### Key Conventions
- Commands are markdown prompts, not executable code
- All agents pin **sonnet** in frontmatter (cost efficiency) — do not change without good reason. The pin is the default, not a ceiling: a command may escalate an *individual spawn* via the Task call's `model` parameter (which overrides frontmatter for that spawn only) where a wrong answer is expensive — currently `/apple:review`'s Critical verifiers and `model="opus"`-tagged plan tasks in `/apple:build` — rules in `templates/_conventions/MODEL-TIERS.md` ("Per-spawn overrides"): Opus only, max 1–2 tasks per phase, Haiku deliberately withheld pending ledger evidence
- Commands spawn `swift-generalist`, never the built-in `general-purpose` — `general-purpose` has no pinned model and silently inherits the session model (Opus/Fable rates for Sonnet-grade work); `swift-generalist` is the same breadth with `model: sonnet` enforced in frontmatter
- Skill references use `Read:` directives pointing to SKILL.md files or specific reference .md files within skill directories
- The help.md ASCII box uses Unicode box-drawing characters (║, ═, ╔, ╗, etc.) — maintain column alignment when adding rows

### Optional Tool Handoffs
Some commands can act directly on an external service (push App Store metadata via the `asc-metadata` MCP, screenshot the running app via the `run-simulator` skill, read sales) instead of only printing manual steps. These follow one shared convention — **detect → preview → confirm → act → fall back** — defined once in `templates/_conventions/TOOL-HANDOFF.md` (loaded at runtime via `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`). Rules: the **manual path is always the default**; outward/irreversible actions are **confirm-before-acting** with a before→after preview; a command's `allowed-tools` lists only the exact `mcp__*` tools it calls (least privilege); commands must still work with zero MCPs/skills installed. When adding a handoff, reference the convention doc — don't duplicate the five-step logic.

### Usage Log (optional, local-only)
Multi-step workflow commands (`build`, `review`, `plan`, `autonomous`, `verify`, `bugfix`, `test`, `ship`, `submit`) append one outcome line to `~/.claude/swiftship-usage.jsonl` at completion, per the schema in `templates/_conventions/USAGE-LOG.md`. A complementary opt-in hook (`hooks/swiftship-usage-log.sh`, registered manually in `~/.claude/settings.json`) records invocations deterministically at zero token cost. **Nothing ever leaves the machine** — schema fields only, no PII, no code, no paths. Rules: logging must never block a task; commands must work when the convention file or ledger is absent. When adding a new workflow command, reference the convention in its completion step — don't duplicate the schema.

### Agent Vendoring (optional, per-project)
`templates/_conventions/AGENT-VENDORING.md` — `/apple:new-app` and `/apple:map` offer to copy the six agents into the target project's `.claude/agents/` (with a `.swiftship-agents` marker for refresh detection), because project-level agents outrank user-level and travel with git to cloud/CI/remote sessions where `~/.claude/` doesn't exist. `build` and `review` reference the same convention's degraded-mode guard: when agents can't spawn, ask before proceeding and log `"degraded":"no-agents"` (review also banners its output DEGRADED and logs `outcome: "partial"`). Manage only the six agents by name; never touch other files in a project's `.claude/agents/`.

### Model Tiers (advisory)
`templates/_conventions/MODEL-TIERS.md` maps each command to a recommended **session model** tier (judgment / analysis / execution) — separate from agent pinning, which is enforced in agent frontmatter — and defines the task-level "Per-spawn overrides" rules (plan-tagged Opus tasks, review's Critical verifiers). Execution-tier hot-loop commands (`build`, `review`, `verify`, `test`, `bugfix`, `ship`) pin `model: sonnet` in command frontmatter — a **turn-scoped** override (the session model resumes on the next user prompt) that per-spawn Opus escalation still outranks. `plan` and `autonomous` stay unpinned (their main loop is judgment work), so they print a one-line tier note on mismatch — never blocking; `autonomous` alone asks once before a long run. Compliance is measured via the ledger's `model` field, not policed. Rules mirror the other conventions: the check must never block a task, and commands must work when the file is absent. Important: this rule lives in command bodies, not here — target projects never load this CLAUDE.md.
