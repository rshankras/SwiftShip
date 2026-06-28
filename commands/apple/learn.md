---
description: Capture a mistake or pattern into skills for future sessions
argument-hint: [what-went-wrong or pattern-to-remember]
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Learn — Capture Lessons Into Skills

Capture a mistake, gotcha, or pattern so it never recurs. This is the feedback loop that makes every future session better — lessons get written into skills or project conventions so they're applied automatically.

## Step 1: Understand the Lesson

Parse `$ARGUMENTS` for the lesson description.

If no argument provided, ask:

```
What did you learn? This could be:

1. A mistake that cost time (e.g., "forgot weak self in closure causing retain cycle")
2. A pattern that worked well (e.g., "always use .id() when switching detail views")
3. A gotcha/trap (e.g., "SwiftData @Query doesn't update when predicate changes")
4. A project convention (e.g., "always use async/await, never Combine")

Describe what happened and what the fix or pattern is.
```

Also check recent git history for context:

```bash
# See what was recently changed — may relate to the lesson
git log --oneline -5
git diff HEAD~1 --stat 2>/dev/null
```

If the recent changes relate to the lesson, read the relevant diff to understand the full context:

```bash
git diff HEAD~1 -- [relevant-files] 2>/dev/null
```

## Step 2: Classify the Lesson

Determine where this lesson belongs:

| Type | Destination | Examples |
|------|-------------|---------|
| **Swift/SwiftUI pattern** | Existing skill in `claude-code-apple-skills` | Retain cycles, @ViewBuilder limits, NavigationStack gotchas |
| **Framework gotcha** | Existing skill in `claude-code-apple-skills` | SwiftData quirks, StoreKit edge cases, CloudKit conflicts |
| **Platform best practice** | Platform skill (`ios/` or `macos/` coding-best-practices) | Error handling patterns, concurrency patterns |
| **Testing pattern** | Testing skill in `claude-code-apple-skills` | Mock patterns, async test patterns |
| **Project-specific convention** | Target project's `CLAUDE.md` | Naming conventions, architecture decisions, team preferences |
| **Performance insight** | Performance skill or SwiftUI debugging skill | Layout thrashing, main thread blocking |

## Step 3: Find the Right Target

Search the skills repo for the most relevant skill:

```
Glob: ~/.claude/swiftship-skills/**/SKILL.md
```

Search by keywords from the lesson:

```
Grep: [keyword] in ~/.claude/swiftship-skills/
```

Read the top candidate skill to understand its structure:

```
Read: ~/.claude/swiftship-skills/[category]/[skill]/SKILL.md
```

Present the match to the user:

```
Lesson: [one-line summary]
Category: [type from Step 2]

Best match: [skill-name] at [path]
Section: [which section of the skill it fits in — e.g., "Common Pitfalls", "Anti-patterns", "Best Practices"]

Alternative locations:
- [other-skill] — [why it could also fit]
- Project CLAUDE.md — [if project-specific]

Where should I add this?
```

If no existing skill fits well:

```
No existing skill closely matches this lesson.

Options:
1. Add to the closest skill: [skill-name] (new section: "[section name]")
2. Add to platform best practices: [ios/macos]/coding-best-practices
3. Add to project CLAUDE.md (project-specific only)

Which option?
```

## Step 4: Draft the Update

Format the lesson to match the target file's existing style.

### For Skills (SKILL.md files)

Use the `wrong → right → why` pattern:

```markdown
### [Concise Title]

**Wrong:**
```swift
// Code that causes the problem
[problematic code]
```

**Right:**
```swift
// Code that avoids the problem
[correct code]
```

**Why:** [One-sentence explanation of the root cause and why the fix works]
```

If the lesson is a gotcha without a code pattern:

```markdown
### [Concise Title]

> [One-sentence gotcha description]

[Explanation with context. When does this happen? What are the symptoms? How to detect it?]

**Fix:** [What to do about it]
```

### For CLAUDE.md (Project Conventions)

Use a concise rule format:

```markdown
- **[Convention name]**: [What to always/never do]. [Brief reason why.]
```

## Step 5: Confirm with User

Show the exact edit before applying:

```
I'll add this to: [file path]
In section: [section name]

--- PROPOSED ADDITION ---

[exact content to be added]

--- END ---

Apply this change?
```

Wait for user confirmation.

## Step 6: Apply

Edit the target file:

- If adding to a skill: insert the lesson in the appropriate section, maintaining the file's existing formatting
- If adding to CLAUDE.md: append to the relevant section (or create a "Conventions" section if none exists)
- If the target section doesn't exist, create it in a logical position within the file

## Completion

```
✅ Lesson captured!

Updated: [file path]
Section: [section name]
Lesson: [one-line summary]

This will now be applied automatically in future sessions when this skill is referenced.
```
