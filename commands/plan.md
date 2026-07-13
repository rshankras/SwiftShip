---
description: Create detailed task plan for current or specified phase
argument-hint: [phase-number]
allowed-tools: Read, Write, Glob, Grep
---

# Plan Phase

Create a detailed task plan for the specified phase (or current phase from STATE.md).

**Model check:** apply
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md` — planning is
judgment-tier for complex phases (architecture, data model, Phases 1–2) and
analysis-tier for routine ones; if this session is below that, note the
quality risk once and continue. Skip silently if the file is absent.

## Arguments

- `$ARGUMENTS` or `$1`: Phase number (1-7). If not provided, use current phase from STATE.md.

## Prerequisites

Read required files:
```
Read: .planning/APP.md
Read: .planning/ROADMAP.md
Read: .planning/STATE.md
```

Also read implementation preferences if they exist (created by `/apple:discuss`):
```
Read: .planning/PREFERENCES.md   # Optional — apply if present
```

If `PREFERENCES.md` exists, **apply it** when generating tasks: use the chosen
project structure in `<file>` paths, the chosen architecture/state pattern and
async approach in `<apple-patterns>`, the chosen error-handling style, and the
chosen test-coverage target for Phase 5 tasks. Preferences override the
SwiftShip defaults below wherever they conflict. If `PREFERENCES.md` is absent,
fall back to the defaults and (optionally) suggest the user run
`/apple:discuss [phase]` first.

Also read the release scope if it exists (created by `/apple:release`):
```
Read: .planning/RELEASE.md   # Optional — present for existing-app releases
```

If `RELEASE.md` exists, this is an **existing-app release**, not a greenfield
build: the phases in `ROADMAP.md` are **intent-tagged** (see *Release Phases*
below), the `<baseline>` describes code that already ships (don't re-create it),
and `<regression-scope>` lists existing flows the Harden phase must re-verify.

If any required file is missing:
```
⚠️ Missing planning files. Run these commands first:
- /apple:new-app - Create app specification
- /apple:roadmap - Create development roadmap
```

## Phase Analysis

Determine which skills and generators are relevant based on phase:

| Phase | Primary Skills | Generators |
|-------|---------------|------------|
| 1 (Foundation) | ios/coding-best-practices, macos/coding-best-practices | logging-setup, networking-layer, analytics-setup, consent-flow, force-update, permission-priming |
| 2 (Core) | ios/, macos/, product/ux-spec, product/implementation-guide, design/design-principles (screen structure, navigation, empty states) | auth-flow, onboarding-generator, deep-linking, push-notifications, account-deletion, app-clip, offline-queue, spotlight-indexing, state-restoration, streak-tracker, app-extensions, background-processing, data-export (+ varies by feature) |
| 3 (Polish) | ios/ui-review, macos/ui-review-tahoe, ios/accessibility-audit (audit + Nutrition Label criteria), design/liquid-glass, design/animation-patterns, design/ux-writing (copy pass), design/sf-symbols, design/typography | widget-generator, accessibility-generator, preview-data-generator, localization-setup, tipkit-generator, live-activity-generator, feature-flags, announcement-banner, feedback-form, lapsed-user, milestone-celebration, share-card, social-export, usage-insights, watermark-engine, quick-win-session |
| 4 (Monetization) | monetization/ (strategy, pricing-models, app-type-guides) | paywall-generator, review-prompt, referral-system, subscription-lifecycle, variable-rewards, offer-codes-setup, pre-orders, promoted-iap, subscription-offers, win-back-offers |
| 5 (Testing) | product/test-spec, testing/ (TDD workflows) | test-generator, preview-data-generator, testing/tdd-feature, testing/test-data-factory, testing/snapshot-test-setup, testing/integration-test-scaffold, debug-menu |
| 6 (Pre-Release) | app-store/, security/privacy-manifests, legal/privacy-policy | app-icon-generator, error-monitoring, screenshot-automation, whats-new, app-store-assets, custom-product-pages, featuring-nomination, in-app-events, product-page-optimization, app-store/iap-finalizer, legal/privacy-publish |
| 7 (Submission) | release-review/, app-store/, product/release-spec, app-store/rejection-handler | - |

The table above maps phases by **number**, which assumes the greenfield v1.0
roadmap from `/apple:roadmap`. Release roadmaps use intent instead —

### Release Phases (intent-tagged, from `/apple:release`)

When `ROADMAP.md` phases carry an `intent` attribute, route by **intent**, not by
number (a release "Phase 1" is a feature phase, not Foundation):

| Intent | Primary Skills | Task shape |
|--------|---------------|------------|
| `feature` | ios/, macos/, design/, swiftui/ (+ the same agent-matching `/apple:build` uses) | One `type="auto"` task per feature. For UI features, add a `<flows>` block and a Visual QA task, exactly as in a greenfield UI phase. |
| `bugfix` | `testing/tdd-bug-fix`, `performance/swiftui-debugging` | One `type="auto"` task per bug, following the `/apple:bugfix` workflow: locate → minimal fix → **regression test**. Each task's `<verify>` MUST include a `type="test"` check for the new regression test. |
| `quality` | `ios/ui-review`, `testing/`, `security/`, `performance/profiling` | Regression walkthrough of the `<regression-scope>` flows from `RELEASE.md` (drive with `/apple:walkthrough`), plus tests/review/security/perf as scope warrants. |
| `release` | `app-store/`, `product/release-spec`, `legal/privacy-policy` | What's New (`generators/whats-new`), screenshot refresh if UI changed (`generators/screenshot-automation`), release notes, TestFlight, submit. Keep submit `type="manual"`. |

Everything else about task generation (the XML format, `<verify>`, `<done>`,
committing per task) is identical — only skill selection changes.

### Conditional Generator Selection

Not every plan needs every generator. Inspect APP.md's `<apple-technologies>` and `<architecture>` to decide which generators to include as tasks:

- **logging-setup**: Include if app has backend integration, analytics, or debugging needs
- **networking-layer**: Include if app has API calls, sync, or remote data
- **http-cache**: Include if app has API calls and needs offline support or reduced network usage
- **pagination**: Include if app displays lists of remote data with load-more or infinite scroll
- **image-loading**: Include if app displays remote images (avatars, photos, thumbnails)
- **analytics-setup**: Include if app tracks user behavior or has business metrics
- **auth-flow**: Include if `<auth>` is not `None`
- **onboarding-generator**: Include if app has auth or first-run setup experience
- **deep-linking**: Include if app has sharing, external links, or universal links
- **push-notifications**: Include if `Push Notifications` is in `<apple-technologies>`
- **localization-setup**: Include if app targets multiple regions or languages
- **tipkit-generator**: Include for apps with discoverable features that benefit from coaching
- **live-activity-generator**: Include if `Live Activities` is in `<apple-technologies>`
- **feature-flags**: Include if app has A/B testing, staged rollout, or remote config
- **review-prompt**: Include for all apps with monetization or user engagement goals
- **app-icon-generator**: Include in pre-release phase for all apps
- **error-monitoring**: Include if app has backend/network features or crash reporting needs
- **consent-flow**: Include if app collects personal data or targets EU/California users
- **force-update**: Include if app has API versioning or server-side breaking changes
- **permission-priming**: Include if app requests sensitive permissions (camera, location, microphone, health)
- **account-deletion**: Include if app has user accounts (Apple requirement since 2022)
- **app-clip**: Include if app benefits from lightweight try-before-install experiences
- **offline-queue**: Include if app needs to queue user actions while offline for later sync
- **spotlight-indexing**: Include if app has searchable content (articles, items, records)
- **state-restoration**: Include if app has complex navigation that should survive relaunch
- **streak-tracker**: Include if app has daily engagement, habit tracking, or streak mechanics
- **announcement-banner**: Include if app needs to communicate updates, promotions, or alerts in-app
- **feedback-form**: Include if app collects user feedback, bug reports, or feature requests
- **lapsed-user**: Include if app has retention goals and needs win-back flows
- **milestone-celebration**: Include if app has achievements, progress milestones, or completion events
- **share-card**: Include if app has content users can share as branded images
- **social-export**: Include if app has content users share to social media platforms
- **usage-insights**: Include if app benefits from showing users their activity or usage statistics
- **watermark-engine**: Include if app generates images or exports that need branding/watermarks
- **quick-win-session**: Include if app benefits from short, rewarding engagement loops
- **referral-system**: Include if app benefits from word-of-mouth or invite-a-friend growth
- **subscription-lifecycle**: Include if app has subscriptions (renewal, grace period, billing state management)
- **variable-rewards**: Include if app uses gamification, surprise rewards, or engagement hooks
- **debug-menu**: Include for all apps — hidden debug menu for internal/TestFlight builds
- **screenshot-automation**: Include for all apps — automated App Store screenshot capture
- **whats-new**: Include for all apps — What's New screen shown after app updates
- **app-extensions**: Include if app needs share, action, or keyboard extensions with App Groups
- **background-processing**: Include if app needs BGTaskScheduler or background downloads
- **data-export**: Include if app needs JSON/CSV/PDF export or GDPR data portability compliance
- **app-store-assets**: Include for all apps — comprehensive App Store asset specs
- **custom-product-pages**: Include if app targets multiple distinct audiences needing tailored pages
- **featuring-nomination**: Include if app is a strong candidate for Apple editorial featuring
- **in-app-events**: Include if app has seasonal events, challenges, or live content on App Store
- **product-page-optimization**: Include if planning to A/B test App Store screenshots and metadata
- **offer-codes-setup**: Include if app uses promo codes for influencers, press, or partnerships
- **pre-orders**: Include if app will launch with App Store pre-orders
- **promoted-iap**: Include if app has in-app purchases to display on the App Store product page
- **subscription-offers**: Include if app has subscriptions needing intro, promo, or win-back offers
- **win-back-offers**: Include if app has churned subscribers to re-engage with targeted offers

**Testing skills (Phase 5):**
- **testing/tdd-feature**: Include for all apps — TDD workflow for new test coverage
- **testing/test-data-factory**: Include if app has SwiftData/model layer — generates test fixture factories
- **testing/snapshot-test-setup**: Include if app has custom UI components — SwiftUI visual regression testing
- **preview-data-generator**: Include for views with multiple data/appearance states (empty/loading/error/loaded, dark, Dynamic Type, RTL), or whenever snapshot-test-setup is included — it produces the sample data + `#Preview` matrix the snapshots render, so both share one dataset
- **testing/integration-test-scaffold**: Include if app has networking + persistence — cross-module test harness
- **testing/test-contract**: Include if app has protocol-based abstractions — contract test suites
- **testing/characterization-test-generator**: Include for brownfield/existing codebases being refactored

