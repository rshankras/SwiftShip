# Design System Template

Copy this file to your project's `.planning/DESIGN-SYSTEM.md`.

```markdown
# Design System

<!-- Written by /apple:design-system. Build agents read the token map and
     component list; /apple:debt shrinks the baseline count below.
     Rules: ~/.claude/swiftship-skills/design/design-system/SKILL.md -->

**Source:** [Figma "[file]" version "[name]" | tokens.json [date] | interview [date]]
**Pinned:** [date] — phases build against this version; later design changes are change requests
**Platforms:** [iOS 17+ / macOS 14+ / watchOS 10+]
**Location:** `[App]/DesignSystem/`

## Colours

| Designer name | Code | Light | Dark |
|---------------|------|-------|------|
| Text/Primary | `Color.textPrimary` | #111111 | #F5F5F5 |
| Action/Primary/Background | `Color.actionPrimaryBackground` | [value] | [value] |

## Text Styles

Apply with `.appText(.[style])`; user-generated text uses `.appText(.[style].original)`.

| Style | Font | Size / relativeTo | Weight | Line height | Tracking | Case |
|-------|------|-------------------|--------|-------------|----------|------|
| `body` | [Inter / SF] | 17 / .body | regular | +4 | 0 | — |
| `label` | [Inter / SF] | 12 / .caption | semibold | 0 | 0.6 | uppercase |

**Custom fonts:** [files] — registered via [UIAppFonts / ATSApplicationFontsPath]; debug check: `assertCustomFontsRegistered()` ✅

## Scales

| Spacing | xxs | xs | s | m | l | xl | xxl |
|---------|-----|----|---|---|---|----|-----|
| pt | 2 | 4 | 8 | 16 | 24 | 32 | 48 |

| Radius | s | m | l | pill |
|--------|---|---|---|------|
| pt | 6 | 12 | 20 | 999 |

Shadow: [names → values] · IconSize: [names → values]

## Components

| Component | Path | Variants | States | Snapshot |
|-----------|------|----------|--------|----------|
| `ContentStateView` | DesignSystem/Components/ContentStateView.swift | — | loading, empty, error, offline | ✅/— |
| `AppButtonStyle` | [path] | primary, secondary, destructive | loading, disabled | ✅/— |

## Lint

- Rules: `ds_raw_font_size`, `ds_raw_color`, `ds_raw_spacing`, `ds_call_site_case`
- Baseline: [none (new app) | `.swiftlint-baseline.json` — [n] violations on [date]]

| Date | Baseline violations | Design debt (map) |
|------|---------------------|-------------------|
| [date] | [n] | [x]% |

## Reference Screen

[Screen] (`path`) — migrated [date]: [before]% → 0% raw styling; tests: [existing | characterization added]

## Renames (existing apps)

| Old | New | Why |
|-----|-----|-----|
| `Color.grey600` | `Color.textSecondary` | appearance → role |
```

## How to Use

1. **Created by `/apple:design-system`**, before the first UI phase or as phase 1 of a redesign
2. **Read by `/apple:build`** with UTILITIES.md, so agents use the tokens and components instead of rebuilding them
3. **Checked by `/apple:verify`**: the per-screen design definition of done
4. **Shrunk by `/apple:debt design`**: append a row to the Lint table each run
5. Keep the token map in sync when the designer renames a variable: rename in code, then here
