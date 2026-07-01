# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SwiftShip is a spec-driven workflow system for iOS/macOS app development with Claude Code. It provides slash commands (`/apple:*`) that guide you from app idea validation through App Store submission. It is **not** an app itself — it's a set of commands, agents, and templates that get symlinked into `~/.claude/`.

## Installation & Testing

```bash
./install.sh    # Symlinks commands/ and agents/ into ~/.claude/
```

There are no build steps, linters, or automated tests. Commands are markdown prompts — test by invoking the command (e.g. `/apple:help`) in a real target project.

## Architecture

```
Commands (user invokes /apple:*)
    → Read/write .planning/ files in the TARGET project
    → Spawn Agents for specialized execution
    → Reference Skills from claude-code-apple-skills
```

**Three-layer system:**

1. **Commands** (`commands/apple/*.md`) — Slash command definitions. Each is a markdown prompt with YAML frontmatter that Claude Code executes.

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

- `/apple:build` is the main execution engine — reads `.planning/PLAN.md`, finds pending tasks, matches them to agents via a task-content-to-agent table, and executes sequentially
- `/apple:autonomous` drives the full `plan → build → verify` cycle across multiple phases unattended. It pauses for manual tasks, blockers, Critical review findings, or failed verification, and stops before the release phases (6–7) unless `--to N` says otherwise. Both `/apple:plan` and `/apple:build` read `.planning/PREFERENCES.md` (from `/apple:discuss`) and apply those choices
- `/apple:spike` runs a time-boxed experiment to validate an Apple API before planning around it — checks OS availability, device/simulator gating, and required capabilities, then records a finding in `.planning/spikes/[topic].md`. De-risks Apple's annual beta-API churn
- `/apple:prototype` explores *divergent* UI directions for a screen as named SwiftUI `#Preview`s — go wide, remix the strongest elements, fill with lived-in content + edge cases, then tune key animations — **before** `/apple:plan` commits to one layout. Novice-friendly (interviews you for features + mood); outputs `.planning/PROTOTYPE.md` and real Swift the winning variation carries into `/apple:plan` and `/apple:build`. Implements Apple's WWDC prototyping-with-coding-agents method. Delegates to `design/ui-prototyping`, reusing `generators/preview-data-generator`, the `swiftui-builder` agent, and `design/animation-patterns`
- `/apple:icon` generates or re-rolls the app icon on demand at any phase — a fast **placeholder** + light/dark/tinted variants, plus flat layered source to finish in **Icon Composer** (the Liquid Glass / iOS 26+ standard; a script can't author the layered `.icon`, so the command hands off to the GUI tool) — via `generators/app-icon-generator`. Phase 6 (Pre-Release) + `/apple:submit` gate the final icon
- `/apple:test` generates or expands tests on demand (Swift Testing or XCTest, plus snapshot/integration/contract) over the existing `testing/*` skills — a thin wrapper that works against a phase, a path, or recent changes without running the full Phase 5 flow
- `/apple:bugfix` is the fast lane for known bugs — locate, fix, regression test, commit. Escalates to `/apple:debug` for mystery bugs
- `/apple:security` runs a comprehensive security audit (secure storage, auth, network, privacy manifests) — outputs `.planning/SECURITY.md`
- `/apple:perf` profiles and diagnoses performance issues using Instruments guidance and SwiftUI debugging — outputs `.planning/PERFORMANCE.md`
- `/apple:review` spawns 5 parallel review agents (code quality, HIG, App Store, performance, security)
- `/apple:release-notes` generates release text for App Store, TestFlight, changelog, and social from git history + planning files — outputs `.planning/RELEASE-NOTES.md`
- `/apple:visual-qa` analyzes screenshots or scans SwiftUI code for visual issues — outputs `.planning/VISUAL-QA.md`
- `/apple:walkthrough` drives each user flow in the Simulator (XCUITest + per-step screenshots), statically audits the nav graph for dead-ends/missing edit paths, and emits a human discoverability checklist — the UI-*flow* counterpart to `/apple:visual-qa` (screens). Outputs `.planning/WALKTHROUGH.md`; delegates to `testing/flow-walkthrough`
- `/apple:learn` captures mistakes and patterns into skills or CLAUDE.md so they never recur — the feedback loop that compounds session quality
- Tasks have three types: `auto` (agent-executed), `generator` (skill-invoked), `manual` (user action required)
- State is tracked in `.planning/STATE.md` and task status in `.planning/PLAN.md`

## External Dependency: claude-code-apple-skills

Commands reference skills from `claude-code-apple-skills` (140+ skills across 23 categories):
- **Referenced as:** `~/.claude/swiftship-skills/` (symlink created by `install.sh`)
- **Real location:** the `skills/` dir of a separate `claude-code-apple-skills` checkout — set `$SWIFTSHIP_SKILLS_DIR`, pass it as `install.sh`'s first arg, or place it as a sibling `../claude-code-apple-skills`

| Category | Skills |
|----------|--------|
| `app-store/` | app-description-writer, apple-search-ads, keyword-optimizer, marketing-strategy, rejection-handler, review-response-writer, screenshot-planner |
| `apple-intelligence/` | app-intents, foundation-models, visual-intelligence |
| `design/` | animation-patterns, liquid-glass, ui-prototyping |
| `core-ml/` | (Core ML, Vision, NaturalLanguage framework patterns) |
| `foundation/` | attributed-string |
| `generators/` (63) | accessibility-generator, account-deletion, analytics-setup, announcement-banner, app-clip, app-extensions, app-icon-generator, app-store-assets, auth-flow, background-processing, ci-cd-setup, cloudkit-sync, consent-flow, custom-product-pages, data-export, debug-menu, deep-linking, error-monitoring, feature-flags, featuring-nomination, feedback-form, force-update, http-cache, image-loading, in-app-events, lapsed-user, live-activity-generator, localization-setup, logging-setup, milestone-celebration, networking-layer, offer-codes-setup, offline-queue, onboarding-generator, pagination, paywall-generator, permission-priming, persistence-setup, pre-orders, preview-data-generator, product-page-optimization, promoted-iap, push-notifications, quick-win-session, referral-system, review-prompt, screenshot-automation, settings-screen, share-card, social-export, spotlight-indexing, state-restoration, streak-tracker, subscription-lifecycle, subscription-offers, test-generator, tipkit-generator, usage-insights, variable-rewards, watermark-engine, whats-new, widget-generator, win-back-offers |
| `growth/` | analytics-interpretation, community-building, indie-business, press-media |
| `legal/` | privacy-policy |
| `monetization/` | (monetization strategy, pricing-models, app-type-guides) |
| `ios/` | app-planner, assistive-access, coding-best-practices, ipad-patterns, migration-patterns, navigation-patterns, ui-review |
| `macos/` | app-planner, appkit-swiftui-bridge, architecture-patterns, coding-best-practices, macos-capabilities, macos-tahoe-apis, swiftdata-architecture, ui-review-tahoe |
| `mapkit/` | geotoolbox |
| `performance/` | profiling, swiftui-debugging |
| `product/` (14) | app-namer, architecture-spec, beta-testing, competitive-analysis, idea-generator, implementation-guide, implementation-spec, localization-strategy, market-research, prd-generator, product-agent, release-spec, test-spec, ux-spec |
| `release-review/` | (release readiness checks) |
| `security/` | privacy-manifests (+ reference files: secure-storage.md, biometric-auth.md, network-security.md, platform-specifics.md) |
| `swift/` | concurrency, concurrency-patterns, memory |
| `testing/` (9) | characterization-test-generator, tdd-bug-fix, tdd-feature, test-contract, tdd-refactor-guard, snapshot-test-setup, test-data-factory, integration-test-scaffold, flow-walkthrough |
| `swiftdata/` | inheritance |
| `swiftui/` | alarmkit, charts-3d, text-editing, toolbars, webkit |
| `visionos/` | widgets |
| `watchos/` | (watch development) |
| `shared/` | skill-creator |

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
Generator tasks add `<generator>` and `<customization>` tags. Maintain tag consistency — commands match on these exact tag names.

### Adding a New Command
1. Create `commands/apple/[name].md` with frontmatter
2. Add to `commands/apple/help.md` ASCII box (match column alignment), Quick Reference table, and Planning Files table if it creates an output file
3. Add to this CLAUDE.md if it's part of the main workflow
4. Update the command count in `README.md` (two places: the **Highlights** bullet and the **Directory structure** comment)
5. Run `./install.sh` to re-symlink, then test in a real project

### Adding a New Agent
1. Create `agents/[name].md` with frontmatter
2. Add matching row to the task-content-to-agent table in `commands/apple/build.md`
3. Add to `commands/apple/help.md` Specialized Agents table

### Key Conventions
- Commands are markdown prompts, not executable code
- All agents use **sonnet** model (cost efficiency) — do not change without good reason
- Skill references use `Read:` directives pointing to SKILL.md files or specific reference .md files within skill directories
- The help.md ASCII box uses Unicode box-drawing characters (║, ═, ╔, ╗, etc.) — maintain column alignment when adding rows

### Optional Tool Handoffs
Some commands can act directly on an external service (push App Store metadata via the `asc-metadata` MCP, screenshot the running app via the `run-simulator` skill, read sales) instead of only printing manual steps. These follow one shared convention — **detect → preview → confirm → act → fall back** — defined once in `templates/_conventions/TOOL-HANDOFF.md` (loaded at runtime via `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`). Rules: the **manual path is always the default**; outward/irreversible actions are **confirm-before-acting** with a before→after preview; a command's `allowed-tools` lists only the exact `mcp__*` tools it calls (least privilege); commands must still work with zero MCPs/skills installed. When adding a handoff, reference the convention doc — don't duplicate the five-step logic.
