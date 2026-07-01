# Phase Plan Template

Copy this file to your project's `.planning/PLAN.md`.

```xml
<plan phase="[phase-number]" platform="iOS|macOS|both">
  <objective>[Phase objective from ROADMAP.md]</objective>
  <apple-focus>[Key Apple technologies for this phase]</apple-focus>

  <!-- Enumerate for any phase with UI. Each flow is an end-to-end user journey
       AND a testable script for /apple:walkthrough. State where every Done/Back
       lands; for each created entity include a reopen-to-edit step; mark the one
       least-discoverable action. Missing arrows here are dead-ends found on paper. -->
  <flows>
    <flow id="F1" persona="[who]" priority="critical|high">
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

  <task id="1" type="auto|manual|generator" status="pending|in_progress|completed">
    <name>[Task name]</name>

    <files>
      <!-- Files to create or modify -->
      <file action="create">Sources/Models/Item.swift</file>
      <file action="modify">Sources/App/MyApp.swift</file>
    </files>

    <apple-patterns>
      <!-- Apple-specific patterns to follow -->
      <pattern>Use @Observable macro for state (iOS 17+)</pattern>
      <pattern>NavigationStack for navigation</pattern>
      <pattern>SwiftData @Model for persistence</pattern>
    </apple-patterns>

    <action>
      [Detailed implementation instructions]

      Key requirements:
      - [Requirement 1]
      - [Requirement 2]

      Example structure:
      ```swift
      // Code example if helpful
      ```
    </action>

    <verify>
      <!-- Verification steps -->
      <check type="build">Project builds without errors</check>
      <check type="preview">SwiftUI preview renders correctly</check>
      <check type="simulator">Feature works in iOS Simulator</check>
      <check type="test">Unit tests pass</check>
    </verify>

    <hig-compliance>
      <!-- HIG checks relevant to this task -->
      <check>Navigation follows platform conventions</check>
      <check>Touch targets are at least 44pt</check>
      <check>System colors used for Dark Mode support</check>
    </hig-compliance>

    <done>
      <!-- Specific completion criteria -->
      - [Criterion 1]
      - [Criterion 2]
      - Preview renders without errors
      - Builds for target platform
    </done>
  </task>

  <!-- Generator task example -->
  <task id="2" type="generator" status="pending">
    <name>Add Settings Screen</name>
    <generator>settings-screen</generator>
    <customization>
      <include>appearance-toggle</include>
      <include>notification-preferences</include>
      <include>account-section</include>
      <exclude>debug-section</exclude>
    </customization>
    <done>
      - Settings screen accessible from main navigation
      - All toggles persist to UserDefaults
      - Appearance changes apply immediately
    </done>
  </task>

  <!-- Manual task example -->
  <task id="3" type="manual" status="pending">
    <name>Configure App Store Connect</name>
    <action>
      User must complete in App Store Connect:
      1. Create app record
      2. Set up in-app purchases
      3. Configure TestFlight
    </action>
    <done>
      - App record exists with correct bundle ID
      - At least one in-app purchase configured
      - Internal testing group created
    </done>
  </task>
</plan>
```

## Task Types

| Type | Execution | Agent |
|------|-----------|-------|
| `auto` | Executed by Claude with appropriate agent | swiftui-builder, storekit-expert, etc. |
| `generator` | Uses a generator skill | References skill in `<generator>` tag |
| `manual` | User must complete (e.g., App Store Connect) | None - instructions provided |

## How to Use

1. Run `/apple:plan [phase-number]` to generate this file
2. Run `/apple:build` to execute pending tasks
3. Tasks are executed in order by ID
4. After building a UI flow's slice, run `/apple:walkthrough [flow-id]` to drive it in the Simulator and catch dead-ends / discoverability gaps (per flow-slice, not just at phase end)
5. Each task updates STATE.md on completion
6. Commit is created after each completed task
