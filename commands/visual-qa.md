---
description: Visual QA from screenshots or code-level UI audit
argument-hint: [screenshot-paths or "code"]
allowed-tools: Read, Write, Glob, Grep, Bash, AskUserQuestion, Skill
---

# Visual QA

Analyze screenshots of your app's UI or scan SwiftUI code for visual anti-patterns. Catches issues that code-only review misses — alignment, spacing, visual hierarchy, dark mode rendering.

## Arguments

- `$ARGUMENTS`: Screenshot file paths, `"code"` for code-only audit, or both. If omitted, asks the user which mode to use.

## Step 1: Load Context

```
Read: .planning/APP.md (if exists)
Read: .planning/STATE.md (if exists)
Read: CLAUDE.md (if exists)
```

Determine the target platform (iOS, macOS, or both) from APP.md. This controls which skills to load.

## Step 2: Determine Mode

Parse `$ARGUMENTS` to determine the analysis mode:

- **Screenshot Mode**: Arguments contain image file paths (`.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.heic`)
- **Code-Only Mode**: Argument is `"code"` or empty
- **Both**: Mix of image paths and `"code"`

If no arguments provided, ask the user:
```
AskUserQuestion:
  "How would you like to run Visual QA?"
  Options:
    - "Capture now" — "Build, launch & screenshot the running app for me"
    - "Screenshot analysis" — "I already have screenshots to analyze"
    - "Code-only audit" — "Scan SwiftUI code for visual anti-patterns"
    - "Both" — "Analyze screenshots and scan code"
```

**If "Capture now" is selected** — optional handoff per
`~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`, using
`~/.claude/swiftship-templates/_conventions/RUN-AND-SHOT.md`:
- DETECT the platform (iOS → `run-simulator` skill; macOS → `xcodebuild` +
  `screencapture`). If neither is available, fall back to "Screenshot analysis"
  and ask the user to supply paths.
- Build, launch, and capture the running app (note the macOS menu-bar/popover
  caveat — open the popover before capturing, or ask the user to click the icon).
- Treat the captured image(s) as the screenshots for **Step 4** below.

