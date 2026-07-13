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
- Logging infrastructure (if app has backend/analytics — use `generators/logging-setup`)
- Networking layer (if app has API/sync — use `generators/networking-layer`)
- HTTP response caching (if app needs offline support — use `generators/http-cache`)
- Pagination infrastructure (if app has paginated lists — use `generators/pagination`)
- Image loading pipeline (if app displays remote images — use `generators/image-loading`)
- Consent flow (if app collects personal data or targets EU/California — use `generators/consent-flow`)
- Force update mechanism (if app has API versioning or breaking changes — use `generators/force-update`)
- Permission priming screens (if app requests sensitive permissions like camera/location — use `generators/permission-priming`)

### Phase 2: Core Features
Based on `<mvp-features>`. Tasks:
- One task per `priority="must"` feature
- Data persistence integration
- Basic UI for each feature
- Authentication flow (if `<auth>` is not None — use `generators/auth-flow`)
- Onboarding experience (if app has `<auth>` or first-run setup — use `generators/onboarding-generator`)
- Push notification setup (if Push Notifications in `<apple-technologies>` — use `generators/push-notifications`)
- Deep linking (if app has sharing or external links — use `generators/deep-linking`)
- Account deletion (if app has user accounts — Apple requirement since 2022 — use `generators/account-deletion`)
- App Clip experience (if app benefits from lightweight try-before-install — use `generators/app-clip`)
- Offline queue (if app needs to queue actions while offline — use `generators/offline-queue`)
- Spotlight indexing (if app has searchable content — use `generators/spotlight-indexing`)
- State restoration (if app has complex navigation that should survive relaunch — use `generators/state-restoration`)
- Streak tracking (if app has daily engagement or habit mechanics — use `generators/streak-tracker`)
- App extensions (if app needs share/action/keyboard extensions — use `generators/app-extensions`)
- Background processing (if app needs background tasks or downloads — use `generators/background-processing`)
- Data export (if app needs JSON/CSV/PDF export or GDPR data portability — use `generators/data-export`)

### Phase 3: Polish & Platform Features
Based on `<apple-technologies>` with `required="false"`. Tasks:
- Loading/empty/error states
- Haptic feedback
- Accessibility
- Animations
- Widget integration (if WidgetKit selected)
- Siri/Shortcuts (if App Intents selected)
- Other optional frameworks
- Localization setup (if app targets multiple regions — use `generators/localization-setup`)
- TipKit coaching tips (use `generators/tipkit-generator`)
- Live Activities (if Live Activities in `<apple-technologies>` — use `generators/live-activity-generator`)
- Feature flags infrastructure (if app has A/B testing or staged rollout — use `generators/feature-flags`)
- Announcement banner (if app needs to communicate updates/promotions in-app — use `generators/announcement-banner`)
- Feedback form (if app collects user feedback or bug reports — use `generators/feedback-form`)
- Lapsed user re-engagement (if app has retention goals — use `generators/lapsed-user`)
- Milestone celebration (if app has achievement or progress milestones — use `generators/milestone-celebration`)
- Share card (if app has shareable content — use `generators/share-card`)
- Social export (if app has content users share to social media — use `generators/social-export`)
- Usage insights dashboard (if app benefits from showing users their usage stats — use `generators/usage-insights`)
- Watermark engine (if app generates images or exports that need branding — use `generators/watermark-engine`)
- Quick win session (if app benefits from short engagement loops — use `generators/quick-win-session`)

### Phase 4: Monetization
Only if `<monetization><model>` is not "Free". Tasks:
- Monetization strategy & pricing model selection (use `monetization/` skill)
- Tier structure and free trial strategy
- App Store Connect product setup (manual)
- StoreKit 2 manager implementation
- Paywall UI (use `generators/paywall-generator` skill)
- Restore purchases
- Sandbox testing
- Review/rating prompt (use `generators/review-prompt`)
- Referral system (if app benefits from word-of-mouth growth — use `generators/referral-system`)
- Subscription lifecycle management (if app has subscriptions — use `generators/subscription-lifecycle`)
- Variable rewards (if app uses gamification or engagement hooks — use `generators/variable-rewards`)
- Offer codes setup (if app uses promo codes for influencers or partners — use `generators/offer-codes-setup`)
- Pre-order setup (if app will use App Store pre-orders — use `generators/pre-orders`)
- Promoted in-app purchases (if app has IAPs to display on product page — use `generators/promoted-iap`)
- Subscription offers (if app has subscriptions with intro/promo/win-back offers — use `generators/subscription-offers`)
- Win-back offers (if app needs to re-engage churned subscribers — use `generators/win-back-offers`)

### Phase 5: Quality & Testing
Always included. Tasks:
- Unit tests using TDD workflow (use `testing/tdd-feature` for red-green-refactor cycle)
- Test data factories for models (use `testing/test-data-factory`)
- UI snapshot tests for custom components (use `testing/snapshot-test-setup`)
- Integration tests for networking + persistence (if applicable — use `testing/integration-test-scaffold`)
- Test contracts for protocol abstractions (if applicable — use `testing/test-contract`)
- UI tests for critical flows
- Performance profiling
- Memory leak detection
- Accessibility audit
- Debug menu (for internal/TestFlight builds — use `generators/debug-menu`)

### Phase 6: Pre-Release
Always included. Tasks:
- App Store Connect setup (manual)
- App icon generation (use `generators/app-icon-generator`)
- Screenshots
- App description and keywords
- Privacy policy
- TestFlight distribution
- Error monitoring setup (use `generators/error-monitoring`)
- Screenshot automation (use `generators/screenshot-automation`)
- What's New screen (use `generators/whats-new`)
- App Store asset specs (use `generators/app-store-assets`)
- Custom product pages (if app targets multiple audiences — use `generators/custom-product-pages`)
- Featuring nomination (if pitching for Apple editorial — use `generators/featuring-nomination`)
- In-app events (if app has seasonal or live events — use `generators/in-app-events`)
- Product page optimization (if running A/B tests on App Store page — use `generators/product-page-optimization`)

### Phase 7: Submission
Always included. Tasks:
- App Review Guidelines check
- Export compliance
- Privacy declarations
- Final QA
- Submit for review
- Privacy policy and legal documents (use `legal/privacy-policy` skill)
- Rejection handling playbook (use `app-store/rejection-handler` skill)

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
Tip:  /apple:growth --new seeds the P0–P9 growth scorecard next to this roadmap
```

## Integration with Existing Skills

Reference these skills for deeper planning:
- `product/prd-generator` for detailed requirements
- `product/architecture-spec` for technical architecture
- `monetization/` for pricing strategy, tier structure, and trial design
- `generators/paywall-generator` for StoreKit 2 paywall implementation
