# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

SwiftShip is a spec-driven workflow system for iOS/macOS app development with Claude Code. It provides slash commands (`/apple:*`) that guide you from app idea validation through App Store submission, plus life management commands (`/life:*`). It is **not** an app itself — it's a set of commands, agents, and templates that get symlinked into `~/.claude/`.

## Installation

```bash
./install.sh
```

This symlinks `commands/` and `agents/` into `~/.claude/`, making all commands available globally in Claude Code sessions.

## Architecture

```
Commands (user invokes /apple:* or /life:*)
    → Read/write .planning/ files in the TARGET project
    → Spawn Agents for specialized execution
    → Reference Skills from claude-code-apple-skills
```

**Three-layer system:**

1. **Commands** (`commands/apple/*.md`, `commands/life/*.md`) — Slash command definitions with frontmatter (`description`, `allowed-tools`, `argument-hint`). Each is a markdown prompt that Claude Code executes.

2. **Agents** (`agents/*.md`) — Specialized subagents spawned by commands (primarily `/apple:build`). The `swiftui-builder` agent runs on Sonnet for cost efficiency. Agents have their own tool permissions and system prompts defined in frontmatter.

3. **Templates** (`templates/*.md`) — XML-structured templates copied into target projects as `.planning/` files. These are the persistent context that survives across sessions.

## Key Workflow

The canonical flow is:
```
/apple:brainstorm → /apple:validate → /apple:new-app → /apple:roadmap → /apple:plan [phase] → /apple:build → /apple:review → /apple:submit
```

- `/apple:build` is the main execution engine — it reads `.planning/PLAN.md`, finds pending tasks, matches them to agents, and executes sequentially
- `/apple:bugfix` is the fast lane for known bugs — locate, fix, regression test, commit. Escalates to `/apple:debug` for mystery bugs
- Tasks have three types: `auto` (agent-executed), `generator` (skill-invoked), `manual` (user action required)
- State is tracked in `.planning/STATE.md` and task status in `.planning/PLAN.md`

## External Dependency: claude-code-apple-skills

Commands reference skills from `claude-code-apple-skills` (72 skills across 18 categories):
- **Path:** `/Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/`

| Category | Skills |
|----------|--------|
| `app-store/` | app-description-writer, keyword-optimizer, review-response-writer, screenshot-planner |
| `apple-intelligence/` | app-intents, foundation-models, visual-intelligence |
| `design/` | animation-patterns, liquid-glass |
| `foundation/` | attributed-string |
| `generators/` (22) | accessibility, analytics-setup, app-icon, auth-flow, ci-cd-setup, cloudkit-sync, deep-linking, error-monitoring, feature-flags, live-activity, localization-setup, logging-setup, networking-layer, onboarding, paywall, persistence-setup, push-notifications, review-prompt, settings-screen, test, tipkit, widget |
| `ios/` | app-planner, assistive-access, coding-best-practices, ipad-patterns, migration-patterns, navigation-patterns, ui-review |
| `macos/` | app-planner, appkit-swiftui-bridge, architecture-patterns, coding-best-practices, macos-capabilities, macos-tahoe-apis, swiftdata-architecture, ui-review-tahoe |
| `mapkit/` | geotoolbox |
| `performance/` | profiling, swiftui-debugging |
| `product/` (10) | architecture-spec, competitive-analysis, idea-generator, implementation-guide, implementation-spec, market-research, prd-generator, product-agent, release-spec, test-spec, ux-spec |
| `release-review/` | (release readiness checks) |
| `security/` | privacy-manifests |
| `swift/` | concurrency, concurrency-patterns, memory |
| `swiftdata/` | inheritance |
| `swiftui/` | alarmkit, charts-3d, text-editing, toolbars, webkit |
| `visionos/` | widgets |
| `watchos/` | (watch development) |
| `shared/` | skill-creator |

## When Editing This Repo

- Commands are markdown prompts, not executable code — test by invoking the command in a real project
- Template files use XML structure that commands parse — maintain XML tag consistency
- Agent frontmatter format: `name`, `description`, `model`, `tools`, `color`
- Command frontmatter format: `description`, `allowed-tools`, `argument-hint`
- The `commands/life/` directory contains LifeOS personal productivity commands, separate from the Apple development workflow
