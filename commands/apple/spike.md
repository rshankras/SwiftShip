---
description: Time-boxed experiment to validate an Apple API or approach before planning
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
argument-hint: [topic or API to validate]
---

# Spike — Validate an Apple API Before You Commit to It

A spike is a small, throwaway experiment that answers **one technical question**
before it goes into a plan: *"Does this Apple API actually do what I need, on my
minimum OS, on the devices I support?"*

Apple ships a new OS every year and most flagship APIs are availability-gated,
device-gated, capability-gated, or simulator-incompatible. Discovering that
*after* you've planned a phase around an API is expensive. A spike de-risks it
in minutes and records the finding so the decision is never re-litigated.

This is exploration, not production. The probe code is disposable; the
**finding** is the deliverable.

## Arguments

- `$ARGUMENTS` — the question or API to validate (e.g. "Can AlarmKit schedule a
  recurring alarm on iOS 26?", "Does Foundation Models run on this min-OS?",
  "MeshGradient performance with 20 points").

If no argument is given, ask:
```
What do you want to validate? Frame it as a yes/no or "does X do Y" question.
Examples:
- "Can <API> do <thing> on <min OS>?"
- "Is <API> available on <device/simulator>?"
- "What's the fallback if <API> isn't available?"
```

## Prerequisites

Read for context if present (a spike works even without a full project):
```
Read: .planning/APP.md      # Min OS, target platforms, devices — the gating constraints
```

Check the local Apple documentation before writing any probe code (per the
user's reference docs):
```
Glob: /Users/ravishankar/Downloads/docs/*.md
```
If a doc file matches the API (e.g. Foundation Models, Visual Intelligence,
Liquid Glass, AlarmKit), **read it first** — it has the current API shape.

## Process

### 1. Frame the Spike

State four things up front and confirm with the user:
- **Question** — the single thing being validated.
- **Decision it unblocks** — what plan/task depends on the answer.
- **Done when** — the concrete signal that answers it (compiles? runs on device? returns expected output?).
- **Time box** — keep it small (default ~30 min of effort); if it grows, stop and report.

### 2. Check Apple Availability & Constraints (before coding)

Resolve these from the docs + the target's `<min-os>`:

| Constraint | Question |
|------------|----------|
| **OS availability** | What `@available(iOS X, macOS Y, *)` does the API carry? Is X ≤ the app's min OS? If not, what's the `if #available` fallback path? |
| **Device gating** | Does it need specific hardware (Neural Engine, LiDAR, camera, Secure Enclave)? Which devices lack it? |
| **Simulator** | Does it work in the Simulator, or device-only? (Many ML/camera/sensor APIs are device-only.) |
| **Capability / entitlement** | Does it require a capability, entitlement, or `Info.plist` usage string? |
| **SDK / Xcode** | Does it require a beta SDK or a specific Xcode version? |

Record any constraint that fails — that alone may answer the spike.

### 3. Build the Smallest Probe

Write the minimum code that exercises the API. Keep it isolated and disposable:
- Put it under `Spikes/[topic]/` or a scratch Swift file — **not** in the app's real sources.
- Gate it with `if #available` so you can observe both the new path and the fallback.
- Make the output observable: a `print`/`Logger` line, a returned value, or a tiny `#Preview`.

Then build and (if possible) run it:
```bash
# Compile the probe
swift build 2>&1 | tail -20
# or, for an Xcode target:
xcodebuild -scheme [Scheme] -destination '[platform=… or a real device]' build 2>&1 | tail -20
```
If the API is device-only, say so and ask the user to run it on a device when
hands-on confirmation is needed.

### 4. Record the Finding

Write `.planning/spikes/[topic-slug].md`:

```markdown
# Spike: [Question]

**Date:** [date]
**Time spent:** [actual]
**Min OS / targets:** [from APP.md]

## Question
[The single thing validated]

## What unblocks
[The plan/task this decision feeds]

## Finding
**[WORKS / WORKS WITH FALLBACK / DOESN'T WORK / NEEDS DEVICE]**

[2–4 sentences: what happened when the probe ran.]

## Apple constraints discovered
- Availability: `@available(...)` — [met / needs fallback below min OS]
- Device: [any hardware gating]
- Simulator: [works / device-only]
- Capability/entitlement: [any required]
- SDK/Xcode: [any requirement]

## Gotchas
- [Anything surprising — main-thread requirements, async quirks, deprecations]

## Recommendation
**[Adopt / Adopt with fallback / Avoid / Defer]** — [one line why]

[If "Adopt with fallback", sketch the `if #available { … } else { … }` shape.]

## Probe code
[Path to the throwaway probe, or inline snippet. Mark it disposable.]
```

### 5. Wrap Up

- If the finding is a reusable pattern or a non-obvious gotcha, offer to capture
  it permanently with `/apple:learn` so it lands in a skill or `CLAUDE.md`.
- Delete or clearly mark the probe code so it doesn't leak into production.
- If the spike grew beyond its time box without an answer, stop and report what
  you learned — an inconclusive spike is still a valid result.

## Output

- `.planning/spikes/[topic-slug].md` — the finding (the real deliverable).
- Disposable probe code under `Spikes/[topic]/` (to be removed once recorded).

## Completion Message

```
🔬 Spike complete: [Question]

Finding: [WORKS / WORKS WITH FALLBACK / DOESN'T WORK / NEEDS DEVICE]
Recommendation: [Adopt / Adopt with fallback / Avoid / Defer]

Key constraint: [the one that matters most — e.g. "device-only, no Simulator"]

Recorded: .planning/spikes/[topic-slug].md

Next:
- If adopting: the finding is ready to feed into /apple:plan.
- If reusable lesson: run /apple:learn to capture the gotcha.
- Remember to remove the throwaway probe under Spikes/.
```
