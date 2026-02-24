---
description: Create phased development roadmap from APP.md
allowed-tools: Read, Write
---

# Create Apple Development Roadmap

Generate a phased development roadmap based on the app specification in `.planning/APP.md`.

## Prerequisites

First, verify APP.md exists:
```
Read: .planning/APP.md
```

If APP.md doesn't exist, instruct the user:
```
⚠️ No app specification found. Run /apple:new-app first to define your app.
```

## Roadmap Generation

Parse APP.md and create a tailored roadmap based on:
- Platform (iOS, macOS, or both)
- Selected Apple frameworks
- Monetization model
- MVP features

## Standard Phases

Create `.planning/ROADMAP.md` with these phases, customized to the app:

### Phase 1: Foundation
Always included. Tasks:
- Xcode project setup with bundle ID from APP.md
- SwiftData/Core Data models based on `<data-layer>`
- App architecture (MVVM with @Observable)
- Navigation structure based on `<core-flow>`
- Entitlements based on `<apple-technologies>`

### Phase 2: Core Features
Based on `<mvp-features>`. Tasks:
- One task per `priority="must"` feature
- Data persistence integration
- Basic UI for each feature

### Phase 3: Polish & Platform Features
Based on `<apple-technologies>` with `required="false"`. Tasks:
- Loading/empty/error states
- Haptic feedback
- Accessibility
- Animations
- Widget integration (if WidgetKit selected)
- Siri/Shortcuts (if App Intents selected)
- Other optional frameworks

### Phase 4: Monetization
Only if `<monetization><model>` is not "Free". Tasks:
- Monetization strategy & pricing model selection (use `monetization/` skill)
- Tier structure and free trial strategy
- App Store Connect product setup (manual)
- StoreKit 2 manager implementation
- Paywall UI (use `generators/paywall-generator` skill)
- Restore purchases
- Sandbox testing

### Phase 5: Quality & Testing
Always included. Tasks:
- Unit tests (Swift Testing)
- UI tests for critical flows
- Performance profiling
- Memory leak detection
- Accessibility audit

### Phase 6: Pre-Release
Always included. Tasks:
- App Store Connect setup (manual)
- App icons
- Screenshots
- App description and keywords
- Privacy policy
- TestFlight distribution

### Phase 7: Submission
Always included. Tasks:
- App Review Guidelines check
- Export compliance
- Privacy declarations
- Final QA
- Submit for review

## Output: ROADMAP.md

```markdown
# Roadmap: [App Name from APP.md]

## Milestone: v1.0 MVP

### Phase 1: Foundation
**Status:** pending
**Objective:** Project setup and core architecture
**Apple Focus:** Xcode config, [data layer from APP.md], navigation

Tasks:
- [ ] Create Xcode project: [bundle-id from APP.md]
- [ ] Define [data layer] models for: [inferred from features]
- [ ] Set up MVVM architecture with @Observable
- [ ] Implement [navigation type] navigation
- [ ] Configure entitlements: [from apple-technologies]

### Phase 2: Core Features
**Status:** pending
**Objective:** [core-flow from APP.md]
**Apple Focus:** SwiftUI views, data binding

Tasks:
[Generate from mvp-features with priority="must"]

### Phase 3: Polish & Platform Features
**Status:** pending
**Objective:** Platform integration and UX polish
**Apple Focus:** HIG, [optional frameworks from APP.md]

Tasks:
- [ ] Loading/empty/error states
- [ ] Haptic feedback
- [ ] Accessibility labels and traits
- [ ] Animations
[Add tasks for each optional framework selected]

[Continue with remaining phases...]
```

## Also Create: STATE.md

Initialize `.planning/STATE.md`:

```markdown
# Project State

## Current Position
- **Milestone:** v1.0 MVP
- **Phase:** 1 (Foundation)
- **Phase Status:** pending
- **Last Updated:** [current date]

## Environment
- **Xcode:** [detect or ask]
- **Swift:** 6.0
- **Target iOS:** [from APP.md minimum-os]
- **Target macOS:** [from APP.md minimum-os if applicable]

## Key Decisions Made
| Decision | Rationale | Date |
|----------|-----------|------|
| [Architecture] | MVVM with @Observable | [today] |
| [Data Layer] | [from APP.md] | [today] |

## Blockers
[None]

## TestFlight Status
- **Latest Build:** Not started

## App Store Status
- **Status:** Not Started
```

## Completion Message

```
✅ Roadmap created!

Created:
- .planning/ROADMAP.md - 7 development phases
- .planning/STATE.md - Project state tracker

Your roadmap has [X] phases:
1. Foundation - Project setup
2. Core Features - [feature count] must-have features
3. Polish - UX and platform features
4. Monetization - [if applicable]
5. Quality - Testing and performance
6. Pre-Release - App Store prep
7. Submission - Final review and submit

Next: Run /apple:plan 1 to create detailed tasks for Phase 1
```

## Integration with Existing Skills

Reference these skills for deeper planning:
- `product/prd-generator` for detailed requirements
- `product/architecture-spec` for technical architecture
- `monetization/` for pricing strategy, tier structure, and trial design
- `generators/paywall-generator` for StoreKit 2 paywall implementation
