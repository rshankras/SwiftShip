---
description: Capture a lesson so it never recurs — as a lint rule or test, a project or library skill, or a CLAUDE.md convention
argument-hint: [what-went-wrong or pattern-to-remember]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
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
5. A project rule that should never be broken (e.g., "always use PriceFormatter")
6. A project procedure agents keep getting wrong (e.g., "how to wire a new screen")

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
| **Performance insight** | Performance skill or SwiftUI debugging skill | Layout thrashing, main thread blocking |
| **Project rule a tool can check** | **Enforcement** in the target project — SwiftLint rule (mechanical) or fitness-function test (structural) | "Never format `Decimal` by hand — use `PriceFormatter`", "Views never import the networking module", "No SwiftData schema change without a migration" |
| **Project procedure** (multi-step, repeatable) | **Project skill** — `<project>/.claude/skills/<name>/SKILL.md` | "How a screen is wired into our router", "How we add a SwiftData migration", "How we add a new IAP product" |
| **Project convention** (one line, needs judgment) | Target project's `CLAUDE.md` (or `AGENTS.md` if the project has one) | Naming conventions, architecture decisions, team preferences |

**Project lessons: pick the strongest destination that can express the rule** —
prose decays, enforcement compounds:

1. **Enforcement first.** Could a regex or SwiftLint rule catch every future
   instance? → *mechanical*. Could a source-tree / API scan catch it (an import
   boundary, a call on a forbidden path, a contract drifting)? → *structural*.
   Either way it becomes a check that fails the build, not advice an agent may
   skip. Same classes and rules as `/apple:review`'s enforcement factory.
2. **Project skill** when the lesson is a *procedure* — several steps an agent
   must follow in order, often with a template — that a check can't express.
3. **CLAUDE.md line** only when it is a short convention needing judgment that
   neither a check nor a procedure captures.

A lesson can land in two places — e.g. a skill teaching *how* to add a
migration **plus** a fitness test failing when a schema changes without one.

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

*(Project lessons — enforcement, project skill, CLAUDE.md — skip this library
search: their target is the project. For a project skill, check for an
existing one first: `Glob: .claude/skills/*/SKILL.md`, and prefer extending a
matching skill over creating a near-duplicate.)*

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

### Resolve the source repo (library skills only)

The installed copy at `~/.claude/swiftship-skills/` is overwritten by the
next `/plugin marketplace update` — an edit that lands only there dies on
update. When the target is a library skill (not project CLAUDE.md), resolve
the **source repository** (claude-code-apple-skills) before applying:

1. Installed copy already inside a checkout (symlinked installs):
   ```bash
   git -C ~/.claude/swiftship-skills rev-parse --show-toplevel 2>/dev/null
   ```
2. Previously configured path: `Read: ~/.claude/swiftship-skills-repo`
   (single line — the checkout path). Verify it still exists and is a git
   repo before trusting it.
3. Ask the user once:
   "Where is your claude-code-apple-skills checkout? (Leave empty to skip —
   the lesson will be saved as a patch card instead.)"
   Save a non-empty answer to `~/.claude/swiftship-skills-repo` so this ask
   never repeats.

Record `SOURCE_REPO=[path]` or `SOURCE_REPO=none` for Step 6.

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

### For Enforcement (project rule a tool can check)

**Mechanical → SwiftLint.** Prefer enabling a built-in rule (`force_unwrapping`,
`force_try`, …). Otherwise draft a `custom_rules:` entry:

```yaml
custom_rules:
  [rule_id]:                       # learn: [one-line lesson]
    name: "[Readable name]"
    regex: '[pattern]'
    message: "[What to do instead — name the helper/API to use]"
    severity: error
    included: ["[App sources path]"]
    excluded: ["[Tests paths, generated code]"]
```

Scope it so it can't cry wolf: Grep the regex against the tree and tighten
`included:`/`excluded:` until it matches only real violations (a `print()` rule
excludes tests; never ban `import XCTest` globally — XCUITest needs it).

**Structural → fitness-function test.** Read
`~/.claude/swiftship-skills/testing/fitness-functions/SKILL.md`, pick the
pattern (import-boundary allowlist scan, runtime sentinel, or contract pin),
and draft a Swift Testing suite for the project's existing test target. Name
the suite after the lesson so a failure explains itself.

**Prove it before offering** — an unproven check is unverified:
- *Red:* it fails on the violation (if the code was already fixed, reintroduce
  the violation temporarily, run, then revert).
- *Green:* it passes on the current code.

### For Project Skills (`.claude/skills/<name>/SKILL.md`)

Kebab-case `<name>` that says what it does (`wire-screen-into-router`,
`add-swiftdata-migration`). Frontmatter `name` + a `description` that states
**when to use it** — agents load project skills by matching that line:

