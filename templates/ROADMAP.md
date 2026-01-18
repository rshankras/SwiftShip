# Development Roadmap Template

Copy this file to your project's `.planning/ROADMAP.md`.

```markdown
# Roadmap: [App Name]

## Milestone: v1.0 MVP

### Phase 1: Foundation
**Status:** pending | in_progress | completed
**Objective:** Project setup and core architecture
**Apple Focus:** Xcode config, SwiftData setup, navigation

Tasks:
- [ ] Create Xcode project with correct bundle ID and capabilities
- [ ] Define SwiftData models
- [ ] Set up app architecture (MVVM with @Observable)
- [ ] Implement navigation structure (NavigationStack/NavigationSplitView)
- [ ] Configure entitlements and Info.plist

### Phase 2: Core Features
**Status:** pending
**Objective:** Primary user flow implementation
**Apple Focus:** SwiftUI views, data binding, persistence

Tasks:
- [ ] [Main screen implementation]
- [ ] [Core feature 1]
- [ ] [Core feature 2]
- [ ] [Data persistence integration]

### Phase 3: Polish & Platform Features
**Status:** pending
**Objective:** Platform integration and UX polish
**Apple Focus:** HIG compliance, SF Symbols, animations, accessibility

Tasks:
- [ ] Add proper loading/empty/error states
- [ ] Implement haptic feedback where appropriate
- [ ] Add accessibility labels and traits
- [ ] Polish animations and transitions
- [ ] Integrate platform features (Widgets, Intents, etc.)

### Phase 4: Monetization
**Status:** pending
**Objective:** StoreKit integration (if applicable)
**Apple Focus:** StoreKit 2, subscription management

Tasks:
- [ ] Set up products in App Store Connect
- [ ] Implement StoreKit 2 manager
- [ ] Build paywall UI
- [ ] Handle restore purchases
- [ ] Test in sandbox environment

### Phase 5: Quality & Testing
**Status:** pending
**Objective:** Comprehensive testing and performance
**Apple Focus:** XCTest, Swift Testing, Instruments

Tasks:
- [ ] Unit tests for business logic (Swift Testing)
- [ ] UI tests for critical flows (XCUITest)
- [ ] Performance profiling (Instruments)
- [ ] Memory leak detection
- [ ] Accessibility audit (Accessibility Inspector)

### Phase 6: Pre-Release
**Status:** pending
**Objective:** App Store Connect setup and beta testing
**Apple Focus:** TestFlight, App Store metadata

Tasks:
- [ ] App Store Connect app record
- [ ] App icons (all sizes)
- [ ] Screenshots and previews
- [ ] App description and keywords
- [ ] Privacy policy
- [ ] TestFlight beta distribution

### Phase 7: Submission
**Status:** pending
**Objective:** App Store submission
**Apple Focus:** App Review Guidelines compliance

Tasks:
- [ ] Final App Review Guidelines check
- [ ] Export compliance
- [ ] Privacy declarations
- [ ] Final QA pass
- [ ] Submit for review

---

## Future Milestones

### v1.1 - Post-Launch Polish
- [ ] Address user feedback from reviews
- [ ] Performance improvements
- [ ] Bug fixes

### v2.0 - Major Feature Update
- [ ] [Major new feature]
- [ ] [Platform expansion - watchOS/macOS]
```

## How to Use

1. Run `/apple:roadmap` to generate this file from APP.md
2. Each phase should be completed before moving to the next
3. Update status as you progress: `pending` → `in_progress` → `completed`
4. Run `/apple:plan [phase-number]` to create detailed tasks for a phase
