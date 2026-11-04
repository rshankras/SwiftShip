# Run & Screenshot the App (iOS + macOS)

A live screenshot of the running app turns "it compiles" into "it works." This
procedure builds, launches, and captures the app, then **Reads the image back**
to judge it. A blank, crashed, or launch-screen-stuck frame is a **failure**, not
a pass.

Apply the [TOOL-HANDOFF convention](TOOL-HANDOFF.md): this whole step is an
**optional handoff** — detect the capability, do it, and on any failure fall back
to today's "check it yourself" instruction. **DETECT the platform first** from
`.planning/APP.md` (`<platform>` / min-OS), or infer from the project.

> **The rule:** navigate with the accessibility tree; screenshots verify
> outcomes, never locate tap targets. Every image Read stays in context for
> the rest of the session — take one, at the destination, as a thumbnail.

**Parallel checkouts:** pass `-derivedDataPath .build/DerivedData` (relative to
the checkout root) to **every** `xcodebuild` call here, so parallel checkouts
or worktrees don't lock each other's DerivedData. Ensure `.build/` is
gitignored — add it if missing (show the one-line diff first).

---

## iOS → follow the `run-simulator` skill

**DETECT by path, not by skill name:** the skill is available when
`~/.claude/swiftship-skills/ios/run-simulator/SKILL.md` exists (same path
pattern as every other SwiftShip skill reference — works for plugin and manual
installs; a skill named `run-simulator` appearing in the session's skill list
also counts). If found, Read it and follow it: it discovers the scheme, picks
a booted simulator, builds, installs, launches, then:

- **Navigates** to the changed screen when it's behind a tab/route: deep link
  (`simctl openurl`) → **AXe** accessibility tree (`axe describe-ui` filtered
  to a ~2 KB element list; tap by `--id` / `--label` / exact list `xy`) →
  otherwise tells the user the taps. `xcrun simctl io … tap` does **not**
  exist — never use it.
- **Confirms each step by re-listing elements** (text), not by screenshot.
- **Screenshots once at the destination** and Reads a `sips -Z 600`
  **thumbnail** — enough to judge blank / crashed / wrong screen. The
  full-size PNG stays on disk; Read it only when fine detail is the question
  (`/apple:visual-qa` reads full size by design).

If the skill is **not** found, fall back: ask the user to run it in the
Simulator and share a screenshot (the existing manual path).

## macOS → no simulator; build, open, screencapture

`run-simulator` is iOS-only. For a Mac app, do it directly:

```bash
# 1. Scheme
xcodebuild -list -project <App>.xcodeproj 2>/dev/null   # or -workspace

# 2. Build for macOS (look for ** BUILD SUCCEEDED **; surface error: lines on failure)
xcodebuild build -scheme <Scheme> -destination 'platform=macOS' \
  -derivedDataPath .build/DerivedData 2>&1 | tail -5

# 3. Resolve the built .app from build settings (don't guess DerivedData)
eval $(xcodebuild -scheme <Scheme> -destination 'platform=macOS' \
  -derivedDataPath .build/DerivedData -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ TARGET_BUILD_DIR =/{print "DIR=\""$2"\""} / FULL_PRODUCT_NAME =/{print "NAME=\""$2"\""}')
APP="$DIR/$NAME"

# 4. Launch and bring to front
open "$APP"
osascript -e 'tell application "<AppName>" to activate'; sleep 1

# 5. Capture (full screen, no shadow, silent) and Read it back
screencapture -o -x /tmp/mac-shot.png
# Window-targeted alternative (preferred — less desktop noise): screencapture -R<x,y,w,h> /tmp/mac-shot.png

# 6. Thumbnail for the pass/fail read (Mac displays are wide — 800 keeps a window legible)
sips -Z 800 /tmp/mac-shot.png --out /tmp/mac-shot-thumb.png >/dev/null
```

Then **Read `/tmp/mac-shot-thumb.png`** and judge it (blank desktop / crash
dialog = failure). Read the full-size `/tmp/mac-shot.png` only for fine detail.

### Menu-bar / popover apps (the common case here)

A status-item app has **no ordinary window** — `open` just adds it to the menu
bar and the popover is closed, so a naive `screencapture` shows an empty desktop.

**Detect this case** (cleaner than guessing): after launch,
```bash
osascript -e 'tell application "System Events" to tell process "<AppName>" to count windows'
```
returning `0` means there's nothing to capture yet. When it's `0`, surface the
UI before capturing:

1. Try clicking the status item via accessibility:
   `osascript -e 'tell application "System Events" to tell process "<AppName>" to click menu bar item 1 of menu bar 2'`
   then `screencapture`.
2. If that's unavailable or fails, **STOP and ask the user** to click the
   menu-bar icon (and open the relevant view), then capture.

**Never screenshot an empty desktop and call it a pass.**

## Report

Per the run-simulator skill's format: what ran (scheme, sim/Mac), build result,
launch result, how you navigated (deep link / AXe / none), **what the
screenshot shows**, and any taps the user must do to reach a gated screen —
including any unlabeled control that blocked navigation (that's an
accessibility bug: VoiceOver can't name it either). Give the full-size
screenshot path so the user can open it.
