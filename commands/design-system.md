---
description: Set up the design system before any screens — role-named tokens, text styles that carry case, bundled fonts, shared components with ContentStateView, and SwiftLint rules with a shrinking baseline. Writes .planning/DESIGN-SYSTEM.md.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion, mcp__figma__get_variable_defs
argument-hint: "[figma-url | tokens.json | DESIGN_SYSTEM.md]"
---

# Design System Setup

Projects that build screens first and extract a design system later (or never)
turn every restyle into a hand-edit across hundreds of call sites. This
command sets the system up **before the first UI phase**, or as phase 1 of a
redesign, so later restyles are token edits.

**When:** after `/apple:roadmap`, before planning the first UI phase. For an
existing app, after `/apple:map` (it reads the design-debt score), as the
first step of a redesign or of `/apple:debt design`.

## Arguments

- `$1` (optional): the design source. Either a Figma file URL, an exported
  variables/tokens JSON, or a `DESIGN_SYSTEM.md` spec. Empty means detect,
  then interview.

## Prerequisites

```
Read: .planning/APP.md          # platforms + min OS (decides Dynamic Type, ContentUnavailableView, etc.)
Read: .planning/CODEBASE.md     # optional — existing tokens + the "Design Debt" section from /apple:map
Read: .planning/UTILITIES.md    # optional — existing tokens/components to keep, not duplicate
Read: .planning/PREFERENCES.md  # optional — component style, structure
Read: .planning/DESIGN-SYSTEM.md  # optional — exists → UPDATE mode (add/rename, never wipe)
```

Load the rules this command implements:
```
Read: ~/.claude/swiftship-skills/design/design-system/SKILL.md
Read: ~/.claude/swiftship-skills/design/typography/SKILL.md   # custom-font scaling, Dynamic Type
```

**Existing project with tokens already** (CODEBASE.md / UTILITIES.md list a
`Theme`, `Spacing`, colour extension…)? **Extend and rename toward role names;
never create a parallel second system.** Note the renames in DESIGN-SYSTEM.md.

## Step 1: Design Input

Use the first source available:

1. **Figma**: per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`.
   - **Detect:** is a Figma MCP connected with a variables tool
     (`mcp__figma__get_variable_defs`)?
   - **If yes:** read the file's colour/number variables and text styles.
   - **If not:** ask for an export (Figma Variables JSON / Tokens Studio JSON)
     as `$1`.
   - Never ask for a personal access token in chat.
2. **Spec file**: a `DESIGN_SYSTEM.md` from `product/ux-spec`, or the path in `$1`.
3. **Short interview** (`AskUserQuestion`, one round): brand/accent colour(s),
   font (system SF, or a custom font file you'll provide), density
   (compact/regular/airy → spacing scale), corner style (sharp/soft/round →
   radius scale), and label style (e.g. small uppercase tracked labels, yes/no).

Record the source and its **version or date** (Figma version name, file date, or
"interview [date]"). Phases are built against that version
(design-system skill, rule 21).

## Step 2: Tokens (role-named)

Write one token file per kind under `[App]/DesignSystem/`. The lint rules
skip this folder, so it's the only place raw values may live.

- **Colours:** asset-catalog colour sets with light/dark (and
  high-contrast if given). Names mirror the designer's variables by **role**:
  `Text/Primary` → `textPrimary`, `Action/Primary/Background` →
  `actionPrimaryBackground`. Add a `Color` extension exposing each one.
  Never use appearance names (`grey600`, `blue2`).
- **Scales:** `Spacing` (`xxs…xxl`), `Radius` (`s/m/l/pill`), `Shadow`, and
  `IconSize`, as small enums with `static let` values.
- **Map every designer name → code name → value** into DESIGN-SYSTEM.md
  (Step 7).

## Step 3: Text Styles + Fonts

- **Text styles:** `AppTextStyle` carrying family, size, weight, line
  height, tracking **and case**, plus one `.appText(_:)` modifier and an
  `.original` variant for user-generated text (skill: Styling, rule 3).
  Keep it to the designer's styles; don't invent extra ones.
- **Custom font:**
  - copy the font files into the project and add them to the target
  - register them: iOS `UIAppFonts`, macOS `ATSApplicationFontsPath`
  - scale with `Font.custom(_:size:relativeTo:)` on iOS/watchOS
  - add the **debug-time registration check** from the skill and call it at
    launch
  A declared-but-missing font silently falls back to the system font, so
  confirm the check passes in Step 6.
- **System font only:** text styles wrap `.system(.body, …)` text styles,
  so Dynamic Type comes for free.

## Step 4: Shared Components

Spawn **one** `swiftui-builder` (bare name; retry `apple:swiftui-builder` on
"Agent type not found") with:
- the token map and text styles from Steps 2–3
- the skill's Components section
- APP.md's platforms/min OS
- the `<existing-helpers>` block from UTILITIES.md, if present

Ask for the components the app actually needs, from this set:
- button style (primary/secondary/destructive + loading + disabled)
- card, chip
- text field with error state, search field
- sheet and confirm sheet
- toast with undo
- **`ContentStateView`**: always build this one

Each component gets `#Preview`s for its variants and states. If the project
has a snapshot setup (`testing/snapshot-test-setup`, `__Snapshots__/`), add
one snapshot test per component; otherwise note it as a follow-up.
Components go in `[App]/DesignSystem/Components/`.

