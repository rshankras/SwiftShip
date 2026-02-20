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
| StoreKit, purchases | storekit-expert | StoreKit 2 implementation |
| CloudKit, sync | cloudkit-expert | iCloud sync patterns |
| Data models, persistence | general-purpose | `macos/swiftdata-architecture` |
| Navigation, architecture | general-purpose | `ios/navigation-patterns`, `macos/architecture-patterns` |
| Apple Intelligence, Siri, App Intents | general-purpose | `apple-intelligence/` |
| watchOS, complications, Watch Connectivity | general-purpose | `watchos/` |
| Liquid Glass, animations, transitions | swiftui-builder | `design/animation-patterns`, `design/liquid-glass` |
| AlarmKit, Charts, WebKit integration | swiftui-builder | `swiftui/alarmkit`, `swiftui/charts-3d`, `swiftui/webkit` |
| MapKit, location, geolocation | general-purpose | `mapkit/geotoolbox` |
| AppKit bridging, NSViewRepresentable | general-purpose | `macos/appkit-swiftui-bridge` |
| Swift concurrency, actors, Sendable | general-purpose | `swift/concurrency-patterns` |
| SwiftData hierarchies, inheritance | general-purpose | `swiftdata/inheritance` |
| Rich text, AttributedString | general-purpose | `foundation/attributed-string` |
| iPad layouts, sidebar, Stage Manager | swiftui-builder | `ios/ipad-patterns` |
| macOS windows, menus, entitlements | general-purpose | `macos/macos-capabilities` |

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

## Completion Message

When all tasks are done:

```
🎉 Phase [X] complete!

Completed [N] tasks:
1. ✅ [Task 1]
2. ✅ [Task 2]
...

Summary:
- Files created: [count]
- Files modified: [count]
- Commits: [count]

Next steps:
1. Run /apple:review for code quality check
2. Test in simulator/device
3. Run /apple:plan [X+1] for next phase
```
