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
| 1 (Foundation) | ios/coding-best-practices, macos/coding-best-practices | - |
| 2 (Core) | ios/, macos/, product/ux-spec, product/implementation-guide | Varies by feature |
| 3 (Polish) | ios/ui-review, macos/ui-review-tahoe, design/liquid-glass, design/animation-patterns | widget-generator, accessibility-generator |
| 4 (Monetization) | - | paywall-generator |
| 5 (Testing) | product/test-spec | test-generator |
| 6 (Pre-Release) | app-store/, security/privacy-manifests | - |
| 7 (Submission) | release-review/, app-store/, product/release-spec | - |

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
