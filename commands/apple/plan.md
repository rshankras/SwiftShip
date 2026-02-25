---
description: Create detailed task plan for current or specified phase
argument-hint: [phase-number]
allowed-tools: Read, Write, Glob, Grep
---

# Plan Phase

Create a detailed task plan for the specified phase (or current phase from STATE.md).

## Arguments

- `$ARGUMENTS` or `$1`: Phase number (1-7). If not provided, use current phase from STATE.md.

## Prerequisites

Read required files:
```
Read: .planning/APP.md
Read: .planning/ROADMAP.md
Read: .planning/STATE.md
```

If any file is missing:
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
| 2 (Core) | ios/, macos/, product/ux-spec, product/implementation-guide | auth-flow, onboarding-generator, deep-linking, push-notifications, account-deletion, app-clip, offline-queue, spotlight-indexing, state-restoration, streak-tracker (+ varies by feature) |
| 3 (Polish) | ios/ui-review, macos/ui-review-tahoe, design/liquid-glass, design/animation-patterns | widget-generator, accessibility-generator, localization-setup, tipkit-generator, live-activity-generator, feature-flags, announcement-banner, feedback-form, lapsed-user, milestone-celebration, share-card, social-export, usage-insights, watermark-engine, quick-win-session |
| 4 (Monetization) | monetization/ (strategy, pricing-models, app-type-guides) | paywall-generator, review-prompt, referral-system, subscription-lifecycle, variable-rewards |
| 5 (Testing) | product/test-spec, testing/ (TDD workflows) | test-generator, testing/tdd-feature, testing/test-data-factory, testing/snapshot-test-setup, testing/integration-test-scaffold, debug-menu |
| 6 (Pre-Release) | app-store/, security/privacy-manifests | app-icon-generator, error-monitoring, screenshot-automation, whats-new |
| 7 (Submission) | release-review/, app-store/, product/release-spec | - |

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

**Testing skills (Phase 5):**
- **testing/tdd-feature**: Include for all apps — TDD workflow for new test coverage
- **testing/test-data-factory**: Include if app has SwiftData/model layer — generates test fixture factories
- **testing/snapshot-test-setup**: Include if app has custom UI components — SwiftUI visual regression testing
- **testing/integration-test-scaffold**: Include if app has networking + persistence — cross-module test harness
- **testing/test-contract**: Include if app has protocol-based abstractions — contract test suites
- **testing/characterization-test-generator**: Include for brownfield/existing codebases being refactored

Only add generators whose conditions are met — avoid bloating the plan with unnecessary tasks.

## Task Generation

Create `.planning/PLAN.md` with detailed tasks:

### For Phase 1 (Foundation):

```xml
<plan phase="1" platform="[from APP.md]">
  <objective>Project setup and core architecture</objective>
  <apple-focus>Xcode config, SwiftData, NavigationStack</apple-focus>

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

```
✅ Phase [X] plan created!

Created: .planning/PLAN.md with [N] tasks

Tasks:
1. [Task 1 name] (type: [auto/manual/generator])
2. [Task 2 name] (type: [auto/manual/generator])
...

Task types:
- auto: Claude executes with specialized agent
- generator: Uses generator skill
- manual: You complete (e.g., App Store Connect setup)

Next: Run /apple:build to execute tasks
```
