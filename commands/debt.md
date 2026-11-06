---
description: Measure an existing app against SwiftShip's best practices (design system, code size, concurrency, coding practices, tests), rank the debt by how often each area changes, and pay it down safely — characterization tests first, one area per task, a SwiftLint baseline that only shrinks. Writes .planning/DEBT.md.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[area | design | size | concurrency | practices | tests] [--report]"
---

# Debt — pay down your own debt

`/apple:modernize` keeps an app current with Apple (deprecations, new APIs).
This command pays down **your own** debt: the places where the code bypasses
the rules SwiftShip's skills already enforce on new work. It measures, ranks
by cost to you, puts a safety net under each area, and turns the result into
a quality phase the normal `plan → build → verify` cycle executes.

**Never a mass refactor.** One area per task, behavior unchanged, tests
before and after.

## Arguments

- **No argument:** measure the whole app and build the backlog.
- **`[area]`:** a folder (e.g. `Views/Projects`). Measure and plan that area only.
- **`[rule-set]`:** `design`, `size`, `concurrency`, `practices` or `tests`.
  Narrow to one rule set across the app. `design` is the follow-on to
  `/apple:design-system`, which migrates one reference screen.
- **`--report`:** measure and write DEBT.md only. No phase, no lint or
  baseline changes.

## When to Use

- After `/apple:map` on an app you've shipped, before planning a release.
- After `/apple:design-system` on an existing app, to migrate the remaining
  screens (`/apple:debt design`).
- Once per release cycle, to record the trend and pick the next area.

## Prerequisites

```
Read: .planning/CODEBASE.md        # optional — reuse its Design Debt section and structure
Read: .planning/DEBT.md            # optional — exists → append a trend row, keep the backlog's done items
Read: .planning/DESIGN-SYSTEM.md   # optional — design rule set: tokens + components to migrate to
Read: .planning/CRITICAL.md        # optional — areas that need your review, never agent-only
Read: .planning/ROADMAP.md         # optional — where the quality phase goes
Read: .planning/APP.md             # optional — platforms + min OS (decides which rules apply)
```

Works without `/apple:map`: everything is measured directly. Needs
`swiftlint` and `jq`; if either is missing, say so and stop (suggest
`brew install swiftlint jq`).

Load the rules being measured:
```
Read: ~/.claude/swiftship-skills/design/design-system/SKILL.md      # design
Read: ~/.claude/swiftship-skills/swift/code-size/SKILL.md           # size
Read: ~/.claude/swiftship-skills/swift/concurrency/SKILL.md         # concurrency
Read: ~/.claude/swiftship-skills/ios/coding-best-practices/SKILL.md # practices
Read: ~/.claude/swiftship-skills/testing/tdd-refactor-guard/SKILL.md
Read: ~/.claude/swiftship-skills/testing/characterization-test-generator/SKILL.md
Read: ~/.claude/swiftship-skills/testing/coverage-ratchet/SKILL.md  # tests
```

**Which rules apply:**
- `observable_object_legacy` only when the min OS is iOS 17 / macOS 14 /
  watchOS 10 or later. Below that, drop it from the counts.
- No SwiftUI view files → skip the design rule set (say so).
- macOS-only apps: no Dynamic Type findings; everything else applies.

## Step 1: Measure

Lint the app once with the project's config plus every rule-set fragment,
then count violations per **area** (the folder that holds the file) and rule
set, next to how often each area changed in the last six months. The skills'
fragments are passed as extra `--config` files, so nothing in the project
changes:

```bash
bash ~/.claude/swiftship-templates/_scripts/debt-measure.sh
```
It prints the area table (Design, Size, Concurrency, Practices, Total,
Commits in 6 months, Priority), highest priority first, and a Totals line.
Test folders, `Pods/`, `.build/`, `DerivedData/` and `Spikes/` are skipped.
Exit 2 means `swiftlint` or `jq` is missing. If the script is missing, SwiftShip is out of date: tell the user to update it (`claude plugin update apple@indie-apple-stack`, or `git pull` for a manual install). Don't retype the program from memory.

Only the rules in the four fragments count. SwiftLint's other default rules
(line length, identifier names, trailing commas) are style noise for this
purpose and are ignored. With an `[area]` argument, keep only rows under that
folder; with a rule-set argument, keep only that column.

