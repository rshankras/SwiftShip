---
description: Verify completed work against plan deliverables
argument-hint: "[phase-number]"
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion, Skill
model: sonnet
---

# Verify Completed Work

You are a quality assurance expert verifying that completed work meets the planned deliverables. Your goal is to ensure everything works before moving to the next phase.

## Step 1: Write Your Own List From the Spec (before reading the plan)

The plan was written by the same kind of model that did the work. If the
plan forgot something, checking only the plan forgets it too. So first,
**without opening PLAN.md**, read what was promised:

```
Read: .planning/APP.md        # new apps: <mvp-features>
Read: .planning/RELEASE.md    # updates: <features>, <bugs> (optional)
Read: .planning/ROADMAP.md    # which of those this phase delivers
```

If a phase number is provided as argument, verify that specific phase.

For each feature or bug this phase delivers, write down in your own words
what a person should be able to see or do when it works: the normal case,
plus the empty, error and edit cases where they apply. Use the same
Given / When / Then shape the plan uses. Keep this list; it goes into the
report unchanged as **Expected from the spec**.

## Step 2: Read the Plan and Compare

```
Read: .planning/PLAN.md      # tasks, <criteria>, <spec-clarifications>
Read: .planning/STATE.md     # current state and completed tasks
```

**Trace every promise to its proof.** For each feature on your Step 1 list:

1. Find the plan's `<criterion>` entries for it (matched by `feature`).
   Apply `<spec-clarifications>`: an answer there settles what the spec
   meant. Note any `source="assumed"` items; a person still has to confirm
   them.
2. Compare them with your list. Something you expected that no criterion
   covers is a **gap in the plan**, even if every task says completed.
3. Check each criterion's `<proof>` exists: the named test is in the test
   target, the flow id is in `<flows>`, the lint rule is in
   `.swiftlint.yml`. A criterion whose proof doesn't exist is **unproven**.
4. Criteria with `via="package"` are checked through the package's public
   functions (its tests); `via="screen"` through what's on screen (UI test,
   walkthrough, screenshot, or a manual check).

How these count:

| Finding | Severity | Effect on the result |
|---------|----------|----------------------|
| A `must` feature (or `crash`/`high` bug) has no criterion | High | FAIL |
| A `should`/`could` feature or lower bug has no criterion | Medium | PARTIAL |
| Something you expected is missing from the criteria | Medium (High if it loses data) | PARTIAL |
| A criterion's proof doesn't exist | Medium | PARTIAL |
| A criterion's proof runs and fails | as the failure | FAIL |
| An assumed clarification is still unconfirmed | Low | ask in Step 4 |

**Older plans with no `<criteria>`:** don't fail them for the format. Trace
the spec list to the `<done>` lines instead, mark each feature "no
checkable criteria (older plan)", and turn your Step 1 statements into
the manual checks in Step 4.

Then build the checklist. Each criterion becomes a check of its proof type:
`test` runs in 3.2 (name the tests), `lint` in 3.5, `flow` through
`/apple:walkthrough` results or Step 4, `manual` in Step 4 (ask it as
written: "Given …, when you …, do you see …?"). Gaps go straight to
Issues Found.

```markdown
## Deliverables to Verify

### Spec coverage
- [ ] [Feature] → AC[n] → [proof]
- [ ] [Feature] → ⚠️ no criterion (gap)

### Automated Checks
- [ ] Project builds without errors
- [ ] All tests pass (including every test named in a criterion)
- [ ] No compiler warnings
- [ ] Lint gate passes (if .swiftlint.yml exists)
- [ ] Coverage gate passes (if .coverage-baseline exists)
- [ ] [Feature X] file exists at [path]

### Manual Checks
- [ ] AC[n]: Given [..], when [..], then [..]
- [ ] Confirm assumption: [clarification]
- [ ] [User flow] completes successfully
```

## Step 3: Run Automated Checks

### 3.1 Build Verification

```bash
# For Xcode projects
xcodebuild -scheme [SchemeName] -destination 'platform=macOS' build 2>&1 | tail -20

# Check for build success
echo $?
```

