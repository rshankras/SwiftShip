---
description: Explore divergent UI directions for a screen as named Swift #Previews, remix the best, fill with lived-in content + edge cases, and tune key animations — before committing to one layout
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: [screen-name]
---

# Prototype UI Directions

Explore *many divergent* UI options for a screen — as named, real SwiftUI `#Preview`s you flip between in Xcode — **before** `/apple:plan` commits you to one layout. Removes the biggest early trap: anchoring on the first arbitrary structure an agent guesses, then fighting feature creep around it. Based on Apple's WWDC "prototyping with coding agents in Xcode" method: **go wide → remix → make lived-in → tune.**

## Arguments

- `$ARGUMENTS` or `$1`: the screen to prototype (e.g. `Home`, `ContestDetail`). Empty → the primary screen implied by `.planning/APP.md`'s `<mvp-features>`.

## Prerequisites

```
Read: .planning/APP.md      # features + audience (what to bake into every variation)
Read: .planning/PLAN.md     # the current phase's views/flows, if planning has started
Read: .planning/STATE.md
```

If there's **no `APP.md` yet, that's fine** — the skill interviews you for the screen, its must-have features, and the mood (novice-friendly). You do **not** need to know how to write a good prompt; assembling it is the skill's job.

If there's no Xcode project yet, you can still explore Stage 1 as standalone SwiftUI files and fold them in once a project exists.

## Load the Skill

Apply the full methodology (four stages, the novice interview, output format):
```
Read: ~/.claude/swiftship-skills/design/ui-prototyping/SKILL.md
```

## Process

Follow the skill. In short:

1. **Brief** — via `AskUserQuestion` if not already pinned in `APP.md`: the screen, its 3–5 must-have features (baked in, nothing extra → no feature creep), the mood/feeling, 0–2 reference apps.
2. **Stage 1 — go wide.** Generate 6–10 *divergent* SwiftUI variations of that one screen, each with its own descriptively-named `#Preview` (`"Cozy"`, `"Editorial"`, `"Blueprint Atelier"`). Vary the organizing metaphor, not just the tint. `xcodebuild build` to confirm they compile — this is real code you carry forward.
3. **Stage 2 — remix + lived-in.** You name the variations/elements you like → generate hybrids. Add reusable sample data (`generators/preview-data-generator`) and edge-case previews — empty, unbounded growth, long input (delegate the state matrix to the `swiftui-builder` agent).
4. **Stage 3 — tune.** For 1–3 signature animations, generate a DEBUG-only **tuning panel** (named phases, laid out side-by-side on a wide window) so you dial spring/timing without context-switching.

**Optional handoff — see the variations rendered.** If you'd like screenshots of each named preview instead of only reading code, offer to capture them via the `run-simulator` skill (detect → preview → confirm → act → fall back, per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`). The Xcode-canvas / manual path stays the default.

## Output: `.planning/PROTOTYPE.md`

Write the record in the skill's format — variations explored (name + organizing idea + verdict), the chosen direction and remix, sample-data location, edge cases covered, and tuned parameter values. The Swift files (variations, sample data, tuning panel) stay in the project as **real code carried forward**.

The winning variation feeds `/apple:plan`'s `<flows>` / `<apple-patterns>` and `/apple:build` — don't rebuild it.

## Cadence

Run **early and per signature screen** — after `/apple:new-app`, or at the start of a UI-heavy phase, before `/apple:plan` locks a layout. Bookends with `/apple:walkthrough`: prototype the *screen*, walkthrough the *flow*.

## Completion Message

```
🎨 Prototype exploration complete!

Created: .planning/PROTOTYPE.md
Swift:   [N] named #Preview variations (+ sample data[, + tuning panel])

Stage 1 (go wide):   [N] divergent directions — flip between them in Xcode's canvas
Stage 2 (remix):     chose "[name]"[ + grafts]; filled with lived-in content + edge cases
Stage 3 (tune):      [tuned [moment] / skipped — no signature animation yet]

Next: carry the winning layout into /apple:plan, then /apple:walkthrough the flow once built.
Remember: the agent proposed — the choice was yours.
```