```markdown
---
name: [kebab-name]
description: [What this does]. Use when [trigger — e.g. "adding a new screen", "changing a @Model"].
---

# [Title]

[One paragraph: why this procedure exists — the mistake it prevents.]

## Steps
1. [Concrete step — exact file/type names from this project]
2. [...]

## Verify
- [How to tell it was done right — a build, test, or check to run]
```

Add a `template.*` (e.g. `template.swift`) or `scripts/` file beside SKILL.md
only when the procedure stamps out the same code each time; reference it from
the steps.

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

### Project enforcement (SwiftLint rule / fitness-function test)

- **Mechanical:** merge the rule into the project's `.swiftlint.yml` (create a
  minimal one with only this rule if none exists — no opinionated
  boilerplate). Run `swiftlint lint --strict` and confirm the only new
  violations are real ones; if the project uses a baseline
  (`.swiftlint-baseline.json`) and the lesson's violations should be fixed
  later rather than now, say so — never regenerate the baseline to hide them.
- **Structural:** Write the suite into the test target and run it to confirm
  the red/green proof from Step 4.
- No `.swiftlint.yml` and the user declines creating one, or no test target
  exists → fall back to a project skill or CLAUDE.md line, and note that the
  rule is prose-only (that is itself worth fixing).

### Project skills

- **New:** create `.claude/skills/[name]/SKILL.md` (plus any template/script).
- **Existing skill with the same or overlapping name:** never overwrite
  silently — show the diff of the proposed change and apply only on an
  explicit yes; prefer adding a step/section over rewriting.
- Remind the user: project skills load at **session start** — restart before
  relying on it. Commit `.claude/skills/` so the skill travels with the repo
  to cloud, CI, and remote sessions (like vendored agents).

### Project conventions (CLAUDE.md)

Append to the relevant section (or create a "Conventions" section if none
exists). If the target section doesn't exist, create it in a logical position
within the file. If the project has an `AGENTS.md` that CLAUDE.md imports,
write tool-neutral conventions there instead.

### General lessons (library skills)

**With `SOURCE_REPO` resolved:**

1. Refuse to touch a dirty checkout — check first, fall back to the patch
   card below (and say why) if it has uncommitted changes:
   ```bash
   git -C [SOURCE_REPO] status --porcelain
   ```
2. Branch and apply (never commit to the source repo's main):
   ```bash
   git -C [SOURCE_REPO] checkout -b learn/[slug] main
   ```
   Edit `[SOURCE_REPO]/skills/[category]/[skill]/SKILL.md` with the confirmed
   content, then:
   ```bash
   git -C [SOURCE_REPO] add skills/[category]/[skill]/SKILL.md
   git -C [SOURCE_REPO] commit -m "learn: [one-line lesson summary]"
   ```
3. Offer the PR (one question): "Push `learn/[slug]` and open a PR against
   claude-code-apple-skills?" On yes:
   ```bash
   git -C [SOURCE_REPO] push -u origin learn/[slug]
   gh pr create --repo [origin owner/repo] --head learn/[slug] \
     --title "learn: [summary]" --body "[lesson + why + captured by /apple:learn]"
   ```
   On no: leave the local branch and say it's ready to push later. Either
   way, switch the checkout back to its previous branch.
4. **Also apply the same edit to the installed copy** so the lesson is live
   in this session, with a marker line above the added section:
   `<!-- pending upstream: learn/[slug] -->`
   (greppable if the install is overwritten before the PR merges).

**Without `SOURCE_REPO` (or dirty checkout / git errors):**

Write a patch card the lesson survives in — `.planning/patches/skill-[slug].md`
(create the directory if needed):

```markdown
# Pending skill lesson: [slug]
Date: [today] · Target: skills/[category]/[skill]/SKILL.md · Section: [section]
Apply: paste the block below into the target section in a
claude-code-apple-skills checkout, then PR it.

--- CONTENT ---
[the exact confirmed content]
```

Then apply to the installed copy too (live now), marked
`<!-- pending upstream: patch .planning/patches/skill-[slug].md -->`.

## Completion

```
✅ Lesson captured!

[Enforcement:]
Rule: [.swiftlint.yml custom rule `id` | fitness suite `Name` in [test target]]
Proven: red on the violation ✅ · green on current code ✅

[Project skill:]
Skill: .claude/skills/[name]/SKILL.md — [created | extended]
Restart the session to load it; commit .claude/skills/ so it travels with the repo.

[Project convention:]
Updated: [CLAUDE.md path] — [section name]

[General, source-repo path:]
Source repo: learn/[slug] — [committed | PR opened: URL]
Installed copy: updated (live now, marked pending-upstream)

[General, patch-card path:]
Patch card: .planning/patches/skill-[slug].md — apply when a skills-repo
checkout is available
Installed copy: updated (live now)

Lesson: [one-line summary]

This will now be applied automatically in future sessions when this skill is referenced.
```
