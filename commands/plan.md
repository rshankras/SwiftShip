---
description: Create detailed task plan for current or specified phase
argument-hint: "[phase-number]"
allowed-tools: Read, Write, Bash, Task, Glob, Grep, AskUserQuestion
---

# Plan Phase

Create a detailed task plan for the specified phase (or current phase from STATE.md).

**Model check:** apply
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md` — planning is
judgment-tier for complex phases (architecture, data model, Phases 1–2) and
analysis-tier for routine ones; if this session is below that, note the
quality risk once and continue. Skip silently if the file is absent.

## Arguments

- `$ARGUMENTS` or `$1`: Phase number (1-7). If not provided, use current phase from STATE.md.

## Prerequisites

Read required files:
```
Read: .planning/APP.md
Read: .planning/ROADMAP.md
Read: .planning/STATE.md
```

**Unverified-phase check (warn, never block).** If STATE.md has a
`## Phase Verification` table and any phase *earlier* than the one being
planned shows a `Built` date but `Verified` is `—` or `FAIL`, print once:

```
⚠️ Phase [N] was built but never verified (or failed verification).
Planning on top of it risks compounding a broken foundation.
Recommended: /apple:verify [N] first. Continuing with the plan.
```

Then continue. No table (older projects) → skip silently.

**Design system (optional).** The project *has a design system* when
`.planning/DESIGN-SYSTEM.md` exists (from `/apple:design-system`) **or**
`.swiftlint.yml` contains the `ds_*` design rules. If so, read it:
```
Read: .planning/DESIGN-SYSTEM.md   # token map, text styles, components, lint status
```
It changes how UI tasks are written (see Verification rules). No design
system → nothing below about design applies.

Also read implementation preferences if they exist (created by `/apple:discuss`):
```
Read: .planning/PREFERENCES.md   # Optional — apply if present
```

Also read `.planning/CRITICAL.md` if it exists (paths that need a person's
review; used by *Second opinion* below).

If `PREFERENCES.md` exists, **apply it** when generating tasks: use the chosen
project structure in `<file>` paths, the chosen architecture/state pattern and
async approach in `<apple-patterns>`, the chosen error-handling style, and the
chosen test-coverage target for Phase 5 tasks. Preferences override the
SwiftShip defaults below wherever they conflict. If `PREFERENCES.md` is absent,
fall back to the defaults and (optionally) suggest the user run
`/apple:discuss [phase]` first.

Also read the release scope if it exists (created by `/apple:release`):
```
Read: .planning/RELEASE.md   # Optional — present for existing-app releases
```