Add the numbers lint can't give:
- **Design debt score:** reuse CODEBASE.md's `### Design Debt` section if it
  is less than a month old. Otherwise run the snippet from `/apple:map` Step
  4.4 (`~/.claude/commands/apple/map.md` or the plugin's `commands/map.md`).
  Report declared-but-missing fonts as a live bug.
- **Concurrency:** if a recent build log is at hand, or a quick
  `xcodebuild build` is cheap, count `Sendable`/actor-isolation warnings per
  area. Otherwise report the lint column only and say so.
- **Tests (`tests` rule set):** per area, does a test file exercise its types
  (`Grep` the type names under the test targets)? Read `.coverage-baseline`
  if present. Don't run the full suite just to measure.
  **Slow tests:** read `.planning/test-slowest.tsv` (written by
  `/apple:verify` each phase) and `.planning/test-times.tsv` for the trend.
  Every test over 10 s is a debt item in its own right, listed with its
  time and likely cause: an app launch per UI test, copied tests that could
  be one test with a list of inputs, real network calls or `sleep` instead
  of fakes. Its area is the test's folder. No file yet → "test speed not
  measured yet (runs with `/apple:verify`)".

## Step 2: Prioritize by cost to you

The table's **Priority** is `violations × (commits in 6 months + 1)`: debt in
code you change every week costs you every week. Split the areas:

- **Pay down:** the top areas by priority, at most 3–5 per run. A small
  focused run finishes; a 20-area backlog doesn't.
- **Freeze:** areas with no commits in six months. Leave them in the
  baseline. They cost nothing until someone touches them; then the lint gate
  makes that someone clean the file.
- **Critical paths:** an area matching a CRITICAL.md glob stays in the
  backlog, but its tasks pause for your review (`/apple:build` Step 4c
  does this already).

With a `design` argument and a DESIGN-SYSTEM.md, rank screens rather than
areas, and skip the reference screen `/apple:design-system` already migrated.
No DESIGN-SYSTEM.md → suggest `/apple:design-system` first: migrating to
tokens that don't exist yet means inventing them per screen.

## Step 3: Write DEBT.md

Write `.planning/DEBT.md` from `~/.claude/swiftship-templates/DEBT.md`:
- the per-area table, top 15 rows, and the totals
- the design-debt score, fonts, tests and concurrency notes from Step 1
- the ordered **backlog**: pay-down areas with the rule sets to fix and
  whether a safety net exists, then frozen areas
- a **Trend** row for this run (date, totals, design-debt %, baseline count)

Existing DEBT.md: append the Trend row, mark backlog items whose area is now
clean as done, and add new ones. Never delete the trend history.

**`--report`:** stop here and print the completion message.

## Step 4: Safety net per area

For each pay-down area, apply `testing/tdd-refactor-guard` to its types:
- **PROCEED** (tests cover the behavior): no extra task.
- **NEEDS TESTS** or **STOP**: the area's first task writes
  characterization tests (`testing/characterization-test-generator`) that pin
  current behavior, including output the code produces today that looks
  wrong. Fixing it is a separate bug, not part of the debt work.

Views have little logic to pin, so for view areas the net is: unit tests on
any model or formatting logic moved out of the view, plus a snapshot or
screenshot of each screen before the change (`testing/snapshot-test-setup` if
the project has it, else a `RUN-AND-SHOT` screenshot recorded in the task).

**No net, no refactor:** a task without a passing safety net never starts.

## Step 5: Plan the quality phase

Turn the backlog into one **quality-intent phase** that `/apple:plan`
expands into tasks:

```markdown
### Phase N: Pay Down Debt — [areas]   (intent: quality)
**Status:** pending
**Objective:** Bring [areas] up to the [rule sets] rules without changing behavior
**Source:** .planning/DEBT.md ([date])
Tasks:
- [ ] [Area 1]: characterization tests (if Step 4 flagged it)
- [ ] [Area 1]: [design | size | concurrency | practices] — clear [n] violations, leave the baseline
- [ ] [Area 2]: …
- [ ] Re-measure: /apple:debt --report
```

**Where it goes:**
- **No ROADMAP.md:** write a one-phase release roadmap in the `/apple:release`
  format, plus a minimal STATE.md pointing at Phase 1.
- **ROADMAP.md with pending phases:** ask once (`AskUserQuestion`) whether
  to add it as the next phase, add it before the release phase, or keep it
  in DEBT.md for a later release.
- **ROADMAP.md fully complete:** suggest `/apple:release` (or
  `/apple:milestone` first) and keep the backlog in DEBT.md.

Never rewrite or renumber existing phases. Insert by appending, or by
asking before renumbering.

**Rules each task carries into the plan:**
- One area (or one screen) per task, and **behavior unchanged**
- `<verify>` includes the area's tests (`type="test"`) and the lint gate
  (`type="lint"`): no violations from the in-scope rule sets in the touched
  files, and the files' baseline entries removed
- Design tasks use DESIGN-SYSTEM.md's tokens, text styles and components, and
  `ContentStateView` for states
- Size tasks split by section into subviews or extensions in their own files
  (`swift/code-size`), with no logic change
- An area that hits a CRITICAL.md glob keeps its build pause

## Step 6: Ratchet

Skip with `--report`.

**Lint rules.** For each rule set in scope that isn't in `.swiftlint.yml`
yet, merge its fragment (`~/.claude/swiftship-skills/<skill>/rules/swiftlint.yml`)
into `.swiftlint.yml`, keeping the project's own `excluded:` and settings.
Create the file if absent. **Show the diff and confirm before writing.**

**Baseline.** New rules mean new violations to freeze:
```bash
bash ~/.claude/swiftship-templates/_scripts/baseline-refresh.sh
```
It prints one line per rule: `added` (a rule new in this run), `shrank`,
`cleared` or `grew`.

A rule that was **already** in the baseline may only stay the same or go
down; only rules added in this run may appear. If an existing rule grew
(exit 3), someone added violations since the last baseline: the script has
already restored the old baseline. Don't absorb them. List the new
violations and add a task to fix them first. If the script is missing, SwiftShip is out of date: tell the user to update it (`claude plugin update apple@indie-apple-stack`, or `git pull` for a manual install). Don't retype the program from memory.

**Coverage.** If the project has `scripts/coverage-gate.sh` and
`.coverage-baseline` (`testing/coverage-ratchet`), each task's tests may only
raise it. If not, note "coverage ratchet: not set up" in DEBT.md and offer
the skill's setup as a backlog item. Don't install it here.

Record the baseline count in DEBT.md's Trend row and, for the design rule
set, in DESIGN-SYSTEM.md's Lint table.

**Commit:** stage by explicit path, never `git add -A`:
`.planning/DEBT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`,
`.swiftlint.yml`, `.swiftlint-baseline.json`, and DESIGN-SYSTEM.md if
updated. Message: `chore(debt): measure + plan [areas]`.

## Platform Notes

- **iOS / iPadOS:** all rule sets apply. Design work keeps Dynamic Type
  (`relativeTo:`) when replacing raw sizes.
- **macOS:** no Dynamic Type findings. Hover and focus states are part of
  any component a design task introduces.
- **watchOS:** smaller files, but the same rules. Skip `observable_object_legacy`
  below watchOS 10.
- **Multi-platform apps:** areas are folders, so per-platform targets show up
  as separate rows. Rank them together.

## Completion Message

**Wording:** write the completion message and DEBT.md's top line per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.

```
🧹 Debt measured — [app]

[One plain sentence: how much clean-up the app needs, where it hurts most, and what happens next.]

Rule sets:  design [n] · size [n] · concurrency [n] · practices [n]
Design:     [x]% design debt [· ⚠️ declared-but-missing fonts: …]
Tests:      [n] of [m] pay-down areas need characterization tests first
Slow tests: [n] over 10 s (slowest: [test], [n] s) — or "not measured yet"
Trend:      [first run | total [before] → [after] since [date]]

Pay down (by priority):
  1. [area] — [n] violations, [c] commits in 6 months ([rule sets])
  2. …
Frozen: [n] areas untouched for 6 months (stay in the baseline)

[--report] Written: .planning/DEBT.md
[full]     Written: .planning/DEBT.md · Phase [N] "Pay Down Debt" in ROADMAP.md
           Lint: [rule sets added] · baseline [n] violations (only shrinks)

Next:
- /apple:plan [N]: expand the phase into tasks (characterization tests first)
- [no DESIGN-SYSTEM.md + design debt > 15%] /apple:design-system first
```
