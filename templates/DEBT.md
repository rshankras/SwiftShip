# Debt Template

Copy this file to your project's `.planning/DEBT.md`.

```markdown
# Debt

<!-- Written by /apple:debt. Each run appends a Trend row; backlog items are
     marked done, never deleted. Rules: design/design-system, swift/code-size,
     swift/concurrency, ios/coding-best-practices, testing/coverage-ratchet -->

**Measured:** [date] · **Scope:** [whole app | area | rule set]
**Platforms:** [iOS 17+ / macOS 14+ / watchOS 10+]

## By Area

Priority = violations × (commits in 6 months + 1). Top 15 rows.

| Area | Design | Size | Concurrency | Practices | Total | Commits (6 mo) | Priority |
|------|--------|------|-------------|-----------|-------|----------------|----------|
| [Views/Projects] | [n] | [n] | [n] | [n] | [n] | [n] | [n] |

**Totals:** design [n] · size [n] · concurrency [n] · practices [n]

## Other Signals

- **Design debt score:** [x]% (from [CODEBASE.md [date] | measured]) [· ⚠️ declared-but-missing fonts: …]
- **Concurrency warnings:** [n per area | not measured: no build log]
- **Tests:** [areas with no tests]; coverage ratchet [baseline [x]% | not set up]

## Backlog

| # | Area | Rule sets | Safety net | Status |
|---|------|-----------|------------|--------|
| 1 | [Views/Projects] | design, size | [tests exist | characterization tests first] | [pending | phase [N] | done [date]] |

**Frozen** (no commits in 6 months; stay in the baseline): [areas]

## Trend

| Date | Design | Size | Concurrency | Practices | Design debt % | Baseline violations |
|------|--------|------|-------------|-----------|---------------|---------------------|
| [date] | [n] | [n] | [n] | [n] | [x]% | [n] |
```

## How to Use

1. **Written by `/apple:debt`** (`--report` writes only this file)
2. **Turned into a quality phase** in ROADMAP.md, which `/apple:plan` expands into one task per area, characterization tests first
3. **Re-measured** at the end of that phase (`/apple:debt --report`) — the Trend row shows whether it worked
4. The baseline count only goes down; a rise means new code bypassed the lint gate
