---
description: Audit the app for accessibility and declare App Store Accessibility Nutrition Labels — automated XCUITest audits, a static scan, the manual assistive-tech passes, then a gated per-device-family label declaration via the ASC API. The compliance gate for the EU Accessibility Act.
argument-hint: "[audit | labels | fix] — omit to run the full audit, then offer the labels step"
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion, Skill, mcp__asc-metadata__list_apps, mcp__asc-metadata__get_metadata, mcp__asc-metadata__update_accessibility
---

# Accessibility Audit & Nutrition Labels

Two jobs, one loop: prove the app is usable with the assistive technologies people actually
use, then declare what you support on the App Store product page. Accessibility Nutrition
Labels make that support (or its absence) visible **before** download, so the claim has to be
true — and the EU Accessibility Act has applied to consumer apps in the EU market since
June 2025.

**Every ASC write is gated**: read → diff → explicit OK → `dryRun` → apply. A published label
is a public claim about your app.

## Arguments

- *(none)* — run the full audit (phases 1–5), then offer the labels step.
- `audit` — phases 1–4 only. No ASC calls.
- `labels` — skip to phase 5–6: evaluate claims against an existing `.planning/ACCESSIBILITY.md`, then declare.
- `fix` — take the findings in `.planning/ACCESSIBILITY.md` and implement them.

## Prerequisites

```
Glob: **/*.swift
Read: .planning/APP.md (if exists)
Read: .planning/STATE.md (if exists)
```

If no Swift files found:
```
⚠️ No Swift files found. Build your app first with /apple:build
```

For `labels`: a live app; `appId` resolvable from `STATE.md`, else `list_apps` + confirm.

## Load Skills

```
Read: ~/.claude/swiftship-skills/ios/accessibility-audit/SKILL.md
Read: ~/.claude/swiftship-skills/ios/accessibility-audit/automated-audits.md
Read: ~/.claude/swiftship-skills/ios/accessibility-audit/nutrition-labels.md
```

For the `fix` path, also load the implementation patterns:
```
Read: ~/.claude/swiftship-skills/generators/accessibility-generator/SKILL.md
Read: ~/.claude/swiftship-skills/generators/accessibility-generator/accessibility-patterns.md
```

macOS targets — add the Mac-specific depth:
```
Read: ~/.claude/swiftship-skills/macos/ui-review-tahoe/accessibility.md
```

## Phase 1: Define Common Tasks

Everything downstream is evaluated **per common task**, so get this right first.