If Screenshot Mode selected with no paths (and capture isn't available), ask:
```
AskUserQuestion:
  "Provide screenshot paths (drag files into terminal, or paste paths)"
```

## Step 3: Load Skills

Load platform-appropriate UI review skills:

**For iOS projects:**
```
Read: ~/.claude/swiftship-skills/ios/ui-review/SKILL.md
Read: ~/.claude/swiftship-skills/ios/ui-review/hig-checklist.md
Read: ~/.claude/swiftship-skills/ios/ui-review/accessibility-quick-ref.md
Read: ~/.claude/swiftship-skills/ios/ui-review/font-guidelines.md
Read: ~/.claude/swiftship-skills/ios/accessibility-audit/SKILL.md   # audit criteria for the a11y scan below
```

> This command's accessibility scan is **code + screenshot level**. It cannot run
> `performAccessibilityAudit` or declare Nutrition Labels — for the full audit
> (XCUITest + assistive-tech passes + App Store label declaration) run `/apple:accessibility`.

**All platforms — the layer above HIG mechanics:**
```
Read: ~/.claude/swiftship-skills/design/design-principles/SKILL.md   # wayfinding 3 questions, hierarchy, discoverability
Read: ~/.claude/swiftship-skills/design/typography/SKILL.md          # type hierarchy, Dynamic Type survival
```

**For macOS projects:**
```
Read: ~/.claude/swiftship-skills/macos/ui-review-tahoe/SKILL.md
Read: ~/.claude/swiftship-skills/macos/ui-review-tahoe/macos-tahoe-hig.md
Read: ~/.claude/swiftship-skills/macos/ui-review-tahoe/accessibility.md
Read: ~/.claude/swiftship-skills/macos/ui-review-tahoe/swiftui-macos.md
```

**For all projects (SwiftUI debugging + snapshot testing):**
```
Read: ~/.claude/swiftship-skills/performance/swiftui-debugging/SKILL.md
Read: ~/.claude/swiftship-skills/testing/snapshot-test-setup/SKILL.md
```

## Step 4: Screenshot Analysis (if applicable)

For each screenshot provided, read the image file and perform systematic visual inspection across these 7 categories:

### 4.1 HIG Compliance
- Spacing and alignment (standard margins, consistent gutters)
- Typography hierarchy (title, body, caption are visually distinct)
- System controls used correctly (no custom controls mimicking system ones poorly)
- Navigation bar, tab bar, toolbar conventions

### 4.2 Dark Mode Consistency
- If light/dark pairs provided, compare them side-by-side
- Check for invisible or low-contrast elements in dark mode
- Verify backgrounds, separators, and tints adapt properly

### 4.3 Dynamic Type
- If multiple type-size screenshots provided, check text truncation
- Verify layout adapts without overlapping or clipping
- Check that touch targets remain adequate at larger sizes

### 4.4 Platform Nativeness
- Does it look and feel like a native Apple app?
- Proper use of SF Symbols vs custom icons
- Standard sheet/modal presentation
- Platform-appropriate navigation patterns

### 4.5 Visual Polish
- Pixel-level alignment issues (misaligned baselines, uneven padding)
- Inconsistent spacing between similar elements
- Visual clutter or information density issues
- Icon and image quality (blurry, wrong aspect ratio)

### 4.6 Accessibility
- Sufficient color contrast (4.5:1 for body text, 3:1 for large text)
- Touch targets appear to meet minimum 44pt
- Color is not the sole indicator of state or meaning
- Text readability against backgrounds

### 4.7 State Completeness
- Loading states shown (or note if missing)
- Empty states shown (or note if missing)
- Error states shown (or note if missing)
- Content overflow handling visible

For each finding, note:
- **Category** (from above)
- **Severity**: Critical / High / Medium / Low
- **Screenshot**: which file
- **Location**: describe where in the screenshot
- **Issue**: what's wrong
- **Recommendation**: how to fix

## Step 5: Code Cross-Reference

For each screenshot finding, locate the corresponding SwiftUI code:

```
Grep: [view name or relevant keyword from the screenshot]
Glob: **/*.swift
```

For each finding:
- Identify the specific file and line producing the visual issue
- Suggest a concrete SwiftUI fix with file:line reference
- Reference the appropriate HIG guideline or skill pattern

## Step 6: Code-Only Audit (if applicable)

Scan the SwiftUI codebase for visual anti-patterns using Grep:

### 6.1 Hardcoded Colors (won't adapt to dark mode)
```
Grep: Color\(\s*red:|Color\(\s*\.init\(red:|UIColor\(red:|NSColor\(red:|#[0-9a-fA-F]{6}|\.white(?!\s*\.)(?!Mode)|\.black(?!\s*\.)
```
**Expected**: System colors (`Color.primary`, `Color(nsColor: .controlBackgroundColor)`, `Color(uiColor: .systemBackground)`)

### 6.2 Fixed Font Sizes (won't scale with Dynamic Type)
```
Grep: \.font\(\.system\(size:|\.font\(Font\.custom\(|UIFont\(name:|UIFont\.systemFont\(ofSize:|NSFont\.systemFont\(ofSize:
```
**Expected**: Dynamic Type styles (`.font(.body)`, `.font(.headline)`)

### 6.3 Missing Accessibility Labels
```
Grep: Image\(systemName:|Image\("|AsyncImage\(
```
Cross-reference with:
```
Grep: \.accessibilityLabel\(|\.accessibilityHidden\(
```
Flag images without accessibility labels.

### 6.4 Small Touch Targets
```
Grep: \.frame\(width:\s*[0-3][0-9]|\.frame\(height:\s*[0-3][0-9]|\.frame\(width:\s*4[0-3].*height:\s*4[0-3]
```
Flag interactive elements with frames below 44pt.

### 6.5 Missing View States
Look for views that fetch data but lack loading/empty/error states:
```
Grep: \.task\s*\{|\.onAppear\s*\{|\.refreshable\s*\{
```
Cross-reference with:
```
Grep: ProgressView|EmptyView|ContentUnavailableView|placeholder|emptyState|errorState|isLoading
```

### 6.6 Rigid Fixed-Frame Layouts
```
Grep: \.frame\(width:\s*\d+,\s*height:\s*\d+\)
```
Flag fixed dimensions on views that should be flexible (text containers, list rows, etc.). Exclude icons and images where fixed sizing is appropriate.

For each code finding:
- **File:Line** reference
- **Pattern**: what was detected
- **Severity**: Critical / High / Medium / Low
- **Fix**: concrete code change

## Step 7: Generate Report

Write `.planning/VISUAL-QA.md`:

```markdown
# Visual QA: [App Name]

**Platform**: [from APP.md]
**Date**: [today]
**Mode**: [Screenshot / Code-Only / Both]
**Screenshots Analyzed**: [count, or N/A]

## Summary

| Severity | Screenshot | Code | Total |
|----------|-----------|------|-------|
| 🔴 Critical | [n] | [n] | [n] |
| 🟠 High | [n] | [n] | [n] |
| 🟡 Medium | [n] | [n] | [n] |
| 🟢 Low | [n] | [n] | [n] |

**Overall Visual Quality:** [Excellent / Good / Needs Work / Poor]

---

## 🔴 Critical Issues
[Issues that break usability or accessibility]

---

## 🟠 High Priority
[Significant visual/UX issues]

---

## 🟡 Medium Priority
[Polish and consistency issues]

---

## 🟢 Low Priority / Suggestions
[Nice-to-have improvements]

---

## ✅ Visual Strengths
[What the app does well visually]

---

## Screenshot Findings Detail
[If screenshot mode — per-screenshot breakdown with category, location, issue, and fix]

---

## Code Audit Findings Detail
[If code mode — per-file breakdown with line references and fix suggestions]

---

## Recommended Action Plan

### Immediate (Critical + High)
1. [Fix with file:line reference]

### Next Sprint (Medium)
1. [Fix with file:line reference]

### Backlog (Low)
1. [Fix with file:line reference]

---

## Snapshot Test Recommendations

Based on findings, recommend snapshot tests for:
- [ ] [Screen/component] — catches [issue type]
- [ ] [Screen/component] — catches [issue type]

Reference: `/apple:build` with snapshot-test-setup skill for implementation.
```

## Completion Message

```
👁️ Visual QA complete!

Created: .planning/VISUAL-QA.md

Summary:
- 🔴 Critical: [count]
- 🟠 High: [count]
- 🟡 Medium: [count]
- 🟢 Low: [count]

[If critical issues:]
⚠️ Critical visual issues found — fix before shipping.
Review .planning/VISUAL-QA.md for details and file:line fixes.

[If no critical issues:]
✅ No critical visual issues. App looks solid!

Next steps:
- Fix issues by priority in .planning/VISUAL-QA.md
- Run /apple:visual-qa again after fixes to verify
- Consider adding snapshot tests for regression prevention
- Run /apple:review for full quality review
```