Verify the agent's work **yourself** (build + previews compile), as
`/apple:build` Step 4 does. A self-report is not evidence.

## Step 5: Lint

Merge `~/.claude/swiftship-skills/design/design-system/rules/swiftlint.yml`
(`ds_raw_font_size`, `ds_raw_color`, `ds_raw_spacing`, `ds_call_site_case`)
into `.swiftlint.yml`, creating it if absent. Show the diff first. If your
token folder isn't named `DesignSystem/`, `Tokens/`, `Theme/` or `Styles/`,
adjust the rules' `excluded:` paths.

- **New app:** no baseline. Every screen must be clean from day one.
- **Existing app:** freeze current violations so only new code must be clean:
  ```bash
  swiftlint lint --write-baseline .swiftlint-baseline.json
  ```
  Record the baseline's violation count in DESIGN-SYSTEM.md, because that's
  the number `/apple:debt` will shrink. The baseline may only shrink; never
  re-write it to absorb new violations.

## Step 6: Reference Screen (existing apps)

**Existing app:** migrate **one** screen end to end as the worked example.
Pick a screen that is visible, medium-sized, and high in CODEBASE.md's
design-debt table. The migration:
- tokens and text styles only
- shared components
- `ContentStateView` for its states
- `accessibilityIdentifier`s
- state previews

Behavior must not change: run its tests before and after, and if it has
none, add a characterization test first
(`testing/characterization-test-generator`). Remove the file from the
baseline once it's clean.

**New app:** skip. The first UI phase uses the system from the start.

Then verify:
- the build passes
- `swiftlint lint --strict [--baseline …]` passes
- in a debug run, the font check passes (no assert)

Optionally capture a screenshot via
`~/.claude/swiftship-templates/_conventions/RUN-AND-SHOT.md`.

## Step 7: Record It

- **`.planning/DESIGN-SYSTEM.md`:** write it from
  `~/.claude/swiftship-templates/DESIGN-SYSTEM.md`. It holds the source and
  version, token map, text styles, scales, components, fonts, lint status and
  the reference-screen result.
- **`.planning/UTILITIES.md`:** add a row per token file, the text-style
  modifier, and each component under **Design Tokens** and **Shared Views &
  Modifiers**, so every build agent reuses them.
- **Project `CLAUDE.md`:** add one line under Conventions, unless an
  equivalent is present:
  `- Styling: tokens + .appText only — see .planning/DESIGN-SYSTEM.md (lint enforces it)`
- **Commit:** stage by explicit path, never `git add -A`. That covers the
  `DesignSystem/` folder, the font files, the Info.plist,
  `.swiftlint.yml` / baseline, the reference screen, and the three planning
  files.

## Platform Notes

- **iOS / iPadOS:** Dynamic Type through `relativeTo:`; `@ScaledMetric` for
  spacing that grows with type; components adapt to size classes.
- **macOS:** no Dynamic Type, so design at 100%. Use semantic `NSColor`
  equivalents in the asset catalog. Every interactive component has hover
  and focus states and respects `.controlSize`.
- **watchOS:** compact text styles and a smaller spacing scale. Components
  are sized for glanceable states; skip glass-heavy treatments.
- `ContentUnavailableView` needs iOS 17 / macOS 14 / watchOS 10. Below that,
  `ContentStateView` builds its states from a `VStack`.

## Completion Message

```
🎨 Design system ready

Source:      [Figma "[file]" v[version] | tokens.json [date] | interview [date]]
Tokens:      [n] colours (role-named) · spacing [xxs…xxl] · radius [s/m/l/pill]
Text styles: [n] ([names]) · font: [SF | Custom — bundled ✅, registration check ✅]
Components:  [list] + ContentStateView ([n] snapshot tests | snapshots: follow-up)
Lint:        4 design rules · [new app: no baseline | baseline [n] violations to shrink]
Reference:   [Screen] migrated — [before]% → 0% raw styling | n/a (new app)

Created: .planning/DESIGN-SYSTEM.md · updated UTILITIES.md, CLAUDE.md

Next:
- /apple:plan [first UI phase]: build screens on the system
- [existing app] migrate the remaining screens area by area: /apple:debt design
```
