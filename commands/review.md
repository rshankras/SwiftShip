---
description: Run comprehensive code, HIG, and App Store review
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
model: sonnet
---

# Comprehensive Apple Review

Run parallel reviews covering code quality, HIG compliance, App Store guidelines, and performance.

## Prerequisites

Verify project has code to review:
```
Glob: **/*.swift
```

If no Swift files found:
```
⚠️ No Swift files found. Build your app first with /apple:build
```

## Read Context

```
Read: .planning/APP.md (if exists)
Read: .planning/ROADMAP.md (if exists)
Read: .planning/STATE.md (if exists)
Read: .planning/UTILITIES.md (if exists — pass to Agent 1 for the reimplemented-helper check)
```

## Lint Baseline (pre-pass)

Findings a lint rule already catches are wasted reviewer tokens — the build
catches them for free on every compile. Before spawning reviewers:

1. ```
   Glob: .swiftlint.yml, **/.swiftlint.yml
   ```
2. If configs exist, Read them and build the **enforced-rule list**:
   - built-in rules in force: everything not in `disabled_rules:` plus every
     `opt_in_rules:` entry
   - every `custom_rules:` entry — record its name and what its regex catches
     (one line each)
3. Compose a skip-list block and **append it to all 5 reviewer prompts below**:

   ```
   Already enforced by SwiftLint in this project — do NOT report findings
   these rules already catch:
   [one line per rule: name — what it catches]
   Everything else stays in scope.
   ```

If no `.swiftlint.yml` exists, skip this pre-pass and note it in REVIEW.md's
summary (`Lint baseline: none`) — the graduation step below will offer to
create one.

## Review Scope (changed files)

Compute the Swift files changed since the last review — the coverage check
after the reviewers uses this list:

```bash
# Base: the commit that last updated REVIEW.md (previous review); else the
# branch's merge-base with main; else no base (first review → all files).
BASE=$(git log -1 --format=%H -- .planning/REVIEW.md 2>/dev/null)
[ -z "$BASE" ] && BASE=$(git merge-base HEAD main 2>/dev/null)
if [ -n "$BASE" ]; then
  git diff --name-only "$BASE" HEAD -- '*.swift'; git ls-files --others --exclude-standard -- '*.swift'
else
  git ls-files -- '*.swift'
fi
```

Append this footer to **all 5 reviewer prompts** below (alongside the lint
skip-list):

```
End your output with a line listing every Swift file you actually read:
Files examined: path/A.swift, path/B.swift, ...
```

**Model check (execution tier):** this command pins `model: sonnet` in its
frontmatter (turn-scoped; see
`~/.claude/swiftship-templates/_conventions/MODEL-TIERS.md`). Reviewers are
pinned agents and Critical verifiers escalate per-spawn (see the foreman
step) — both independent of the turn model, so the pin costs no rigor. If
your system prompt still names a premium model, the pin didn't apply — the
usual cause is Skill-tool routing (the command body runs inside the current
turn, which no frontmatter can switch; `./install.sh` only fixes stale
symlink installs). Note once that `/model sonnet` costs nothing in quality
here, continue. Skip silently if the convention file is absent.

## Spawn Review Agents in Parallel

Launch all 5 review agents simultaneously for efficiency. Use exactly the
`subagent_type` named in each block — **never the built-in `general-purpose`
agent**, which has no pinned model and silently inherits the session model
(Opus/Fable rates for Sonnet-grade work); `swift-generalist` is the pinned
equivalent. The same rule applies to verifier spawns below. Plugin installs
namespace agent types — if a bare name errors "Agent type not found", retry
as `apple:<name>` (e.g. `apple:hig-reviewer`) before treating agents as
unavailable.

**If the agents are unavailable in this environment** (spawn fails — common in
cloud/remote sessions without `~/.claude/agents/` or vendored
`.claude/agents/`, or right after vendoring: definitions load at session
start): apply the degraded-mode guard in
`~/.claude/swiftship-templates/_conventions/AGENT-VENDORING.md` — tell the
user, ask before proceeding, banner `REVIEW.md` as **DEGRADED**, and log the
outcome as `"partial"` with `"degraded":"no-agents"`. **Substituting
`general-purpose` for the named agents is degraded mode too**, even with a
per-call `model` override — the specialist reviewers are gone. Keep the
override if proceeding (it preserves the cost pin), but the run gets the same
ask, banner, and ledger fields. A substituted or single-pass self-review must
never be indistinguishable from the full verified gate.

