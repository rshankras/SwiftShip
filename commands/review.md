---
description: Run comprehensive code, HIG, and App Store review
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion
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

    9. **Design Token Centralization**
       - Hardcoded colors (Color.white.opacity, Color(white:), hex colors) outside design tokens
       - Hardcoded font sizes (.font(.system(size:))) outside design tokens
       - Hardcoded spacing/radius values outside design tokens
       - Check that a centralized design tokens file exists and is used consistently

    10. **Logging Hygiene**
        - print() statements in non-preview production code (should use os.Logger)
        - Sensitive data in log output (emails, tokens, passwords)
        - Check that Logger categories exist for each service layer

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

## Compile Results

Before compiling, check one coverage gap: if this phase touched top-level screens, has a **screenshot or filmstrip-mode** `/apple:visual-qa` covered them? All five agents above read code; none see rendered frames, and emergent-layout defects (composition-dependent alignment, unequal-cell grids) hide from every one of them. If uncovered, add the run to Suggestions.

After verification completes, compile the verified findings into `.planning/REVIEW.md`:

```markdown
# Release Review: [App Name]

**Platform**: [from APP.md]
**Review Date**: [today]
**Reviewers**: Claude (code-quality, hig-reviewer, app-store-reviewer, performance, security) + adversarial verification of Critical/High

## Summary

| Priority | Count | Status |
|----------|-------|--------|
| Critical | [count, verified] | ⬜ Pending |
| High | [count, verified] | ⬜ Pending |
| Medium | [count] | ⬜ Pending |
| Low | [count] | ⬜ Pending |

**Verification:** [N] Critical / [M] High claimed → [n] confirmed, [d] downgraded, [r] refuted

**Lint baseline:** [N rules enforced — matching findings skipped / none — no .swiftlint.yml]

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

```
📋 Review complete!

Created: .planning/REVIEW.md

Summary:
- 🔴 Critical: [count] (verified)
- 🟠 High: [count] (verified)
- 🟡 Medium: [count]
- 🟢 Low: [count]
- ⚙️ Graduated to enforcement: [count] lint rules + [count] fitness functions ([installed] installed, [offered] offered)
- 🚫 Refuted in verification: [count]

[If critical issues exist:]
⚠️ Critical issues found - must fix before release.
Review .planning/REVIEW.md for details.

[If no critical issues:]
✅ No critical issues! Ready for TestFlight.
Run /apple:testflight to prepare beta release.
```
