# Utilities Inventory Template

Copy this file to your project's `.planning/UTILITIES.md`.

```markdown
# Existing Helpers

<!-- Shared code agents must REUSE, not reimplement. One line per helper:
     name → path → what it's for. Keep it short — this is passed to every
     build agent. Written by /apple:map; /apple:build appends new shared
     helpers as tasks create them. -->

**Updated:** [date]

## Formatting
| Helper | Path | Use for |
|--------|------|---------|
| [PriceFormatter] | [Sources/Util/PriceFormatter.swift] | [Currency display — never format Decimal by hand] |

## Networking
| Helper | Path | Use for |
|--------|------|---------|
| [APIClient] | [path] | [All HTTP calls — auth, retries, decoding] |

## Persistence
| Helper | Path | Use for |
|--------|------|---------|

## Design Tokens
| Helper | Path | Use for |
|--------|------|---------|
| [Theme / Spacing / Typography] | [path] | [Colors, spacing, fonts — no hardcoded values] |

## Logging
| Helper | Path | Use for |
|--------|------|---------|

## Shared Views & Modifiers
| Helper | Path | Use for |
|--------|------|---------|

## Extensions (project-wide)
| Helper | Path | Use for |
|--------|------|---------|
```

## How to Use

1. **Created by `/apple:map`** for existing codebases (inventory of what's already there)
2. **Greenfield projects:** created by `/apple:build` the first time a task adds a shared helper — the file grows with the app
3. **Read by `/apple:build`** and passed to every agent: reuse a listed helper; if none fits, say so before adding a new one
4. **Checked by `/apple:review`**: reimplementing a listed helper is a DRY finding
5. Delete sections that stay empty; list only code meant to be shared, not every type