### 3.2 Test Verification

```bash
# Run tests
xcodebuild test -scheme [SchemeName] -destination 'platform=macOS' 2>&1 | tail -30
```

### 3.3 File Existence

Use Glob/Grep to verify expected files exist:

```bash
ls -la [expected-file-path]
```

### 3.4 Code Quality Checks

- Check for TODO/FIXME comments that should be resolved
- Verify no hardcoded secrets or API keys
- Check for proper error handling

```
Grep: "TODO|FIXME|HACK" in project files
Grep: "password|secret|api_key" in project files (should be in config, not code)
```

### 3.5 Lint Gate (deterministic)

If the project has a `.swiftlint.yml`, the lint gate is a hard check, not a
suggestion:

```bash
# With a violations baseline (brownfield adoption — see swift/code-size):
swiftlint lint --strict --baseline .swiftlint-baseline.json
# Without one:
swiftlint lint --strict
```

PASS = exit 0 (zero non-baselined violations). Any violation is a real
failure — new code broke a rule existing code is held to. No config → skip
and record "Lint: —" in the report.

### 3.6 Coverage Gate (deterministic)

If the project has a coverage gate script and a committed baseline
(`Scripts/coverage-gate.sh` + `.coverage-baseline` — generated by
`testing/coverage-ratchet`), run it:

```bash
Scripts/coverage-gate.sh
```

PASS = exit 0 (app-target line coverage ≥ baseline − epsilon). A failure means
this phase shipped code without tests — that is exactly what the gate exists
to catch; add tests rather than lowering the baseline. If the script suggests
a ratchet-up, raise `.coverage-baseline` in this phase's final commit. Missing
script/baseline → skip, record "Coverage: —", and suggest adopting
`testing/coverage-ratchet`.

### 3.7 Fitness-Function & Snapshot Suites

Architecture fitness functions (import-boundary scans, network sentinels,
count/copy pins — see `testing/fitness-functions`) and snapshot suites
(pixel-diff visual regression — see `testing/snapshot-test-setup`) are
ordinary tests: they already ran inside 3.2, no separate invocation. Here,
confirm they exist where they should:

- Grep the test target for boundary/pin suites (e.g. suites scanning imports
  or pinning registry counts).
- If the project has hard rules (CLAUDE.md constraints, offline guarantees,
  module boundaries) with NO fitness-function suite enforcing them, flag the
  gap and suggest `testing/fitness-functions` — a hard rule enforced only by
  prose is a finding, not a preference.
- If this phase touched views, grep the test target for a snapshot suite
  covering the touched screens (`assertSnapshot` + `__Snapshots__/`
  baselines). A view-touching phase whose screens have no snapshot coverage
  is a flagged gap → suggest `testing/snapshot-test-setup` — compile + tests
  cannot see clipped, invisible, or crushed UI; only a pixel diff can.

### 3.7b Design-System Definition of Done (UI phases)

Run this when the phase created or changed SwiftUI view files. A phase can
compile, pass its tests and still add restyling debt, and that debt builds
up phase by phase unless each screen is checked when it ships. Rules come
from `~/.claude/swiftship-skills/design/design-system/SKILL.md`.

