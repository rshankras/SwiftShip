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
/Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/
```

All skill references in commands use this base path. When adding new skill references, use the pattern:
```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/[category]/[skill-name]/SKILL.md
```

## Key Workflow

The canonical flow is:
```
/apple:brainstorm → /apple:validate → /apple:new-app → /apple:roadmap → /apple:plan [phase] → /apple:build → /apple:review → /apple:submit
```

- `/apple:build` is the main execution engine — reads `.planning/PLAN.md`, finds pending tasks, matches them to agents via a task-content-to-agent table, and executes sequentially
- `/apple:bugfix` is the fast lane for known bugs — locate, fix, regression test, commit. Escalates to `/apple:debug` for mystery bugs
- `/apple:security` runs a comprehensive security audit (secure storage, auth, network, privacy manifests) — outputs `.planning/SECURITY.md`
- `/apple:perf` profiles and diagnoses performance issues using Instruments guidance and SwiftUI debugging — outputs `.planning/PERFORMANCE.md`
- `/apple:review` spawns 5 parallel review agents (code quality, HIG, App Store, performance, security)
- Tasks have three types: `auto` (agent-executed), `generator` (skill-invoked), `manual` (user action required)
- State is tracked in `.planning/STATE.md` and task status in `.planning/PLAN.md`

## External Dependency: claude-code-apple-skills

Commands reference skills from `claude-code-apple-skills` (75 skills across 19 categories):
- **Path:** `/Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/`

| Category | Skills |
|----------|--------|
| `app-store/` | app-description-writer, keyword-optimizer, review-response-writer, screenshot-planner |
| `apple-intelligence/` | app-intents, foundation-models, visual-intelligence |
| `design/` | animation-patterns, liquid-glass |
| `foundation/` | attributed-string |
| `generators/` (22) | accessibility, analytics-setup, app-icon, auth-flow, ci-cd-setup, cloudkit-sync, deep-linking, error-monitoring, feature-flags, live-activity, localization-setup, logging-setup, networking-layer, onboarding, paywall-generator, persistence-setup, push-notifications, review-prompt, settings-screen, test, tipkit, widget |
| `monetization/` | (monetization strategy, pricing-models, app-type-guides) |
| `ios/` | app-planner, assistive-access, coding-best-practices, ipad-patterns, migration-patterns, navigation-patterns, ui-review |
| `macos/` | app-planner, appkit-swiftui-bridge, architecture-patterns, coding-best-practices, macos-capabilities, macos-tahoe-apis, swiftdata-architecture, ui-review-tahoe |
| `mapkit/` | geotoolbox |
| `performance/` | profiling, swiftui-debugging |
| `product/` (11) | architecture-spec, competitive-analysis, idea-generator, implementation-guide, implementation-spec, market-research, prd-generator, product-agent, release-spec, test-spec, ux-spec |
| `release-review/` | (release readiness checks) |
| `security/` | privacy-manifests (+ reference files: secure-storage.md, biometric-auth.md, network-security.md, platform-specifics.md) |
| `swift/` | concurrency, concurrency-patterns, memory |
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
4. Run `./install.sh` to re-symlink, then test in a real project

### Adding a New Agent
1. Create `agents/[name].md` with frontmatter
2. Add matching row to the task-content-to-agent table in `commands/apple/build.md`
3. Add to `commands/apple/help.md` Specialized Agents table

### Key Conventions
- Commands are markdown prompts, not executable code
- All agents use **sonnet** model (cost efficiency) — do not change without good reason
- Skill references use `Read:` directives pointing to SKILL.md files or specific reference .md files within skill directories
- The help.md ASCII box uses Unicode box-drawing characters (║, ═, ╔, ╗, etc.) — maintain column alignment when adding rows