Only add generators whose conditions are met — avoid bloating the plan with unnecessary tasks.

**Visual QA (Phases 1-3):**
- **visual-qa**: Always include as the **final task** in any phase that creates or modifies UI views (typically phases 1, 2, and 3). Runs a code-level audit checking HIG compliance, accessibility, touch targets, hardcoded colors, missing view states, and fixed-frame layouts. Generates `.planning/VISUAL-QA.md` and fixes all Critical/High issues before the phase is marked complete.

## User Flows (any phase with UI)

A task list verifies that *screens exist and compile*. It is blind to whether the **flow between screens works for a human with a goal** — the return paths, the dead-ends, the discoverability. Those bugs (e.g. "a saved record can only be viewed, never reopened to edit"; "Done drops me to the home screen and loses my work"; "how do I even select this?") are *missing arrows in a journey*, and a journey map catches them on paper — before code.

**For any phase that adds or changes UI, enumerate a `<flows>` block** (place it right after `<apple-focus>`, before the tasks). Each flow is one end-to-end user journey *and* a testable script for `/apple:walkthrough`. Rules for good flows:

- Write them as **screen → action → screen** arrows, including the **return / back / Done** destination of every step (state where each `Done`/`Back` must land).
- For **every persisted model with a Create step**, include a flow that **leaves and reopens it editable** (reopen-from-list). Create-without-a-reopen-edit-path is the most common dead-end.
- Cover the **empty**, **edit**, and **error** paths, not just the happy path.
- Mark the single **least-discoverable action** in each flow — the thing a first-timer might not find.

