---
description: Execute current plan using specialized agents
allowed-tools: Read, Write, Edit, Bash, Task, Glob, Grep
---

# Execute Build Plan

Execute pending tasks from `.planning/PLAN.md` using specialized agents.

## Prerequisites

Read required files:
```
Read: .planning/APP.md
Read: .planning/PLAN.md
Read: .planning/STATE.md
```

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

Match task to appropriate agent and spawn:

| Task Content | Agent | Skills Reference |
|-------------|-------|-----------------|
| SwiftUI views, UI | swiftui-builder | `ios/ui-review`, `macos/ui-review-tahoe` |
| StoreKit, purchases | storekit-expert | `monetization/`, `generators/paywall-generator` |
| Pricing strategy, monetization model, revenue | general-purpose | `monetization/` (SKILL.md, pricing-models.md, app-type-guides.md) |
| CloudKit, sync | cloudkit-expert | iCloud sync patterns |
| Data models, persistence | general-purpose | `macos/swiftdata-architecture` |
| Navigation, architecture | general-purpose | `ios/navigation-patterns`, `macos/architecture-patterns` |
| Apple Intelligence, Siri, App Intents | general-purpose | `apple-intelligence/` |
| watchOS, complications, Watch Connectivity | general-purpose | `watchos/` |
| Liquid Glass, animations, transitions | swiftui-builder | `design/animation-patterns`, `design/liquid-glass` |
| AlarmKit, Charts, WebKit integration | swiftui-builder | `swiftui/alarmkit`, `swiftui/charts-3d`, `swiftui/webkit` |
| MapKit, location, geolocation | general-purpose | `mapkit/geotoolbox` |
| AppKit bridging, NSViewRepresentable | general-purpose | `macos/appkit-swiftui-bridge` |
| Swift concurrency, actors, Sendable, async/await | general-purpose | `swift/concurrency-patterns`, `swift/concurrency` |
| SwiftData hierarchies, inheritance | general-purpose | `swiftdata/inheritance` |
| Foundation Models, on-device LLM, AI generation | general-purpose | `apple-intelligence/foundation-models` |
| Visual Intelligence, image analysis, camera AI | general-purpose | `apple-intelligence/visual-intelligence` |
| Text editing, rich text, styled text | swiftui-builder | `swiftui/text-editing` |
| Toolbars, toolbar customization | swiftui-builder | `swiftui/toolbars` |
| macOS Tahoe, Liquid Glass, new macOS APIs | swiftui-builder | `macos/macos-tahoe-apis` |
| Memory management, retain cycles, leaks | general-purpose | `swift/memory` |
| HTTP caching, offline fallback, conditional requests | general-purpose | `generators/http-cache` |
| Image loading, image caching, AsyncImage replacement | swiftui-builder | `generators/image-loading` |
| Pagination, infinite scroll, load more | general-purpose | `generators/pagination` |
| Migration, version upgrade, breaking changes | general-purpose | `ios/migration-patterns` |
| Unit tests, integration tests, test infrastructure | general-purpose | `testing/tdd-feature`, `testing/test-data-factory`, `testing/integration-test-scaffold` |
| Snapshot tests, visual regression, UI tests | swiftui-builder | `testing/snapshot-test-setup` |
| Test contracts, protocol tests | general-purpose | `testing/test-contract` |
| Rich text, AttributedString | general-purpose | `foundation/attributed-string` |
| iPad layouts, sidebar, Stage Manager | swiftui-builder | `ios/ipad-patterns` |
| macOS windows, menus, entitlements | general-purpose | `macos/macos-capabilities` |
| Consent flow, GDPR, privacy consent | general-purpose | `generators/consent-flow` |
| Force update, version gating, mandatory update | general-purpose | `generators/force-update` |
| Permission priming, pre-permission, permission request | swiftui-builder | `generators/permission-priming` |
| Account deletion, delete account, user removal | general-purpose | `generators/account-deletion` |
| App Clip, clip experience, instant app | general-purpose | `generators/app-clip` |
| Offline queue, pending actions, retry queue | general-purpose | `generators/offline-queue` |
| Spotlight, search indexing, CSSearchableItem | general-purpose | `generators/spotlight-indexing` |
| State restoration, scene restoration, NSUserActivity | general-purpose | `generators/state-restoration` |
| Streak tracking, daily streak, habit tracking | general-purpose | `generators/streak-tracker` |
| Announcement banner, in-app banner, promo banner | swiftui-builder | `generators/announcement-banner` |
| Feedback form, bug report, user feedback | swiftui-builder | `generators/feedback-form` |
| Lapsed user, re-engagement, win-back | general-purpose | `generators/lapsed-user` |
| Milestone celebration, achievement, confetti | swiftui-builder | `generators/milestone-celebration` |
| Share card, share sheet, shareable image | swiftui-builder | `generators/share-card` |
| Social export, social media sharing | general-purpose | `generators/social-export` |
| Usage insights, usage stats, activity summary | swiftui-builder | `generators/usage-insights` |
| Watermark, branded export, image watermark | general-purpose | `generators/watermark-engine` |
| Quick win, short session, quick engagement | swiftui-builder | `generators/quick-win-session` |
| Referral, invite friends, referral program | general-purpose | `generators/referral-system` |
| Subscription lifecycle, renewal, grace period, billing | storekit-expert | `generators/subscription-lifecycle` |
| Variable rewards, gamification, reward schedule | general-purpose | `generators/variable-rewards` |
| Debug menu, developer settings, internal tools | general-purpose | `generators/debug-menu` |
| Screenshot automation, snapshot testing, marketing screenshots | general-purpose | `generators/screenshot-automation` |
| What's new, release notes, version changelog | swiftui-builder | `generators/whats-new` |
| Core ML, machine learning, Vision framework, NaturalLanguage | general-purpose | `core-ml/` |
| App Store assets, marketing screenshots, preview video, event cards | general-purpose | `generators/app-store-assets` |
| Custom product pages, variant pages, audience targeting | general-purpose | `generators/custom-product-pages` |
| Featuring nomination, Apple editorial, App Store featuring | general-purpose | `generators/featuring-nomination` |
| In-app events, seasonal events, live events, event metadata | general-purpose | `generators/in-app-events` |
| Product page optimization, A/B test screenshots, conversion | general-purpose | `generators/product-page-optimization` |
| Offer codes, promo codes, redemption codes | storekit-expert | `generators/offer-codes-setup` |
| Pre-order, launch countdown, pre-release | general-purpose | `generators/pre-orders` |
| Promoted IAP, in-app purchase display, product page purchases | storekit-expert | `generators/promoted-iap` |
| Subscription offers, introductory offer, promo offer | storekit-expert | `generators/subscription-offers` |
| Win-back offers, churned subscriber, lapsed subscription | storekit-expert | `generators/win-back-offers` |
| App extensions, share extension, action extension, keyboard extension | general-purpose | `generators/app-extensions` |
| Background processing, BGTaskScheduler, background download | general-purpose | `generators/background-processing` |
| Data export, CSV export, PDF export, GDPR data portability | general-purpose | `generators/data-export` |
| Visual QA, UI audit, HIG review, accessibility audit | general-purpose | `ios/ui-review`, `macos/ui-review-tahoe` |