From `.planning/APP.md` (and `AskUserQuestion` if it's thin), list:
- The primary functionality people download the app for.
- The fundamentals, always included: **first-launch experience, login, purchase, settings**.

Record the list in the report. A feature can only be claimed if **all** common tasks work with it,
on **every device family the app supports**.

## Phase 2: Automated Audit (XCUITest)

Generate or extend a UI test that audits each distinct screen — audits only see what's on screen,
so one audit per screen state.

```swift
func testAccessibility_DetailScreen() throws {
    let app = XCUIApplication()
    app.launch()
    app.buttons["Show Detail"].tap()
    continueAfterFailure = true                  // surface ALL issues, not just the first
    try app.performAccessibilityAudit(for: .all) { issue in
        // return true ONLY to ignore a known, accepted issue — never to reach green
        false
    }
}
```

Run it and parse the failures:
```
Bash: xcodebuild test -scheme [scheme] -destination 'platform=iOS Simulator,name=[device]' \
      -only-testing:[UITestTarget]/AccessibilityAuditTests 2>&1 | tail -60
```

Map each `XCUIAccessibilityAuditIssue` to its audit type: `.contrast`, `.elementDetection`,
`.hitRegion`, `.sufficientElementDescription`, `.dynamicType`, `.textClipped`, `.trait`.

If the project has no UI test target, say so and offer to create one (`/apple:test`) rather than
silently skipping the phase.

## Phase 3: Static Scan

Grep the source for the failure patterns the audit can't see on screens you didn't navigate to:

```
Grep: Image\(systemName:.*\)(?!.*accessibilityLabel)   # icon-only buttons with no label
Grep: \.lineLimit\(1\)                                  # truncation at accessibility sizes
Grep: \.font\(\.system\(size:                           # hardcoded sizes that don't scale
Grep: accessibilityLabel\("[A-Z_]{4,}"\)                # technical IDs used as spoken labels
```

Also flag: color-only state (no shape/icon/text), `.accessibilityHidden(true)` on interactive
elements, custom controls with no `accessibilityRepresentation` or traits, and gesture-only
interactions with no `accessibilityAction`.

## Phase 4: Manual Pass Checklist

The audit is the floor, not the ceiling — Apple is explicit that turning on VoiceOver and
Dynamic Type remains the best validation. Emit a per-common-task checklist the user runs:

| Pass | Setting | Pass criterion |
|---|---|---|
| VoiceOver | Settings ▸ Accessibility ▸ VoiceOver | Every element speaks label + trait + value; task completable eyes-free |
| Voice Control | Settings ▸ Accessibility ▸ Voice Control | Every control is nameable by voice |
| Larger Text | 200%, then max (310%) | Text wraps (never truncates), fields grow, layout adapts |
| Sufficient Contrast | Increase Contrast on; light + dark | Legible everywhere (4.5:1 body-text floor) |
| Dark Interface | Dark mode + Smart Invert | Photos/video NOT inverted |
| Reduced Motion | Reduce Motion on | No zoom/slide/parallax/autoplay triggers; animations modified, not just removed |

## Phase 5: Nutrition Label Evaluation

Map the evidence from phases 2–4 onto the nine App Store features, per device family:

VoiceOver · Voice Control · Larger Text · Sufficient Contrast · Dark Interface ·
Differentiate Without Color Alone · Reduced Motion · Captions · Audio Descriptions

Three rules, non-negotiable:
- **Fix first, claim after.** A feature with open 🔴/🟠 findings is "Fix first", not "Claim".
- **N/A ≠ supported.** No video/audio content → leave Captions and Audio Descriptions unclaimed.
- **All tasks, all device families.** One failing common task on iPad sinks the claim for iPad.

## Phase 6: Declare the Labels (gated)

Only on the `labels` path, or after the user opts in at the end of a full run.

1. **Read** current state — `mcp__asc-metadata__update_accessibility` with `listOnly: true` (per `appId`).
2. **Diff** — show current declaration vs. what phase 5's evidence supports, per `deviceFamily`
   (`IPHONE`, `IPAD`, `MAC`, `APPLE_WATCH`, `APPLE_TV`, `VISION`).
3. **Confirm** — one `AskUserQuestion` with the exact claim set. Never infer consent.
4. **Dry-run** — `dryRun: true`, show the payload.
5. **Apply** — re-call without `dryRun`. `publish: true` only on a second explicit OK.

```
mcp__asc-metadata__update_accessibility(
  appId: [id], deviceFamily: "IPHONE",
  supportsVoiceover: true, supportsVoiceControl: true,
  supportsLargerText: false,          # ← open truncation finding: fix first
  supportsSufficientContrast: true, supportsDarkInterface: true,
  supportsDifferentiateWithoutColorAlone: true, supportsReducedMotion: true,
  supportsCaptions: false, supportsAudioDescriptions: false,   # ← no media content: N/A
  dryRun: true
)
```

**Never** claim a feature the audit didn't support, even if the user asks — say what's missing
and offer `/apple:accessibility fix`.

## Output

Generate `.planning/ACCESSIBILITY.md`:

```markdown
# Accessibility Audit: [App Name]

**Platform(s)**: [from APP.md]
**Audit Date**: [today]
**Scope**: [full / audit / labels]

## Common Tasks Evaluated
1. [primary flow]
2. First launch · 3. Login · 4. Purchase · 5. Settings

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| 🔴 Critical | [n] | ⬜ Pending |
| 🟠 High | [n] | ⬜ Pending |
| 🟡 Medium | [n] | ⬜ Pending |
| 🟢 Low | [n] | ⬜ Pending |

---

## 🔴 Critical
[Blocks an assistive-tech user from completing a common task — unlabeled control on the
purchase path, VoiceOver trap, text that doesn't scale]

## 🟠 High
[Puts a feature claim at risk — truncation at accessibility sizes, color-only state]

## 🟡 Medium
[Friction — reading order, unclear labels, missing rotors/actions]

## 🟢 Low
[Polish — verbosity, missing input-label synonyms, hint quality]

## ✅ Strengths
[What passed, and which pass proved it]

---

## Nutrition Label Claims

| Feature | iPhone | iPad | Evidence / blocker |
|---|---|---|---|
| VoiceOver | ✅ Claim | ✅ Claim | All tasks completed eyes-free |
| Larger Text | ⚠️ Fix first | ⚠️ Fix first | Description truncates at 310% (🟠 #3) |
| Captions | — N/A | — N/A | No media content |
| … | | | |

**Declared in App Store Connect**: [yes — date / not yet]

---

## Action Plan
[Prioritized fixes; each names the audit pass that will detect the regression]
```

## Completion Message

```
♿️ Accessibility audit complete!

Created: .planning/ACCESSIBILITY.md

Findings: 🔴 [n] · 🟠 [n] · 🟡 [n] · 🟢 [n]
Claimable now: [k] of 9 features   |   Fix first: [m]   |   N/A: [j]

[If critical:]
⚠️ Critical issues block common tasks — fix before claiming any feature.

Next:
- /apple:accessibility fix       Implement the findings
- /apple:accessibility labels    Declare the labels in App Store Connect (gated)
- /apple:visual-qa               Broader UI/HIG pass
```