```xml
<flows>
  <!-- End-to-end journeys this phase must satisfy. Each drives /apple:walkthrough. -->
  <flow id="F1" persona="[who]" priority="critical|high">
    <goal>[what the user is trying to accomplish]</goal>
    <steps>
      <step>Launch → [screen]</step>
      <step>Tap [control] → [screen]</step>
      <step>[action] → [expected result / screen]</step>
      <step>Tap Done/Back → MUST land on [screen]</step>
    </steps>
    <returns-to-edit>[for each entity created: the step that reopens it editable]</returns-to-edit>
    <discoverability>[the one action a first-timer might not find]</discoverability>
  </flow>
</flows>
```

After building a flow's slice, run `/apple:walkthrough [flow-id]` — it drives the flow in the Simulator (UI test + per-step screenshots), statically audits the nav graph for dead-ends, and produces a human discoverability checklist. Do this **per flow-slice, not just at phase end**.

## Task Generation

Create `.planning/PLAN.md` with detailed tasks:

### Model tagging (`type="auto"` tasks only)

Tag **at most 1–2 tasks per phase** with `model="opus"` — only tasks whose
mistakes propagate into everything built after them:

- App architecture / project structure being locked in
- Data model / schema foundations (SwiftData models, CloudKit record design)
- Concurrency-heavy engines (actors, sync pipelines, background processing)
- Migrations with data-loss risk