**Visual QA tasks:** When a task named "Visual QA Audit" is encountered, execute the `/apple:visual-qa` skill in code-only mode. Run all 6 Grep-based scans (hardcoded colors, fixed fonts, missing accessibility, small touch targets, missing view states, rigid frames), fix all Critical/High issues, and generate `.planning/VISUAL-QA.md`.

**Before executing each task:** Load the referenced skill from `/Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/[skills-reference]/SKILL.md` and include its patterns in the agent prompt context.

Spawn agent with context:

```
Task({
  subagent_type: "[matched-agent]",
  prompt: `
    You are executing a task for an Apple app.

    <app-context>
      App: [name from APP.md]
      Platform: [from APP.md]
      Min OS: [from APP.md]
    </app-context>

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
Load skill from: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/generators/[generator-name]/

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

1. Execute `/apple:review` — this spawns 5 parallel agents (code quality, HIG, App Store, performance, security)
2. The code quality agent (Agent 1) checks SOLID, DRY, design tokens, and logging hygiene
3. If **Critical** issues are found: fix them before proceeding, then re-run the review
4. If **High** issues are found: fix them inline, no re-run needed
5. **Medium/Low** issues: log to `.planning/REVIEW.md` as backlog for the next phase

This gate is mandatory for phases 1-5. Phase 6 (Pre-Release) and Phase 7 (Submission) have their own dedicated review flows.

## Completion Message

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
