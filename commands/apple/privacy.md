---
description: Publish privacy policy + terms to hosted URLs and set the App Store Connect Privacy/Support URLs (dry-run first). Nutrition label stays a manual checklist.
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion, mcp__claude-in-chrome__navigate, mcp__claude-in-chrome__computer, mcp__claude-in-chrome__read_page
argument-hint:
---

# Publish Legal Pages & Set ASC URLs

Turn `.planning/legal/{privacy,terms}.md` into hosted pages and set the App Store Connect **Privacy Policy** + **Support/Marketing** URLs via the ASC REST API. A Phase-6 pre-submit step; also invoked from `/apple:submit`. The **App Privacy nutrition label** stays manual (no Apple API) — this prints the exact answers to click.

## Prerequisites

```
Read: .planning/legal/privacy.md, .planning/legal/terms.md   # from legal/privacy-policy
Read: .planning/APP.md
```

- `_shared/asc-api/` set up (one-time ASC API key).
- Hosting: the skill asks **once** where your pages live (git / WordPress / Netlify / browser) and remembers it in `.planning/`.

## Load the Skill

```
Read: ~/.claude/swiftship-skills/legal/privacy-publish/SKILL.md
```

## Process

Follow the skill: render md → HTML → publish per your host → **confirm both URLs return 200** → PATCH `appInfoLocalizations.privacyPolicyUrl` + `appStoreVersionLocalizations.supportUrl` → emit the nutrition-label checklist. **Every ASC write is dry-run → confirm → `--apply`.**

## Output

Legal pages live + resolving; Privacy/Support URLs set in ASC; nutrition-label checklist for you to click. Feeds `/apple:submit`.

## Completion Message

```
📄 Legal pages published!

Privacy: [url]  (200 ✓ → set in ASC)
Support: [url]  (200 ✓ → set in ASC)
Nutrition label: checklist printed — click it in ASC ▸ App Privacy (no API).

Next: /apple:submit.
```
