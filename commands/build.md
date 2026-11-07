---
description: Execute current plan using specialized agents
allowed-tools: Read, Write, Edit, Bash, Task, Glob, Grep, AskUserQuestion, Skill, mcp__asc-metadata__list_apps, mcp__asc-metadata__list_beta_groups, mcp__asc-metadata__list_iap
model: sonnet
---

# Execute Build Plan

Execute pending tasks from `.planning/PLAN.md` using specialized agents.

**Model check (execution tier):** this command pins `model: sonnet` in its
frontmatter — the turn runs on Sonnet and the session model returns on the
next user prompt (see
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md`). If your system
prompt still names a premium model, the pin didn't apply. The usual cause is
**Skill-tool routing**: when this command reaches you through the Skill tool
(Claude invoking it, or a harness that routes typed commands through Skill),
the body executes inside the already-running turn — no frontmatter can switch
a turn in flight. Stale installs and org model allowlists are the rarer
causes (`./install.sh` refreshes symlink installs; it cannot fix routing).
Note once that `/model sonnet` before execution-heavy stretches costs nothing
in quality here (agents are pinned regardless), then continue. Skip silently
if the convention file is absent.

## Prerequisites

Read required files:
```
Read: .planning/APP.md
Read: .planning/PLAN.md
Read: .planning/STATE.md
```

Also read implementation preferences if they exist (created by `/apple:discuss`):
```
Read: .planning/PREFERENCES.md   # Optional — apply if present
```

If `PREFERENCES.md` exists, carry its choices (architecture/state pattern,
async approach, error-handling style, component style, project structure) into
every agent prompt you spawn below, so generated code matches the decisions the
user already made. Preferences override agent defaults wherever they conflict.

Also read the existing-helpers inventory if it exists (written by `/apple:map`,
grown by this command):
```
Read: .planning/UTILITIES.md     # Optional — pass to every agent if present
```
Agents rebuild helpers that already exist (a second formatter, hand-formatted
prices, a parallel networking wrapper) — duplication that inflates diffs and
splits behavior. Every spawn below gets this list with a reuse rule.

Also read the critical-paths list if it exists (seeded by `/apple:new-app` /
`/apple:map`, edited by the user):
```
Read: .planning/CRITICAL.md      # Optional — drives the Step 4c pause
```
If absent, Step 4c is skipped and nothing else changes.

Also read the design system if the project has one (written by
`/apple:design-system`):
```
Read: .planning/DESIGN-SYSTEM.md # Optional — token map, text styles, components, lint status
```
The project **has a design system** when this file exists **or**
`.swiftlint.yml` contains the `ds_*` rules. Then UI spawns get a
`<design-system>` block, and every view-touching task gets the design lint
gate in Step 4. Without one, nothing changes.

## Execution Process

### 1. Find Next Pending Task

Parse PLAN.md and find the first task with `status="pending"`.

**Unsettled second opinion (ask once, before the first task).** If any
pending task has `<second-opinion verdict="plan-worse" resolved="pending">`
(plan ran under `/apple:autonomous`), ask about all of them in one
`AskUserQuestion` call before building anything, exactly as `/apple:plan`
*Second opinion* step 4 does, and update the task. When building a task with
`<options>`, include them in the agent prompt so it builds the chosen option
and doesn't drift to a rejected one.

If no pending tasks:
```
✅ All tasks in current phase are complete!

Next steps:
- Run /apple:verify to confirm the deliverables actually work (build, tests, UAT)
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

Match task to appropriate agent and spawn. Agent names below are bare
(symlink/vendored installs); **plugin installs namespace them** — if a bare
name errors "Agent type not found", retry as `apple:<name>`
(e.g. `apple:swift-generalist`) before applying the degraded-mode guard:

| Task Content | Agent | Skills Reference |
|-------------|-------|-----------------|
| SwiftUI views, UI | swiftui-builder | `ios/ui-review`, `macos/ui-review-tahoe` |
| StoreKit, purchases | storekit-expert | `monetization/`, `generators/paywall-generator` |
| Pricing strategy, monetization model, revenue | swift-generalist | `monetization/` (SKILL.md, pricing-models.md, app-type-guides.md) |
| CloudKit, sync | cloudkit-expert | iCloud sync patterns |
| Data models, persistence | swift-generalist | `macos/swiftdata-architecture` |
| Navigation, architecture | swift-generalist | `ios/navigation-patterns`, `macos/architecture-patterns` |
| Apple Intelligence, Siri, App Intents | swift-generalist | `apple-intelligence/` |
| watchOS, complications, Watch Connectivity | swift-generalist | `watchos/` |
| visionOS: windows, volumes, immersive spaces, spatial UI | swiftui-builder | `visionos/spatial-design`, `visionos/widgets` |
| Liquid Glass, animations, transitions | swiftui-builder | `design/animation-patterns`, `design/liquid-glass` |
| Screen structure, navigation clarity, empty states | swiftui-builder | — (evergreen UX principles: native model knowledge) |
| User-facing copy: labels, alerts, onboarding text, feature names | swiftui-builder | `design/ux-writing` |
| Iconography, custom symbols | swiftui-builder | `design/sf-symbols` |
| Fonts, type hierarchy, Dynamic Type | swiftui-builder | `design/typography` |
| Design tokens, text styles, shared components, restyling screens, design-system setup or migration | swiftui-builder | `design/design-system`, `design/typography` |
| State management, Observation, @State/@Bindable choices | swiftui-builder | `swiftui/data-flow` |
| Custom layouts, containers, lazy stacks, scroll performance | swiftui-builder | `swiftui/layout` |
| AlarmKit, Charts, WebKit integration | swiftui-builder | `swiftui/alarmkit`, `swiftui/charts-3d`, `swiftui/webkit` |
| MapKit, location, geolocation | swift-generalist | `mapkit/geotoolbox` |
| AppKit bridging, NSViewRepresentable | swift-generalist | `macos/appkit-swiftui-bridge` |
| Swift concurrency, actors, Sendable, async/await | swift-generalist | `swift/concurrency-patterns`, `swift/concurrency` |
| SwiftData hierarchies, inheritance | swift-generalist | `swiftdata/inheritance` |
| Foundation Models, on-device LLM, AI generation | swift-generalist | `apple-intelligence/foundation-models` |
| Visual Intelligence, image analysis, camera AI | swift-generalist | `apple-intelligence/visual-intelligence` |
| Text editing, rich text, styled text | swiftui-builder | `swiftui/text-editing` |
| Toolbars, toolbar customization | swiftui-builder | `swiftui/toolbars` |
| macOS Tahoe, Liquid Glass, new macOS APIs | swiftui-builder | `macos/macos-tahoe-apis` |
| Memory management, retain cycles, leaks | swift-generalist | `swift/memory` |
| HTTP caching, offline fallback, conditional requests | swift-generalist | `generators/http-cache` |
| Image loading, image caching, AsyncImage replacement | swiftui-builder | `generators/image-loading` |
| Pagination, infinite scroll, load more | swift-generalist | `generators/pagination` |
| Migration, version upgrade, breaking changes | swift-generalist | `ios/migration-patterns` |
| Unit tests, integration tests, test infrastructure | swift-generalist | `testing/tdd-feature`, `testing/test-data-factory`, `testing/integration-test-scaffold` |
| Snapshot tests, visual regression, UI tests | swiftui-builder | `testing/snapshot-test-setup` |
| Test contracts, protocol tests | swift-generalist | `testing/test-contract` |
| Rich text, AttributedString | swift-generalist | `foundation/attributed-string` |
| iPad layouts, sidebar, Stage Manager | swiftui-builder | `ios/ipad-patterns` |
| macOS windows, menus, entitlements | swift-generalist | `macos/macos-capabilities` |
| Consent flow, GDPR, privacy consent | swift-generalist | `generators/consent-flow` |
| Force update, version gating, mandatory update | swift-generalist | `generators/force-update` |
| Permission priming, pre-permission, permission request | swiftui-builder | `generators/permission-priming` |
| Account deletion, delete account, user removal | swift-generalist | `generators/account-deletion` |
| App Clip, clip experience, instant app | swift-generalist | `generators/app-clip` |
| Offline queue, pending actions, retry queue | swift-generalist | `generators/offline-queue` |
| Spotlight, search indexing, CSSearchableItem | swift-generalist | `generators/spotlight-indexing` |
| State restoration, scene restoration, NSUserActivity | swift-generalist | `generators/state-restoration` |
| Streak tracking, daily streak, habit tracking | swift-generalist | `generators/streak-tracker` |
| Announcement banner, in-app banner, promo banner | swiftui-builder | `generators/announcement-banner` |
| Feedback form, bug report, user feedback | swiftui-builder | `generators/feedback-form` |
| Lapsed user, re-engagement, win-back | swift-generalist | `generators/lapsed-user` |
| Milestone celebration, achievement, confetti | swiftui-builder | `generators/milestone-celebration` |
| Share card, share sheet, shareable image | swiftui-builder | `generators/share-card` |
| Social export, social media sharing | swift-generalist | `generators/social-export` |
| Usage insights, usage stats, activity summary | swiftui-builder | `generators/usage-insights` |
| Watermark, branded export, image watermark | swift-generalist | `generators/watermark-engine` |
| Quick win, short session, quick engagement | swiftui-builder | `generators/quick-win-session` |
| Referral, invite friends, referral program | swift-generalist | `generators/referral-system` |
| Subscription lifecycle, renewal, grace period, billing | storekit-expert | `generators/subscription-lifecycle` |
| Variable rewards, gamification, reward schedule | swift-generalist | `generators/variable-rewards` |
| Debug menu, developer settings, internal tools | swift-generalist | `generators/debug-menu` |
| Screenshot automation, snapshot testing, marketing screenshots | swift-generalist | `generators/screenshot-automation` |
| What's new, release notes, version changelog | swiftui-builder | `generators/whats-new` |
| Preview data, sample data, `#Preview` matrix, canvas/prototype data | swiftui-builder | `generators/preview-data-generator` |
| Core ML, machine learning, Vision framework, NaturalLanguage | swift-generalist | `core-ml/` |
| App Store assets, marketing screenshots, preview video, event cards | swift-generalist | `generators/app-store-assets` |
| Custom product pages, variant pages, audience targeting | swift-generalist | `generators/custom-product-pages` |
| Featuring nomination, Apple editorial, App Store featuring | swift-generalist | `generators/featuring-nomination` |
| In-app events, seasonal events, live events, event metadata | swift-generalist | `generators/in-app-events` |
| Product page optimization, A/B test screenshots, conversion | swift-generalist | `generators/product-page-optimization` |
| Offer codes, promo codes, redemption codes | storekit-expert | `generators/offer-codes-setup` |
| Pre-order, launch countdown, pre-release | swift-generalist | `generators/pre-orders` |
| Promoted IAP, in-app purchase display, product page purchases | storekit-expert | `generators/promoted-iap` |
| Subscription offers, introductory offer, promo offer | storekit-expert | `generators/subscription-offers` |
| Win-back offers, churned subscriber, lapsed subscription | storekit-expert | `generators/win-back-offers` |
| App extensions, share extension, action extension, keyboard extension | swift-generalist | `generators/app-extensions` |
| Background processing, BGTaskScheduler, background download | swift-generalist | `generators/background-processing` |
| Data export, CSV export, PDF export, GDPR data portability | swift-generalist | `generators/data-export` |
| Visual QA, UI audit, HIG review | swift-generalist | `ios/ui-review`, `macos/ui-review-tahoe` |
| Accessibility audit, VoiceOver support, Dynamic Type, Nutrition Labels | swift-generalist | `ios/accessibility-audit` (full audit: `/apple:accessibility`) |
| Accessibility fixes — labels, traits, custom actions, rotors, adjustable controls | swift-generalist | `generators/accessibility-generator` |
| **Anything else — no row above matches** (project setup, scaffolding, configuration, one-off scripts, …) | swift-generalist | — |

**Never spawn the built-in `general-purpose` agent.** It has no pinned model and
silently inherits the session model — Opus/Fable rates for Sonnet-grade work.
`swift-generalist` is the same breadth with `model: sonnet` enforced; it is the
fallback for every task, not just the rows above. This applies to every agent
spawn in this command, including verification and fix-up passes.

**If the agents are unavailable in this environment** (spawn fails — common in
cloud/remote sessions without `~/.claude/agents/` or vendored
`.claude/agents/`, or right after vendoring: definitions load at session
start): apply the degraded-mode guard in
`~/.claude/swiftship-templates/_conventions/AGENT-VENDORING.md` — tell the
user the pin is lost (tasks would run inline at session-model rates), ask
before proceeding, and log the outcome with `"degraded":"no-agents"`.
Substituting `general-purpose` for the named agents counts as degraded even
with per-call `model` overrides — keep the overrides if proceeding (they
preserve the cost pin and any `model="opus"` task tags), but the run must
still be asked-about and logged degraded.

**Visual QA tasks:** When a task named "Visual QA Audit" is encountered, execute the `/apple:visual-qa` skill in code-only mode. Run all 6 Grep-based scans (hardcoded colors, fixed fonts, missing accessibility, small touch targets, missing view states, rigid frames), fix all Critical/High issues, and generate `.planning/VISUAL-QA.md`.

**Before executing each task:** Load the referenced skill from `~/.claude/swiftship-skills/[skills-reference]/SKILL.md` and include its patterns in the agent prompt context.

**Per-task model override:** if the task XML carries `model="opus"` (set by
`/apple:plan` on at most 1–2 foundation tasks per phase), pass it through as
the spawn's `model` parameter — it overrides the agent's Sonnet frontmatter
for that spawn only. Absent attribute → omit the parameter entirely (the pin
applies). Never pass any other value, and never inherit the session model. If
the escalated spawn fails (older harness, model unavailable), retry once
without the parameter — the override must never block a task. Count escalated
spawns separately for the ledger (see Completion).

Spawn agent with context:

```
Task({
  subagent_type: "[matched-agent]",
  model: "opus",   // only when the task XML has model="opus" — omit otherwise
  prompt: `
    You are executing a task for an Apple app.

    <app-context>
      App: [name from APP.md]
      Platform: [from APP.md]
      Min OS: [from APP.md]
    </app-context>

    <preferences>
      [Relevant choices from PREFERENCES.md if it exists — architecture,
       state pattern, async approach, error handling, structure. Omit if none.]
    </preferences>

    <task>
      [Full task XML from PLAN.md]
    </task>

    <existing-code>
      [Relevant existing files if any]
    </existing-code>

    <existing-helpers>
      [Contents of .planning/UTILITIES.md if it exists. Omit if none.]
    </existing-helpers>

    <folder-rules>
      [The "## Folder Rules" table from .planning/CODEBASE.md, if it has
       one. Omit otherwise.]
    </folder-rules>

    <design-system>
      [UI tasks only, when the project has one: the token map, text styles
       and component list from .planning/DESIGN-SYSTEM.md. Omit otherwise.]
    </design-system>

    Requirements:
    1. Follow the <apple-patterns> specified
    2. Create/modify files listed in <files>
    3. Verify all <verify> checks pass
    4. Meet all <done> criteria, and every <criteria> Given/When/Then:
       write each test named in a <proof type="test"> in this task, with
       that name, testing the behavior from outside (on screen for
       via="screen", public functions for via="package").
       **Red first:** write those tests before the code, run them, and see
       them fail. A test that already passes checks nothing; rewrite it.
       Then write the code until they pass.
    5. Reuse <existing-helpers> — never reimplement a listed helper. If none
       fits, say so in your report before adding a new shared one.
    6. If <design-system> is present: tokens and .appText only, the listed
       components (states through ContentStateView), accessibilityIdentifier
       on interactive elements, view files under ~300 lines. A missing token
       goes into the token file and is reported, never inlined.
    7. If <folder-rules> is present: put code in the folder whose rules
       allow it, and never add a file to a rule's known exceptions. If the
       task can't be done without breaking a rule, stop and report it
       instead of working around it.

    After completing, report:
    - Files created/modified
    - Test files written for <criteria> (paths), and the test command that runs them by name
    - Choices you made that the task didn't specify, each as: chose X,
      instead of Y, because Z (e.g. "stored drafts in SwiftData instead of
      files, because sync needs it"). Only real choices; none is fine.
    - Verification results
    - New shared helpers added (name, path, one-line purpose), if any
    - Any issues encountered
  `
})
```

#### For `type="generator"` Tasks:

Invoke the specified generator skill:

```
Load skill from: ~/.claude/swiftship-skills/generators/[generator-name]/

Apply customizations from <customization> tag.
```

Generator tasks are verified exactly like `auto` tasks: after the skill has
been applied, run Step 4 — the baseline `build` check plus any `<check>`s the
task declares. Generators drop in more code per task than most agent spawns
do; generated code that doesn't compile is not done.

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

**After "done", probe what a probe can reach.** A manual task's `<done>`
criteria are often machine-checkable read-only. Before marking the task
completed, verify each criterion you can, per
`~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md` (DETECT silently;
reads run without a confirmation prompt):

- Filesystem / project / git criteria → check directly (`ls`, `git tag`,
  `xcodebuild -list`, …).
- App Store Connect criteria → when the matching read-only tool is detected:
  app record exists → `mcp__asc-metadata__list_apps`; beta/testing group →
  `mcp__asc-metadata__list_beta_groups`; IAP configured →
  `mcp__asc-metadata__list_iap`.
- No probe available → accept the confirmation (the existing behavior). Never
  block a manual task on a missing tool.

If a probe **contradicts** the "done" (e.g. no beta group exists yet), don't
mark the task completed — show what the probe found next to the criterion,
re-display the task instructions, and wait again. Never silently accept a
claim a tool just refuted.

### 4. Verify Task Completion

**Run the checks yourself.** The agent's completion report is a claim, not
evidence — the same agent that wrote the code is grading its own work. After
the spawn returns, execute every `<verify>` check directly and record what
YOUR runs showed. Never copy the agent's reported ✅s into the progress
report, and never mark a task completed on the strength of its report alone.

For each `<check>` in `<verify>`:

| Check Type | Verification (run by you, not the agent) |
|------------|------------------------------------------|
| `build` | Run `xcodebuild build` / `swift build`; require success, surface `error:` lines |
| `preview` | Covered by the `build` check — previews are compiled code; no separate run |
| `simulator` | Rendered-frame check via RUN-AND-SHOT (below); fall back to asking the user |
| `test` | Run `swift test` / `xcodebuild test`; require 0 failures |
| `lint` | Run `swiftlint lint --strict` (with `--baseline .swiftlint-baseline.json` if one exists); require zero non-baselined violations |
| `coverage` | Run `Scripts/coverage-gate.sh`; require exit 0 (app-target line coverage ≥ committed `.coverage-baseline` − epsilon) |
| `design` | For each view file the task touched: under ~300 lines (`wc -l`); a stateful screen has `#Preview`s for its states plus the platform size variant; interactive elements carry `accessibilityIdentifier`; a **new** file does not appear in `.swiftlint-baseline.json`. Any miss = FAIL with the file and item |
| `snapshot` | Run the snapshot suite scoped to the task's touched screens (`-only-testing:<Tests>/<SnapshotSuite>`); a pixel diff is a FAIL, not a discussion — re-record baselines only with the intent stated in the commit |

**Baseline check:** run the `build` check after **every** `auto` and
`generator` task, even when its `<verify>` block omits it (or is missing
entirely — older plans). A task that doesn't compile is never complete.

**Design lint gate** (projects with a design system, every task whose
changed files include views, even when `<verify>` omits it, as with the
build check): lint the **whole tree** with the baseline, then keep only
the touched files' lines,
```bash
swiftlint lint --strict --quiet [--baseline .swiftlint-baseline.json] \
  | grep -E '(<touched-file-1>|<touched-file-2>):'
```
and require **no output** (zero violations in new code). Don't pass the
files as path arguments: SwiftLint then fails to match them against the
baseline (stored paths differ), and baselined legacy violations show up as
new. Then confirm the baseline did
not grow: `git diff --stat -- .swiftlint-baseline.json` must show no change,
or only removals. Re-writing the baseline to absorb new violations is a
FAIL, never a fix. On watchOS and macOS targets the same rules apply; only
the `design` check's preview variants differ.

**Rendered-frame check** (`simulator` checks, and any task whose `<files>`
touch views or layout): "it compiles" says nothing about what's on screen —
clipped text, invisible cards, and crushed layouts all compile cleanly. Apply
`~/.claude/swiftship-templates/_conventions/RUN-AND-SHOT.md`: build → launch →
screenshot → **Read the image back** and judge it (blank, crashed, or
launch-stuck frame = FAIL). If neither the `run-simulator` skill nor the macOS
path is available, fall back to asking the user to confirm in the Simulator —
and record the check as *user-confirmed*, not *verified*.

**Red-then-green check** (tasks whose `<criteria>` name a
`<proof type="test">`; skip otherwise). Coverage only shows that lines ran,
not that anything was checked, and an agent can write a test that passes no
matter what. So prove each criterion test can fail:

1. **Green:** run the named tests **by name** (`-only-testing:<Target>/<Class>/<method>`
   or `swift test --filter`) on the finished code. They must run (not "0
   tests") and pass. A test that was never written can't hide in a suite total.
2. **Red:** run the same command against the code as it was *before* this
   task, with only the test files copied in. HEAD is still the pre-task
   commit (the task commits in Step 5), and your working tree is never
   touched; the run happens in a throwaway copy:
   ```bash
   bash ~/.claude/swiftship-templates/_scripts/expect-red.sh \
     --copy "<test file>" [--copy "<test file 2>"] \
     [--copy "<App>.xcodeproj/project.pbxproj"]  \
     -- <the same test command, plus -derivedDataPath "${TMPDIR:-/tmp}/swiftship-red-dd">
   ```
   Copy the project file only when new test files aren't in a synchronized
   folder (Xcode 16+ folders need no project change). The shared
   `-derivedDataPath` lets later tasks reuse the build cache; the first run
   builds from scratch and is the slow one.

   | Result | Meaning | Do |
   |--------|---------|----|
   | `RED` (exit 0) | the tests fail without the code | proven |
   | `NO-BUILD` (exit 3) | the tests need the new code to even compile (a brand-new type) | proven |
   | `GREEN` (exit 1) | the tests pass **without** the code: they check nothing | send back to the agent once, with the criterion, to rewrite them; still green → FAIL the task |
   | `SETUP` (exit 2) | wrong test names, or no tests ran | fix the command and rerun; if it still can't run, record `not proven` with the reason (not a failure) |

   If the script is missing, SwiftShip is out of date: tell the user to
   update it (`claude plugin update apple@indie-apple-stack`, or `git pull`
   for a manual install). Don't retype the program from memory.
3. **Record** one line per test inside the task in PLAN.md, after `<done>`:
   ```xml
   <red-green criterion="AC3" test="NotesTests/testOfflineSave" before="red|no-build|not proven: [reason]" after="green"/>
   ```
   `/apple:verify` counts these lines.

**Record the agent's choices.** For each choice the agent reported, add a
line inside the task in PLAN.md, after any `<red-green>` lines:
```xml
<decision chose="SwiftData for drafts" instead-of="files on disk" why="sync needs it"/>
```
`/apple:verify` puts them in the phase's review guide, so a person sees what
was decided without reading the code. A choice that shapes later phases
(storage, architecture, a dependency) also goes into STATE.md's
`## Key Decisions Made`.

Only when every check passes does the task move to Step 4b. A failing check
follows Error Handling below — the agent's claim of success never overrides
what your run showed.

### 4b. Diff-Size Check (simplicity guard)

Agents write roughly twice the code a requirement needs — speculative
abstractions, defensive handling for cases that can't happen — and every extra
line is review and maintenance load. Before committing, size the diff against
the task's scope:

```bash
git diff --stat                                   # tracked changes
git status --porcelain | grep '^??'               # new files (count their lines with wc -l)
```

**Flag the task when any of these hold:**
- **Out of scope** — the agent changed a file not in the task's `<files>` and
  its report doesn't explain why the task required it.
- **Oversized** — more than ~300 changed lines, or any single file growing by
  more than ~150, for a task whose `<action>` describes a small change (one
  view, one model, one fix). Use judgment: a full screen or a data layer can
  legitimately be large.
- **Speculative structure** — a new protocol with a single conformer, a
  generic/abstraction with one caller, or a new helper duplicating one in
  `.planning/UTILITIES.md`.

**`generator` tasks are exempt** — generators drop in a known, larger amount of
code by design.

**If flagged:** run **one** simplify pass — re-spawn the same agent with the
current diff and: *"Reduce this to the simplest change that meets `<done>`.
Remove abstractions with one use, defensive handling for unrealistic cases,
dead or speculative code, and changes outside `<files>` that the task doesn't
need. Do not change behavior. Re-run `<verify>`."* Then re-run the task's
`<verify>` checks yourself (Step 4). Keep the simplified version only if the
checks pass; otherwise keep the original. Never loop — one pass, then commit.
Note the before/after line counts in the progress report:
`✂️ Simplified: [before] → [after] lines`. If not flagged, continue silently.

### 4c. Critical-Path Pause (only if `.planning/CRITICAL.md` exists)

Some code the developer must understand, not just accept — payments, sync,
migrations, user-data handling. Hand those off unread and the first real bug
lands in code nobody on the project can reason about.

Match this task's **actually changed files** (the Step 4b list, after any
simplify pass — not just the planned `<files>`) against the globs in
CRITICAL.md's Paths column. No match → continue silently to Step 5.

On a match, **stop before committing**, even inside `/apple:autonomous` and
even with `--yes` — this is a safety pause, like a manual task:

```
🔒 Critical path changed — [Area] ([why it matters, from CRITICAL.md])

Task [id]: [name]
Files: [matching files]   (verify: ✅ passed)

[git diff -- <matching files>, plus `git diff --stat` for the rest of the task]
```

Then `AskUserQuestion` — **Approve & commit** / **Request changes** (the user
says what; re-spawn the same agent with it, re-run Step 4 → 4b → 4c) /
**Stop** (leave the changes uncommitted, task stays `in_progress`, note it
under Blockers in STATE.md). Never commit a critical-path change without the
explicit approve.

### 5. Update Status

On successful completion:

1. Update PLAN.md: `status="completed"`

2. Update STATE.md:
   - Clear Current Task
   - Add to Session History

2b. Keep the helpers inventory current: if the agent reported **new shared
    helpers** (or the task obviously added one — a formatter, client,
    design-token file, shared modifier), append a row per helper to
    `.planning/UTILITIES.md` (create it from
    `~/.claude/swiftship-templates/UTILITIES.md` if absent — greenfield
    projects grow it this way). Skip one-off private helpers. Include the
    file in this task's commit.

3. Commit changes — **stage only what this task owns, never `git add -A`**
   (a blanket add sweeps stray scratch files, unignored build artefacts,
   local secrets, and the user's unrelated in-progress edits into the task
   commit):

   a. The commit set is: the task's `<files>`, any other file the task
      demonstrably created or changed, and the `.planning/` files this
      command just updated (PLAN.md, STATE.md, and UTILITIES.md if step 2b
      touched it).
   b. Run `git status --porcelain` and compare against that set. Anything
      changed **outside** it — files the task didn't list, or changes that
      were already in the tree before the task started — is out of scope:
      list them and ask the user whether to include them, leave them
      uncommitted, or stop. Never include or drop them silently.
   c. Stage by explicit path:
```bash
git add -- [task <files>] [other files this task created/changed] .planning/PLAN.md .planning/STATE.md [.planning/UTILITIES.md if updated]
git status --short   # confirm nothing unexpected is staged
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
- The user chooses **Stop** at a critical-path pause (Step 4c)

## Error Handling

If a task fails:

1. Keep status as `in_progress`
2. Document error in STATE.md under Blockers
3. Ask user how to proceed:
   - Retry with different approach
   - Skip task (mark as `skipped`)
   - Stop execution

## Progress Reporting

**Wording:** write progress and completion messages per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.

After each task:

```
✅ Task [id] complete: [name]
[One plain sentence: what the app can do now that it couldn't before]

Files changed:
- [file 1]
- [file 2]

Verification (orchestrator-run — not the agent's self-report):
- [✅/❌] Build succeeds
- [✅/❌] [each other check, as your run showed]
- [📸 screenshot-verified | 🙋 user-confirmed] [simulator check, if any]

Progress: [completed]/[total] tasks

Continuing to task [next-id]: [next-name]...
```

## Phase-End Quality Gate

After all tasks in the phase are complete, automatically run `/apple:review` as a quality gate before declaring the phase done.

1. Execute `/apple:review` — this spawns 5 parallel agents (code quality, HIG, App Store, performance, security), then adversarially verifies every Critical/High finding against the actual code before it lands in REVIEW.md
2. The code quality agent (Agent 1) checks SOLID, DRY, design tokens, logging hygiene, and simplicity (could this be less code?)
3. If **Critical** issues are found (all Criticals in REVIEW.md are verified): fix them before proceeding, then re-run the review
4. If **High** issues are found: fix them inline, no re-run needed
5. **Medium/Low** issues: log to `.planning/REVIEW.md` as backlog for the next phase — except findings review set aside as *needlessly defensive* (its appendix): those are not backlog and are never "fixed"

This gate is mandatory for phases 1-5. Phase 6 (Pre-Release) and Phase 7 (Submission) have their own dedicated review flows.

**Record the phase as built.** In `.planning/STATE.md`, under
`## Phase Verification`, set this phase's row to `Built: [date]` and
`Verified: —` (add the section from the STATE template if it is missing).
The review gate checks the code is *good*; it does not check the
deliverables *work* — that is `/apple:verify`, offered below.

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent). Key spawns that ran with a per-task model override as `"agent:opus"` in the `agents` object, e.g. `{"swift-generalist": 2, "swift-generalist:opus": 1}`.

When all tasks and the quality gate pass:

```
🎉 Phase [X] complete!

[One plain sentence: what this phase added, and whether anything needs you.]

Completed [N] tasks:
1. ✅ [Task 1]
2. ✅ [Task 2]
...

Quality Gate:
- 🔴 Critical: [count] (must be 0)
- 🟠 High: [count] (fixed inline)
- 🟡 Medium: [count] (backlogged)
- 🟢 Low: [count] (backlogged)

Summary:
- Files created: [count]
- Files modified: [count]
- Commits: [count]

Verification: ⏳ not yet verified — offered below

You need to decide: [short list | Nothing for you to decide.]
```

## Phase Verification Handoff

The review gate above judges code quality; only `/apple:verify` confirms the
phase's deliverables actually work (build, tests, flows, UAT). Usage data
showed phases completing and the next phase being planned with verify never
run, so offer it here instead of leaving it as a suggestion.

**Skip this step when running inside `/apple:autonomous`** — it verifies every
phase through its own independent verifier.

Otherwise, ask with AskUserQuestion:

- **"Verify phase [X] now (Recommended)"** — invoke the `apple:verify` skill
  with argument `[X]` via the Skill tool. It updates STATE.md's
  `## Phase Verification` row itself. If the Skill tool can't resolve the
  command, tell the user to run `/apple:verify [X]` and stop.
- **"Later"** — leave the row as `Verified: —` and print:
  ```
  ⚠️ Phase [X] is built but not verified.
  Run /apple:verify [X] before /apple:plan [X+1] —
  /apple:plan and /apple:progress will remind you.
  ```

Never block on this choice; "Later" is a valid answer.
