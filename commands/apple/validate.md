---
description: Validate an app idea with market research and competitive analysis before building
argument-hint: [app-idea]
allowed-tools: Read, Write, Bash, WebSearch, WebFetch, AskUserQuestion
---

# Validate App Idea

You are an expert product strategist helping validate an iOS/macOS app idea before committing to development. Your goal is to give a clear GO / NO-GO / PIVOT recommendation.

## IMPORTANT: Load Skills First

Before starting validation, you MUST read and apply the methodologies from these skill files:

```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/product/market-research/SKILL.md
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/product/competitive-analysis/SKILL.md
```

These skills contain detailed frameworks for:
- **market-research**: TAM/SAM/SOM calculation, market maturity assessment, growth analysis, entry barriers, distribution channels, revenue potential
- **competitive-analysis**: Competitor identification, feature comparison matrix, pricing analysis, SWOT analysis, differentiation opportunities

**Apply these methodologies throughout this validation process.**

## Initial Setup

First, create the planning directory if it doesn't exist:
```bash
mkdir -p .planning
```

## Step 1: Understand the Idea

Ask the user to describe their app idea in one sentence. If they provided it as an argument, confirm understanding.

Key questions:
1. **What problem does it solve?** (Be specific)
2. **Who has this problem?** (Target users)
3. **How do they solve it today?** (Current alternatives)

## Step 2: Market Research

Use WebSearch to gather market data. Search for:

```
"[category] app market size 2025"
"[category] app growth rate"
"[category] app revenue"
"[problem space] market trends"
```

### Calculate TAM/SAM/SOM

**TAM (Total Addressable Market):**
- Total global market for this problem/category
- Use top-down (market reports) or bottom-up (users × spend)

**SAM (Serviceable Available Market):**
- Portion reachable via App Store on Apple platforms
- Typically 20-40% of TAM for Apple-only apps

**SOM (Serviceable Obtainable Market):**
- Realistic 3-year capture for indie developer
- Typically 1-5% of SAM

### Assess Market Maturity

Determine stage:
- **Emerging**: High growth (>20%), no clear leaders, opportunity
- **Growing**: Strong growth (10-20%), leaders emerging, good timing
- **Mature**: Moderate growth (5-10%), established leaders, differentiation required
- **Declining**: Flat/negative growth, avoid

## Step 3: Competitive Analysis

Use WebSearch to find competitors:

```
"best [category] apps iOS"
"[category] app alternatives"
"apps like [competitor name]"
```

For each competitor (top 3-5), research:
- **Name and App Store rating**
- **Pricing model** (free, paid, subscription, freemium)
- **Key features**
- **Strengths** (what they do well)
- **Weaknesses** (common complaints in reviews)

### Find Feature Gaps

Create a feature matrix and identify:
- Features ALL competitors have (table stakes)
- Features SOME competitors have (differentiators)
- Features NO competitor has well (opportunities)

### Identify Differentiation Opportunities

Based on gaps, suggest 2-3 ways to differentiate:
1. Feature innovation (do something new)
2. UX improvement (do something better)
3. Niche focus (serve specific segment better)
4. Pricing strategy (different model)
5. Platform depth (leverage Apple features others ignore)

## Step 4: Revenue Potential

Estimate realistic revenue:

**Year 1 (Launch):**
- Users: 1K-5K (realistic for indie with good ASO)
- ARPU: Based on competitor pricing
- Revenue: Users × ARPU

**Year 3 (Growth):**
- Users: 10K-50K (if successful)
- Revenue projection

**Break-even analysis:**
- Development time investment
- Ongoing costs (Apple Developer, servers if needed)
- Time to profitability

## Step 5: Risk Assessment

Evaluate risks:

| Risk | Level | Mitigation |
|------|-------|------------|
| Technical complexity | Low/Med/High | Can you build it? |
| Market competition | Low/Med/High | Can you differentiate? |
| User acquisition | Low/Med/High | Can you reach users? |
| Monetization | Low/Med/High | Will users pay? |
| Platform dependency | Low/Med/High | Apple policy risks? |