**Screens in scope:** view files the phase touched (`git diff --name-only`
over the phase's commits, filtered to files declaring a `View`). Check each
one:

| # | Check | How |
|---|-------|-----|
| 1 | Design lint clean, no exception for this file | Already run in 3.5. Additionally, the file must not appear in `.swiftlint-baseline.json` (`grep -c "<file>" .swiftlint-baseline.json` → 0). New screens never enter the baseline |
| 2 | Shared components only | No local re-implementation of a component listed in `.planning/UTILITIES.md` (a private `struct …Button`/`…Card` duplicating a shared one) |
| 3 | States via the shared state component | Screens that load data (`.task {`, `async` model calls, lists) render through `ContentStateView`, with no ad-hoc `ProgressView()` or "No results" `Text` |
| 4 | User-generated text keeps its case | No case transform applied to model/user strings (`.appText(….original)` for user text) |
| 5 | View file under ~300 lines | `wc -l`. Over 300 → ❌ with the sections to split |
| 6 | Previews for each state | Stateful screen: `#Preview`s for default/loading/empty/error + large Dynamic Type (iOS) / narrow + wide window (macOS) / smallest + largest watch (watchOS). Trivial view: one preview is enough |
| 7 | Identifiers, and tests use them | Interactive elements carry `accessibilityIdentifier`; this phase's UI tests locate by identifier (`app.buttons["editor.save"]`), not visible text |
| 8 | Matches the design | Optional: with a pinned frame (`.planning/design/phase-N/pinned/`, named in the task's `<action>`) or another exported PNG, compare a screenshot via `/apple:visual-qa`; otherwise ask in UAT. Compare against the **pinned** frame, not a newer export: newer changes are 3.7c's change requests |

**No design system yet** (no token file, no `ds_*` lint rules)? Checks 1–4
don't apply: record them as "—". Checks 5–8 still run, since they don't
depend on tokens.

**Outcome:** any ❌ becomes an Issue (Medium, or High for check 1 on a new
screen) with the file path, plus a fix task. It makes the phase **PARTIAL**,
not FAIL; a lint violation already fails the phase through 3.5. Under
`/apple:autonomous` a PARTIAL with DoD gaps stops the run, which is the
point: fix per phase, not at redesign time.

### 3.7c Design Changes Since Pin (UI phases with a pin)

Run this when PLAN.md has a `<design-pin>` (from `/apple:plan`). It answers
one question: did the design change after this phase was planned? Changes
are **change requests, not defects**: they never fail the phase and never
become fix tasks here (`design/design-system`, rule 21).

1. **Figma shortcut (optional).** If the pin has `figma-version-id` and
   `FIGMA_TOKEN` is set, fetch the latest version (same `curl … /versions`
   call as `/apple:plan`; never print the token). Same id → "Design
   unchanged since pin (Figma version history)", done. Different → note the
   named versions since the pin and continue to step 2 to find which screens.
2. **Get a fresh export.** Ask once: "Export the same frames again (same
   scale) to a folder, to compare with the pin?" with options **Folder**
   (path via Other) / **Skip: the design hasn't changed**. Under
   `/apple:autonomous`, use `.planning/design/phase-N/current/` if it exists,
   else skip and record "not checked".
3. **Compare** by file name and image hash:
   ```bash
   bash ~/.claude/swiftship-templates/_scripts/design-compare.sh N "<fresh export folder>"
   ```
   It prints one line per difference (`added`, `removed` or `changed`, then
   the frame name). No output means the design is unchanged. If the script
   is missing, SwiftShip is out of date: tell the user to update it
   (`claude plugin update apple@indie-apple-stack`, or `git pull` for a
   manual install). Don't retype the program from memory.
   **Every** screen changed usually means a different export scale or
   setting, not a redesign. Check that before reporting.
4. **Report** each added / removed / changed screen in VERIFICATION.md's
   "Design Changes Since Pin" table with both image paths for a side-by-side
   look. The hash says *that* a screen changed, not *what*; Read both PNGs and
   describe the visible difference in one line (layout, colour, type, copy,
   new element).

**Outcome:** no effect on PASS / PARTIAL / FAIL. Changed screens go to
the next phase or release as change requests (the user decides; suggest
`/apple:redesign` when many screens changed and it is installed). Don't
re-pin here; the next `/apple:plan` pins the new export for the next phase.

### 3.7d Tests Can Fail

"All tests pass" is weak proof if the tests would pass anyway. Two cheap
checks, every phase. (The `testing/mutation-testing` skill, with muter, is
the optional deep version; this is the small one.)

**1. Red then green.** Count the `<red-green>` lines `/apple:build` wrote in
PLAN.md: how many criterion tests failed before the code (`red` or
`no-build`) and pass now. A criterion with a test proof but no line is
`not recorded` (older builds); say so, it's not a failure. Any `before`
of `not proven` is listed with its reason.

**2. Planted bugs.** Pick the **1–2 riskiest** criteria with a test proof:
`must` features, anything that saves, deletes, syncs or charges money, and
`crash`/`high` bugs from RELEASE.md. For each:

1. Find the code that makes the criterion true, and choose one small break
   that should make it false: flip a condition, return early, skip the
   save, drop the error message.
2. Run the tests with that break planted in a throwaway copy of the
   committed code. Your working tree is never changed:
   ```bash
   bash ~/.claude/swiftship-templates/_scripts/expect-red.sh \
     --swap "<file>" '<exact original text>' '<broken text>' \
     -- <the test command from 3.2, with -derivedDataPath "${TMPDIR:-/tmp}/swiftship-red-dd">
   ```
   The original text must appear exactly once in the file; include
   surrounding lines if needed. If the script is missing, SwiftShip is out
   of date: tell the user to update it, and skip this check.
3. Read the result:
   - `RED`: **caught**, a test noticed the bug.
   - `GREEN`: **missed**. The tests are too weak for that criterion. Add an
     issue (Medium; High when the criterion protects user data) with a fix
     task: "Add a test that fails when [the break you planted]".
   - `NO-BUILD`: the break didn't compile, which proves nothing. Choose a
     different break (at most 2 tries), else record `not run`.
   - `SETUP`: fix the command or text and rerun; else record `not run`.
4. Afterwards confirm `git status --porcelain` shows nothing new. A planted
   bug must never be left behind.

The check runs against the **last commit**; if `git status` shows
uncommitted code changes, say "checked against the last commit". Criteria
proven only by a flow, lint rule or manual check are skipped; list them as
"not checked (no test)" in the report.

## Step 3.8: Optional handoff — run the app and screenshot

Before relying on the user's memory in the manual UAT below, try to **show the
running app**. Apply `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`
with the procedure in
`~/.claude/swiftship-templates/_conventions/RUN-AND-SHOT.md`:

- **DETECT:** iOS → does `~/.claude/swiftship-skills/ios/run-simulator/SKILL.md`
  exist (detect by path, per RUN-AND-SHOT)? macOS → are `xcodebuild`
  + `screencapture` available? If neither path is available, **skip to Step 4**
  (the manual walk-through is the fallback).
- **CONFIRM** (a build can be slow): "Run & screenshot the app now? / Skip — I'll
  check manually."
- **ACT:** run the platform path, capture, and **Read the screenshot back**. Feed
  what it shows into the UAT questions below (e.g. confirm the changed screen
  renders) instead of asking the user from memory.
- **FALL BACK:** on any build/launch/capture failure, note it and continue to the
  manual walk-through unchanged.

## Step 4: Manual Verification (UAT)

Walk the user through manual checks ONE AT A TIME.

For each manual check:

1. **Describe what to verify:**
   ```
   Please verify: [Feature X]

   Expected behavior:
   - [Step 1]
   - [Step 2]
   - [Expected result]
   ```

2. **Ask for result:**
   Use AskUserQuestion with options:
   - "Pass - Works as expected"
   - "Fail - Doesn't work"
   - "Partial - Works but has issues"
   - "Skip - Can't test right now"

3. **If Fail or Partial:**
   - Ask user to describe the issue
   - Log the failure details
   - Create a fix task

### Manual Check Categories

**UI/UX Verification:**
- Views render correctly
- Navigation works
- Dark mode support
- Dynamic type support
- Accessibility (VoiceOver)

**Functionality Verification:**
- Core features work
- Data persists correctly
- Edge cases handled
- Error states shown properly

**Platform Integration:**
- Widgets display correctly (if applicable)
- Shortcuts work (if applicable)
- Notifications arrive (if applicable)

## Step 5: Diagnose Failures

For any failed checks:

1. **Identify the failure type:**
   - Build error → Check compiler output
   - Test failure → Check test logs
   - Runtime error → Check console logs
   - UI issue → Check view hierarchy

2. **Find root cause:**
   - Read relevant source files
   - Check recent changes
   - Look for related issues

3. **Create fix task:**
   ```markdown
   ### Fix Required: [Issue Title]

   **Failure:** [What failed]
   **Expected:** [What should happen]
   **Actual:** [What happened]
   **Root Cause:** [Why it failed]
   **Fix:** [How to fix it]
   **Files:** [Which files to modify]
   ```

## Step 6: Generate Verification Report

**Wording:** write the report's top ("In plain words") and each issue's title per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.

Create `.planning/VERIFICATION.md`:

```markdown
# Verification Report - Phase [N]

**Date:** [date]
**Status:** [PASS / FAIL / PARTIAL]

**In plain words:** [One or two sentences: does the phase work, what's missing, and whether you need to do anything.]

## Summary

- **Spec coverage:** X of Y features proven ([n] gaps, [n] unproven)
- **Automated Checks:** X/Y passed
- **Manual Checks:** X/Y passed
- **Issues Found:** X
- **Fixes Required:** X

## Automated Checks

| Check | Status | Notes |
|-------|--------|-------|
| Build | ✅/❌ | [notes] |
| Tests | ✅/❌ | [notes] |
| Files exist | ✅/❌ | [notes] |
| Code quality | ✅/❌ | [notes] |
| Lint | ✅/❌/— | [— if no .swiftlint.yml] |
| Coverage | ✅/❌/— | [— if no .coverage-baseline; note ratchet-up suggestions] |
| Design DoD | ✅/❌/— | [n of m screens pass; — if the phase touched no views] |
| Tests can fail | ✅/❌/— | [n of m red then green; planted bugs n of m caught; — if no criterion tests] |

## Design-System Definition of Done (UI phases)

| Screen (file) | Lint | Shared | States | Case | <300 | Previews | IDs | Design |
|---------------|------|--------|--------|------|------|----------|-----|--------|
| [ProfileView.swift] | ✅ | ✅ | ❌ ad-hoc ProgressView | ✅ | ✅ 212 | ⚠️ no error preview | ✅ | — |

## Design Changes Since Pin

[No pin | Unchanged (Figma version history) | Not checked | n added, n removed, n changed]

| Screen | Change | Pinned | New export | What changed |
|--------|--------|--------|------------|--------------|
| [Profile Edit.png] | changed | .planning/design/phase-N/pinned/… | [export]/… | [one line] |

Change requests, not defects: [next phase | next release | /apple:redesign]

## Spec Coverage

Every promise in the spec, what checks it, and whether it held. Written
from APP.md / RELEASE.md before reading the plan.

| Feature (spec) | Criterion | Proof | Result |
|----------------|-----------|-------|--------|
| [Offline notes] | AC3: Given no internet, when Save is tapped, then the note stays and "Saved offline" shows | test `NotesTests.testOfflineSave` | ✅ Passed |
| [Offline notes] | ⚠️ none: what happens when the same note changed on two devices? | — | ❌ Gap in the plan |
| [Export] | AC5: … | manual | ⚠️ Not run |

**Assumptions to confirm:** [list from `<spec-clarifications source="assumed">` | none]

## Tests Can Fail

[12 of 12] criterion tests failed before the code was written and pass now.
Planted bugs: [2 of 2] caught.

| Criterion | Planted bug | Result |
|-----------|-------------|--------|
| [AC3 Offline save] | [skipped the save in NoteStore.save()] | ✅ Caught by [NotesTests.testOfflineSave] |
| [AC5 Delete] | [returned early from delete] | ❌ Missed: no test noticed |

[Not checked (no test): AC1, AC2 (checked by walkthrough)]

## Manual Checks (UAT)

| Feature | Status | Notes |
|---------|--------|-------|
| [Feature 1] | ✅/❌/⚠️ | [notes] |
| [Feature 2] | ✅/❌/⚠️ | [notes] |

## Issues Found

### Issue 1: [Title]
- **Severity:** Critical / High / Medium / Low
- **Description:** [What's wrong]
- **Root Cause:** [Why]
- **Fix:** [How to fix]

## Fix Tasks

If issues were found, these tasks need to be completed:

1. [ ] [Fix task 1]
2. [ ] [Fix task 2]

## Verification Result

**[PASS]** - All checks passed. Ready to proceed to next phase.

OR

**[FAIL]** - Issues found. Run `/apple:build` to fix issues, then `/apple:verify` again.

OR

**[PARTIAL]** - Some checks passed. Review issues and decide whether to proceed.

---
*Generated by SwiftShip /apple:verify*
```

## Step 6b: Write the Review Guide

Everything a person needs to decide "is this good to keep?" is spread
across VERIFICATION.md, REVIEW.md, PLAN.md and git. Put it on one page:
`.planning/REVIEW-GUIDE.md`, from the template:
```
Read: ~/.claude/swiftship-templates/REVIEW-GUIDE.md
```
Replace the previous phase's guide (git keeps it). Fill it, in this order,
only from what already exists:

1. **What changed:** two plain sentences on what someone using the app
   will notice, and which screens or features. Count files and commits
   from this phase's task commits (`Completed task` in the message).
2. **Choices the agents made:** the `<decision>` lines in PLAN.md (chose /
   instead of / why). None → "None: the plan decided everything."
3. **Proof:** spec coverage (Step 2), tests that can fail (3.7d), lint and
   coverage (3.5, 3.6), design since the pin (3.7c). One line each, in
   plain numbers.
4. **Problems found:** this phase's `.planning/REVIEW.md` counts by
   severity, how many were thrown out after a second check (its "Refuted"
   appendix), and one plain line per Critical/High with what happened to it.
   No REVIEW.md for this phase → "Code review not run yet: `/apple:review`".
5. **What only you can decide**, as checkboxes: open questions, `source="assumed"`
   spec answers to confirm, gaps and missed planted bugs that need a call,
   and checks that need a person (`NOT RUN (unattended)`, `Skip`ped UAT).
   Nothing → "Nothing for you to decide."
6. **Links** to every file and commit mentioned.

Rules: write per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md`
(the guide is always plain, even with `reader: technical`, since it exists
for a person deciding); at most one screen (about 40 lines) before the
links; detail stays in the linked reports. If the template is absent, skip
this step.

## Step 7: Update State

In `.planning/STATE.md`, set this phase's `Verified` cell under
`## Phase Verification` to `PASS [date]`, `PARTIAL [date]`, or `FAIL [date]`
(add the section and row from the STATE template if missing; leave `Built`
as is, or fill it with today's date if empty).

If all checks pass:
- Update phase status to "completed"

If checks fail:
- Keep phase status as "in_progress"
- Add blocker noting verification failed

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent).

**Wording:** write the completion message per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.

```
Verification complete!

[One plain sentence: does it work, and is there anything you need to do?]

Status: [PASS / FAIL / PARTIAL] ([everything works | works, with gaps listed below | something important is broken])

Results:
- Promised features proven: X of Y [(n not covered by any check)]
- Tests that can fail: [n of m failed before the code; planted bugs n of m caught]
- Automated: X/Y passed
- Manual: X/Y passed
- Issues: X found
- Design since pin: [unchanged | n changed (change requests) | — ]

Created: .planning/VERIFICATION.md
Read first: .planning/REVIEW-GUIDE.md (one page: what changed, the proof, what you need to decide)

Next steps:
- If PASS: Run /apple:review for code quality review
- If FAIL: Fix issues and run /apple:verify again
- If PARTIAL: Review issues and decide next action

You need to decide: [short list | Nothing for you to decide.]
```

## Workflow Integration

```
/apple:plan [N]   → Create tasks for phase
/apple:build      → Implement tasks
/apple:verify     → Verify deliverables (YOU ARE HERE)
/apple:review     → Code/HIG/App Store review
```

**Difference from /apple:review:**
- `/apple:verify` - Checks that work is DONE (deliverables exist and work)
- `/apple:review` - Checks that work is GOOD (code quality, HIG, guidelines)
