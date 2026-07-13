---
description: Generate an app icon on demand — a fast placeholder + light/dark/tinted variants, and flat layered source ready for Icon Composer (the Liquid Glass / iOS 26+ standard) — at any phase
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: [style]
---

# Generate App Icon

Create or iterate the app icon **on demand, at any phase** — a fast placeholder so early builds / TestFlight / screenshots feel real, or a starting point you finish in Icon Composer. Wraps the `app-icon-generator` skill.

**Reality check (iOS 26 / macOS 26):** the shippable modern icon is a **layered Liquid Glass `.icon`** authored in **Icon Composer** (a GUI tool that ships with Xcode 26). No command can generate that end-to-end. So this command's honest job is to produce a **placeholder flat icon + appearance variants** and **flat layered source art** you hand off to Icon Composer — not to pretend a CoreGraphics PNG is a shippable iOS 26 icon. The Phase 6 (Pre-Release) task + `/apple:submit` gate the final icon.

## Arguments

- `$ARGUMENTS` or `$1`: an optional style/direction hint (e.g. `gradient glyph`, `abstract mark`, `warm, playful`). Empty → the skill interviews you.

## Prerequisites

```
Read: .planning/APP.md      # name, category, audience — seeds the icon's direction (optional)
```

Works with zero planning files. Needs an Xcode project with `Assets.xcassets` to install (without one, it emits the 1024 masters to a folder). **Icon Composer** — for the *final* icon — needs Xcode 26 / macOS Tahoe 26.4+.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/generators/app-icon-generator/SKILL.md
```

## Process

Follow the skill. In short:

1. **Detect the target** — read the deployment target. iOS 26+ / macOS 26+ → treat the output as a *placeholder* and lead with the Icon Composer handoff; older targets → a classic flat icon is fine to ship.
2. **Direction** — via `AskUserQuestion` (or `$1` / `APP.md`): category, style, mood/palette.
3. **Generate** — a CoreGraphics script produces variants at 1024×1024. ⚠️ **No baked specular / shadows / rounded corners** for iOS 26+ — the system applies Liquid Glass lighting and masks the shape; baking them in double-exposes. Read the variants back to compare.
4. **Pick + install** — `sips`-resize and install into `Assets.xcassets/AppIcon.appiconset`, wiring **light / dark / tinted** appearance variants into `Contents.json`.
5. **Validate (hard checks — skill Step 4.6).** Judge every variant at 60–64 px, not 1024; elements adjacent to the icon background must contrast with it; the tinted variant must be strictly grayscale (beware colors hardcoded inside shared draw functions — verify the exported PNG, not the call site).
6. **Hand off to Icon Composer (iOS 26+)** — export flat background / midground / foreground layers (SVG for shapes, PNG for texture), assemble ≤4 depth groups in Icon Composer, tune the glass, and export the `.icon`. The command preps the layers; Icon Composer authors the final icon.
7. **Re-roll freely** — run again with a different style hint anytime; it's cheap and non-destructive.

**Required — see it in place.** After installing, build + screenshot the Home screen so the icon is judged among other apps at real size via the `run-simulator` skill (detect → preview → confirm → act → fall back, per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`). A 1024px asset on a neutral canvas hides same-hue contrast failures that are obvious at 60 pt.

## Output

- `Assets.xcassets/AppIcon.appiconset/` — the icon with **light / dark / tinted** variants (placeholder-grade for iOS 26+, shippable for older targets).
- Flat **layer source** for Icon Composer + a handoff note, when the target is iOS 26+.

## Cadence

Run it **whenever** — an early placeholder right after `/apple:new-app`, or a polish pass anytime. `/apple:build` generates and validates the final icon in **Phase 6 (Pre-Release)**, and `/apple:testflight` + `/apple:submit` gate it (1024×1024 flattened, no alpha, all appearances present).

## Completion Message

```
🎨 App icon generated!

Installed: Assets.xcassets/AppIcon.appiconset/  (light / dark / tinted)
Type:      [placeholder for iOS 26+ — finish in Icon Composer | classic — ready to ship]
Layers:    [exported bg/mid/fg for Icon Composer | n/a]

Next: [iOS 26+] assemble the layers in Icon Composer → export .icon before submitting.
      [older]   you're set — re-roll with /apple:icon "[style]" for another direction.
```
