---
description: Localize the app for new markets — translate App Store metadata + in-app strings, add/manage locales, and localize IAPs/events, with keywords re-optimized per market. The biggest untapped reach lever for a portfolio.
argument-hint: "[locale(s), e.g. es-ES,de-DE,ja]"
allowed-tools: Read, Write, Edit, Glob, Grep, AskUserQuestion, Skill, mcp__asc-metadata__list_locales, mcp__asc-metadata__get_metadata, mcp__asc-metadata__update_name, mcp__asc-metadata__update_description, mcp__asc-metadata__update_keywords, mcp__asc-metadata__update_promo_text, mcp__asc-metadata__update_iap, mcp__asc-metadata__bulk_update
---

# Localize — reach new markets

Expand the app into new languages: translate the store listing (name/subtitle/keywords/promo/
description), the in-app strings, and the IAP/event copy — with keywords re-optimized per market,
not machine-transliterated.

## Arguments

- `$ARGUMENTS` or `$1`: target locale(s), comma-separated (e.g. `es-ES,de-DE,ja`). Empty → propose
  targets by opportunity in Step 1 and confirm.

## When to Use

- A live app with traction in English, ready to widen reach (highest ROI when the app is UI-light).
- Alongside `/apple:next-version` to ship localization as a feature.

## Prerequisites

```
Read: .planning/STATE.md, .planning/ASO.md   # current listing + keyword strategy
```

- The app's user-facing strings extractable (String Catalog / `Localizable.strings`).
- ASC access (optional) to read current locales + push metadata; falls back to manual entry.

## Load Skills

```
Read: ~/.claude/swiftship-skills/product/localization-strategy/SKILL.md
Read: ~/.claude/swiftship-skills/generators/localization-setup/SKILL.md
```

Apply `localization-strategy` for market selection + per-market keyword re-optimization, and
`localization-setup` for the String Catalog / i18n plumbing.

## Step 1: Choose markets

- `list_locales` (existing) + `get_metadata`. Pick targets by opportunity — large stores,
  low-competition keywords, existing organic downloads by territory.

## Step 2: In-app strings

- Ensure a String Catalog / `Localizable.strings` exists; extract user-facing strings.
- Translate naturally (not literal); keep format specifiers + accessibility labels intact.
- Verify layout survives longer languages (de/fi) — flag truncation.

## Step 3: Store metadata per locale — Optional handoff

- Translate **and re-optimize keywords for that market** (don't reuse English transliterated).
- Respect field limits (name/subtitle 30, keywords 100) and the app's guardrails per language.
- Per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`, push via the MCP if available:
  **DETECT** `update_*` / `bulk_update` → **PREVIEW** the per-locale before→after (⚠️ live listing)
  → **CONFIRM** (manual default) → **ACT** `update_name` / `update_description` / `update_keywords` /
  `update_promo_text` (or `bulk_update` for many locales) → **FALL BACK** to the manual ASC entry list.

## Step 4: IAP + events

- Localize IAP display name/description (`update_iap`, same preview→confirm gate) and any in-app
  events (`/apple:event`).

## Step 5: QA + record

- Screenshot key screens per locale (`/apple:screenshots`); confirm no untranslated leaks.
- Record covered locales in `STATE.md`.

## Output

Localized in-app strings + per-locale store listing (name/keywords/promo/description) pushed to ASC,
IAP/event copy localized, per-locale screenshots. Covered locales recorded in `STATE.md`.

## Completion Message

```
🌍 Localized — [es-ES, de-DE, ja]

Strings: String Catalog translated (specifiers + a11y labels intact; no truncation)
Listing: name/keywords/promo/description per locale — keywords re-optimized, not transliterated
IAP:     display name + description localized
QA:      per-locale screenshots — no untranslated leaks

Next: /apple:screenshots for localized store shots, or /apple:next-version to ship.
```

## Principles

- Translate for meaning + culture, not word-for-word; re-optimize keywords per store.
- Preserve format specifiers, a11y labels, and guardrails in every language.
- Dry-run → confirm → apply.
