---
description: Sweep the app (or portfolio) for deprecations and new-OS API adoption each release cycle — fix warnings, adopt current SwiftUI/OS APIs (Liquid Glass, new toolbars), and keep older apps from rotting.
argument-hint: "[app path | --portfolio]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill
---

# Modernize — keep it current

Each OS cycle, find what's deprecated or dated and bring the code up to the current platform:
build-warning triage, deprecated-API replacement, and opt-in adoption of new design/APIs. Critical
for a portfolio — unmaintained apps quietly break and slide in ranking.

## Arguments

- `$ARGUMENTS` or `$1`: an app path, or `--portfolio` to triage every app. Empty → the current project.

## When to Use

- A new major OS / Xcode (adopt new APIs, clear new deprecations).
- Reviving an app that hasn't shipped in a while.
- `--portfolio` to triage which apps need attention most.

## Prerequisites

```
Read: .planning/STATE.md   # current min-OS + what shipped last
```

- The app builds (so warnings are collectable); Xcode/SDK for the OS you're targeting.
- Apple docs available under `~/Downloads/docs/` for the APIs you'll adopt.

## Load Skills

```
Read: ~/.claude/swiftship-skills/ios/migration-patterns/SKILL.md
Read: ~/.claude/swiftship-skills/macos/macos-tahoe-apis/SKILL.md
Read: ~/.claude/swiftship-skills/design/liquid-glass/SKILL.md
Read: ~/.claude/swiftship-skills/swift/concurrency/SKILL.md
```

Load only what fits the target (iOS vs macOS). Apply `migration-patterns` for deprecated→current API
moves, `macos-tahoe-apis` / `liquid-glass` for new design + platform adoption, `concurrency` for
Swift 6 / async migration.

## Step 1: Baseline

- Build; collect deprecation warnings + the minimum-OS gap. Read the relevant docs under
  `~/Downloads/docs/` (Liquid Glass, new toolbars, Swift Concurrency) via the
  `design/liquid-glass`, `ios/migration-patterns`, and `macos/macos-tahoe-apis` skills.

## Step 2: Triage

- Group findings: (a) deprecations that will break, (b) new-API adoption opportunities,
  (c) design-language updates (Liquid Glass, SF Symbols). Rank by risk × user-visibility.

## Step 3: Apply (incremental, verified)

- Fix in small, buildable steps; keep behavior identical unless intentionally adopting new UX.
- Respect the user's SwiftUI patterns (extract complex `@ViewBuilder` switches; `@Observable`;
  system colors). Rebuild green after each cluster; run `/apple:verify` / `/apple:visual-qa`.

## Step 4: Adopt new capabilities (optional, gated)

- Where it fits the product: new toolbars, App Intents, widgets, on-device intelligence —
  propose before building.

## Step 5: Record

- Note what changed + the new min-OS in `STATE.md`; suggest `/apple:release-notes`.

## Output

Deprecations cleared and (where chosen) new-OS APIs adopted, in small verified build-green steps.
`STATE.md` updated with what changed + the new minimum-OS; `/apple:release-notes` suggested.

## Completion Message

```
🧹 Modernized — [app]

Deprecations: [N] fixed (build warning-clean)
Adopted:      [Liquid Glass toolbar · @Observable · async migration]  (gated, proposed first)
Min-OS:       [old] → [new]
Verified:     rebuilt green after each cluster; /apple:verify passed

Next: /apple:release-notes to describe the update.
```

## Principles

- Deprecation fixes first (correctness), adoption second (value).
- Small verified steps; never a big-bang rewrite.
- Follow HIG + the user's SwiftUI patterns; check the docs before writing.
