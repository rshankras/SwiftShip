---
description: Gather implementation preferences before planning a phase
argument-hint: [phase-number]
allowed-tools: Read, Write, AskUserQuestion
---

# Discuss Phase Implementation

Before planning a phase, gather implementation preferences to ensure the plan matches your expectations. This prevents wasted effort from misaligned assumptions.

## Step 1: Load Context

Read the planning files:

```
Read: .planning/APP.md       # App specification
Read: .planning/ROADMAP.md   # Phase overview
Read: .planning/STATE.md     # Current state
```

If phase number provided, focus on that phase from ROADMAP.md.

## Step 2: Identify Discussion Topics

Based on the phase, identify areas where preferences matter:

### For Foundation Phase (Phase 1)

- **Project structure:** Feature-based vs layer-based organization?
- **Architecture pattern:** MVVM, MV, TCA, or simple?
- **Dependency injection:** Environment, singletons, or manual?
- **Navigation:** NavigationStack, NavigationSplitView, or custom?

### For Core Features Phase

- **UI approach:** Build custom or use system components?
- **Data flow:** @Observable, ObservableObject, or mix?
- **Error handling:** Result type, throws, or custom?
- **Async approach:** async/await, Combine, or callbacks?

### For Data/Persistence Phase

- **Storage:** SwiftData, Core Data, or custom?
- **Sync strategy:** Real-time, on-demand, or background?
- **Conflict resolution:** Last-write-wins, merge, or manual?

### For Platform Integration Phase

- **Widget approach:** Simple static or complex interactive?
- **Intents scope:** Basic or comprehensive?
- **Notifications:** Local only or push?

### For Quality Phase

- **Testing approach:** Unit-heavy, integration-heavy, or balanced?
- **UI testing:** Full coverage or critical paths only?
- **Performance targets:** What's acceptable?

## Step 3: Ask Preference Questions

Use AskUserQuestion to gather preferences ONE TOPIC AT A TIME.

Example for Foundation Phase:

```
Question 1: Project Structure

How should we organize the code?

Options:
1. Feature-based (Recommended)
   - Group by feature: Features/Home/, Features/Settings/
   - Each feature contains views, models, services
   - Good for: Medium to large apps

2. Layer-based
   - Group by type: Views/, Models/, Services/
   - Traditional MVC-style organization
   - Good for: Small apps

3. Hybrid
   - Features for main modules, shared layers for common code
   - Features/Home/, Shared/Models/, Shared/Services/
```

## Step 4: Document Preferences

After gathering preferences, create/update `.planning/PREFERENCES.md`:

```markdown
# Implementation Preferences

**Phase:** [N] - [Phase Name]
**Discussed:** [date]

---

## Architecture Decisions

### Project Structure
**Choice:** Feature-based
**Reasoning:** [User's reasoning or "User preference"]

### Architecture Pattern
**Choice:** MVVM with @Observable
**Reasoning:** Modern SwiftUI approach, simpler than TCA

### Navigation
**Choice:** NavigationStack with NavigationPath
**Reasoning:** Type-safe, supports deep linking

---

## Code Style Preferences

### Error Handling
**Choice:** Swift throws with custom Error types
**Reasoning:** Native Swift pattern, good IDE support

### Async Approach
**Choice:** async/await
**Reasoning:** Modern, readable, native support

---

## UI Preferences

### Component Style
**Choice:** Custom components wrapping system views
**Reasoning:** Consistent styling, reusable

### Dark Mode
**Choice:** Full support required
**Reasoning:** User expectation for modern apps

---

## Testing Preferences

### Coverage Target
**Choice:** 70% unit, critical path UI tests
**Reasoning:** Balance between coverage and velocity

---

## Specific Decisions

### [Topic 1]
**Decision:** [What was decided]
**Context:** [Why this matters]

### [Topic 2]
**Decision:** [What was decided]
**Context:** [Why this matters]

---

*These preferences will be applied when running /apple:plan and /apple:build*
```

## Step 5: Confirm Understanding

Summarize back to user:

```
Based on our discussion, here are your preferences for Phase [N]:

Architecture:
- Project structure: Feature-based
- Pattern: MVVM with @Observable
- Navigation: NavigationStack

Code Style:
- Errors: throws with custom types
- Async: async/await

Testing:
- 70% unit coverage target
- UI tests for critical paths

Does this look correct? Any changes before I save?
```

## Step 6: Integration with Plan

Note in PREFERENCES.md how these affect planning:

```markdown
## Impact on Planning

When running `/apple:plan [N]`, apply these preferences:

1. **Task generation:** Use feature-based structure in file paths
2. **Agent selection:** Use swiftui-builder with @Observable patterns
3. **Code templates:** Apply MVVM structure
4. **Test tasks:** Target 70% coverage
```

## Completion

```
Preferences saved!

Created: .planning/PREFERENCES.md

Your preferences will be applied when you run:
- /apple:plan [N] - Tasks will reflect your choices
- /apple:build - Code will follow your patterns

Next step: /apple:plan [N] to create the detailed plan
```

## Default Preferences

If user doesn't want to discuss, offer sensible defaults:

```markdown
## SwiftShip Defaults (iOS 17+ / macOS 14+)

- Structure: Feature-based
- Architecture: MVVM with @Observable
- Navigation: NavigationStack
- Data: SwiftData
- Async: async/await
- Testing: Unit tests for logic, UI tests for critical paths
- Style: Follow Apple HIG
```