Everything else stays untagged — the agents' Sonnet pin plus `<verify>` gates
carry routine work. Discipline check before writing PLAN.md: if more than 2
tasks are tagged, untag the least foundation-shaping until 2 remain. Never tag
`generator` or `manual` tasks, and never use a value other than `opus` (Haiku
downshift is deliberately not offered pending ledger evidence — see the
"Per-spawn overrides" section of
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md`). `/apple:build`
passes the attribute through as the agent spawn's `model` override; an absent
attribute means the agent's pinned default. Phases with no foundation-shaping
tasks get zero tags — that is the common case.

### For Phase 1 (Foundation):

```xml
<plan phase="1" platform="[from APP.md]">
  <objective>Project setup and core architecture</objective>
  <apple-focus>Xcode config, SwiftData, NavigationStack</apple-focus>

  <!-- Enumerate for any phase with UI. Each flow drives /apple:walkthrough. -->
  <flows>
    <flow id="F1" persona="[who]" priority="critical">
      <goal>[what the user is trying to accomplish]</goal>
      <steps>
        <step>Launch → [screen]</step>
        <step>Tap [control] → [screen]</step>
        <step>Tap Done/Back → MUST land on [screen]</step>
      </steps>
      <returns-to-edit>[for each entity created: the step that reopens it editable]</returns-to-edit>
      <discoverability>[the one action a first-timer might not find]</discoverability>
    </flow>
  </flows>

  <task id="1" type="manual" status="pending">
    <name>Create Xcode Project</name>
    <action>
      Create new Xcode project with:
      - Product Name: [from APP.md]
      - Bundle Identifier: [from APP.md]
      - Interface: SwiftUI
      - Language: Swift
      - Storage: [SwiftData if selected]

      Configure:
      - Deployment target: [from APP.md]
      - Device orientations
      - Capabilities: [from apple-technologies]
    </action>
    <done>
      - Xcode project created and builds
      - Bundle ID matches APP.md
      - Correct deployment target set
    </done>
  </task>

  <task id="2" type="auto" status="pending">
    <name>Define Data Models</name>
    <files>
      <file action="create">Sources/Models/[Model].swift</file>
    </files>
    <apple-patterns>
      <pattern>Use @Model macro for SwiftData</pattern>
      <pattern>Use Codable for API responses</pattern>
      <pattern>Relationships with @Relationship</pattern>
    </apple-patterns>
    <action>
      Create SwiftData models based on MVP features:
      [Analyze features and suggest models]

      Each model should:
      - Use @Model macro
      - Have appropriate relationships
      - Include computed properties where helpful
    </action>
    <verify>
      <check type="build">Models compile without errors</check>
      <check type="preview">Can be used in SwiftUI previews</check>
    </verify>
    <done>
      - All models defined with @Model
      - Relationships configured
      - Builds successfully
    </done>
  </task>

  <task id="3" type="auto" status="pending">
    <name>Set Up App Architecture</name>
    <files>
      <file action="modify">[AppName]App.swift</file>
      <file action="create">Sources/App/AppState.swift</file>
    </files>
    <apple-patterns>
      <pattern>@Observable for app-wide state</pattern>
      <pattern>@Environment for dependency injection</pattern>
      <pattern>ModelContainer in App struct</pattern>
    </apple-patterns>
    <action>
      Create MVVM architecture:

      1. AppState with @Observable:
      ```swift
      @Observable
      final class AppState {
          var isOnboarded: Bool = false
          // Add app-wide state
      }
      ```

      2. Configure App struct:
      ```swift
      @main
      struct [AppName]App: App {
          @State private var appState = AppState()

          var body: some Scene {
              WindowGroup {
                  ContentView()
                      .environment(appState)
              }
              .modelContainer(for: [Models].self)
          }
      }
      ```
    </action>
    <verify>
      <check type="build">App builds and launches</check>
    </verify>
    <done>
      - AppState created with @Observable
      - Environment configured
      - ModelContainer set up
    </done>
  </task>

  <task id="4" type="auto" status="pending">
    <name>Implement Navigation Structure</name>
    <files>
      <file action="create">Sources/Views/ContentView.swift</file>
      <file action="create">Sources/Navigation/Router.swift</file>
    </files>
    <apple-patterns>
      <pattern>NavigationStack for iOS</pattern>
      <pattern>NavigationSplitView for iPad/Mac</pattern>
      <pattern>@Observable Router for programmatic navigation</pattern>
    </apple-patterns>
    <action>
      Based on app type, implement navigation:

      For single-column apps:
      - NavigationStack with path binding

      For multi-column apps (iPad/Mac):
      - NavigationSplitView with sidebar

      Include Router class for programmatic navigation.
    </action>
    <verify>
      <check type="simulator">Navigation works correctly</check>
    </verify>
    <done>
      - Navigation structure matches app type
      - Programmatic navigation works
      - Adapts to device size
    </done>
  </task>

  <!-- Visual QA: ALWAYS the last task in phases with UI work (1-3) -->
  <task id="last" type="auto" status="pending">
    <name>Visual QA Audit</name>
    <action>
      Run /apple:visual-qa code-level audit on all views created/modified in this phase.
      Scan for: HIG compliance, accessibility labels/traits, touch targets (44pt min),
      hardcoded colors, Dynamic Type support, missing view states, fixed-frame layouts.
    </action>
    <verify>
      <check type="build">All fixes compile without errors</check>
    </verify>
    <done>
      - .planning/VISUAL-QA.md generated with full report
      - All Critical and High severity issues fixed
      - Medium issues documented for backlog
    </done>
  </task>
</plan>
```

### For Other Phases:

Generate tasks based on:
- ROADMAP.md phase tasks
- APP.md features and frameworks
- Relevant generator skills

### Generator Task Example:

```xml
<task id="X" type="generator" status="pending">
  <name>Add Settings Screen</name>
  <generator>generators/settings-screen</generator>
  <customization>
    <include>appearance-toggle</include>
    <include>notification-preferences</include>
    <include>about-section</include>
  </customization>
  <done>
    - Settings accessible from navigation
    - All preferences persist
    - Version info displays correctly
  </done>
</task>
```

## Update STATE.md

After creating PLAN.md, update STATE.md:
- Set Phase Status to "pending" (ready to build)
- Update Last Updated timestamp

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent).

```
✅ Phase [X] plan created!

Created: .planning/PLAN.md with [N] tasks

Tasks:
1. [Task 1 name] (type: [auto/manual/generator][; append ", model: opus" if tagged])
2. [Task 2 name] (type: [auto/manual/generator])
...

Task types:
- auto: Claude executes with specialized agent
- generator: Uses generator skill
- manual: You complete (e.g., App Store Connect setup)

Next: Run /apple:build to execute tasks
```
