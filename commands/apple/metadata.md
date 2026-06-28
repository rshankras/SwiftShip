---
description: Generate App Store metadata (name, description, keywords)
allowed-tools: Read, Write, WebSearch, AskUserQuestion
---

# Generate App Store Metadata

Generate optimized App Store content using the keyword-optimizer and app-description-writer skills.

## IMPORTANT: Load Skills First

Before generating metadata, read and apply these skill files:

```
Read: ~/.claude/swiftship-skills/app-store/keyword-optimizer/SKILL.md
Read: ~/.claude/swiftship-skills/app-store/app-description-writer/SKILL.md
```

Also load any reference files mentioned in the skills:
```
Read: ~/.claude/swiftship-skills/app-store/keyword-optimizer/keyword-criteria.md
Read: ~/.claude/swiftship-skills/app-store/keyword-optimizer/advanced-tactics.md
Read: ~/.claude/swiftship-skills/product/localization-strategy/SKILL.md
Read: ~/.claude/swiftship-skills/app-store/marketing-strategy/SKILL.md
Read: ~/.claude/swiftship-skills/app-store/apple-search-ads/SKILL.md
```

## Step 1: Load Project Context

Read existing planning files:

```
Read: .planning/APP.md           # App specification
Read: .planning/VALIDATION.md    # Market research (if exists)
```

Extract:
- App name
- Core problem/solution
- Target users
- Key features
- Differentiators
- Competitors (from validation)

## Step 2: Keyword Research

Using the keyword-optimizer methodology:

### 2.1 Generate Initial Keyword List

Based on APP.md, brainstorm keywords in these categories:

1. **Branded** - App name variations
2. **Category** - Generic category terms
3. **Feature** - Specific functionality
4. **Problem** - User pain points
5. **Long-tail** - Specific phrases

### 2.2 Competitive Keyword Analysis

If VALIDATION.md exists, analyze competitor keywords:
- What keywords do top competitors use in their names/subtitles?
- What gaps exist?

Use WebSearch if needed:
```
"[competitor name] app store"
"best [category] apps iOS"
```

### 2.3 Prioritize Keywords

Rate each keyword:

| Keyword | Relevance | Volume | Difficulty | Priority |
|---------|-----------|--------|------------|----------|
| [word] | High/Med/Low | Est. | Est. | 🎯/💪/✅/❌ |

**Priority Guide:**
- 🎯 High Volume + Low Difficulty = Target First
- 💪 High Volume + High Difficulty = Long-term
- ✅ Low Volume + Low Difficulty = Easy Wins
- ❌ Low Volume + High Difficulty = Skip

## Step 3: Generate App Name & Subtitle

### App Name (30 characters max)

Format options:
```
[Brand] - [Top Keywords]
[Brand]: [Value Proposition]
[Descriptive Name]
```

Generate 3 options and ask user to choose.

### Subtitle (30 characters max)

Format:
```
[Secondary Keywords] & [Benefit]
[Action] [Target] [Differentiator]
```

Generate 3 options.

## Step 4: Generate Keywords Field

100 characters, comma-separated, NO spaces after commas.

Rules (from skill):
- No plurals (Apple handles it)
- No duplicates from name/subtitle
- No category name
- Single words perform better
- No "app", "free", "best"

Example format:
```
timer,pomodoro,focus,concentration,study,productivity,work,session,break,technique
```

## Step 5: Generate App Description

Using app-description-writer methodology:

### Short Description (First 3 lines visible)

Hook format:
```
[Problem] → [Solution] → [Benefit]
```

### Full Description (4000 chars max)

Structure:
1. **Opening Hook** (2-3 sentences)
2. **Key Features** (bullet points)
3. **How It Works** (brief)
4. **Social Proof** (if available)
5. **Call to Action**

### What's New (for updates)

Template:
```
What's New in [Version]:
• [Major feature/fix]
• [Improvement]
• [Bug fix]
```

## Step 6: Generate Promotional Text

170 characters, can be updated without review.

Use for:
- Seasonal promotions
- Feature highlights
- Awards/recognition

## Step 7: Create ASO.md

Generate `.planning/ASO.md`:

```markdown
# App Store Optimization: [App Name]

**Generated:** [date]
**Version:** 1.0

---

## App Identity

### App Name (30 chars)
```
[Final app name]
```
Characters: [X]/30

### Subtitle (30 chars)
```
[Final subtitle]
```
Characters: [X]/30

---

## Keywords (100 chars)

```
[comma,separated,keywords,no,spaces]
```
Characters: [X]/100

### Keyword Strategy

| Keyword | Type | Priority | Expected Ranking |
|---------|------|----------|------------------|
| [word] | Category | 🎯 | Top 10 |
| [word] | Feature | 🎯 | Top 20 |
| [word] | Problem | ✅ | Top 50 |

### Searchable Combinations
- "[combination 1]"
- "[combination 2]"
- "[combination 3]"

---

## App Description

### Short (First 3 lines)
```
[Hook that appears before "more" button]
```

### Full Description
```
[Complete 4000-char description]
```

---

## Promotional Text (170 chars)
```
[Promotional text for current version]
```

---

## What's New
```
[Release notes template]
```

---

## Localization Priority

| Market | Priority | Status |
|--------|----------|--------|
| 🇺🇸 US English | P0 | ✅ Done |
| 🇬🇧 UK English | P1 | ⬚ Pending |
| 🇩🇪 German | P2 | ⬚ Pending |
| 🇫🇷 French | P2 | ⬚ Pending |
| 🇯🇵 Japanese | P2 | ⬚ Pending |

---

## Competitor Keyword Analysis

| Competitor | Name Keywords | Subtitle Keywords |
|------------|---------------|-------------------|
| [Comp 1] | [words] | [words] |
| [Comp 2] | [words] | [words] |

---

## A/B Test Ideas

1. **Name variant:** [alternative]
2. **Subtitle variant:** [alternative]
3. **Description hook:** [alternative]

---

*Generated by SwiftShip /apple:metadata*
*Uses: keyword-optimizer, app-description-writer skills*
```

## Step 8: Completion

```
App Store metadata generated!

Created: .planning/ASO.md

Summary:
- App Name: [name] ([X]/30 chars)
- Subtitle: [subtitle] ([X]/30 chars)
- Keywords: [X]/100 chars used
- Description: [X]/4000 chars

Next steps:
1. Review .planning/ASO.md
2. Copy content to App Store Connect
3. Run /apple:screenshots to create visuals
4. Run /apple:submit when ready

Tips:
- Update keywords quarterly
- A/B test different subtitles
- Localize for top markets
```
