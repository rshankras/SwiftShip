# Run & Screenshot the App (iOS + macOS)

A live screenshot of the running app turns "it compiles" into "it works." This
procedure builds, launches, and captures the app, then **Reads the image back**
to judge it. A blank, crashed, or launch-screen-stuck frame is a **failure**, not
a pass.

Apply the [TOOL-HANDOFF convention](TOOL-HANDOFF.md): this whole step is an
**optional handoff** — detect the capability, do it, and on any failure fall back
to today's "check it yourself" instruction. **DETECT the platform first** from
`.planning/APP.md` (`<platform>` / min-OS), or infer from the project.

---

## iOS → delegate to the `run-simulator` skill

If the `run-simulator` skill is available (DETECT), invoke it — it discovers the
scheme, picks a booted simulator, `xcodebuild build` → `xcrun simctl install` →
`launch` → `xcrun simctl io <sim> screenshot`, and Reads the PNG. Drive
navigation with `simctl io tap` / `openurl` if the change is behind a tab/route.

If the skill is **not** available, fall back: ask the user to run it in the
Simulator and share a screenshot (the existing manual path).

## macOS → no simulator; build, open, screencapture

`run-simulator` is iOS-only. For a Mac app, do it directly:

```bash
# 1. Scheme
xcodebuild -list -project <App>.xcodeproj 2>/dev/null   # or -workspace

# 2. Build for macOS (look for ** BUILD SUCCEEDED **; surface error: lines on failure)
xcodebuild build -scheme <Scheme> -destination 'platform=macOS' 2>&1 | tail -5

# 3. Resolve the built .app from build settings (don't guess DerivedData)
eval $(xcodebuild -scheme <Scheme> -destination 'platform=macOS' -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ TARGET_BUILD_DIR =/{print "DIR=\""$2"\""} / FULL_PRODUCT_NAME =/{print "NAME=\""$2"\""}')
APP="$DIR/$NAME"

# 4. Launch and bring to front
open "$APP"
osascript -e 'tell application "<AppName>" to activate'; sleep 1

# 5. Capture (full screen, no shadow, silent) and Read it back
screencapture -o -x /tmp/mac-shot.png
# Window-targeted alternative: screencapture -R<x,y,w,h> /tmp/mac-shot.png
```

Then **Read `/tmp/mac-shot.png`** and judge it (blank desktop / crash dialog =
failure).

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
launch result, **what the screenshot shows**, and any taps the user must do to
reach a gated screen. Embed/Read the image so the user sees it too.