### Agent 1: Code Quality Review

```
Task({
  subagent_type: "swift-generalist",
  prompt: `
    Review Swift code quality for this Apple app.

    Reference skills: swift/concurrency-patterns (for async/await and actor patterns), swift/memory (for retain cycle and memory analysis), testing/test-contract (for protocol conformance testing)

    Examine:
    1. **Swift Patterns**
       - Modern Swift (async/await, actors, @Observable)
       - Proper use of optionals (no force unwraps without good reason)
       - Value types vs reference types
       - Protocol-oriented design

    2. **Memory Management**
       - Potential retain cycles (closures, delegates)
       - Proper use of weak/unowned
       - Large allocations

    3. **Error Handling**
       - Proper error propagation
       - User-facing error messages
       - Recovery strategies

    4. **SwiftUI Patterns**
       - @Observable vs ObservableObject
       - Proper state management
       - View composition
       - Environment usage

    5. **SwiftData/Persistence**
       - Model design
       - Query efficiency
       - Relationship handling

    6. **Test Coverage**
       - Existing test quality and coverage gaps
       - Protocol contracts without test suites
       - Missing regression tests for critical paths

    7. **SOLID Principles**
       - SRP: Classes/structs doing too much (e.g. view handling business logic, service doing orchestration + persistence)
       - OCP: Hard-to-extend switch statements or if-else chains that grow with new cases
       - DIP: Concrete service dependencies instead of protocols (hurts testability)
       - Flag files with multiple responsibilities or God objects

    8. **DRY Violations**
       - Duplicated view components across files (same layout/styling repeated)
       - Duplicated logic (same validation, formatting, or data transform in multiple places)
       - Opportunities to extract shared components, modifiers, or helpers
       - **Reimplemented helpers:** if .planning/UTILITIES.md exists, flag
         code that duplicates a listed helper (e.g. formats a Decimal by hand
         while PriceFormatter exists; builds a URLRequest outside the listed
         client) — cite both the duplicate and the helper it should use.
         Shared helpers missing from UTILITIES.md: note them as a Low
         finding ("add to inventory") so agents learn to reuse them

    9. **Design System (restyle cost)**: rules from
       ~/.claude/swiftship-skills/design/design-system/SKILL.md
       - Hardcoded colors (Color.white.opacity, Color(white:), hex colors) outside design tokens
       - Hardcoded font sizes (.font(.system(size:))) outside design tokens
       - Hardcoded spacing/radius values outside design tokens
       - Check that a centralized design tokens file exists and is used consistently
       - **Case or letter spacing at call sites:** .uppercased() on displayed
         text, .textCase(, .tracking(, .kerning( outside the text-style
         definition. Also flag user-generated text forced into a case
       - **Custom fonts not bundled:** names in UIAppFonts /
         ATSApplicationFontsPath with no matching font file in the project,
         or custom fonts used with no debug-time registration check. A missing
         font silently falls back to the system font (High: shipped visual bug)
       - **Tokens named by appearance** (grey600, label2, tagSemibold) rather
         than role (textSecondary, actionPrimaryBackground)
       - **Oversized view files:** over ~300 lines → Low; over ~500 → Medium.
         Name the sections to split out
       - **Ad-hoc state UI:** screens that hand-build spinners or "No
         results" text instead of the shared ContentStateView (or, if there
         is none, several screens each building their own)
       - **UI tests matching visible text** (app.buttons["Save"],
         staticTexts["Welcome"]) instead of accessibilityIdentifier. Copy
         and case changes break them
       - **Status enums without an unknown fallback:** a Decodable
         String-backed enum decoded from server/CloudKit data with no
         `.unknown` case, which fails decoding when the server adds a value
       Platform scope: skip Dynamic Type items for macOS; on watchOS check
       compact styles instead.

    10. **Logging Hygiene**
        - print() statements in non-preview production code (should use os.Logger)
        - Sensitive data in log output (emails, tokens, passwords)
        - Check that Logger categories exist for each service layer

    11. **Simplicity (could this be less code?)**
        - Abstractions with one caller or one conformer (protocol, generic, wrapper)
        - Speculative generality: configuration, hooks, or parameters nothing uses
        - Defensive handling for cases that cannot occur given the types/callers
        - Dead code, commented-out code, unused helpers
        - Report the concrete deletion ("remove protocol X, use struct Y directly")
        Do NOT suggest adding defensive code as a fix for anything below High —
        only recommend added handling for a failure that can actually occur.

    Output findings in this format:

    ## Code Quality Review

    ### 🔴 Critical
    [Issues that could cause crashes or data loss]

    ### 🟠 High
    [Significant issues affecting reliability]

    ### 🟡 Medium
    [Code smells and improvements]

    ### 🟢 Suggestions
    [Nice-to-have improvements]
  `
})
```

### Agent 2: HIG Compliance Review

```
Task({
  subagent_type: "hig-reviewer",
  prompt: `
    Review Human Interface Guidelines compliance for this Apple app.

    Reference existing skills:
    - ios/ui-review
    - macos/ui-review-tahoe
    - ios/accessibility-audit    (audit criteria + the nine Nutrition Label features; a full
                                  audit with XCUITest + label declaration is /apple:accessibility)
    - ios/assistive-access
    - ios/navigation-patterns
    - design/ux-writing          (copy pass: labels, alerts, empty states, feature names)
    - visionos/spatial-design    (visionOS targets only: eye-target sizes, motion comfort, hover rules)

    Check:
    1. **Navigation**
       - Platform-appropriate patterns
       - Back button behavior
       - Tab bar usage (3-5 items)
       - Modal presentation

    2. **Layout & Spacing**
       - Standard margins (16pt iOS)
       - Touch targets (≥44pt)
       - Safe area handling
       - Responsive design

    3. **Typography**
       - Dynamic Type support
       - System fonts
       - Proper hierarchy

    4. **Color**
       - System colors for Dark Mode
       - Contrast ratios (4.5:1 text)
       - Color not sole indicator

    5. **Accessibility**
       - VoiceOver labels
       - Accessibility traits
       - Reduce Motion support

    Output findings with specific HIG references.
  `
})
```

### Agent 3: App Store Guidelines Review

```
Task({
  subagent_type: "app-store-reviewer",
  prompt: `
    Review App Store Review Guidelines compliance.

    Reference existing skill: release-review/, growth/analytics-interpretation

    Check:
    1. **Safety (1.x)**
       - Objectionable content
       - User-generated content moderation
       - Physical harm prevention

    2. **Performance (2.x)**
       - App completeness
       - Beta/test/demo references
       - Accurate metadata
       - Hardware compatibility

    3. **Business (3.x)**
       - In-app purchase rules
       - Subscription requirements
       - Advertising guidelines

    4. **Design (4.x)**
       - Copycat concerns
       - Minimum functionality
       - Apple branding usage

    5. **Legal (5.x)**
       - Privacy requirements
       - Data collection disclosure
       - Intellectual property
       - Gambling regulations

    Flag anything that could cause rejection.
  `
})
```

### Agent 4: Performance Review

```
Task({
  subagent_type: "swift-generalist",
  prompt: `
    Review performance concerns for this Apple app.

    Reference skill: performance/profiling (for Instruments-based analysis)

    Check:
    1. **Main Thread**
       - UI updates on main thread
       - Heavy work off main thread
       - Potential blocking calls

    2. **Memory**
       - Large image handling
       - Cache management
       - Memory warnings handling

    3. **Launch Time**
       - App delegate/scene delegate work
       - Lazy initialization
       - Async startup tasks

    4. **SwiftUI Efficiency**
       - Unnecessary redraws
       - Complex view hierarchies
       - Proper use of @State vs @Binding

    5. **Network**
       - Efficient API calls
       - Proper caching
       - Offline handling

    Identify specific performance concerns with file:line references.
  `
})
```

### Agent 5: Security Quick-Check

```
Task({
  subagent_type: "swift-generalist",
  prompt: `
    Quick security scan for this Apple app.

    Reference skills:
    - security/privacy-manifests/ (privacy manifest audit; general secure-storage/auth/network guidance is native model knowledge)

    Quick checks:
    1. **Sensitive Data Storage**
       - Secrets in source code (API keys, tokens)
       - UserDefaults used for sensitive data
       - Proper Keychain usage

    2. **Network Security**
       - ATS configuration
       - HTTP vs HTTPS usage
       - API key exposure in URLs

    3. **Privacy Manifest**
       - PrivacyInfo.xcprivacy presence
       - Required Reason APIs declared

    4. **Common Vulnerabilities**
       - SQL injection (if using raw queries)
       - Insecure deserialization
       - URL scheme hijacking

    This is a quick scan — for full audit, recommend /apple:security.

    Output findings with severity levels and specific file:line references.
  `
})
```

## Coverage Check (changed files no reviewer examined)

Verification below only challenges what reviewers *reported*; it can't catch
what they never looked at. Before verifying, close that gap cheaply:

1. **Examined set** = every file in the five `Files examined:` footers, plus
   every file cited in a finding's `file:line`.
2. **Unexamined** = Review Scope files − examined set. None → note
   `Coverage: all [N] changed files examined` and continue.
3. **One sweep spawn** — `swift-generalist`, Sonnet pin (no `model`
   parameter), over the unexamined files only. If more than 20, take the 20
   with the largest diffs and list the rest in REVIEW.md as unreviewed.
   ```
   Task({
     subagent_type: "swift-generalist",
     prompt: `
       These changed Swift files were not examined by this review's five
       reviewers: [list]. Read each one and report only REAL problems —
       correctness, crashes/data loss, security or privacy, concurrency, App
       Store rejection risks, HIG violations. Every finding needs a
       file:line and the quoted code. Do NOT report style, naming, or
       defensive "what if" suggestions; "no issues" is a valid answer.
       [lint skip-list block]
       Use the same severity format as the other reviewers.
     `
   })
   ```
4. Merge its findings into the pool **before** the next step — a Critical or
   High from the sweep goes through the same adversarial verification (2×
   Opus for Critical) as any other; the needlessly-defensive filter applies
   to its Medium/Low.

This check only covers files nobody read — it never re-reviews examined
files or asks reviewers to find more in what they already covered.

## Verify Critical & High Findings (Foreman)

A false Critical pauses `/apple:autonomous`; a false High gets "fixed" inline — both are worse than a missed nitpick. Before compiling results, adversarially verify every Critical and High finding against the actual code. Medium/Low findings skip verification (they are backlog either way).

If the 5 agents produced no Critical or High findings, skip straight to Compile Results.

| Claimed severity | Verifiers | Verdict rule |
|---|---|---|
| Critical | 2 independent spawns, each escalated to Opus (`model: "opus"`) | Both confirm → stays Critical. Split verdict → High, with a note. Both refute → refuted. |
| High | 1 (batch all High findings from one review area into one spawn), Sonnet pin | Confirmed → stays High. Real but overstated → Medium, with a note. Refuted → refuted. |

Rules:
- A finding without a concrete `file:line` cannot be verified — downgrade it to Medium with the note "unverifiable: no file:line".
- Critical findings get separate verifier spawns so the two verdicts stay independent — never one agent issuing both.
- Critical verifiers escalate to Opus via the spawn's `model` parameter (a
  per-spawn override of the agent's Sonnet frontmatter — it applies to that
  spawn only). Rationale: a Sonnet verifier checking a Sonnet reviewer shares
  its blind spots, and a wrong verdict here either pauses `/apple:autonomous`
  (false Critical) or ships a real bug (false confirm). Volume is tiny — the
  few Opus spawns per review are the cheapest rigor in the pipeline. High
  verifiers stay on the Sonnet pin. If the escalated spawn fails (older
  harness, model unavailable), retry once without the `model` parameter and
  note the fallback in the audit appendix — never skip verification.
- Refuted findings are never silently dropped — they go to the "Refuted During Verification" appendix with the reason.

Spawn each verifier with:

```
Task({
  subagent_type: "swift-generalist",
  model: "opus",   // Critical verifiers only — omit this line for High verifiers
  prompt: `
    You are an adversarial verifier. Another reviewer claims the issue(s)
    below exist in this codebase. Your job is to REFUTE each claim if you
    can — you are the check against false alarms, not a second reviewer.
    Do not fix anything; verdicts only.

    <claims>
    [One entry per finding: claimed severity, description, file:line, claimed impact]
    </claims>

    For each claim:
    1. Read the actual code at the cited file:line, plus enough surrounding
       context to judge. Do not trust the claim's quotes — read the file.
    2. Verdict:
       - CONFIRMED — the issue is real and the claimed severity is justified
       - DOWNGRADED — real but overstated; state the severity that fits and why
       - REFUTED — does not exist, misreads the code, or cannot occur; explain why
    3. Evidence is mandatory: quote the decisive line(s). If you cannot find
       the code at the cited location, the verdict is REFUTED with reason
       "code not found at cited location".

    Default to skepticism: if the claim's reasoning does not hold up against
    the code you actually read, refute it.

    Return one block per claim: [VERDICT] [file:line] — [reason, 1–3 lines].
  `
})
```

Apply the verdicts: only confirmed findings keep their severity; downgraded findings move to the fitting section with a "(downgraded from [severity]: [reason])" note; refuted findings go to the appendix.

## Classify Findings for Graduation (enforcement factory)

Prose findings decay; deterministic enforcement compounds. After verification,
classify every surviving finding (all severities):

| Class | Test | Action |
|---|---|---|
| **Mechanical** | A regex or existing SwiftLint rule catches every future instance (force unwraps, `print()` in production code, hardcoded colors/secrets, `ObservableObject` on iOS 17+ targets…) | Draft the rule and offer to install it |
| **Structural** | A project invariant a per-line regex can't express but a source-tree or API scan can — an import outside a module boundary, a network call on an offline-guaranteed path, a registry/content contract drifting from its documented shape | Draft a fitness-function test (`testing/fitness-functions`) and offer to install it in the test target |
| **Judgment** | Needs context neither a linter nor a scan can have (architecture trade-offs, HIG taste, copy, strategy) | Stays prose in REVIEW.md — this is what review is for |
| **One-off** | A single mistake, no recurring pattern | Note only; no rule |

For each **mechanical** finding, draft the enforcement:

- Prefer enabling a **built-in SwiftLint rule** (`force_unwrapping`,
  `force_try`, `force_cast`, …) over writing a regex.
- Else draft a `custom_rules:` entry — name, message, regex, and
  `included:`/`excluded:` scoping so it can't cry wolf: a `print()` rule
  excludes test targets; an `import XCTest` rule includes unit-test paths
  only (**XCUITest legitimately requires XCTest — never ban it globally**).
- Deployment-target-conditional rules (`ObservableObject` → `@Observable`
  applies only to iOS 17+/macOS 14+ targets) get the condition as a YAML
  comment; don't offer them to projects deploying below it.
- **Design-system findings** (check #9: raw font sizes, raw colours,
  numeric spacing/radius, call-site case/tracking) map to the four rules
  shipped in `~/.claude/swiftship-skills/design/design-system/rules/swiftlint.yml`
  (`ds_raw_font_size`, `ds_raw_color`, `ds_raw_spacing`,
  `ds_call_site_case`). Offer those, already fixture-tested, rather than
  drafting new regexes, and for an existing codebase pair them with a
  baseline (`swiftlint lint --write-baseline .swiftlint-baseline.json`) so
  only new code must be clean.
- Never offer a rule that fires on current intentional code: Grep the regex
  against the tree and tighten the scoping until it's quiet everywhere except
  the finding sites.

For each **structural** finding, draft the fitness function instead:

- Pick the pattern from `testing/fitness-functions` — import-boundary
  allowlist scan, runtime sentinel, or contract pin — and draft the Swift
  Testing suite for the app's existing test target.
- **Prove it red on the finding** before offering: the drafted suite must fail
  against the current violation (or, if the finding was already fixed during
  review, fail when the violation is temporarily reintroduced). A fitness
  function that has never failed is unverified.

Then follow the optional-tool handoff convention (detect → preview → confirm →
act → fall back):

1. **Detect** — mechanical: does `.swiftlint.yml` exist (from the pre-pass)?
   Structural: does a unit-test target exist to host the suite?
2. **Preview** — show the exact YAML to append (or the minimal new
   `.swiftlint.yml` if none exists: the drafted rules only, no opinionated
   boilerplate) / the exact test file to add.
3. **Confirm** — one gate: "Install these [N] lint rules into .swiftlint.yml
   / this fitness-function suite into [test target]? They'll catch [summary]
   on every build." (AskUserQuestion)
4. **Act** — merge into `.swiftlint.yml` (create if absent) / Write the suite
   into the test target and run it once to confirm green on current code.
5. **Fall back** — declined, or no write access → the drafted YAML/suite stays
   in REVIEW.md's Graduated section, copy-paste-ready. Never install silently.

## Filter Needlessly Defensive Findings (Medium/Low only)

AI reviewers reliably raise a dozen "what if" suggestions — guard against a
nil that can't be nil, handle an error the API never throws, validate input
the type system already constrains. Fixing them inflates the code and the
next review. Before compiling, set aside every **Medium/Low** finding whose
**only** recommendation is to add defensive handling for a case that cannot
realistically occur. Test each one:

- Can the case actually happen given the types, callers, and platform
  guarantees? (Non-optional types, `@MainActor` isolation, an API that
  documents it doesn't throw, values the app itself constructs.)
- Is there any evidence — a crash report, a test, a real input path — that it
  happens?

No to both → move it to the **🧹 Set Aside — Needlessly Defensive** appendix
(one line each: the claim + why it can't occur). Set-aside findings are not
counted, not backlogged, and never handed to `build` as fixes. When in doubt,
keep the finding.

**Never filter Critical or High** — they have already survived adversarial
verification above. Never filter security, privacy, or data-loss findings at
any severity.

## Compile Results

Before compiling, check one coverage gap: if this phase touched top-level screens, has a **screenshot or filmstrip-mode** `/apple:visual-qa` covered them? All five agents above read code; none see rendered frames, and emergent-layout defects (composition-dependent alignment, unequal-cell grids) hide from every one of them. If uncovered, add the run to Suggestions.

After verification completes, compile the verified findings into `.planning/REVIEW.md`.

**Wording:** write the summary and each Critical/High finding (add a "What this means" line in everyday words: who is affected and how, e.g. "Users who sign out lose unsaved drafts") per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.


```markdown
# Release Review: [App Name]

**Platform**: [from APP.md]
**Review Date**: [today]
**Reviewers**: Claude (code-quality, hig-reviewer, app-store-reviewer, performance, security) + adversarial verification of Critical/High

**In plain words:** [One or two sentences: is the code safe to ship, the most important problem in everyday words, and what you need to do.]

## Summary

| Priority | Count | Status |
|----------|-------|--------|
| Critical | [count, verified] | ⬜ Pending |
| High | [count, verified] | ⬜ Pending |
| Medium | [count] | ⬜ Pending |
| Low | [count] | ⬜ Pending |

**Verification:** [N] Critical / [M] High claimed → [n] confirmed, [d] downgraded, [r] refuted

**Lint baseline:** [N rules enforced — matching findings skipped / none — no .swiftlint.yml]

**Coverage:** [N] changed files since [base: last review / merge-base / first review] — [M] examined by reviewers, [K] swept, [U] unreviewed (over the 20-file sweep cap: [list])

**Overall Status:** [Ready / Issues Found / Not Ready]

---

## 🔴 Critical Issues

[Compiled from all agents]

---

## 🟠 High Priority

[Compiled from all agents]

---

## 🟡 Medium Priority

[Compiled from all agents]

---

## 🟢 Suggestions

[Compiled from all agents]

---

## ⚙️ Graduated to Enforcement

[One entry per mechanical finding: the finding → the rule that now catches it →
`Installed ✅` or `Offered ⬜` with the copy-paste YAML. One entry per
structural finding: the invariant → the fitness-function suite that now pins
it → `Installed ✅` (proven red on the violation, green on current code) or
`Offered ⬜` with the copy-paste test file. Findings listed here also keep
their severity entry above until fixed — enforcement prevents recurrence, it
doesn't fix the instance. Omit the section if nothing was mechanical or
structural.]

---

## 🧹 Set Aside — Needlessly Defensive

[One line per Medium/Low finding filtered out: the claim + why the case can't
occur. Not counted, not backlogged, not fixed. Omit if none.]

---

## 🚫 Refuted During Verification

[One line per refuted claim: original severity, the claim, and the verifier's refutation reason. Omit this section if nothing was refuted. Kept for audit — a pattern of refutations from one review area means that area's prompt needs tuning.]

---

## ✅ Strengths

[Positive findings from review]

---

## Recommended Action Plan

[Prioritized list of fixes]
```

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent).

**Wording:** write the completion message per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.

```
📋 Review complete!

[One plain sentence: safe to ship or not, and the main reason.]

Created: .planning/REVIEW.md

Summary:
- 🔴 Critical: [count] (verified)
- 🟠 High: [count] (verified)
- 🟡 Medium: [count]
- 🟢 Low: [count]
- ⚙️ Graduated to enforcement: [count] lint rules + [count] fitness functions ([installed] installed, [offered] offered)
- 🚫 Refuted in verification: [count]
- 🧹 Set aside as needlessly defensive: [count]
- 🔍 Coverage: [M]/[N] changed files examined by reviewers, [K] swept[, U unreviewed]

[If critical issues exist:]
⚠️ Critical issues found - must fix before release.
Review .planning/REVIEW.md for details.

[If no critical issues:]
✅ No critical issues! Ready for TestFlight.
Run /apple:testflight to prepare beta release.

You need to decide: [short list | Nothing for you to decide.]
```
