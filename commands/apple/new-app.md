---
description: Define a new iOS/macOS app through structured questioning
argument-hint: [app-name]
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# New Apple App Definition

You are an expert Apple platform architect helping define a new app. Guide the user through structured questions to create a comprehensive app specification.

## Initial Setup

First, create the planning directory:
```bash
mkdir -p .planning
```

## Check for Existing Validation

Before asking questions, check if `.planning/VALIDATION.md` exists:

```bash
ls .planning/VALIDATION.md
```

**If VALIDATION.md exists:**
- Read it first: `Read: .planning/VALIDATION.md`
- Pre-fill answers from validation findings (problem, users, differentiator, monetization)
- Skip questions already answered in validation
- Confirm pre-filled answers with user: "Based on your validation, I'll use [X] for [field]. Is that correct?"

**If VALIDATION.md doesn't exist:**
- Recommend running `/apple:validate` first for better results
- Proceed with full questioning if user wants to continue without validation

## Questioning Process

Ask questions in phases, ONE AT A TIME. Wait for user response before proceeding.

### Phase 1: Platform & Distribution

1. **Platform**: Is this for iOS, macOS, or both?
   - If both: iOS-first with Mac Catalyst, or native for each?

2. **Minimum OS**: What's your minimum deployment target?
   - Recommend: iOS 17+ / macOS 14+ for modern SwiftUI features

3. **Distribution**: How will you distribute?
   - App Store
   - Direct download (macOS only)
   - TestFlight only (beta)

4. **Device Types**: Which devices?
   - iPhone only
   - iPhone + iPad
   - iPad only
   - Mac
   - Apple Watch (companion)
   - Apple TV

### Phase 2: Core Concept

5. **App Name**: What's the app called?
   - If the user doesn't have a name yet (or wants options), offer to generate
     and validate App-Store-ready candidates first:
     `Read: ~/.claude/swiftship-skills/product/app-namer/SKILL.md`
     It produces a ranked, availability-checked shortlist (ASC name / trademark /
     domain / handle) with name + subtitle. Then continue with the chosen name.

6. **Problem**: What problem does this app solve?
   - Be specific about the pain point

7. **Users**: Who are your target users?
   - Demographics, behaviors, needs

8. **Core Flow**: What's the ONE thing users do most?
   - The primary action that delivers value

9. **Differentiator**: What makes this different from alternatives?
   - Why would someone choose this over competitors?

### Phase 3: Technical Architecture

10. **UI Framework**: SwiftUI (recommended) or UIKit?
    - SwiftUI is strongly recommended for new apps

11. **Data Storage**: How will you store data?
    - Local only (SwiftData recommended for iOS 17+)
    - Cloud sync (CloudKit/iCloud)
    - Backend API (specify provider)

12. **Authentication**: What authentication method?
    - None (anonymous use)
    - Sign in with Apple (recommended if any auth needed)
    - Custom auth + Sign in with Apple

13. **Monetization**: How will you make money?
    - Free
    - Paid upfront ($X.XX)
    - Freemium (free with in-app purchases)
    - Subscription (monthly/yearly)

### Phase 4: Apple Technologies

14. **Apple Frameworks**: Which of these do you need?
    Present as a checklist:
    - [ ] WidgetKit (home screen/lock screen widgets)
    - [ ] App Intents (Siri and Shortcuts integration)
    - [ ] Live Activities (lock screen updates)
    - [ ] Apple Intelligence (iOS 18.1+ on-device AI)
    - [ ] CloudKit (iCloud sync)
    - [ ] HealthKit (health and fitness data)
    - [ ] HomeKit (smart home)
    - [ ] MapKit (maps and location)
    - [ ] StoreKit 2 (in-app purchases)
    - [ ] Push Notifications
    - [ ] SharePlay (shared experiences)
    - [ ] Focus Filters (focus mode integration)

15. **Privacy Requirements**:
    - What user data will you collect?
    - Do you need camera, microphone, or location?
    - Any analytics or tracking?

### Phase 5: Scope

16. **MVP Features**: What's the minimum for v1.0?
    - List 3-5 must-have features
    - Distinguish from nice-to-haves

17. **Non-Goals**: What are you explicitly NOT building?
    - Important to define boundaries

18. **Timeline**: When do you want to submit to App Store?
    - For planning purposes only

## Output Generation

After gathering all answers, load platform-specific planning skills:

**If iOS selected:**
```
Read: ~/.claude/swiftship-skills/ios/app-planner/SKILL.md
```

**If macOS selected:**
```
Read: ~/.claude/swiftship-skills/macos/app-planner/SKILL.md
```

**If both platforms selected:** Read both skill files.

Use the platform-specific app planner insights to inform the APP.md generation below.

### 1. Create `.planning/APP.md`

Read the template from the swiftship repo and fill it in:
```
Read: ~/.claude/swiftship-templates/APP.md
```

Fill in the XML structure with user's answers. All fields should be populated based on the conversation.

**If VALIDATION.md exists:** Include a reference to validation findings in the `<concept>` section.

### 2. Create or Update `CLAUDE.md`

Create a project-level CLAUDE.md with quick reference:

```markdown
# [App Name]

## Quick Reference
- Platform: [iOS/macOS/both]
- Min OS: [version]
- UI: SwiftUI
- Data: [SwiftData/Core Data] [+ CloudKit]
- Auth: [Sign in with Apple/None/Custom]
- Monetization: [Free/Paid/Subscription]

## Project Structure
[To be filled as project develops]

## Key Commands
- `/apple:roadmap` - Create development phases
- `/apple:plan [phase]` - Plan a specific phase
- `/apple:build` - Execute current plan
- `/apple:review` - Run pre-release review

## Apple Frameworks
[List selected frameworks from Phase 4]

## Conventions
- Follow Apple HIG
- Use SF Symbols for icons
- SwiftUI previews for all views
- @Observable for state management (iOS 17+)
- SwiftData @Model for persistence
```

## Completion Message

After creating both files:

```
✅ App specification complete!

Created:
- .planning/APP.md - Full app specification
- CLAUDE.md - Project quick reference

Next steps:
1. Review .planning/APP.md and adjust if needed
2. Run /apple:roadmap to create development phases
3. Run /apple:plan 1 to plan the first phase
```

## Workflow Integration

**Recommended flow:**
```
/apple:validate → /apple:new-app → /apple:roadmap → /apple:plan → /apple:build
```

**If user skipped validation:**
- Suggest running `/apple:validate` for market research and competitive analysis
- Or suggest using skills directly:
  - `product/market-research` for market sizing
  - `product/competitive-analysis` for competitor review

**Files this command creates:**
- `.planning/APP.md` - Full app specification
- `CLAUDE.md` - Project quick reference (or updates existing)
