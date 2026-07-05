---
description: Execute current plan using specialized agents
allowed-tools: Read, Write, Edit, Bash, Task, Glob, Grep
model: sonnet
---

# Execute Build Plan

Execute pending tasks from `.planning/PLAN.md` using specialized agents.

**Model check (execution tier):** this command pins `model: sonnet` in its
frontmatter — the turn runs on Sonnet and the session model returns on the
next user prompt (see
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md`). If your system
prompt still names a premium model, the pin didn't apply. The usual cause is
**Skill-tool routing**: when this command reaches you through the Skill tool
(Claude invoking it, or a harness that routes typed commands through Skill),
the body executes inside the already-running turn — no frontmatter can switch
a turn in flight. Stale installs and org model allowlists are the rarer
causes (`./install.sh` refreshes symlink installs; it cannot fix routing).
Note once that `/model sonnet` before execution-heavy stretches costs nothing
in quality here (agents are pinned regardless), then continue. Skip silently
if the convention file is absent.

## Prerequisites

Read required files:
```
Read: .planning/APP.md
Read: .planning/PLAN.md
Read: .planning/STATE.md
```

Also read implementation preferences if they exist (created by `/apple:discuss`):
```
Read: .planning/PREFERENCES.md   # Optional — apply if present
```

If `PREFERENCES.md` exists, carry its choices (architecture/state pattern,
async approach, error-handling style, component style, project structure) into
every agent prompt you spawn below, so generated code matches the decisions the
user already made. Preferences override agent defaults wherever they conflict.

## Execution Process

### 1. Find Next Pending Task

Parse PLAN.md and find the first task with `status="pending"`.

If no pending tasks:
```
✅ All tasks in current phase are complete!

Next steps:
- Run /apple:review to check code quality
- Run /apple:plan [next-phase] to plan the next phase
```

### 2. Mark Task In Progress

Update the task in PLAN.md: `status="in_progress"`

Update STATE.md:
```markdown
## Current Task
- **Task ID:** [id]
- **Description:** [task name]
- **Started:** [timestamp]
```

### 3. Execute Task Based on Type

#### For `type="auto"` Tasks:

Match task to appropriate agent and spawn. Agent names below are bare
(symlink/vendored installs); **plugin installs namespace them** — if a bare
name errors "Agent type not found", retry as `apple:<name>`
(e.g. `apple:swift-generalist`) before applying the degraded-mode guard:

| Task Content | Agent | Skills Reference |
|-------------|-------|-----------------|
| SwiftUI views, UI | swiftui-builder | `ios/ui-review`, `macos/ui-review-tahoe` |
| StoreKit, purchases | storekit-expert | `monetization/`, `generators/paywall-generator` |
| Pricing strategy, monetization model, revenue | swift-generalist | `monetization/` (SKILL.md, pricing-models.md, app-type-guides.md) |
| CloudKit, sync | cloudkit-expert | iCloud sync patterns |
| Data models, persistence | swift-generalist | `macos/swiftdata-architecture` |
| Navigation, architecture | swift-generalist | `ios/navigation-patterns`, `macos/architecture-patterns` |
| Apple Intelligence, Siri, App Intents | swift-generalist | `apple-intelligence/` |
| watchOS, complications, Watch Connectivity | swift-generalist | `watchos/` |
| Liquid Glass, animations, transitions | swiftui-builder | `design/animation-patterns`, `design/liquid-glass` |
| AlarmKit, Charts, WebKit integration | swiftui-builder | `swiftui/alarmkit`, `swiftui/charts-3d`, `swiftui/webkit` |
| MapKit, location, geolocation | swift-generalist | `mapkit/geotoolbox` |
| AppKit bridging, NSViewRepresentable | swift-generalist | `macos/appkit-swiftui-bridge` |
| Swift concurrency, actors, Sendable, async/await | swift-generalist | `swift/concurrency-patterns`, `swift/concurrency` |
| SwiftData hierarchies, inheritance | swift-generalist | `swiftdata/inheritance` |
| Foundation Models, on-device LLM, AI generation | swift-generalist | `apple-intelligence/foundation-models` |
| Visual Intelligence, image analysis, camera AI | swift-generalist | `apple-intelligence/visual-intelligence` |
| Text editing, rich text, styled text | swiftui-builder | `swiftui/text-editing` |
| Toolbars, toolbar customization | swiftui-builder | `swiftui/toolbars` |
| macOS Tahoe, Liquid Glass, new macOS APIs | swiftui-builder | `macos/macos-tahoe-apis` |
| Memory management, retain cycles, leaks | swift-generalist | `swift/memory` |
| HTTP caching, offline fallback, conditional requests | swift-generalist | `generators/http-cache` |
| Image loading, image caching, AsyncImage replacement | swiftui-builder | `generators/image-loading` |
| Pagination, infinite scroll, load more | swift-generalist | `generators/pagination` |
| Migration, version upgrade, breaking changes | swift-generalist | `ios/migration-patterns` |
| Unit tests, integration tests, test infrastructure | swift-generalist | `testing/tdd-feature`, `testing/test-data-factory`, `testing/integration-test-scaffold` |
| Snapshot tests, visual regression, UI tests | swiftui-builder | `testing/snapshot-test-setup` |
| Test contracts, protocol tests | swift-generalist | `testing/test-contract` |
| Rich text, AttributedString | swift-generalist | `foundation/attributed-string` |
| iPad layouts, sidebar, Stage Manager | swiftui-builder | `ios/ipad-patterns` |
| macOS windows, menus, entitlements | swift-generalist | `macos/macos-capabilities` |
| Consent flow, GDPR, privacy consent | swift-generalist | `generators/consent-flow` |
| Force update, version gating, mandatory update | swift-generalist | `generators/force-update` |
| Permission priming, pre-permission, permission request | swiftui-builder | `generators/permission-priming` |
| Account deletion, delete account, user removal | swift-generalist | `generators/account-deletion` |
| App Clip, clip experience, instant app | swift-generalist | `generators/app-clip` |
| Offline queue, pending actions, retry queue | swift-generalist | `generators/offline-queue` |
| Spotlight, search indexing, CSSearchableItem | swift-generalist | `generators/spotlight-indexing` |
| State restoration, scene restoration, NSUserActivity | swift-generalist | `generators/state-restoration` |
| Streak tracking, daily streak, habit tracking | swift-generalist | `generators/streak-tracker` |
| Announcement banner, in-app banner, promo banner | swiftui-builder | `generators/announcement-banner` |
| Feedback form, bug report, user feedback | swiftui-builder | `generators/feedback-form` |
| Lapsed user, re-engagement, win-back | swift-generalist | `generators/lapsed-user` |
| Milestone celebration, achievement, confetti | swiftui-builder | `generators/milestone-celebration` |
| Share card, share sheet, shareable image | swiftui-builder | `generators/share-card` |
| Social export, social media sharing | swift-generalist | `generators/social-export` |
| Usage insights, usage stats, activity summary | swiftui-builder | `generators/usage-insights` |
| Watermark, branded export, image watermark | swift-generalist | `generators/watermark-engine` |
| Quick win, short session, quick engagement | swiftui-builder | `generators/quick-win-session` |
| Referral, invite friends, referral program | swift-generalist | `generators/referral-system` |
| Subscription lifecycle, renewal, grace period, billing | storekit-expert | `generators/subscription-lifecycle` |
| Variable rewards, gamification, reward schedule | swift-generalist | `generators/variable-rewards` |
| Debug menu, developer settings, internal tools | swift-generalist | `generators/debug-menu` |
| Screenshot automation, snapshot testing, marketing screenshots | swift-generalist | `generators/screenshot-automation` |
| What's new, release notes, version changelog | swiftui-builder | `generators/whats-new` |
| Preview data, sample data, `#Preview` matrix, canvas/prototype data | swiftui-builder | `generators/preview-data-generator` |
| Core ML, machine learning, Vision framework, NaturalLanguage | swift-generalist | `core-ml/` |
| App Store assets, marketing screenshots, preview video, event cards | swift-generalist | `generators/app-store-assets` |
| Custom product pages, variant pages, audience targeting | swift-generalist | `generators/custom-product-pages` |
| Featuring nomination, Apple editorial, App Store featuring | swift-generalist | `generators/featuring-nomination` |
| In-app events, seasonal events, live events, event metadata | swift-generalist | `generators/in-app-events` |
| Product page optimization, A/B test screenshots, conversion | swift-generalist | `generators/product-page-optimization` |
| Offer codes, promo codes, redemption codes | storekit-expert | `generators/offer-codes-setup` |
| Pre-order, launch countdown, pre-release | swift-generalist | `generators/pre-orders` |
| Promoted IAP, in-app purchase display, product page purchases | storekit-expert | `generators/promoted-iap` |
| Subscription offers, introductory offer, promo offer | storekit-expert | `generators/subscription-offers` |
| Win-back offers, churned subscriber, lapsed subscription | storekit-expert | `generators/win-back-offers` |
| App extensions, share extension, action extension, keyboard extension | swift-generalist | `generators/app-extensions` |
| Background processing, BGTaskScheduler, background download | swift-generalist | `generators/background-processing` |
| Data export, CSV export, PDF export, GDPR data portability | swift-generalist | `generators/data-export` |
| Visual QA, UI audit, HIG review, accessibility audit | swift-generalist | `ios/ui-review`, `macos/ui-review-tahoe` |
| **Anything else — no row above matches** (project setup, scaffolding, configuration, one-off scripts, …) | swift-generalist | — |

**Never spawn the built-in `general-purpose` agent.** It has no pinned model and
silently inherits the session model — Opus/Fable rates for Sonnet-grade work.
`swift-generalist` is the same breadth with `model: sonnet` enforced; it is the
fallback for every task, not just the rows above. This applies to every agent
spawn in this command, including verification and fix-up passes.

**If the agents are unavailable in this environment** (spawn fails — common in
cloud/remote sessions without `~/.claude/agents/` or vendored
`.claude/agents/`, or right after vendoring: definitions load at session
start): apply the degraded-mode guard in
`~/.claude/swiftship-templates/_conventions/AGENT-VENDORING.md` — tell the
user the pin is lost (tasks would run inline at session-model rates), ask
before proceeding, and log the outcome with `"degraded":"no-agents"`.
Substituting `general-purpose` for the named agents counts as degraded even
with per-call `model` overrides — keep the overrides if proceeding (they
preserve the cost pin and any `model="opus"` task tags), but the run must
still be asked-about and logged degraded.

**Visual QA tasks:** When a task named "Visual QA Audit" is encountered, execute the `/apple:visual-qa` skill in code-only mode. Run all 6 Grep-based scans (hardcoded colors, fixed fonts, missing accessibility, small touch targets, missing view states, rigid frames), fix all Critical/High issues, and generate `.planning/VISUAL-QA.md`.

**Before executing each task:** Load the referenced skill from `~/.claude/swiftship-skills/[skills-reference]/SKILL.md` and include its patterns in the agent prompt context.

**Per-task model override:** if the task XML carries `model="opus"` (set by
`/apple:plan` on at most 1–2 foundation tasks per phase), pass it through as
the spawn's `model` parameter — it overrides the agent's Sonnet frontmatter
for that spawn only. Absent attribute → omit the parameter entirely (the pin
applies). Never pass any other value, and never inherit the session model. If
the escalated spawn fails (older harness, model unavailable), retry once
without the parameter — the override must never block a task. Count escalated
spawns separately for the ledger (see Completion).

Spawn agent with context:

```
Task({
  subagent_type: "[matched-agent]",
  model: "opus",   // only when the task XML has model="opus" — omit otherwise
  prompt: `
    You are executing a task for an Apple app.

    <app-context>
      App: [name from APP.md]
      Platform: [from APP.md]
      Min OS: [from APP.md]
    </app-context>

    <preferences>
      [Relevant choices from PREFERENCES.md if it exists — architecture,
       state pattern, async approach, error handling, structure. Omit if none.]
    </preferences>

    <task>
      [Full task XML from PLAN.md]
    </task>

    <existing-code>
      [Relevant existing files if any]
    </existing-code>

    Requirements:
    1. Follow the <apple-patterns> specified
    2. Create/modify files listed in <files>
    3. Verify all <verify> checks pass
    4. Meet all <done> criteria

    After completing, report:
    - Files created/modified
    - Verification results
    - Any issues encountered
  `
})
```

#### For `type="generator"` Tasks:

Invoke the specified generator skill:

```
Load skill from: ~/.claude/swiftship-skills/generators/[generator-name]/

Apply customizations from <customization> tag.
```

#### For `type="manual"` Tasks:

Display instructions to user:

```
📋 Manual Task: [task name]

This task requires your action:

[action content from task]

Completion criteria:
[done criteria from task]

When complete, I'll mark this task as done and continue.
Reply "done" when you've completed this task.
```

Wait for user confirmation before proceeding.

### 4. Verify Task Completion

For each `<check>` in `<verify>`:

| Check Type | Verification |
|------------|--------------|
| `build` | Run `xcodebuild` or `swift build` |
| `preview` | Confirm SwiftUI preview compiles |
| `simulator` | User confirms in simulator |
| `test` | Run `swift test` or `xcodebuild test` |

### 5. Update Status

On successful completion:

1. Update PLAN.md: `status="completed"`

2. Update STATE.md:
   - Clear Current Task
   - Add to Session History

3. Commit changes:
```bash
git add -A
git commit -m "feat([area]): [task description]

- Completed task [id]: [name]
- [List key changes]

🤖 Generated with Apple GSD"
```

### 6. Continue to Next Task

After completing a task, automatically proceed to the next pending task.

Continue until:
- All tasks complete
- A task fails verification
- User interrupts

## Error Handling

If a task fails:

1. Keep status as `in_progress`
2. Document error in STATE.md under Blockers
3. Ask user how to proceed:
   - Retry with different approach
   - Skip task (mark as `skipped`)
   - Stop execution

## Progress Reporting

After each task:

```
✅ Task [id] complete: [name]

Files changed:
- [file 1]
- [file 2]

Verification:
- ✅ Build succeeds
- ✅ Preview renders
- ✅ [other checks]

Progress: [completed]/[total] tasks

Continuing to task [next-id]: [next-name]...
```

## Phase-End Quality Gate

After all tasks in the phase are complete, automatically run `/apple:review` as a quality gate before declaring the phase done.

1. Execute `/apple:review` — this spawns 5 parallel agents (code quality, HIG, App Store, performance, security), then adversarially verifies every Critical/High finding against the actual code before it lands in REVIEW.md
2. The code quality agent (Agent 1) checks SOLID, DRY, design tokens, and logging hygiene
3. If **Critical** issues are found (all Criticals in REVIEW.md are verified): fix them before proceeding, then re-run the review
4. If **High** issues are found: fix them inline, no re-run needed
5. **Medium/Low** issues: log to `.planning/REVIEW.md` as backlog for the next phase

This gate is mandatory for phases 1-5. Phase 6 (Pre-Release) and Phase 7 (Submission) have their own dedicated review flows.

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent). Key spawns that ran with a per-task model override as `"agent:opus"` in the `agents` object, e.g. `{"swift-generalist": 2, "swift-generalist:opus": 1}`.

When all tasks and the quality gate pass:

```
🎉 Phase [X] complete!

Completed [N] tasks:
1. ✅ [Task 1]
2. ✅ [Task 2]
...

Quality Gate:
- 🔴 Critical: [count] (must be 0)
- 🟠 High: [count] (fixed inline)
- 🟡 Medium: [count] (backlogged)
- 🟢 Low: [count] (backlogged)

Summary:
- Files created: [count]
- Files modified: [count]
- Commits: [count]

Next steps:
1. Test in simulator/device
2. Run /apple:plan [X+1] for next phase
```