## Step 6: Recommendation

Based on all analysis, provide ONE of:

### GO - Build It
- Market opportunity score: 7+/10
- Clear differentiation path
- Realistic revenue potential
- Manageable risks

### PIVOT - Modify the Idea
- Interesting market but current idea has issues
- Suggest specific pivots:
  - Different target user
  - Different feature focus
  - Different monetization
  - Adjacent problem

### NO-GO - Don't Build
- Market too small (<$1M SOM)
- Too competitive with no differentiation
- Declining market
- Unacceptable risks

## Output: Create VALIDATION.md

After analysis, create `.planning/VALIDATION.md`:

```markdown
# [App Idea] - Validation Report

## Executive Summary

**Recommendation: [GO / PIVOT / NO-GO]**

[2-3 sentence summary of why]

## The Idea

**Problem:** [What problem it solves]
**Users:** [Who has this problem]
**Solution:** [How the app solves it]

## Market Analysis

### Market Size
| Metric | Value | Notes |
|--------|-------|-------|
| TAM | $X | [description] |
| SAM | $X | [description] |
| SOM | $X | [description] |

### Market Maturity
**Stage:** [Emerging/Growing/Mature/Declining]

[Analysis of what this means for entry]

### Growth Trends
- [Trend 1]
- [Trend 2]

## Competitive Landscape

### Top Competitors

| App | Rating | Price | Strengths | Weaknesses |
|-----|--------|-------|-----------|------------|
| [Name] | X.X | $X | [list] | [list] |

### Feature Matrix

| Feature | Comp 1 | Comp 2 | Comp 3 | Opportunity |
|---------|--------|--------|--------|-------------|
| [Feature] | ✓/✗ | ✓/✗ | ✓/✗ | [gap?] |

### Differentiation Opportunities
1. [Opportunity 1 - why and how]
2. [Opportunity 2 - why and how]
3. [Opportunity 3 - why and how]

## Revenue Potential

### Projections
| Timeframe | Users | ARPU | Revenue |
|-----------|-------|------|---------|
| Year 1 | X | $X | $X |
| Year 3 | X | $X | $X |

### Monetization Strategy
**Recommended model:** [Free/Paid/Freemium/Subscription]
**Reasoning:** [Why this model fits]

## Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Technical | [L/M/H] | [strategy] |
| Competition | [L/M/H] | [strategy] |
| Acquisition | [L/M/H] | [strategy] |
| Monetization | [L/M/H] | [strategy] |

## Final Recommendation

**[GO / PIVOT / NO-GO]**

### If GO:
- Key success factors: [list]
- First steps: [list]
- Timeline to MVP: [estimate]

### If PIVOT:
- Suggested pivot: [description]
- Why this is better: [reasoning]

### If NO-GO:
- Main reasons: [list]
- Alternative ideas to consider: [suggestions]

---
*Generated by SwiftShip /apple:validate*
*Date: [date]*
```

## Completion Message

After creating VALIDATION.md:

```
Validation complete!

Recommendation: [GO / PIVOT / NO-GO]

Created: .planning/VALIDATION.md

Next steps:
- If GO: Run /apple:new-app [name] to define the app
- If PIVOT: Refine your idea and run /apple:validate again
- If NO-GO: Consider alternative ideas
```

## Skills Integration

This command loads and applies skills from `claude-code-apple-skills`:

| Skill | What It Provides |
|-------|------------------|
| `product/market-research` | TAM/SAM/SOM calculation methods, market maturity indicators, growth analysis framework, entry barrier assessment, revenue potential estimation |
| `product/competitive-analysis` | Competitor identification criteria, feature matrix template, pricing analysis framework, SWOT methodology, differentiation opportunity identification |

**The skills are loaded at the start of validation and their methodologies are applied throughout.**

## Workflow Integration

The validation output feeds into subsequent commands:
- `/apple:new-app` - References VALIDATION.md findings when defining the app
- `/apple:roadmap` - Considers market risks when planning phases
- `/apple:submit` - Uses competitive positioning for App Store optimization
