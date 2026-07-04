---
description: One-command final mile — push metadata, upload screenshots + build, set IAP price, category & URLs, and submit for review (dry-run/gated). Turns a completed build into a live App Store submission.
argument-hint: "[version] (defaults to MARKETING_VERSION; --testflight to stop at TestFlight)"
allowed-tools: Read, Write, Bash, AskUserQuestion, Skill, mcp__asc-metadata__get_metadata, mcp__asc-metadata__create_version, mcp__asc-metadata__update_whats_new, mcp__asc-metadata__create_phased_release, mcp__asc-metadata__get_iap, mcp__asc-metadata__list_price_points, mcp__asc-metadata__get_age_rating, mcp__asc-metadata__get_availability
model: sonnet
---

# Ship — close the last mile

Take a build that already passed `/apple:review` + `/apple:verify` and drive it to "Waiting for
Review" — the store-side steps that today fall back to the ASC UI: media upload, IAP pricing,
category + URLs, build upload, and submission.

Backed by Fastlane (`deliver`, `pilot`) and/or the `asc` CLI for what the ASC MCP can't do
(screenshot/build upload, price points, category, submit). **Every mutating step is
dry-run → confirm → apply; nothing is submitted or charged without an explicit OK.**

`asc` subcommands below are indicative — verify the exact syntax at runtime with
`asc --help` / `asc search <topic>` before running; the CLI evolves faster than this file.

## When to Use

- After `/apple:submit`'s checklist is green and the build compiles Release.
- To replace the manual ASC UI steps (media, price, category/URLs, upload, submit).
- `--testflight` to stop at a TestFlight upload (defers App Store submission).

## Prerequisites

```
Read: .planning/STATE.md, .planning/METADATA.md, .planning/CAPTIONS.md
```

- `DEVELOPMENT_TEAM` set; automatic signing resolves for the bundle id.
- Fastlane initialised (`/apple:deploy`) and/or `asc` — the App Store Connect CLI
  (https://asccli.sh, `brew install asc`) — with `ASC_*` API-key env vars set
  (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY_PATH`).
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

## Step 2: Ensure the version exists

- From `get_metadata` in Step 1: is there an editable App Store version matching [version]?
- **Missing → create it via `create_version`** (preview "will create version X.Y.Z for [app]" →
  confirm → apply). Fall back to `asc` / the ASC UI only if the MCP tool is unavailable.
  Don't ask the user to click through ASC for something this command can do.

## Step 3: Metadata + media

- Push text via the MCP (or `fastlane deliver` if you keep a `fastlane/metadata/` tree).
- **What's New:** read the App Store section of `.planning/RELEASE-NOTES.md` (offer
  `/apple:release-notes` if missing) and push it per locale via `update_whats_new`
  (preview → confirm). Fallback: `fastlane deliver` / paste manually.
- Upload `.planning/screenshots/**` + any preview video (`fastlane deliver` / `asc screenshots upload`).
  Confirm the frame count/sizes match ASC requirements.

## Step 4: Pricing + IAP

- Set the IAP price from `list_price_points` (e.g. the $6.99 tier) and localized name/description
  (`asc iap ...` / `fastlane`), flipping MISSING_METADATA → READY_TO_SUBMIT. (Defer to `/apple:iap`
  if you'd rather finalize it there.)
- Confirm app base price / free.

## Step 5: Category + URLs

- Set primary/secondary category and Support/Marketing/Privacy URLs (no MCP tool; `asc` covers it).
- Cross-check the URLs resolve.

## Step 6: Build — archive, upload

- Bump `CURRENT_PROJECT_VERSION`; `xcodebuild archive` (Release) → export → upload
  (`fastlane pilot` / Transporter / `asc builds upload`); wait for processing.
- Complete Export Compliance (standard crypto → likely exempt; confirm).

## Step 7: Submit (gated)

- `--testflight`: assign the build to internal/external groups + "What to Test"; stop here.
- Offer a **phased release** (7-day gradual rollout) — if wanted, `create_phased_release`
  (preview → confirm) before submitting.
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
