---
description: Display and manage captured ideas
allowed-tools: Read, Write, AskUserQuestion
---

# Review Ideas

Display all captured ideas and optionally organize, prioritize, or act on them.

## Step 1: Load Ideas

```
Read: .planning/IDEAS.md
```

If no IDEAS.md:

```
No ideas captured yet.

To capture ideas during development:
  /apple:idea "your idea here"

Ideas are stored in .planning/IDEAS.md
```

## Step 2: Display Ideas Summary

Show a quick overview:

```markdown
# Ideas Overview

**Total:** [N] ideas
**New:** [N] 💡
**Reviewing:** [N] 🔍
**Planned:** [N] ✅
**Rejected:** [N] ❌

---

## By Category

| Category | Count | High Priority |
|----------|-------|---------------|
| Features | X | X |
| Improvements | X | X |
| Polish | X | X |
| Technical | X | X |
| Uncategorized | X | X |

---

## Recent Ideas (Last 5)

1. **[Idea 1]** - [date] - 💡 New
2. **[Idea 2]** - [date] - 💡 New
3. **[Idea 3]** - [date] - 🔍 Reviewing
...

---

## High Priority

[List any ideas marked High or Critical priority]

---
```

## Step 3: Offer Actions

```
What would you like to do?

1. View all ideas (full list)
2. Organize ideas (categorize uncategorized)
3. Prioritize ideas (set priorities)
4. Plan ideas (move to roadmap)
5. Clean up (reject/remove old ideas)
6. Nothing (just viewing)
```

### Action 1: View All

Display the complete IDEAS.md content, organized by category.

### Action 2: Organize

For each uncategorized idea:

```
Idea: "[idea description]"
Captured: [date]

What category?
- Features (new functionality)
- Improvements (enhance existing)
- Fixes (known issues)
- Polish (UI/UX refinements)
- Technical (refactoring, perf)
- Keep uncategorized
```

Move to appropriate section in IDEAS.md.

### Action 3: Prioritize

For ideas without priority:

```
Idea: "[idea description]"
Category: [category]

Priority?
- Critical (blocking or urgent)
- High (important for next release)
- Medium (should do eventually)
- Low (nice to have)
- Skip (keep unset)
```

Update the idea's priority field.

### Action 4: Plan Ideas

For ideas to include in planning:

```
Which ideas should be planned for the next version?

[ ] [Idea 1] - [category] - [priority]
[ ] [Idea 2] - [category] - [priority]
...

Selected ideas will be marked as "✅ Planned" and shown in /apple:next-version
```

Update status to "✅ Planned (v[VERSION])"

### Action 5: Clean Up

Review old or stale ideas:

```
These ideas are older than 30 days and still "New":

1. [Idea 1] - [date] - Still relevant?
2. [Idea 2] - [date] - Still relevant?

For each:
- Keep (still want this)
- Reject (no longer relevant)
- Delete (remove completely)
```

## Step 4: Update IDEAS.md

After any action, save changes to IDEAS.md.

## Step 5: Completion

```
Ideas reviewed!

Summary:
- Total: [N] ideas
- Organized: [N] (moved from uncategorized)
- Prioritized: [N] (set priority)
- Planned: [N] (marked for next version)
- Rejected: [N]
- Deleted: [N]

High priority ideas:
- [Idea 1]
- [Idea 2]

Next steps:
- Run /apple:next-version to include planned ideas
- Run /apple:idea "desc" to capture more
- Run /apple:plan to add high-priority to current phase
```

## Ideas Workflow

```
During Development:
  /apple:idea "thought" → Captured instantly

When Planning Next Version:
  /apple:ideas → Review and prioritize
  /apple:next-version → Pull in planned ideas

When Planning Phase:
  /apple:plan → Can include high-priority ideas
```

## Quick Filters

If user wants specific views:

```
/apple:ideas
> Show: all / new / high-priority / planned / category:[name]
```

Display filtered view:

**New ideas only:**
```
## New Ideas (💡)

1. [Idea] - [date]
2. [Idea] - [date]
...
```

**High priority:**
```
## High Priority Ideas

1. [Idea] - [category] - [status]
2. [Idea] - [category] - [status]
...
```

**By category:**
```
## Features

1. [Idea] - [priority] - [status]
2. [Idea] - [priority] - [status]
...
```
