---
description: One-command final mile — push metadata, upload screenshots + build, set IAP price, category & URLs, and submit for review (dry-run/gated). Turns a completed build into a live App Store submission.
argument-hint: "[version] (defaults to MARKETING_VERSION; --testflight to stop at TestFlight)"
allowed-tools: Read, Write, Bash, AskUserQuestion, Skill, mcp__asc-metadata__get_metadata, mcp__asc-metadata__create_version, mcp__asc-metadata__get_iap, mcp__asc-metadata__list_price_points, mcp__asc-metadata__get_age_rating, mcp__asc-metadata__get_availability
---

# Ship — close the last mile

Take a build that already passed `/apple:review` + `/apple:verify` and drive it to "Waiting for
Review" — the store-side steps that today fall back to the ASC UI: media upload, IAP pricing,
category + URLs, build upload, and submission.

Backed by Fastlane (`deliver`, `pilot`) and/or the `asc` CLI for what the ASC MCP can't do
(screenshot/build upload, price points, category, submit). **Every mutating step is
dry-run → confirm → apply; nothing is submitted or charged without an explicit OK.**

## When to Use

- After `/apple:submit`'s checklist is green and the build compiles Release.
- To replace the manual ASC UI steps (media, price, category/URLs, upload, submit).
- `--testflight` to stop at a TestFlight upload (defers App Store submission).

## Prerequisites

```
Read: .planning/STATE.md, .planning/METADATA.md, .planning/CAPTIONS.md
```

- `DEVELOPMENT_TEAM` set; automatic signing resolves for the bundle id.
- Fastlane initialised (`/apple:deploy`) and/or `asc` installed with `ASC_*` API-key env vars.
- Legal pages live + Privacy nutrition label complete (`/apple:privacy`); age rating set.

## Load Skills

```
Read: ~/.claude/swiftship-skills/generators/ci-cd-setup/SKILL.md
Read: ~/.claude/swiftship-skills/generators/screenshot-automation/SKILL.md
Read: ~/.claude/swiftship-skills/generators/app-store-assets/SKILL.md
```

Apply for the Fastlane/`asc` lanes (upload + submit), automated screenshot capture, and the exact
asset specs (sizes/frame counts) ASC requires.

## Step 1: Preflight — verify readiness (read-only)

- `get_metadata` (listing text present) · `get_iap` (not MISSING_METADATA) · `get_age_rating` (set)
  · `get_availability` (territories). List every blocker.
- **Fixable blockers → hand off (via Skill), don't stop:** no staged screenshots → run `/apple:screenshots`;
  legal pages not live → `/apple:privacy`; missing listing text → `/apple:metadata`. Re-check, then continue.
  Stop only on a blocker nothing here can resolve.

## Step 2: Metadata + media

- Push text via the MCP (or `fastlane deliver` if you keep a `fastlane/metadata/` tree).
- Upload `.planning/screenshots/**` + any preview video (`fastlane deliver` / `asc screenshots upload`).
  Confirm the frame count/sizes match ASC requirements.

## Step 3: Pricing + IAP

- Set the IAP price from `list_price_points` (e.g. the $6.99 tier) and localized name/description
  (`asc iap ...` / `fastlane`), flipping MISSING_METADATA → READY_TO_SUBMIT. (Defer to `/apple:iap`
  if you'd rather finalize it there.)
- Confirm app base price / free.

## Step 4: Category + URLs

- Set primary/secondary category and Support/Marketing/Privacy URLs (no MCP tool; `asc` covers it).
- Cross-check the URLs resolve.

## Step 5: Build — archive, upload

- Bump `CURRENT_PROJECT_VERSION`; `xcodebuild archive` (Release) → export → upload
  (`fastlane pilot` / Transporter / `asc build upload`); wait for processing.
- Complete Export Compliance (standard crypto → likely exempt; confirm).

## Step 6: Submit (gated)

- `--testflight`: assign the build to internal/external groups + "What to Test"; stop here.
- Otherwise: attach build + IAP, **AskUserQuestion to confirm final submission**, then submit for review.

## Output

No `.planning/` file of its own — the result lives in App Store Connect (build uploaded, metadata +
media pushed, IAP priced, submitted or in TestFlight). Write the outcome to `STATE.md` (version,
build number, submission time, IAP state) and suggest `/apple:testflight` (beta) or monitoring review.

## Completion Message

Before printing the completion message, append one `"event":"outcome"` line to the usage ledger per `~/.claude/swiftship-templates/_conventions/USAGE-LOG.md` (skip silently if the convention file is absent).

```
🚀 Ship complete — [version] ([build])

Media:   screenshots + preview uploaded (frames match ASC ✓)
IAP:     [name] priced [price] → READY_TO_SUBMIT
Listing: category + Support/Marketing/Privacy URLs set (200 ✓)
Build:   uploaded + processed; Export Compliance done
Status:  Waiting for Review   (or: assigned to TestFlight [group])

Next: monitor review — on rejection → /apple:rejection.
```

## Principles

- Dry-run → confirm → apply on every mutation; **never auto-submit or set a price without explicit OK.**
- Reproducible: same inputs → same submission (Fastlane/`asc`, not hand-clicking).
- Verify before push; carry the app's App-Review guardrails forward.
