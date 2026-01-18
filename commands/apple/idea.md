---
description: Capture an idea for later without disrupting current work
argument-hint: [idea-description]
allowed-tools: Read, Write, Bash
---

# Capture Idea

Quickly capture an idea, feature request, or improvement without disrupting your current work. Ideas are stored for review when planning the next phase or version.

## Why This Exists

During development, you'll think of things like:
- "We should add dark mode"
- "This would be better with haptic feedback"
- "Users might want to export data"

Instead of:
- Forgetting the idea
- Context-switching to add it to the plan
- Creating a TODO that gets lost

Capture it instantly and keep working.

## Step 1: Get the Idea

If provided as argument (`/apple:idea "add haptic feedback"`), use that.

Otherwise, this command shouldn't prompt - it should fail gracefully:

```
Usage: /apple:idea "your idea here"

Example: /apple:idea "Add haptic feedback when completing tasks"
```

## Step 2: Create or Update IDEAS.md

Check if IDEAS.md exists:

```bash
ls .planning/IDEAS.md 2>/dev/null
```

### If New File

Create `.planning/IDEAS.md`:

```markdown
# Ideas & Future Features

Captured ideas for future development. Review these when planning new phases or versions.

---

## Uncategorized

### [Idea from argument]
- **Captured:** [date]
- **Context:** [current phase if known]
- **Priority:** Unset
- **Status:** 💡 New

---

## How to Use

- Run `/apple:idea "description"` to add ideas
- Run `/apple:ideas` to review all ideas
- Move ideas to ROADMAP.md when planning new versions
- Delete ideas that no longer make sense

## Categories

Ideas can be organized into:
- **Features** - New functionality
- **Improvements** - Enhancements to existing features
- **Fixes** - Known issues to address
- **Polish** - UI/UX refinements
- **Technical** - Refactoring, performance, architecture
```

### If File Exists

Append to the Uncategorized section:

```markdown
### [Idea from argument]
- **Captured:** [date]
- **Context:** [current phase if known]
- **Priority:** Unset
- **Status:** 💡 New
```

## Step 3: Quick Confirmation

Output brief confirmation (don't disrupt flow):

```
💡 Idea captured: "[truncated idea if long...]"

Run /apple:ideas to see all [N] ideas.
```

## Idea Format

Each idea entry:

```markdown
### [Short title or full idea]
- **Captured:** YYYY-MM-DD
- **Context:** Phase N / Building [feature] / General
- **Priority:** Unset / Low / Medium / High / Critical
- **Status:** 💡 New / 🔍 Reviewing / ✅ Planned / ❌ Rejected / ✓ Done
- **Notes:** [Optional additional context]
```

## Example IDEAS.md

```markdown
# Ideas & Future Features

---

## Features

### Add Apple Watch companion app
- **Captured:** 2026-01-15
- **Context:** Phase 3 - Polish
- **Priority:** Medium
- **Status:** 🔍 Reviewing
- **Notes:** Users requested quick glance at status from watch

### Export data to CSV
- **Captured:** 2026-01-10
- **Context:** Phase 2 - Core Features
- **Priority:** Low
- **Status:** 💡 New

---

## Improvements

### Haptic feedback on completion
- **Captured:** 2026-01-18
- **Context:** Phase 3 - Polish
- **Priority:** Unset
- **Status:** 💡 New

---

## Polish

### Animate the progress ring
- **Captured:** 2026-01-12
- **Context:** Building dashboard
- **Priority:** Low
- **Status:** ✅ Planned (v1.1)

---

## Technical

### Refactor HealthKitManager for testability
- **Captured:** 2026-01-14
- **Context:** Phase 2 - Struggling with tests
- **Priority:** Medium
- **Status:** 💡 New

---

## Rejected

### Add social sharing
- **Captured:** 2026-01-08
- **Context:** Initial brainstorm
- **Priority:** N/A
- **Status:** ❌ Rejected
- **Notes:** Doesn't fit app philosophy. Focus on personal productivity.
```

## Integration

Ideas feed into:
- `/apple:next-version` - Reviews ideas when planning
- `/apple:plan` - Can pull ideas into phase tasks
- `/apple:roadmap` - Considers ideas for phase allocation
