# Changelog

All notable changes to SwiftShip are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org).

For a prompt repo, "breaking" means: changes to the `.planning/` file schema or
template XML tags that existing projects depend on, renamed or removed
commands, or moved skill-reference paths.

## [Unreleased]

### Added

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
