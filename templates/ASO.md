# App Store Optimization Template

Copy this file to your project's `.planning/ASO.md`.

```markdown
# App Store Optimization: [App Name]

## App Identity

### App Name (30 chars max)
```
[App Name]
```

### Subtitle (30 chars max)
```
[Compelling subtitle with keywords]
```

### Bundle ID
```
com.yourcompany.appname
```

---

## Keywords (100 chars max)

### Primary Keywords (high intent)
```
keyword1,keyword2,keyword3
```

### Secondary Keywords (discovery)
```
keyword4,keyword5,keyword6
```

### Full Keyword Field
```
[All keywords comma-separated, no spaces, 100 chars max]
```

### Keyword Research

| Keyword | Popularity | Difficulty | Include? |
|---------|------------|------------|----------|
| [keyword] | [1-100] | [1-100] | ✅/❌ |
| [keyword] | [1-100] | [1-100] | ✅/❌ |

**Strategy**: Target keywords with Popularity > 20 and Difficulty < 60

---

## App Description (4000 chars max)

### First Paragraph (Most Important - visible before "More")
```
[Hook - what problem you solve, for whom]
[Key benefit 1]
[Key benefit 2]
```

### Features Section
```
KEY FEATURES

• [Feature 1] - [benefit]
• [Feature 2] - [benefit]
• [Feature 3] - [benefit]
• [Feature 4] - [benefit]
```

### Social Proof (if available)
```
WHAT USERS SAY

"[Quote from review or testimonial]"
```

### Call to Action
```
Download [App Name] today and [achieve outcome]!
```

### Full Description
```
[Complete app description - 4000 chars max]
```

---

## Screenshots

### iPhone Screenshots (6.7" required, 6.5", 5.5" optional)

| Position | Content | Caption |
|----------|---------|---------|
| 1 | Hero shot - main feature | [Compelling headline] |
| 2 | Key feature A | [Benefit-focused caption] |
| 3 | Key feature B | [Benefit-focused caption] |
| 4 | Key feature C | [Benefit-focused caption] |
| 5 | Social proof or settings | [Trust-building caption] |

### iPad Screenshots (if supporting iPad)

| Position | Content | Caption |
|----------|---------|---------|
| 1 | Hero shot | [Headline] |
| ... | ... | ... |

### Screenshot Guidelines
- Show the app in use, not just the UI
- Use real content, not placeholder text
- Highlight benefits, not features
- First screenshot is most important (appears in search)
- Consider device frames vs. edge-to-edge

---

## App Preview Video (Optional but Recommended)

**Duration**: 15-30 seconds
**Resolution**: Match screenshot sizes

### Storyboard

| Timestamp | Scene | Audio/Caption |
|-----------|-------|---------------|
| 0:00-0:05 | Hook - problem statement | [Text or voiceover] |
| 0:05-0:15 | Solution demonstration | [Show key feature] |
| 0:15-0:25 | Additional features | [Quick montage] |
| 0:25-0:30 | Call to action | [Download now] |

---

## What's New (for updates)

### Version [X.Y.Z]
```
• [New feature or improvement]
• [Bug fix if notable]
• [Performance improvement]

We love hearing from you! Leave a review or contact us at [support email].
```

---

## Promotional Text (170 chars, can be updated without review)
```
[Time-sensitive promotions, seasonal messages, or highlights]
```

---

## Privacy & Support

### Privacy Policy URL
```
https://yourwebsite.com/privacy
```

### Support URL
```
https://yourwebsite.com/support
```

### Marketing URL (optional)
```
https://yourwebsite.com/app
```

---

## Localization Priority

| Language | Market Size | Priority |
|----------|-------------|----------|
| English (US) | Largest | Required |
| English (UK) | Large | High |
| Spanish | Large | High |
| German | Medium | Medium |
| French | Medium | Medium |
| Japanese | Medium | Medium |
| Chinese (Simplified) | Large | Medium |

---

## Category Selection

### Primary Category
```
[e.g., Productivity, Utilities, Health & Fitness]
```

### Secondary Category
```
[e.g., Business, Lifestyle]
```

---

## Age Rating

### Content Descriptions
- [ ] Cartoon or Fantasy Violence: None | Infrequent | Frequent
- [ ] Profanity or Crude Humor: None | Infrequent | Frequent
- [ ] Mature/Suggestive Themes: None | Infrequent | Frequent
- [ ] Gambling: None | Simulated | Real
- [ ] Horror/Fear Themes: None | Infrequent | Frequent
- [ ] Medical/Treatment Information: No | Yes
- [ ] Alcohol, Tobacco, or Drug Use: None | Infrequent | Frequent
- [ ] Sexual Content or Nudity: None | Infrequent | Frequent

### Unrestricted Web Access
- [ ] Yes | No

**Resulting Rating**: [4+ | 9+ | 12+ | 17+]
```

## How to Use

1. Run `/apple:submit` to generate initial ASO content
2. Use `app-store/keyword-optimizer` skill for keyword research
3. Use `app-store/app-description-writer` skill for description
4. Use `app-store/screenshot-planner` skill for screenshot strategy
5. Update this file as you refine your App Store presence