If `RELEASE.md` exists, this is an **existing-app release**, not a greenfield
build: the phases in `ROADMAP.md` are **intent-tagged** (see *Release Phases*
below), the `<baseline>` describes code that already ships (don't re-create it),
and `<regression-scope>` lists existing flows the Harden phase must re-verify.

If any required file is missing:
```
⚠️ Missing planning files. Run these commands first:
- /apple:new-app - Create app specification
- /apple:roadmap - Create development roadmap
```

## Phase Analysis

Determine which skills and generators are relevant based on phase:

| Phase | Primary Skills | Generators |
|-------|---------------|------------|
| 1 (Foundation) | ios/coding-best-practices, macos/coding-best-practices | logging-setup, networking-layer, analytics-setup, consent-flow, force-update, permission-priming |
| 2 (Core) | ios/, macos/, product/ux-spec, product/implementation-guide | auth-flow, onboarding-generator (value-moment flow; pairs with Phase 4 for paywalled apps), deep-linking, push-notifications, account-deletion, app-clip, offline-queue, spotlight-indexing, state-restoration, streak-tracker, app-extensions, background-processing, data-export (+ varies by feature) |
| 3 (Polish) | ios/ui-review, macos/ui-review-tahoe, ios/accessibility-audit (audit + Nutrition Label criteria), design/liquid-glass, design/animation-patterns, design/ux-writing (copy pass), design/sf-symbols, design/typography | widget-generator, accessibility-generator, preview-data-generator, localization-setup, tipkit-generator, live-activity-generator, feature-flags, announcement-banner, feedback-form, lapsed-user, milestone-celebration, share-card, social-export, usage-insights, watermark-engine, quick-win-session |
| 4 (Monetization) | monetization/ (strategy, pricing-models, app-type-guides) | paywall-generator, review-prompt, referral-system, subscription-lifecycle, variable-rewards, offer-codes-setup, pre-orders, promoted-iap, subscription-offers, win-back-offers |
| 5 (Testing) | product/test-spec, testing/ (TDD workflows), testing/fitness-functions, testing/coverage-ratchet | test-generator, preview-data-generator, testing/tdd-feature, testing/test-data-factory, testing/snapshot-test-setup, testing/integration-test-scaffold, debug-menu |
| 6 (Pre-Release) | app-store/, security/privacy-manifests, legal/privacy-policy | app-icon-generator, error-monitoring, screenshot-automation, whats-new, app-store-assets, custom-product-pages, featuring-nomination, in-app-events, product-page-optimization, app-store/iap-finalizer, legal/privacy-publish |
| 7 (Submission) | release-review/, app-store/, product/release-spec, app-store/rejection-handler | - |

The table above maps phases by **number**, which assumes the greenfield v1.0
roadmap from `/apple:roadmap`. Release roadmaps use intent instead —

### Release Phases (intent-tagged, from `/apple:release`)

When `ROADMAP.md` phases carry an `intent` attribute, route by **intent**, not by
number (a release "Phase 1" is a feature phase, not Foundation):

| Intent | Primary Skills | Task shape |
|--------|---------------|------------|
| `feature` | ios/, macos/, design/, swiftui/ (+ the same agent-matching `/apple:build` uses) | One `type="auto"` task per feature. For UI features, add a `<flows>` block and a Visual QA task, exactly as in a greenfield UI phase. |
| `bugfix` | `testing/tdd-bug-fix`, `performance/swiftui-debugging` | One `type="auto"` task per bug, following the `/apple:bugfix` workflow: locate → minimal fix → **regression test**. Each task's `<verify>` MUST include a `type="test"` check for the new regression test. |
| `quality` | `ios/ui-review`, `testing/`, `security/`, `performance/profiling` | Regression walkthrough of the `<regression-scope>` flows from `RELEASE.md` (drive with `/apple:walkthrough`), plus tests/review/security/perf as scope warrants. **From `/apple:debt`** (phase cites `.planning/DEBT.md`): one task per area and rule set, characterization tests (`testing/characterization-test-generator`) as the area's first task when DEBT.md says so, behavior unchanged, `<verify>` with `type="test"` + `type="lint"` (no in-scope violations in touched files; their baseline entries removed). |
| `release` | `app-store/`, `product/release-spec`, `legal/privacy-policy` | What's New (`generators/whats-new`), screenshot refresh if UI changed (`generators/screenshot-automation`), release notes, TestFlight, submit. Keep submit `type="manual"`. |

Everything else about task generation (the XML format, `<verify>`, `<done>`,
committing per task) is identical — only skill selection changes.

### Conditional Generator Selection

Not every plan needs every generator. Inspect APP.md's `<apple-technologies>` and `<architecture>` to decide which generators to include as tasks:

- **logging-setup**: Include if app has backend integration, analytics, or debugging needs
- **networking-layer**: Include if app has API calls, sync, or remote data
- **http-cache**: Include if app has API calls and needs offline support or reduced network usage
- **pagination**: Include if app displays lists of remote data with load-more or infinite scroll
- **image-loading**: Include if app displays remote images (avatars, photos, thumbnails)
- **analytics-setup**: Include if app tracks user behavior or has business metrics
- **auth-flow**: Include if `<auth>` is not `None`
- **onboarding-generator**: Include for effectively every consumer app that has a definable value moment — which is nearly all of them. Produces a branch-on-readiness flow (ready-now → shortest path to the value moment; later → implementation-intention capture + a contextual local-notification reminder; the welcome carousel is now the fallback, not the default) — name the app's value moment in the task's `<action>`. Pairs with Phase 4 for paywalled apps: the first half of the flow feeds the paywall, the second half runs post-purchase. MUST include the generator's UI-test-suppression step when the project has existing UI tests — onboarding otherwise breaks every existing test's first screen.
- **deep-linking**: Include if app has sharing, external links, or universal links
- **push-notifications**: Include if `Push Notifications` is in `<apple-technologies>`
- **localization-setup**: Include if app targets multiple regions or languages
- **tipkit-generator**: Include for apps with discoverable features that benefit from coaching
- **live-activity-generator**: Include if `Live Activities` is in `<apple-technologies>`
- **feature-flags**: Include if app has A/B testing, staged rollout, or remote config
- **review-prompt**: Include for all apps with monetization or user engagement goals
- **app-icon-generator**: Include in pre-release phase for all apps
- **error-monitoring**: Include if app has backend/network features or crash reporting needs
- **consent-flow**: Include if app collects personal data or targets EU/California users
- **force-update**: Include if app has API versioning or server-side breaking changes
- **permission-priming**: Include if app requests sensitive permissions (camera, location, microphone, health)
- **account-deletion**: Include if app has user accounts (Apple requirement since 2022)
- **app-clip**: Include if app benefits from lightweight try-before-install experiences
- **offline-queue**: Include if app needs to queue user actions while offline for later sync
- **spotlight-indexing**: Include if app has searchable content (articles, items, records)
- **state-restoration**: Include if app has complex navigation that should survive relaunch
- **streak-tracker**: Include if app has daily engagement, habit tracking, or streak mechanics
- **announcement-banner**: Include if app needs to communicate updates, promotions, or alerts in-app
- **feedback-form**: Include if app collects user feedback, bug reports, or feature requests
- **lapsed-user**: Include if app has retention goals and needs win-back flows
- **milestone-celebration**: Include if app has achievements, progress milestones, or completion events
- **share-card**: Include if app has content users can share as branded images
- **social-export**: Include if app has content users share to social media platforms
- **usage-insights**: Include if app benefits from showing users their activity or usage statistics
- **watermark-engine**: Include if app generates images or exports that need branding/watermarks
- **quick-win-session**: Include if app benefits from short, rewarding engagement loops
- **referral-system**: Include if app benefits from word-of-mouth or invite-a-friend growth
- **subscription-lifecycle**: Include if app has subscriptions (renewal, grace period, billing state management)
- **variable-rewards**: Include if app uses gamification, surprise rewards, or engagement hooks
- **debug-menu**: Include for all apps — hidden debug menu for internal/TestFlight builds
- **screenshot-automation**: Include for all apps — automated App Store screenshot capture
- **whats-new**: Include for all apps — What's New screen shown after app updates
- **app-extensions**: Include if app needs share, action, or keyboard extensions with App Groups
- **background-processing**: Include if app needs BGTaskScheduler or background downloads
- **data-export**: Include if app needs JSON/CSV/PDF export or GDPR data portability compliance
- **app-store-assets**: Include for all apps — comprehensive App Store asset specs
- **custom-product-pages**: Include if app targets multiple distinct audiences needing tailored pages
- **featuring-nomination**: Include if app is a strong candidate for Apple editorial featuring
- **in-app-events**: Include if app has seasonal events, challenges, or live content on App Store
- **product-page-optimization**: Include if planning to A/B test App Store screenshots and metadata
- **offer-codes-setup**: Include if app uses promo codes for influencers, press, or partnerships
- **pre-orders**: Include if app will launch with App Store pre-orders
- **promoted-iap**: Include if app has in-app purchases to display on the App Store product page
- **subscription-offers**: Include if app has subscriptions needing intro, promo, or win-back offers
- **win-back-offers**: Include if app has churned subscribers to re-engage with targeted offers

**Testing skills (Phase 5):**
- **testing/tdd-feature**: Include for all apps — TDD workflow for new test coverage
- **testing/test-data-factory**: Include if app has SwiftData/model layer — generates test fixture factories
- **testing/snapshot-test-setup**: Include if app has custom UI components — SwiftUI visual regression testing; once a suite exists, view-touching tasks carry `type="snapshot"` checks (the gauntlet's UI gate)
- **preview-data-generator**: Include for views with multiple data/appearance states (empty/loading/error/loaded, dark, Dynamic Type, RTL), or whenever snapshot-test-setup is included — it produces the sample data + `#Preview` matrix the snapshots render, so both share one dataset
- **testing/integration-test-scaffold**: Include if app has networking + persistence — cross-module test harness
- **testing/test-contract**: Include if app has protocol-based abstractions — contract test suites
- **testing/characterization-test-generator**: Include for brownfield/existing codebases being refactored
- **testing/fitness-functions**: Include if the app has hard architectural rules — offline guarantees, module import boundaries, pinned registries/content contracts (check CLAUDE.md and APP.md constraints). Each rule becomes a deterministic suite in the test target
- **testing/coverage-ratchet**: Include for all apps once a test target exists — commits a coverage baseline that later phases may never drop below
- **testing/mutation-testing**: Advisory only, on explicit request — EXPERIMENTAL muter audit for engine-heavy targets; never a blocking check
- **swift/code-size**: Include when adopting lint gates — complexity/size thresholds with a violations baseline so existing code never blocks

Only add generators whose conditions are met — avoid bloating the plan with unnecessary tasks.

**Visual QA (Phases 1-3):**
- **visual-qa**: Always include as the **final task** in any phase that creates or modifies UI views (typically phases 1, 2, and 3). Runs a code-level audit checking HIG compliance, accessibility, touch targets, hardcoded colors, missing view states, and fixed-frame layouts. Generates `.planning/VISUAL-QA.md` and fixes all Critical/High issues before the phase is marked complete.

## User Flows (any phase with UI)

A task list verifies that *screens exist and compile*. It is blind to whether the **flow between screens works for a human with a goal** — the return paths, the dead-ends, the discoverability. Those bugs (e.g. "a saved record can only be viewed, never reopened to edit"; "Done drops me to the home screen and loses my work"; "how do I even select this?") are *missing arrows in a journey*, and a journey map catches them on paper — before code.

**For any phase that adds or changes UI, enumerate a `<flows>` block** (place it right after `<apple-focus>`, before the tasks). Each flow is one end-to-end user journey *and* a testable script for `/apple:walkthrough`. Rules for good flows:

- Write them as **screen → action → screen** arrows, including the **return / back / Done** destination of every step (state where each `Done`/`Back` must land).
- For **every persisted model with a Create step**, include a flow that **leaves and reopens it editable** (reopen-from-list). Create-without-a-reopen-edit-path is the most common dead-end.
- Cover the **empty**, **edit**, and **error** paths, not just the happy path.
- Mark the single **least-discoverable action** in each flow — the thing a first-timer might not find.

```xml
<flows>
  <!-- End-to-end journeys this phase must satisfy. Each drives /apple:walkthrough. -->
  <flow id="F1" persona="[who]" priority="critical|high">
    <goal>[what the user is trying to accomplish]</goal>
    <steps>
      <step>Launch → [screen]</step>
      <step>Tap [control] → [screen]</step>
      <step>[action] → [expected result / screen]</step>
      <step>Tap Done/Back → MUST land on [screen]</step>
    </steps>
    <returns-to-edit>[for each entity created: the step that reopens it editable]</returns-to-edit>
    <discoverability>[the one action a first-timer might not find]</discoverability>
  </flow>
</flows>
```

After building a flow's slice, run `/apple:walkthrough [flow-id]` — it drives the flow in the Simulator (UI test + per-step screenshots), statically audits the nav graph for dead-ends, and produces a human discoverability checklist. Do this **per flow-slice, not just at phase end**.

## Design Pin (UI phases)

A design that keeps changing after work starts is how projects overrun
without anyone noticing. Pin the design this phase is built against, so
`/apple:verify` can tell "same design" from "four screens changed", and
report changes as **change requests, not defects**
(`design/design-system`, rule 21). It works with any design tool, because
every tool exports PNGs.

**Skip silently** when the phase adds or changes no UI, or the project has
no design file (screens designed in SwiftUI previews or `/apple:prototype`).

1. **Find the frames.** If `.planning/design/phase-N/pinned/` already has
   PNGs (the user dropped them there), use them. Otherwise ask once
   (`AskUserQuestion`): "Is this phase built against exported design
   frames?" with options **Folder of exported PNGs** (path via Other) /
   **No design file for this phase**. Under `/apple:autonomous`, never ask:
   pin an existing folder or skip.
2. **Copy and hash.** One PNG per screen, named after the frame (e.g.
   `Profile Edit.png`), all exported at the **same scale**:
   ```bash
   bash ~/.claude/swiftship-templates/_scripts/design-pin.sh N "<export folder>"   # or without the folder, to pin PNGs already in place
   ```
   It copies the PNGs to `.planning/design/phase-N/pinned/` and writes
   `pin.tsv` (frame name → image hash). If the script is missing,
   SwiftShip is out of date: tell the user to update it (`claude plugin
   update apple@indie-apple-stack`, or `git pull` for a manual install).
   Don't retype the program from memory.
3. **Record it** in PLAN.md, right after `<flows>`:
   ```xml
   <design-pin source="[Figma | Sketch | Penpot | XD | other]" version="[version name or export date]"
               link="[file URL, optional]" scale="[1x | 2x]" frames=".planning/design/phase-N/pinned/"
               figma-version-id="[only with FIGMA_TOKEN, see below]"/>
   ```
   Name each UI task's frame in its `<action>` ("match `Profile Edit.png`"),
   so build agents and verify check 8 compare against the right image.
4. **Optional, Figma only:** when `FIGMA_TOKEN` is set in the environment
   (read-only scope; never ask for it in chat, never print it), record the
   file's current version so verify can check for changes without a
   re-export. The file key is the segment after `/file/` or `/design/` in
   the URL:
   ```bash
   curl -sf -H "X-Figma-Token: $FIGMA_TOKEN" "https://api.figma.com/v1/files/<key>/versions" \
     | jq -r '.versions[0] | "\(.id)\t\(.label // "autosave")\t\(.created_at)"'
   ```
   Put the id in `figma-version-id`. No token, or the call fails → leave it
   out; the PNG pin is enough.

Commit `.planning/design/phase-N/` with PLAN.md (PNGs, `pin.tsv`).

## Acceptance Criteria (every phase)

A `<done>` line like "Profile screen works" can't be proven true or false.
Every task that delivers something a user or caller can notice also gets
**acceptance criteria**: short statements anyone can check, in a fixed
shape:

- **Given** the starting situation
- **When** the user (or the calling code) does something
- **Then** something you can see or test happens

Example: *Given* no internet, *When* the user taps Save, *Then* the note
stays in the list and a "Saved offline" message shows.

**1. List what this phase promises.** Read the features this phase
delivers: the phase's entry in ROADMAP.md, matched to APP.md
`<mvp-features>` (new apps), or to the RELEASE.md `<features>` and `<bugs>`
by id (updates). Each one needs at least one criterion. A bug's criterion
comes from its `<symptom>`: *Given* the conditions that triggered it,
*When* the same action, *Then* the correct behavior.

**2. Ask before writing, not halfway through the build.** If a feature is
too vague to write a criterion (for example "sync works": what happens with
no internet? which copy wins when both changed?), collect those questions
and ask them together with `AskUserQuestion` (up to 4 per call), each with
plain choices and the recommended one first. Record every answer in
PLAN.md's `<spec-clarifications>` block so `/apple:verify` sees it.
Under `/apple:autonomous`, never ask: choose the safest reading (no data
lost, user told what happened), record it with `source="assumed"`, and the
run's next checkpoint lists the assumptions for a person to confirm.

**3. Write the criteria.** Rules:
- **Checkable from outside.** On screen for app screens; through the public
  functions for a Swift package (`Packages/*` or a local package in the
  project). Never "the cache is updated" or "the view model holds X".
  Say which with `via="screen"` or `via="package"`.
- **One behavior each.** Cover the empty, error and edit cases the
  `<flows>` already list, not only the happy path.
- **Name the proof**, the thing that will show it's true:
  - `test`: the test that checks it (name it; the task writes it)
  - `flow`: a `<flows>` id that `/apple:walkthrough` drives
  - `lint`: a lint rule
  - `manual`: a person checks it during `/apple:verify` (only when nothing
    automatic can; most screen behavior can be a UI test or a flow)
- Tasks that deliver nothing a user or caller can notice (project setup,
  the Visual QA task) keep only `<done>`.
- Ids run across the whole plan: `AC1`, `AC2`, ….

```xml
<spec-clarifications>
  <!-- Answers to questions asked before planning. source="assumed" = chosen under autonomous, not yet confirmed -->
  <clarification feature="[feature]" source="asked|assumed">[question] → [answer]</clarification>
</spec-clarifications>

<task id="N" ...>
  ...
  <criteria>
    <criterion id="AC1" feature="[feature name or RELEASE id, as in the spec]" via="screen|package">
      <given>[starting situation]</given>
      <when>[action]</when>
      <then>[what you can see or test]</then>
      <proof type="test|flow|lint|manual">[test name | flow id | rule | what the person checks]</proof>
    </criterion>
  </criteria>
  <done>...</done>
</task>
```

Place `<spec-clarifications>` after `<flows>` (and `<design-pin>`), before
the tasks. Before writing PLAN.md, check: every feature from step 1 has at
least one criterion; if one doesn't, write it or ask.

## Task Generation

Create `.planning/PLAN.md` with detailed tasks:

### Verification rules (every task)

`<verify>` is what `/apple:build` actually executes after the agent returns —
the orchestrator runs every check itself and never accepts the builder's
self-report as evidence. Write checks accordingly:

- Every `auto` and `generator` task MUST carry a `<verify>` block with at
  least a `type="build"` check. (`/apple:build` runs the build check even when
  the block is missing, but an explicit block also states *what success looks
  like* for this task.)
- Any task whose `<files>` create or modify views or layout MUST also carry a
  `type="simulator"` check — `/apple:build` verifies it with a rendered
  screenshot (RUN-AND-SHOT), because compile + tests cannot see clipped,
  invisible, or crushed UI.
- Tasks that add tests carry a `type="test"` check naming the suite that must
  pass.
- Projects with a `.swiftlint.yml`: code tasks carry a `type="lint"` check —
  `/apple:build` runs `swiftlint lint --strict` (with the committed baseline
  when one exists).
- Projects with a committed `.coverage-baseline`: the phase-final task carries
  a `type="coverage"` check — `/apple:build` runs `Scripts/coverage-gate.sh`
  and the phase cannot close below the baseline.
- Projects with a snapshot suite (`__Snapshots__/` baselines committed):
  tasks whose `<files>` touch views carry a `type="snapshot"` check naming
  the suite — new/changed screens get their snapshot in the SAME task, so
  the visual gate is never blind where the change happened.
- **Projects with a design system:** every task whose `<files>` create or
  modify views also carries:
  - `type="lint"` (the design rules run with the baseline), even when the
    project's other code tasks don't
  - `type="design"`: the per-screen definition-of-done items that can be
    checked on a single task. That means previews for each state (Dynamic
    Type on iOS, window sizes on macOS, watch sizes on watchOS),
    `accessibilityIdentifier`s on interactive elements, view file under ~300
    lines, and new files never added to `.swiftlint-baseline.json`

  It also adds `design/design-system` to the task's `<apple-patterns>`, and
  names in `<action>` the components from DESIGN-SYSTEM.md the screen should
  use (e.g. "list states via ContentStateView; actions via AppButtonStyle").
  So violations are caught per task, not at phase end.
- `manual` tasks put their acceptance into `<done>` criteria — write them
  checkable (concrete names, bundle IDs, group names — not "is set up
  correctly").

### Model tagging (`type="auto"` tasks only)

Tag **at most 1–2 tasks per phase** with `model="opus"` — only tasks whose
mistakes propagate into everything built after them:

- App architecture / project structure being locked in
- Data model / schema foundations (SwiftData models, CloudKit record design)
- Concurrency-heavy engines (actors, sync pipelines, background processing)
- Migrations with data-loss risk

Everything else stays untagged — the agents' Sonnet pin plus `<verify>` gates
carry routine work. Discipline check before writing PLAN.md: if more than 2
tasks are tagged, untag the least foundation-shaping until 2 remain. Never tag
`generator` or `manual` tasks, and never use a value other than `opus` (Haiku
downshift is deliberately not offered pending ledger evidence — see the
"Per-spawn overrides" section of
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md`). `/apple:build`
passes the attribute through as the agent spawn's `model` override; an absent
attribute means the agent's pinned default. Phases with no foundation-shaping
tasks get zero tags — that is the common case.

### Second opinion (high-stakes tasks only)

A reviewer who reads the plan first tends to agree with it. For the few
choices that are expensive to undo (data model, sync, payments,
migrations), one extra agent works out **its own approach before seeing
the plan's**, then compares (#117).

**Which tasks.** `type="auto"` tasks tagged `model="opus"`, plus tasks
whose `<files>` match a glob in `.planning/CRITICAL.md` (if it exists).
**At most 2 per phase**: tagged tasks first, then critical-path ones in
task order. Ordinary UI and feature tasks never get one. None qualify →
skip this section.

**1. Record the options.** Every such task gets an `<options>` block: the
chosen approach and at least one real alternative with why it lost.

```xml
<options>
  <option id="A" chosen="true">[approach, one or two lines]</option>
  <option id="B" rejected="[why, one line]">[approach]</option>
</options>
```

**2. Blind first, then compare.** Do this after the tasks are drafted and
before writing PLAN.md, so the plan's choice is only in a file the reviewer
hasn't opened yet:

- Write the task's options to
  `${TMPDIR:-/tmp}/swiftship-second-opinion/T[id]-plan.md`.
- Spawn one agent per task (bare name first; on "Agent type not found"
  retry `apple:swift-generalist`). If the `model` override fails, retry
  once without it; if no agent can spawn, skip this section, write
  `<second-opinion verdict="skipped" reason="no agents"/>` and say so in
  the completion message.

```
Task({
  subagent_type: "swift-generalist",
  model: "opus",
  prompt: `
    You are giving a second opinion on one task in an Apple app plan.
    You must work out your own approach BEFORE you see the plan's.

    Goal: [task <name>]
    Must make true: [the task's <criteria> given/when/then lines and <done>]
    Constraints: [platform + frameworks from APP.md; PREFERENCES.md choices;
                  the CRITICAL.md row's "why it matters", if any]
    Relevant code: [the task's <files> that exist, plus the models/services
                    they touch]. Read them. Do NOT read .planning/PLAN.md.

    Step 1. Write your approach in at most 8 lines: what you would build,
    the key structure (types, storage, who owns what), and the biggest
    risk. Write it to
    ${TMPDIR:-/tmp}/swiftship-second-opinion/T[id]-blind.md BEFORE step 2.

    Step 2. Only now read
    ${TMPDIR:-/tmp}/swiftship-second-opinion/T[id]-plan.md, the plan's
    chosen option and the ones it rejected.

    Step 3. Return exactly:
      VERDICT: same | different-but-fine | plan-worse
      MINE: [your approach, one line]
      WHY: [one or two plain sentences. For plan-worse: "the plan's choice
            is worse because …", naming what would break or cost more
            later. Check especially whether a rejected option was better.]
    Say plan-worse only for a real problem (data loss, a migration later,
    a sync conflict, money), not taste.
  `
})
```

Delete the temp folder afterwards. Count each spawn in the ledger's
`agents` object under `"swift-generalist:opus"`.

**3. Record the verdict** in the task, after `<options>`. Agreement is one
line and nobody is asked anything:

```xml
<second-opinion verdict="same|different-but-fine|plan-worse|skipped" mine="[reviewer's approach, one line]" resolved="kept|switched|pending">[WHY, plain words]</second-opinion>
```

`resolved` only applies to `plan-worse`.

**4. Only real disagreement reaches the user**, as one question before the
build, never halfway through it. Collect every `plan-worse` task into a
single `AskUserQuestion` call (one question per task, at most 2). Each
question gives both choices side by side in plain words, with a `preview`
showing each approach and what it means later:

- "Keep the plan's choice": record `resolved="kept"`
- "Switch to the second opinion": rewrite the task's `<action>` and
  `<options>` (the old choice becomes a rejected option with the
  reviewer's reason), then record `resolved="switched"`

Under `/apple:autonomous`, don't ask: keep the plan's choice, record
`resolved="pending"`, and autonomous pauses before building that phase
(its pause table).

### For Phase 1 (Foundation):

```xml
<plan phase="1" platform="[from APP.md]">
  <objective>Project setup and core architecture</objective>
  <apple-focus>Xcode config, SwiftData, NavigationStack</apple-focus>

  <!-- Enumerate for any phase with UI. Each flow drives /apple:walkthrough. -->
  <flows>
    <flow id="F1" persona="[who]" priority="critical">
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

  <task id="1" type="manual" status="pending">
    <name>Create Xcode Project</name>
    <action>
      Create new Xcode project with:
      - Product Name: [from APP.md]
      - Bundle Identifier: [from APP.md]
      - Interface: SwiftUI
      - Language: Swift
      - Storage: [SwiftData if selected]

      Configure:
      - Deployment target: [from APP.md]
      - Device orientations
      - Capabilities: [from apple-technologies]
    </action>
    <done>
      - Xcode project created and builds
      - Bundle ID matches APP.md
      - Correct deployment target set
    </done>
  </task>

  <task id="2" type="auto" status="pending">
    <name>Define Data Models</name>
    <files>
      <file action="create">Sources/Models/[Model].swift</file>
    </files>
    <apple-patterns>
      <pattern>Use @Model macro for SwiftData</pattern>
      <pattern>Use Codable for API responses</pattern>
      <pattern>Relationships with @Relationship</pattern>
    </apple-patterns>
    <action>
      Create SwiftData models based on MVP features:
      [Analyze features and suggest models]

      Each model should:
      - Use @Model macro
      - Have appropriate relationships
      - Include computed properties where helpful
    </action>
    <verify>
      <check type="build">Models compile without errors</check>
      <check type="preview">Can be used in SwiftUI previews</check>
    </verify>
    <done>
      - All models defined with @Model
      - Relationships configured
      - Builds successfully
    </done>
  </task>

  <task id="3" type="auto" status="pending">
    <name>Set Up App Architecture</name>
    <files>
      <file action="modify">[AppName]App.swift</file>
      <file action="create">Sources/App/AppState.swift</file>
    </files>
    <apple-patterns>
      <pattern>@Observable for app-wide state</pattern>
      <pattern>@Environment for dependency injection</pattern>
      <pattern>ModelContainer in App struct</pattern>
    </apple-patterns>
    <action>
      Create MVVM architecture:

      1. AppState with @Observable:
      ```swift
      @Observable
      final class AppState {
          var isOnboarded: Bool = false
          // Add app-wide state
      }
      ```

      2. Configure App struct:
      ```swift
      @main
      struct [AppName]App: App {
          @State private var appState = AppState()

          var body: some Scene {
              WindowGroup {
                  ContentView()
                      .environment(appState)
              }
              .modelContainer(for: [Models].self)
          }
      }
      ```
    </action>
    <verify>
      <check type="build">App builds and launches</check>
    </verify>
    <done>
      - AppState created with @Observable
      - Environment configured
      - ModelContainer set up
    </done>
  </task>

  <task id="4" type="auto" status="pending">
    <name>Implement Navigation Structure</name>
    <files>
      <file action="create">Sources/Views/ContentView.swift</file>
      <file action="create">Sources/Navigation/Router.swift</file>
    </files>
    <apple-patterns>
      <pattern>NavigationStack for iOS</pattern>
      <pattern>NavigationSplitView for iPad/Mac</pattern>
      <pattern>@Observable Router for programmatic navigation</pattern>
    </apple-patterns>
    <action>
      Based on app type, implement navigation:

      For single-column apps:
      - NavigationStack with path binding

      For multi-column apps (iPad/Mac):
      - NavigationSplitView with sidebar

      Include Router class for programmatic navigation.
    </action>
    <verify>
      <check type="build">App builds with navigation in place</check>
      <check type="simulator">Navigation works correctly</check>
    </verify>
    <criteria>
      <criterion id="AC1" feature="[MVP feature this screen serves]" via="screen">
        <given>A first launch with no saved data</given>
        <when>The app opens</when>
        <then>The main screen shows its empty state with one clear first action</then>
        <proof type="flow">F1</proof>
      </criterion>
    </criteria>
    <done>
      - Navigation structure matches app type
      - Programmatic navigation works
      - Adapts to device size
    </done>
  </task>

  <!-- Visual QA: ALWAYS the last task in phases with UI work (1-3) -->
  <task id="last" type="auto" status="pending">
    <name>Visual QA Audit</name>
    <action>
      Run /apple:visual-qa code-level audit on all views created/modified in this phase.
      Scan for: HIG compliance, accessibility labels/traits, touch targets (44pt min),
      hardcoded colors, Dynamic Type support, missing view states, fixed-frame layouts.
    </action>
    <verify>
      <check type="build">All fixes compile without errors</check>
    </verify>
    <done>
      - .planning/VISUAL-QA.md generated with full report
      - All Critical and High severity issues fixed
      - Medium issues documented for backlog
    </done>
  </task>
</plan>
```

### For Other Phases:

Generate tasks based on:
- ROADMAP.md phase tasks
- APP.md features and frameworks
- Relevant generator skills

### Generator Task Example:

```xml
<task id="X" type="generator" status="pending">
  <name>Add Settings Screen</name>
  <generator>generators/settings-screen</generator>
  <customization>
    <include>appearance-toggle</include>
    <include>notification-preferences</include>
    <include>about-section</include>
  </customization>
  <verify>
    <check type="build">Generated code compiles in the app target</check>
    <check type="simulator">Settings screen renders and toggles respond</check>
  </verify>
  <criteria>
    <criterion id="AC4" feature="Settings" via="screen">
      <given>Appearance is set to Dark</given>
      <when>The user quits and reopens the app</when>
      <then>The app opens in Dark appearance</then>
      <proof type="test">SettingsUITests.testAppearancePersists</proof>
    </criterion>
  </criteria>
  <done>
    - Settings accessible from navigation
    - All preferences persist
    - Version info displays correctly
  </done>
</task>
```

## Update STATE.md

After creating PLAN.md, update STATE.md:
- Set Phase Status to "pending" (ready to build)
- Update Last Updated timestamp

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent).

```
✅ Phase [X] plan created!

Created: .planning/PLAN.md with [N] tasks
Checkable criteria: [n] covering [n of m] features this phase promises
[Questions answered: n | Assumptions to confirm: n (listed in <spec-clarifications>)]
[Second opinion on n high-stakes tasks: n agree, n different but fine, n disagreed (you chose: kept / switched) — omit if none]

Tasks:
1. [Task 1 name] (type: [auto/manual/generator][; append ", model: opus" if tagged])
2. [Task 2 name] (type: [auto/manual/generator])
...

Task types:
- auto: Claude executes with specialized agent
- generator: Uses generator skill
- manual: You complete (e.g., App Store Connect setup)

Next: Run /apple:build to execute tasks
```
