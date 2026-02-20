---
description: Brainstorm app ideas tailored to your skills and interests
argument-hint: [optional: domain or technology focus]
allowed-tools: Read, Write, Bash, AskUserQuestion, WebSearch, WebFetch
---

# Brainstorm App Ideas

Generate a ranked shortlist of 3-5 app ideas tailored to your skills, interests, and constraints. This is "Phase 0" — use it when you don't have an idea yet, before running `/apple:validate`.

**Already have an idea?** Skip this and go straight to `/apple:validate "your idea"`.

## Step 1: Load the Skill

Read the idea-generator skill for full brainstorming methodology:

```
Read: /Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/product/idea-generator/SKILL.md
```

Follow the skill's process exactly — it defines 5 brainstorming lenses, feasibility filters, and scoring criteria.

## Step 2: Gather Developer Profile

If `$ARGUMENTS` is provided, use it as a domain or technology focus hint.

Ask the user (using AskUserQuestion) about:

1. **Technical skills** — What Apple frameworks do you know? (SwiftUI, UIKit, HealthKit, CloudKit, etc.)
2. **Domain interests** — What topics excite you? (health, finance, productivity, creativity, etc.)
3. **Platform** — iOS, macOS, watchOS, or multi-platform?
4. **Time availability** — Side project (5-10 hrs/week), full-time, or weekend hack?
5. **Constraints** — Solo dev? No backend experience? No design skills?

If the user provides partial answers, infer reasonable defaults and state your assumptions.

## Step 3: Apply Five Brainstorming Lenses

Follow the skill's methodology to generate ideas through each lens:

1. **Skills & Interests** — What can you uniquely build?
2. **Problem-First** — What daily friction could an app eliminate?
3. **Technology-First** — Which Apple frameworks have few quality apps?
4. **Market Gap** — Where are App Store categories underserved?
5. **Trend-Based** — What macro trends create new opportunities?

For the Market Gap and Trend lenses, use WebSearch to gather current data:

```
WebSearch: "underserved App Store categories 2026"
WebSearch: "[domain] app complaints" site:reddit.com
WebSearch: "indie iOS app opportunities 2026"
```

## Step 4: Filter and Score

Apply feasibility filters from the skill:

| Filter | Question |
|--------|----------|
| Solo Dev Scope | Can one developer ship an MVP in 4-8 weeks? |
| Platform API Fit | Does this leverage Apple APIs well? |
| Monetization Viability | Is there a clear path to revenue? |
| Competition Density | How crowded is this space? |
| Technical Fit | Does the developer have the skills? |

Remove ideas that score WEAK on Solo Dev Scope or Technical Fit.

Score remaining ideas on all 5 dimensions. Rank by overall score (Solo Dev Scope and Technical Fit weighted 1.5x).

## Step 5: Present Shortlist

Present the top 3-5 ideas in this format:

```
App Idea Shortlist

Rank 1: [Name] (Score: X.X/10)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
One-liner: [description]
Platform: [iOS / macOS / watchOS / multi]
Problem: [what pain point it solves]
Target user: [who benefits]
Monetization: [model and price point]
MVP scope: [what ships in 4-8 weeks]
Key strength: [why this one ranks highest]

Scores:
- Solo Dev Scope: [rating]
- Platform API Fit: [rating]
- Monetization: [rating]
- Competition: [rating]
- Technical Fit: [rating]

---

Rank 2: [Name] (Score: X.X/10)
...

Rank 3: [Name] (Score: X.X/10)
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Filtered out:
- [Idea] — [why it was removed]
- [Idea] — [why it was removed]

Recommendation: [why Rank 1 is the best starting point]
```

## Step 6: Save Results

Save the shortlist to `.planning/BRAINSTORM.md`:

```bash
mkdir -p .planning
```

Write `.planning/BRAINSTORM.md` with:

```markdown
# App Idea Brainstorm

**Date:** [timestamp]
**Developer Profile:** [summary of skills, interests, constraints]

## Shortlist

### Rank 1: [Name] (Score: X.X/10)
- **One-liner:** [description]
- **Platform:** [platform]
- **Problem:** [pain point]
- **Target user:** [who]
- **Monetization:** [model]
- **MVP scope:** [what ships first]
- **Scores:** Solo Dev [X] | API Fit [X] | Revenue [X] | Competition [X] | Tech Fit [X]

### Rank 2: [Name] (Score: X.X/10)
...

### Rank 3: [Name] (Score: X.X/10)
...

## Filtered Out
- [Idea] — [reason]

## Recommendation
[Why Rank 1 is the best bet]
```

## Step 7: Choose and Continue

Ask the user which idea they want to pursue:

```
Which idea do you want to explore further?

1. [Rank 1 name] (Recommended)
2. [Rank 2 name]
3. [Rank 3 name]
4. None — brainstorm more / refine criteria
```

Based on their choice:

**If they pick an idea:**
```
Great choice! Next step:

/apple:validate "[one-liner description of chosen idea]"

This will research the market, analyze competitors, and give you a GO / PIVOT / NO-GO recommendation.
```

**If they want more ideas:**
- Ask what to change (different domain, different platform, more niche, etc.)
- Re-run lenses 2-5 with adjusted criteria
- Present a new shortlist

## Completion

```
Brainstorm complete!

Generated: [N] raw ideas across 5 lenses
Filtered to: [N] shortlisted ideas
Saved to: .planning/BRAINSTORM.md

Next step: /apple:validate "[chosen idea]"
```
