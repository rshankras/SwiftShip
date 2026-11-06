# Changelog

All notable changes to SwiftShip are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org).

For a prompt repo, "breaking" means: changes to the `.planning/` file schema or
template XML tags that existing projects depend on, renamed or removed
commands, or moved skill-reference paths.

## [Unreleased]

### Added

- **Test speed tracked every phase** (#114). `verify` runs the suite
  through the new tested script `test-times.sh`, which records the time and
  test count in `.planning/test-times.tsv` and warns in plain words (never
  fails) when the suite gets over 25% and at least 5 s slower, or a single
  test takes over 10 s, listing the slowest five and the likely cause.
  `debt tests` lists tests over 10 s as debt items. The skills' new "Keep
  Tests Fast" rules (claude-code-apple-skills#70) teach agents to avoid the
  usual causes. Speed shows in VERIFICATION.md and the review guide.

- **"Must not" rules per folder** (#116). `map` surveys which frameworks
  each folder uses (new tested script `folder-imports.sh`), suggests 3–6
  rules such as "Models must not import SwiftUI" or "only Payments/ uses
  StoreKit", each marked true today or broken in N files, and asks which
  to keep. Each kept rule becomes a SwiftLint rule or a fitness test,
  proven to pass on the real code and fail on a planted break in a
  throwaway copy. Files that already break it are listed as known
  exceptions, a list that only shrinks. CODEBASE.md gets a Folder Rules
  table; build agents follow it, and `review` flags new breaks and any
  growth in the exceptions. `expect-red.sh` gains `--no-build-check` for
  lint commands.

- **One-page review guide per phase** (#113). `verify` writes
  `.planning/REVIEW-GUIDE.md` (new template) in plain English: what changed,
  the choices agents made and what they rejected, the proof (promised
  features checked, tests that can fail, lint, coverage, design), problems
  found including ones thrown out on a second check, and a checklist of
  what only you can decide, with links. `build` now records agent choices
  as `<decision>` lines in PLAN.md. `autonomous` points to the guide when
  it stops.

- **Proof that tests can fail** (#111). `build` writes each criterion's
  test before the code and checks it independently: the test is run
  against the pre-task code in a throwaway copy, where it must fail, then
  against the finished code, where it must pass. A test that passes
  without the code is sent back once, then fails the task. Each result is
  a `<red-green>` line in PLAN.md. `verify` (new 3.7d) counts those lines
  and plants 1–2 small bugs in a throwaway copy of the riskiest features'
  code, confirming a test goes red; a missed bug becomes a fix task.
  Reported in plain numbers ("12 of 12 failed before the code; planted
  bugs 2 of 2 caught"). New tested script `templates/_scripts/expect-red.sh`
  never touches the working tree.

- **Checkable acceptance criteria, traced from the spec** (#69). `plan`
  gives each task that users or callers can notice a `<criteria>` block:
  *Given* a starting situation, *When* an action, *Then* something you can
  see or test, plus the proof (a named test, a flow, a lint rule, or a
  manual check). Criteria for Swift packages use public functions; for
  screens, what's on screen. Vague spec items are asked about before the
  build, and answers are kept in `<spec-clarifications>` (under
  `autonomous`, the safest reading is recorded as an assumption to
  confirm). `verify` now writes its own list from APP.md / RELEASE.md
  **before** reading the plan, then traces every promised feature to a
  criterion and its proof; a promise nobody checks is an issue even when
  every task says completed. VERIFICATION.md gains a Spec Coverage table.
  `build` writes the tests criteria name; `autonomous` verifies spec-first.
  Older plans without criteria still verify, against their `<done>` lines.

- **Shared command scripts, tested** (#112). The shell programs that were
  pasted into command text now live in `templates/_scripts/`, and the
  commands call them in one line:
  - `design-debt.sh` (`map`)
  - `debt-measure.sh` and `baseline-refresh.sh` (`debt`)
  - `design-pin.sh` (`plan`)
  - `design-compare.sh` (`verify`)

  `scripts/test-scripts.sh` runs them against fixture projects (folder and
  file names with spaces, test folders, empty projects, baseline growth),
  using a fake `swiftlint`, and `validate.sh` runs it in CI. Each test was
  checked against a planted bug. `baseline-refresh.sh` now restores the old
  baseline itself when an existing rule grows (exit 3).
- **`validate.sh` parses frontmatter as real YAML** (#109), via Ruby's
  parser (`scripts/check-frontmatter.sh`). A block that doesn't parse, or an
  `argument-hint` that reads as a list rather than text, now fails locally,
  not only in CI's `plugin-validate`. Fixtures include #108's broken hint.

- **Plain-English output** (#115). New convention
  `templates/_conventions/PLAIN-OUTPUT.md` for anything a person reads:
  - one plain first sentence (what happened, and whether you need to act)
  - technical terms explained on first use; numbers say what they mean
  - tables after the summary, never instead of it
  - a closing "You need to decide" line
  A `reader: plain | technical` line in PREFERENCES.md (default plain) is
  asked once by `/apple:discuss`. Applied to the completion messages and
  report tops of `verify`, `review`, `build`, `debt` and `map`:
  VERIFICATION.md, REVIEW.md, DEBT.md and CODEBASE.md gain an "In plain
  words" line, and REVIEW.md's Critical/High findings gain a "What this
  means" line. Evidence is unchanged; only wording.

- **Design version pinning** (#97), tool-agnostic: every design tool exports
  PNGs.
  - **`plan`:** a new "Design Pin" step for UI phases copies the exported
    frames to `.planning/design/phase-N/pinned/`, hashes them into
    `pin.tsv`, and records a `<design-pin>` tag (source, version, link,
    scale) in PLAN.md. It asks once, or uses frames already in the folder;
    it never asks under `autonomous`, and skips silently with no design file.
    `plan` gains `Bash` and `AskUserQuestion`.
  - **`verify`:** a new step 3.7c compares a fresh export with the pin by
    name and hash and reports added / removed / changed screens, with both
    image paths and a one-line description, as **change requests, not
    defects**. They never affect PASS / PARTIAL / FAIL. Check 8 compares
    against the pinned frame.
  - **Optional Figma add-on:** with `FIGMA_TOKEN` in the environment, `plan`
    records the file's version id and `verify` skips the re-export when it
    hasn't changed.
  - New sections in the `PLAN.md` and `VERIFICATION.md` templates, plus a
    help Planning Files row.

- **New command `/apple:debt [area | rule-set] [--report]`** (#102). It
  measures an existing app against the rules SwiftShip already enforces on
  new work, then pays the debt down safely:
  - **Measure:** lints with the project config plus the `design/design-system`,
    `swift/code-size`, `swift/concurrency` and `ios/coding-best-practices`
    fragments (as extra `--config` files, nothing written), counting only
    those rules per area. Adds `map`'s design-debt score, missing fonts, test
    coverage per area, and concurrency warnings when a build log is at hand.
  - **Prioritize:** violations × (commits in 6 months + 1). The top 3–5 areas
    are paid down; areas untouched for 6 months are frozen in the baseline.
  - **Safety net:** `tdd-refactor-guard` per area; characterization tests
    come first where it says NEEDS TESTS. No net, no refactor.
  - **Plan:** one `quality`-intent phase ("Pay Down Debt") added to
    ROADMAP.md after asking, or a one-phase roadmap when none exists.
    `plan`'s quality row now knows the debt task shape.
  - **Ratchet:** merges the in-scope fragments into `.swiftlint.yml` (diff
    first), refreshes the baseline and refuses to absorb growth in rules that
    were already baselined; coverage may only rise.
  - **Track:** `.planning/DEBT.md` (new template) gets a trend row per run.
  Tested on Antics, Specimen and ChantFlow. Registered in help, README
  (54 → 55), CLAUDE.md and MODEL-TIERS (Analysis). `/apple:design-system`
  now points at `/apple:debt design` without the "if installed" fallback.

- **New command `/apple:design-system`** (#95). It sets up the design system
  before any screens, so later restyles are token edits:
  - **Design input:** the Figma MCP's variables when connected, else an
    exported tokens JSON, a `DESIGN_SYSTEM.md` spec, or a one-round
    interview. The source version is recorded.
  - **Tokens:** role-named colour assets plus spacing, radius, shadow and
    icon-size scales.
  - **Text styles:** `AppTextStyle` with `.appText` and `.original`;
    custom fonts bundled, registered and launch-checked.
  - **Components:** one `swiftui-builder` spawn builds the shared
    components and `ContentStateView`, with previews and snapshot tests
    when available.
  - **Lint:** merges the `design/design-system` SwiftLint rules, with a
    baseline for existing apps.
  - **Existing apps:** one reference screen is migrated end to end, behind
    characterization tests. The existing tokens are extended and renamed,
    never duplicated.
  - **Output:** writes `.planning/DESIGN-SYSTEM.md` (new template) and
    registers tokens and components in UTILITIES.md.
  Commands 53 → 54.

- **`verify`: design-system definition of done for UI phases** (#98). A new
  Step 3.7b checks every view file the phase touched against 8 items:
  1. design lint clean, and a new screen never enters the baseline
  2. shared components only
  3. states via `ContentStateView`
  4. user text keeps its case
  5. under ~300 lines
  6. previews per state (Dynamic Type on iOS, window sizes on macOS, watch
     sizes on watchOS)
  7. `accessibilityIdentifier`s, with UI tests using them
  8. an optional design comparison through `visual-qa`
  Without a design system, items 1–4 are "—" and 5–8 still run. Failures
  are per-screen issues with paths, and make the phase PARTIAL. The report
  and `templates/VERIFICATION.md` gain a per-screen table.

- **`map` measures design debt** (#94). A new Step 4.4 runs one shell snippet
  that reports, per view folder:
  - raw font sizes, raw colours, numeric spacing/radius/frame values, and
    call-site case/tracking, against all style calls
  - view files over 300 / 500 lines
  - `accessibilityIdentifier` coverage
  - one overall **design debt score** (raw ÷ total style calls)
  It also flags custom fonts declared in `UIAppFonts` but missing from the
  repo, which is a silent system-font fallback. Results go into
  `CODEBASE.md` → `## Design Debt` for `/apple:design-system` and
  `/apple:redesign` to use later. Tested on a 250-file SwiftUI app: 36%
  overall, 12–67% by area, and one missing bundled font found.

- **Early foundation checkpoint + `.planning/CRITICAL.md` always-pause paths**
  (#75). Agent mistakes in the data model or core interfaces are cheap after
  one task and a rewrite after ten, and some code (payments, sync,
  migrations, user data) the developer has to understand, not just accept.
  - `autonomous` pauses after the first 1–2 tasks of a *foundation phase*
    (Phase 1–2, or any phase touching `@Model` types, persistence, sync, or
    core service protocols) with the key types + diff stat.
  - New `templates/CRITICAL.md`: 3–5 areas with path globs. Seeded by
    `new-app` (from APP.md tech choices) and `map` (from real StoreKit /
    CloudKit / migration / Keychain hits); user-editable.
  - `build` Step 4c: a task whose changed files match a CRITICAL glob stops
    before committing, shows the diff, and waits for Approve / Request
    changes / Stop.
  - Both pauses apply even with `autonomous --yes`. No CRITICAL.md → no
    change in behavior.

- **`review` coverage check — changed files no reviewer examined** (#70,
  narrowed scope). Adversarial verification only challenges what reviewers
  *reported*; nothing caught what they never read. Now `review` computes the
  Swift files changed since the last review (base: the commit that last
  updated `REVIEW.md` → merge-base with main → all files), asks every
  reviewer to end with a `Files examined:` footer, and sends the unexamined
  remainder (cap 20, largest diffs first) through **one** Sonnet
  `swift-generalist` sweep that reports only real problems with `file:line`
  — never style or defensive "what if"s. Sweep findings go through the same
  verification (2× Opus for Critical) and the needlessly-defensive filter.
  REVIEW.md + the completion message gain a Coverage line. Deliberately
  does **not** sample Medium findings for upgrade (dropped: AI review
  over-reports — see #74); the opt-in seeded-defect canary is deferred.
  `review` gains `Bash` in `allowed-tools` (for `git diff`).

- **Simplicity guard** (#74). Agents write ~2× the code a requirement needs,
  and AI reviewers make it worse by suggesting defensive handling for cases
  that can't happen (*Agentic Engineering* ch. 3, 5, 20).
  - `build` Step 4b: after a task's checks pass, size the diff against its
    `<files>` — flag out-of-scope files, oversized diffs (~300 lines / ~150
    per file for a small task), and speculative structure (single-conformer
    protocols, one-caller abstractions, helpers duplicating UTILITIES.md).
    Flagged → **one** simplify pass by the same agent, kept only if
    `<verify>` still passes; never loops. Generator tasks exempt.
  - `review` Agent 1 gains a **Simplicity** lens (could this be less code?)
    and must not recommend defensive code below High.
  - `review` gains a **needlessly-defensive filter** on Medium/Low findings:
    claims whose only fix is handling a case that can't occur (per types,
    callers, platform guarantees, and no evidence) move to a
    `🧹 Set Aside` appendix — not counted, not backlogged, never fixed.
    Critical/High (already adversarially verified) and security / privacy /
    data-loss findings are never filtered. `build`'s quality gate skips the
    set-aside list.

- **`learn` routes project lessons to the strongest destination: enforcement
  → project skill → CLAUDE.md** (#76). Previously project lessons only became
  a CLAUDE.md line, which agents can skip. Now:
  - **Enforcement first** — a rule a tool can check becomes a SwiftLint rule
    (mechanical) or a fitness-function test (structural), using the same
    classes as `review`'s enforcement factory, scoped so it can't cry wolf
    and **proven red on the violation and green on current code** before it's
    offered. Replaces a proposed prompt-only GUARDRAILS.md.
  - **Project skill** — a multi-step procedure ("how a screen is wired into
    our router", "how we add a SwiftData migration") becomes
    `.claude/skills/<name>/SKILL.md` with a "Use when…" description, steps,
    a verify section, and an optional template/script. Existing skills are
    never overwritten without a diff + explicit yes; committed, they travel
    with the repo to cloud/CI/remote sessions.
  - **CLAUDE.md line** only for short judgment conventions (or `AGENTS.md`
    when the project has one).
  Description updated in `learn`, `help`, README, and CLAUDE.md.

- **`UTILITIES.md` — existing-helpers inventory so agents reuse instead of
  rebuild** (#79). Agents reimplement helpers that already exist (a second
  formatter, hand-formatted `Decimal` prices next to a `PriceFormatter`, a
  parallel networking wrapper), inflating diffs and splitting behavior. New
  `templates/UTILITIES.md` (name → path → use-for, grouped: formatting,
  networking, persistence, design tokens, logging, shared views, extensions).
  `map` gains Step 3.6 (grep inventory of reusable helpers) and Step 5.5
  (write/merge the file, never deleting user rows). `build` reads it, passes
  it to every spawn as `<existing-helpers>` with a reuse rule (no fit → say
  so before adding a shared helper), and appends new shared helpers after
  each task (creating the file on first use, so greenfield projects grow
  it), staged with the task commit. `review`'s code-quality agent flags
  reimplementations of listed helpers and unlisted shared helpers (Low).
  Every command works unchanged when the file is absent.

- **`snapshot` check type — the gauntlet's UI gate.** `build`'s `<verify>`
  table gains `snapshot` (run the suite scoped to the task's touched screens
  via `-only-testing`; a pixel diff is a FAIL; re-records need stated intent
  in the commit). `verify` Step 3.7 becomes "Fitness-Function & Snapshot
  Suites" — view-touching phases whose screens lack snapshot coverage are a
  flagged gap. `plan` adds the rule: projects with committed `__Snapshots__/`
  baselines put `type="snapshot"` on view-touching tasks, so new/changed
  screens get their snapshot in the same task.
- **Deterministic quality gates (the gauntlet) wired through the
  plan → build → verify → review loop.** `verify` gains three Step-3 gates:
  3.5 Lint Gate (`swiftlint lint --strict`, with the committed
  `.swiftlint-baseline.json` when present), 3.6 Coverage Gate
  (`Scripts/coverage-gate.sh` vs the committed `.coverage-baseline` — the
  ratchet from `testing/coverage-ratchet`), and 3.7 Fitness-Function Suites
  (confirm architecture invariants from `testing/fitness-functions` exist and
  ran with the tests); the report template and Step-2 checklist carry matching
  Lint/Coverage rows. `build` documents two new `<verify>` check types —
  `lint` and `coverage` (additive; older plans unaffected). `plan` registers
  the new skills in the Phase-5 table and testing-skills list
  (`testing/fitness-functions`, `testing/coverage-ratchet`,
  `testing/mutation-testing` advisory-only, `swift/code-size`) and adds two
  verification rules: projects with `.swiftlint.yml` put `type="lint"` on code
  tasks; projects with `.coverage-baseline` put `type="coverage"` on the
  phase-final task.

### Changed
- **`plan` + `build` enforce the design system on every UI task** (#99).
  A project "has a design system" when `.planning/DESIGN-SYSTEM.md` exists
  or `.swiftlint.yml` has the `ds_*` rules.
  - **`plan`:** view tasks get `type="lint"` and a new `type="design"`
    check (state previews per platform, identifiers, under ~300 lines, new
    files never baselined). It also adds `design/design-system` to
    `<apple-patterns>` and names the components to use.
  - **`build`:** a routing row for tokens, text styles, components and
    restyles → `swiftui-builder` + `design/design-system`. UI spawns get a
    `<design-system>` block and requirement 6.
  - **Design lint gate after every view-touching task:** zero violations in
    new code, and the baseline may only shrink.
  - No design system → unchanged.
- **`review` check #9 widened to design-system restyle cost** (#93). It
  now also flags:
  - call-site `.uppercased()`/`.textCase`/`.tracking`/`.kerning`
  - custom fonts declared in `UIAppFonts` but not bundled (High: a silent
    system-font fallback)
  - tokens named by appearance
  - view files over 300 (Low) / 500 (Medium) lines
  - ad-hoc loading/empty UI instead of `ContentStateView`
  - UI tests matching visible text
  - Decodable status enums with no `.unknown` fallback
  The enforcement factory offers the four fixture-tested
  `design/design-system` SwiftLint rules (with a baseline for existing code)
  instead of drafting new regexes for these findings.
- **`swiftui-builder` follows the design-system rules** (#92). New "Design
  System (Always Follow)" section:
  - tokens only, adding a missing token to the token file instead of inlining it
  - text through the project's text-style modifier, with no call-site
    case/tracking (user text uses `.original`)
  - reuse shared components, with variants added to the component
  - async and list content through `ContentStateView`, created once if missing
  - view files under ~300 lines
  - `accessibilityIdentifier` (`screen.element`) on interactive elements
  - iOS/iPadOS, macOS and watchOS notes
  With no design system yet, it uses system styles and semantic colours
  rather than inventing one mid-task. The completion checklist gains a
  design-system check, and `swift-generalist` gets the same rules in short
  form. Loads `design/design-system`.

- **Simulator navigation via the accessibility tree; thumbnail screenshots**
  (#72, pairs with claude-code-apple-skills#65). `RUN-AND-SHOT.md` no longer
  tells agents to tap with `xcrun simctl io … tap` — that operation doesn't
  exist, so gated screens were never reached. It now states the rule
  (*navigate with the accessibility tree; screenshots verify outcomes, never
  locate tap targets*) and follows the updated `run-simulator` skill: deep link
  → AXe (`describe-ui` filtered to a ~2 KB element list — the raw tree is
  ~280 KB; tap by id / label / exact list `xy`) → manual fallback; steps are
  confirmed by re-listing, not screenshots; one screenshot at the destination,
  Read as a `sips` thumbnail (600 iOS / 800 macOS), full size kept for
  `visual-qa`. Also:
  - **DETECT by path** — `~/.claude/swiftship-skills/ios/run-simulator/SKILL.md`
    instead of a skill name that only resolved via a drifted user-level copy
    (RUN-AND-SHOT, TOOL-HANDOFF, verify).
  - **`-derivedDataPath .build/DerivedData`** on every RUN-AND-SHOT
    `xcodebuild` call, so parallel checkouts/worktrees don't lock each other.
  - **Generated CLAUDE.md** (`new-app`) gains an *Agent Rules* line with the
    navigation rule and a labels convention; `map` offers to add the same line
    to an existing project's CLAUDE.md (diff + explicit yes; `map` gains
    `Write`, `Edit` in `allowed-tools`).
  - **`accessibility`** static scan: unlabeled controls block agents as well
    as VoiceOver; suggest `accessibilityIdentifier` for duplicate labels.

- **`review`'s lint-rule factory generalized to an enforcement factory.** The
  graduation table gains a **Structural** class — invariants a per-line regex
  can't express (import boundaries, offline guarantees, registry/content
  contracts) graduate to a fitness-function test drafted from
  `testing/fitness-functions`, proven red on the finding before it's offered,
  and installed into the test target on confirm. Output sections renamed
  "Graduated to Enforcement" accordingly.

- **`onboarding-generator` routing updated for its value-moment-first rework.**
  `plan`'s Conditional Generator Selection entry and Phase 2 table, and
  `roadmap`'s Phase 2 bullet, no longer gate the generator on "auth or
  first-run setup" — it now applies to effectively every consumer app with a
  definable value moment (nearly all of them). Both now describe the
  branch-on-readiness output (ready-now → shortest path to the value moment;
  later → implementation-intention capture + a contextual local-notification
  reminder; the welcome carousel is demoted to fallback), require the app's
  value moment to be named in the task's `<action>`, note the Phase 4 pairing
  for paywalled apps (first half feeds the paywall, second half runs
  post-purchase), and require the generator's UI-test-suppression step
  whenever the project already has UI tests. Swept the rest of `commands/`
  and `CLAUDE.md` for stale "welcome/tour" framing tied to the generator —
  none found; the skill name is unchanged.

### Fixed

- **`map`'s design-debt measure skipped files in folders with spaces.** It
  split paths on spaces, and missed test folders like `App Tests/`.
  ChantFlow's score was 53%; it is 28% with its `ChantFlow Watch App/`
  views counted.
- **24 commands' `argument-hint` parsed as a YAML list, not text**
  (`[phase-number]` unquoted). They're now quoted. `privacy.md` had an empty
  hint, now removed.

- **`build` and `test` no longer commit with `git add -A`** (#77). A blanket
  add swept stray scratch files, unignored build artefacts, local secrets, and
  the user's unrelated in-progress edits into the task commit. `build` now
  stages the task's `<files>`, files the task demonstrably created/changed, and
  the `.planning/` files it updated — by explicit path — and surfaces anything
  else in `git status` as out of scope for the user to include, leave, or stop
  on (never silently). `test` stages only the test files it wrote. `pause`'s
  WIP-commit tip now says to check `git status` and stage by path. Same
  discipline `bugfix` already followed.

- **`verify` is now a real step in the loop, not a suggestion** (#81). The
  usage ledger showed `/apple:verify` had never run: `build` completed four
  phases after the July verify-routing fix and each time the next command was
  `plan` or `review`. Root causes: `build` already runs `review` as its
  phase-end gate, the canonical flow in CLAUDE.md omitted `verify`, and the
  handoff was a line in the completion message. Now:
  - `STATE.md` gains a `## Phase Verification` table (Built / Verified per
    phase). `build` marks a phase Built after its review gate; `verify`
    records PASS / PARTIAL / FAIL.
  - `build` ends with one AskUserQuestion — "Verify phase N now
    (Recommended) / Later" — and runs `apple:verify` via the Skill tool on
    "now" (skipped inside `/apple:autonomous`, which has its own independent
    verifier). `build` gains `AskUserQuestion` and `Skill` in `allowed-tools`.
  - `plan` warns (never blocks) when an earlier phase is built but not
    verified or failed; `progress` lists such phases under **Needs
    Attention** and prioritizes `/apple:verify` over planning ahead.
  - Canonical flows in CLAUDE.md and the README quick start now include
    `verify`. Older projects without the table are unaffected.

## [2.1.0] — 2026-07-18

Verification milestone: the build loop now proves what agents claim —
orchestrator-run checks, rendered-frame verification, proven red-green, and
`/apple:verify` wired into the flow. Plus four new commands (growth, ratings,
accessibility, juice) and the skills library's blind-test slimming.

### Added

- **`/apple:juice` — game-feel audit + tiered fix pass (53rd command).** The
  failure `/apple:visual-qa` can't see in a screenshot: the app *looks* right
  but its big moments fall flat (silent winners, static celebrations). Audit
  mode: three parallel read-only lens agents (haptics+sound / motion /
  cohesion+reach) → event×channel matrix + six-dimension scorecard →
  `.planning/JUICE.md`. Fix mode (`fix 1|2|3`): one tier per invocation —
  wiring, celebration moments, sound layer (gated on user decisions) — with
  the full test suite green as each tier's exit gate. Field-tested end-to-end
  on a real app before merge; delegates to `design/game-feel`.

- **`/apple:accessibility` — the 52nd command.** Audits the app for accessibility and
  declares App Store **Accessibility Nutrition Labels**. Six phases: define common tasks
  (primary flows + first-launch/login/purchase/settings) → automated XCUITest audit
  (`performAccessibilityAudit` per screen, `continueAfterFailure`, issue-handler filtering)
  → static scan (icon-only buttons, `lineLimit(1)`, hardcoded sizes, color-only state) →
  the manual assistive-tech passes (VoiceOver, Voice Control, Larger Text at 200%/310%,
  contrast, Dark + Smart Invert, Reduced Motion) → Nutrition Label evaluation
  (fix-first-claim-after; N/A ≠ supported) → **gated** per-device-family declaration via
  `mcp__asc-metadata__update_accessibility` (`listOnly` → diff → confirm → `dryRun` →
  apply → `publish`). Writes `.planning/ACCESSIBILITY.md`. Backed by the new
  `ios/accessibility-audit` skill; the EU Accessibility Act has applied to consumer apps
  in the EU market since June 2025, and no command owned this ASC surface.

- **/apple:ratings — rating health + gated review replies (51st command).** Per-storefront health via list_reviews, a prioritized reply queue drafted from app-store/review-response-writer, every reply gated before posting via the previously unused respond_to_review MCP tool, and the never-reset guardrail from app-store/ratings-mechanics. learn-from-store now hands the reply backlog here instead of dead-ending at "replies are manual".

- **SwiftUI skill routing** — build routes state-management tasks to swiftui/data-flow and layout/scroll tasks to swiftui/layout; perf triage adds both to the jank and re-render rows.

- **visionOS routing** — build gains a visionOS task row (spatial UI -> visionos/spatial-design + visionos/widgets); review reads spatial-design for visionOS targets (eye-target sizes, motion comfort, hover rules).

- **Design-skill wiring** — the four new design skills route through the build process: plan (Phase 2/3 skill matching), build (task routing table rows for screen structure, copy, symbols, type), review (UX-quality + copy passes above HIG), visual-qa (wayfinding/typography layer), walkthrough (discoverability rubric). prototype and icon already read their upgraded skills.

- **Growth watchlist graduations** — Creative Assets, Retention Messaging, and Group/Volume Purchasing moved from announced to live scoring in templates/GROWTH.md (per WWDC26 transcripts; the skills-side rules updated in the library); watchlist now tracks only the new event badge types.

- **`/apple:growth` phase argument** — `/apple:growth P1` (or `P1-P3`) scopes
  the audit to one stage: evidence batches subset to that phase's items, only
  its scorecard rows update, and the output is the stage's worklist (core
  first, routes attached) with an offer to start the first fix. Backed by the
  skill's new Scoped Runs section.

- **`/apple:growth` — stage-by-stage growth audit (50th command).** Walks an
  app (live, `--new` pre-launch, or `--portfolio`) through the 54-item P0–P9
  growth playbook from `growth/store-growth-audit`: one read-only ASC MCP
  batch + one codebase grep pass + one batched question round, every item
  scored with citable evidence, graded into a 0–9 maturity level, and routed
  to the command that fixes it. Writes the `.planning/GROWTH.md` scorecard
  (new `templates/GROWTH.md`; stable item IDs make re-audits diff cleanly)
  and, gated, a dated top-5 into `ROADMAP.md`. Companion to
  `/apple:learn-from-store`: that asks *are the numbers moving* (monthly),
  this asks *is the machinery installed* (quarterly). Cross-linked from
  `new-app`/`roadmap` (`--new` seed), `release`/`next-version` (quarterly
  re-audit tip), `ship` (phased-release default + never-reset-ratings
  guardrail), and `learn-from-store`.

- **`via` field on invoke lines** — the usage hook now records which shape
  matched (`"typed"` = UserPromptSubmit, `"skill"` = PostToolUse on Skill),
  so `/apple:usage` can measure the routing split and attribute tier drift
  on pinned commands to it with data instead of inference. Older lines
  without the field remain valid (schema addition only).

### Changed

- **`/apple:review` is a lint-rule factory.** A lint-baseline pre-pass reads
  the project's `.swiftlint.yml` and skip-lists already-enforced rules from
  all 5 reviewer prompts (findings the build already catches stop costing
  reviewer tokens); after foreman verification, a graduation post-pass
  classifies surviving findings mechanical/judgment/one-off and drafts scoped
  SwiftLint rules for the mechanical ones (built-ins preferred,
  `included:`/`excluded:` scoping, deployment-target conditions), offered via
  the confirm-gated handoff convention. REVIEW.md gains a "⚙️ Graduated to
  Lint" section. Prose findings decay; lint rules compound.

- **`/apple:learn` upstreams general lessons to the skills source repo.**
  General lessons previously patched the installed copy at
  `~/.claude/swiftship-skills/`, which the next plugin update overwrites —
  lessons died on update instead of reaching the shared library. Step 6 now
  resolves the claude-code-apple-skills source checkout, applies the lesson
  on a `learn/<slug>` branch (never main) with an offered PR, and also
  patches the installed copy (marked `pending upstream`) so it's live
  immediately; the no-checkout fallback is a durable patch card in
  `.planning/patches/`.

- **Routing for the new `ios/accessibility-audit` skill.** `build.md`'s routing table had a
  row labelled "accessibility audit" that pointed at `ios/ui-review` — it now points at the
  real skill, and a11y *fixes* route to `generators/accessibility-generator`. Also wired
  into `review` (hig-reviewer's skill list), `visual-qa` (with a note that a full audit is
  `/apple:accessibility`), `walkthrough` (its UI test target is already up — audit each
  screen it drives), `test` (classification row), `plan` (Phase 3 Polish), `submit` +
  `ship` (Accessibility Nutrition Label as a distinct pre-flight item from the App Privacy
  label), and `swift-generalist`'s fallback list.
- **`CLAUDE.md` skills table refreshed.** It had rotted several harvest rounds behind —
  missing `ios/accessibility-audit`, `run-simulator`, `run-device`, `swiftui/data-flow`,
  `swiftui/layout`, `visionos/spatial-design`, four of the seven `design/` skills, and more.

### Fixed

- **`/apple:build` no longer grades its own homework — verification audit, part 1
  (build-loop integrity).** Four gaps closed:
  - **Orchestrator-run checks.** Step 4 now requires the orchestrator to execute
    every `<verify>` check itself after a spawn returns — build/test commands
    re-run, results recorded from those runs. The builder agent's ✅s are a
    claim, not evidence; the progress report says which it got.
  - **Baseline build check + generator tasks verified.** The `build` check runs
    after every `auto`/`generator` task even when `<verify>` omits it.
    Generator tasks previously ran **zero** checks (build.md's generator branch
    had no verification step, and the PLAN template's generator example carried
    no `<verify>` block — now it does, and `/apple:plan` requires one on every
    auto/generator task).
  - **Rendered-frame checks for UI tasks.** `simulator` checks — and any task
    touching views/layout — verify via RUN-AND-SHOT (screenshot Read back;
    blank/crashed frame = FAIL) instead of "user confirms in simulator".
    build.md never referenced RUN-AND-SHOT before; it was only wired into
    `/apple:verify`, which ledger evidence showed never runs.
    `/apple:autonomous` now defines unattended behavior: screenshot where
    possible, otherwise record `NOT RUN (unattended)` — never a silent pass.
  - **`/apple:verify` wired into the flow.** `/apple:build`'s completion
    messages routed straight to `/apple:plan [X+1]`, skipping the one command
    that checks deliverables actually *work* (review checks that work is
    *good* — different question). Both completion messages now route through
    `/apple:verify` first.

- **`/apple:autonomous` verifies with independent eyes (verification audit,
  part 3).** The per-phase verify step ran inline in the same context that had
  just built the phase — the self-grading gap `/apple:build` Step 4 closes for
  tasks, reopened at phase scope. The verify step now spawns a fresh
  `swift-generalist` that runs the build + test suite and the deliverables
  checklist itself and reports PASS/FAIL with command output as evidence;
  degraded environments fall back to inline verification, recorded as
  `verifier: inline (degraded)` in VERIFICATION.md.

- **USAGE-LOG.md pins down `blocked` vs `partial`.** Ledger data showed the
  two outcomes drifting for manual-task pauses. Now defined: stopped
  *waiting on something* → `blocked` + `blocked_on` (progress lives in
  `tasks_done`); *finished but below full capability* (e.g. degraded review)
  → `partial`. A build paused on a manual task is always `blocked`/`manual-task`.

- **Verification audit, part 2 (follow-ups).**
  - **Manual tasks are probed, not just trusted.** After the user replies
    "done", `/apple:build` read-only-verifies the machine-checkable `<done>`
    criteria — filesystem/git directly; ASC criteria via `list_apps` /
    `list_beta_groups` / `list_iap` when the asc-metadata MCP is detected
    (TOOL-HANDOFF; the three read tools join build's `allowed-tools`) — and a
    probe that contradicts the "done" re-opens the task instead of completing
    it. No probe available → trust the confirmation, as before.
  - **`/apple:bugfix` proves red instead of describing it.** Step 5.3 said the
    regression test should fail without the fix "(conceptually — describe
    this, don't actually revert)" — so a test that passes both ways (testing
    nothing) sailed through. Now: test-first when the order allows, else a
    pathspec-stash roundtrip (`git stash push -- [fix files]` → red →
    `stash pop` → green); if red genuinely can't be proven, the report says
    `red not proven` explicitly.
  - **TOOL-HANDOFF's ACT step gains a read-back.** After any write, re-read
    the value with the same tool PREVIEW used and confirm it stuck — ASC
    writes can partially apply per-locale; success is the read-back matching,
    not the API's 200.

- **The filmstrip loop is closed — `/apple:visual-qa` gets rendered frames it
  never saw.** A device-screenshot review found three defects that survived
  every SwiftShip pass because every visual-qa run had been code-only while
  `/apple:walkthrough`'s per-step screenshots of the same screens sat unread
  on disk. visual-qa gains a **Filmstrip Mode** consuming
  `.planning/walkthrough/` captures (rendered frames required on touched
  top-level screens; code-only demoted to mid-phase spot checks) plus two
  checklist additions (redundant labels, icon nameability); walkthrough hands
  its filmstrips forward at phase close-out; review cross-checks that a
  rendered-frame pass covered the phase's screens.

- **References to skills deleted in the 2026 blind-test audit.**
  `design/design-principles` and the security category modules were removed
  from the library after blind testing (Sonnet + Opus escalation + Fable
  regrade) confirmed the content is native model knowledge; `security`,
  `review`, `visual-qa`, `walkthrough`, `plan`, and `build` stopped reading
  the deleted files (the wayfinding rubric was inlined where it was
  load-bearing). Remains compatible with older skill installs.

- **`/apple:bugfix` carries the `general-purpose` guard.** The command has
  granted `Task` in its frontmatter since it was first added, but its body
  never mentioned agents — so a spawn would have defaulted to the built-in
  `general-purpose` agent, which has no pinned model and inherits the session
  model. Step 4 now routes multi-file fixes to `swift-generalist`
  (`swiftui-builder` for view-only fixes), names the plugin-namespaced retry,
  and falls back to the AGENT-VENDORING degraded guard. This is the same
  guard `build`, `review`, and `test` already carried. Completion now records
  spawn counts in the ledger's `agents` object.

- **Model-pin docs name the real failure mode: Skill-tool routing.** Ledger
  evidence (2026-07-05) showed 17/17 execution-tier runs above tier — with
  the `model: sonnet` pin present in a freshly installed plugin — because
  commands executed via the Skill tool run inside the already-running turn,
  which no frontmatter can switch. `build`/`review` model checks,
  MODEL-TIERS.md, and the `/apple:usage` recommendation rule now diagnose
  routing first (remedy: `/model sonnet` before execution-heavy stretches)
  instead of misdirecting to `./install.sh`, which only fixes stale symlink
  installs.

### Compatibility

- Tested against claude-code-apple-skills `main` @ `34fe932` (2026-07-18,
  "design/game-feel — the juice discipline skill").

## [2.0.0] — 2026-07-04

Distribution milestone: SwiftShip installs as a Claude Code plugin. **No
breaking changes** — every `/apple:*` command name, template tag, and
`.planning/` schema is unchanged (the major version marks the
distribution-model shift, not a compatibility break; strict semver would
call this 1.2.0). Manual clone + `install.sh` remains fully supported.

### Added

- **Plugin distribution** — SwiftShip is now a Claude Code plugin
  (`apple@indie-apple-stack`), installable with three slash commands (add the
  marketplace, install `apple-skills`, install `apple`) and updatable via
  `/plugin marketplace update`. Command names are preserved **byte-identical**:
  the plugin is named `apple`, and `commands/apple/*.md` moved to flat
  `commands/*.md`, so the plugin namespace supplies the same `/apple:*` prefix
  the directory name used to (verified by experiment before converting). The
  manual clone + `install.sh` path is unchanged and remains the
  contributor/dev channel.
- Plugin `hooks/hooks.json` (auto-registers for plugin installs only):
  a SessionStart glue script (`hooks/swiftship-glue.sh`) maintains the
  `~/.claude/swiftship-templates` and `~/.claude/swiftship-skills` symlinks —
  guarded so a symlink pointing at a real git checkout is never overwritten
  (manual installs always win) — and the usage-log hook, making the
  local-only ledger on-by-default for plugin installs (disclosed in the
  README; `/plugin disable apple` turns it off; manual installs stay opt-in).
- Agent types are namespaced in plugin installs (`apple:swift-generalist`):
  spawning commands (`build`, `review`, `submit`, `test`, `autonomous`) and
  the AGENT-VENDORING degraded-mode guard document the bare-name →
  `apple:`-prefixed retry, so agent spawns work in all three install modes
  (manual symlinks, vendored, plugin).
- `scripts/validate.sh` gains plugin checks: `plugin.json`/`hooks.json` must
  parse and the plugin name must be exactly `apple` (it IS the command
  namespace — a rename would silently rename all 49 commands). CI gains a
  `plugin-validate` job running `claude plugin validate .` (non-strict: the
  no-version and CLAUDE.md-at-root warnings are deliberate; errors still
  fail). Fixing plugin validation also surfaced real YAML defects the lenient
  runtime parser had masked: all six agents' multi-line descriptions weren't
  valid block scalars (now `description: |`), and `autonomous.md`'s
  `argument-hint` needed quoting.

## [1.1.0] — 2026-07-04

Model right-sizing and resilience: the first release shaped by the usage
ledger — every change below traces to a measured finding, not a hunch.

### Added

- `./install.sh --uninstall` — removes only SwiftShip's symlinks (commands,
  per-file agent links, templates, skills, hook script); never touches the
  user's own agents, `settings.json`, the usage ledger, or project
  `.planning/` files. README gains matching **Updating** and **Uninstall**
  sections plus a three-command from-zero quickstart (the committed
  `install.sh` is already executable — the `chmod` step was noise).

- Agent vendoring (`templates/_conventions/AGENT-VENDORING.md`): `/apple:new-app`
  and `/apple:map` offer to copy SwiftShip's six pinned agents into the target
  project's `.claude/agents/` — project-level agents outrank user-level and
  travel with git, so cloud/CI/remote-launched sessions keep the Sonnet pin
  and the full review gate. Includes a `.swiftship-agents` marker for
  stale-copy refresh, and a degraded-mode guard in `/apple:build` +
  `/apple:review`: when agents can't spawn, the command must say so, ask
  before proceeding, banner review output as DEGRADED, and log
  `"degraded":"no-agents"` (review: `outcome: "partial"`) — observed in the
  wild as a remote session silently substituting a 3-minute self-review for
  the 8-agent verified gate. Vendoring and the guard also call out that agent
  definitions load once at session start: copies vendored mid-session can't
  spawn until a restart, so `new-app`/`map` say so on acceptance (observed as
  a spike falling back to `general-purpose` right after vendoring).

- Model-tier convention (`templates/_conventions/MODEL-TIERS.md`): maps every
  command to a recommended session model tier — judgment (Fable-class:
  validate, roadmap, debug…), analysis (Opus-class: map, security, metadata…),
  execution (Sonnet-class: build, review, ship…) — on the principle that
  strategy is token-cheap but consequence-expensive while execution is the
  reverse (agents are Sonnet-pinned regardless). `plan`, `build`, `review`
  print a one-line note when the session model is off-tier (never blocking);
  `autonomous` asks once before a long run. Compliance is measured via the
  usage ledger's `model` field.

- Usage ledger: optional `model` field on `"outcome"` lines — records which
  session model a workflow command ran on (subagents are always Sonnet), so
  `/apple:usage` can analyze cost per command.

- Task-level model routing: `/apple:plan` may tag **at most 1–2** foundation
  `type="auto"` tasks per phase with `model="opus"` (architecture, data model,
  concurrency, migration — mistakes that propagate into everything built
  after them); `/apple:build` passes the tag through as the agent spawn's
  per-call `model` override. An absent tag means the Sonnet frontmatter pin,
  so existing PLAN.md files are unaffected (additive schema). Escalated
  spawns land in the usage ledger's `agents` object as `"agent:opus"` keys so
  `/apple:usage` can test whether escalation actually reduces review findings
  and verify failures. Haiku downshift is deliberately withheld pending that
  evidence. Mechanism + rules live in MODEL-TIERS.md ("Per-spawn overrides").

- `/apple:usage` — reads the local usage ledger into a report: command mix
  (invocations vs completed runs), outcome/blocker rates, model-tier
  adherence against MODEL-TIERS.md, and escalation economics (`agent:opus`
  spawns vs review findings). Rule-based recommendations only — including the
  explicit gate that Haiku downshift stays withheld until ≥10 datapoints show
  mechanical tasks never failing verification. Read-only, local-only, prints
  no dollar figures (prices drift; the command must not rot), and — as an
  info command — logs nothing itself.

### Changed

- Execution-tier hot-loop commands (`build`, `review`, `verify`, `test`,
  `bugfix`, `ship`) now pin `model: sonnet` in command frontmatter. The
  override is turn-scoped (documented Claude Code behavior: the command's
  turn runs on the pinned model, the session model resumes on the next user
  prompt), so it can never downgrade a later judgment-tier command, and
  per-spawn Opus escalation (Task-call `model` parameter) still outranks it.
  Replaces the "remember to `/model sonnet`" habit the first `/apple:usage`
  report showed wasn't happening: 10/10 execution-tier runs in the ledger
  billed premium main-loop rates (fable-5 ×5, opus-4-8 ×5) for routing work
  the Sonnet-pinned agents did anyway. The printed tier note remains as
  fallback for installs predating the pin and org model allowlists that
  exclude Sonnet; `/apple:autonomous` stays unpinned (its main loop includes
  plan-phase judgment work) and keeps its ask-once gate.

- `/apple:review` Critical-finding verifiers now escalate to Opus via a
  per-spawn `model` override (High verifiers stay on the Sonnet pin). A
  Sonnet verifier checking a Sonnet reviewer shares its blind spots, and a
  wrong verdict either pauses `/apple:autonomous` (false Critical) or ships a
  real bug (false confirm) — the few Opus spawns per review are the cheapest
  rigor in the pipeline. Falls back to the pin (with an audit note) if the
  escalated spawn fails.

### Fixed

- Degraded-mode guard now catches agent **substitution**, not just spawn
  failure: swapping the built-in `general-purpose` in for the named agents
  triggers the same ask + DEGRADED banner + `"degraded":"no-agents"` ledger
  fields — observed in the wild as a review that ran `general-purpose:sonnet`
  ×8 (no `hig-reviewer`/`app-store-reviewer`) yet logged a clean `completed`,
  indistinguishable from the full gate except via spawn keys. Per-call
  `model` overrides on substitute spawns are kept (they preserve the cost
  pin) but don't make a run non-degraded. `/apple:usage` now cross-checks
  spawn keys against the `degraded` field and reports bypassed guards.

- `install.sh` no longer replaces the user's entire `~/.claude/agents/`
  directory with a symlink — the six agents are now linked **per-file**, so
  any agents the user already has keep loading alongside SwiftShip's.
  Previously an existing agents directory was shunted to `agents.backup` and
  silently deactivated — an adoption-killer for exactly the audience most
  likely to try SwiftShip. Legacy whole-directory installs are migrated
  automatically on the next `./install.sh` run (with a note when an
  `agents.backup` exists to restore from); `--uninstall` handles both layouts.

- `/apple:build` task→agent table gains an explicit catch-all row (anything
  unmatched → `swift-generalist`) and an in-command prohibition on the built-in
  `general-purpose` agent; the same guard added to `/apple:review` and
  `/apple:test`. The rule previously lived only in this repo's CLAUDE.md, which
  target projects never load — first day of ledger data showed Phase-1 builds
  spawning `general-purpose` at session-model rates.
- `/apple:ship` now uses the ASC MCP for steps it previously punted to the
  user: a new Step 2 creates the App Store version via `create_version` when
  missing (it was in `allowed-tools` but never referenced), Step 3 pushes
  What's New from `.planning/RELEASE-NOTES.md` via `update_whats_new`, and
  Step 7 offers a phased release via `create_phased_release` — all
  preview → confirm → apply.
- `TOOL-HANDOFF.md` clarifies that "manual is the default" means the manual
  path always exists — not that it's suggested first; a detected tool is the
  primary path.
- Usage hook now captures user-typed `/apple:*` commands. Slash commands are
  expanded client-side and never reach the Skill tool, so the previous
  `PostToolUse`-only registration missed them entirely; the hook is now also
  registered on `UserPromptSubmit` (same script handles both input shapes).
- `USAGE-LOG.md` outcome example now stamps `ts` via `$(date -u ...)` instead
  of a hardcoded literal — prevents placeholder timestamps (e.g. midnight)
  landing in the ledger when the model doesn't know the current time.

- Adversarial verification ("foreman") step in `/apple:review`: every
  Critical/High finding is verified against the actual code before it reaches
  `REVIEW.md` — 2 independent verifiers per Critical (both must confirm; a
  split verdict downgrades to High), 1 per High; findings without a
  `file:line` are downgraded to Medium as unverifiable. Refuted claims are
  preserved in a "Refuted During Verification" appendix for audit. Protects
  `/apple:autonomous` from pausing on false Criticals.

### Compatibility

- Tested against claude-code-apple-skills `main` @ `a0226e8` (2026-07-04,
  plugin-marketplace distribution); all skill references resolve via
  `~/.claude/swiftship-skills/` unchanged — CI validates against this repo
  on every PR.

## [1.0.0] — 2026-07-02

First stable release. `main` remains the development channel; tags are the
stable channel.

### The workflow

- Spec-driven pipeline from idea to App Store: `/apple:brainstorm` →
  `/apple:validate` → `/apple:new-app` → `/apple:roadmap` → `/apple:plan` →
  `/apple:build` → `/apple:review` → `/apple:submit`
- Brownfield entry for existing apps: `/apple:map` → `/apple:release` →
  `plan → build` with intent-tagged phases (feature/bugfix/quality/release)
- Persistent project memory in `.planning/` (spec, roadmap, plan, state,
  reviews) — stop today, resume tomorrow with context intact
- `/apple:autonomous` drives plan → build → verify across phases unattended,
  pausing on manual tasks, blockers, or Critical findings

### 48 commands

- **Build & quality**: build, review, verify, test, bugfix, debug, security,
  perf, visual-qa, walkthrough, prototype, spike, modernize
- **Planning & product**: brainstorm, validate, new-app, map, roadmap, release,
  plan, discuss, next-version, milestone, idea/ideas, progress, pause/resume
- **App Store & growth**: metadata, screenshots, icon, testflight, deploy,
  submit, ship, iap, privacy, subscription, rejection, localize, differentiate,
  learn-from-store, experiment, event, release-notes
- **Meta**: help, learn, autonomous

### 6 specialist agents

- `swiftui-builder`, `storekit-expert`, `cloudkit-expert`, plus read-only
  `hig-reviewer` and `app-store-reviewer`
- `swift-generalist` — handles the long tail with `model: sonnet` enforced in
  frontmatter, so workers never silently inherit expensive session-model rates

### Skills integration

- 140+ skills from [claude-code-apple-skills](https://github.com/rshankras/claude-code-apple-skills)
  wired into commands via `~/.claude/swiftship-skills/` references
- Portable installer: home-relative symlinks only, no machine-specific paths

### Optional tool handoffs

- One shared convention (detect → preview → confirm → act → fall back) lets
  commands act on external services when tools are connected: App Store
  Connect metadata/TestFlight via MCP, simulator run & screenshot, read-only
  sales/analytics feeds
- Manual path is always the default; outward actions are confirm-first;
  everything degrades gracefully with zero tools installed

### Quality & infrastructure

- `scripts/validate.sh` + GitHub Actions: every PR checks that all skill and
  template references resolve, documented counts match reality, every command
  is registered in help.md, and frontmatter is well-formed
- Local-only usage ledger (opt-in hook + per-command outcome lines) for
  data-driven improvement — nothing leaves the machine

### Compatibility

- Tested against claude-code-apple-skills `main` @ `25a618b` (2026-07-02),
  which includes the `macos/*/SKILL.md` case fix required on case-sensitive
  filesystems (claude-code-apple-skills#15)

[Unreleased]: https://github.com/rshankras/SwiftShip/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/rshankras/SwiftShip/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/rshankras/SwiftShip/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/rshankras/SwiftShip/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/rshankras/SwiftShip/releases/tag/v1.0.0
