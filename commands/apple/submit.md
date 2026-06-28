---
description: Final App Store submission checklist
allowed-tools: Read, Write, Task, mcp__asc-metadata__get_metadata, mcp__asc-metadata__create_version
---

# App Store Submission

Final checklist and preparation for App Store submission.

## Prerequisites

```
Read: .planning/APP.md
Read: .planning/STATE.md
Read: .planning/REVIEW.md
Read: .planning/FEEDBACK.md (if exists)
```

## Pre-Submission Checks

### Check 1: Review Status

```
If REVIEW.md has unresolved Critical/High issues:
⚠️ Outstanding issues from last review:

🔴 Critical:
[List unresolved critical issues]

🟠 High:
[List unresolved high issues]

Recommendation: Fix these before submitting.
Run /apple:review after fixing.

Continue anyway? (not recommended)
```

### Check 2: TestFlight Feedback

```
If FEEDBACK.md has unresolved crashes/bugs:
⚠️ Unresolved TestFlight feedback:

Crashes: [count]
Bugs: [count]

Review .planning/FEEDBACK.md for details.
Fix critical issues before public release.
```

## Final Review Agent

Spawn comprehensive review:

```
Task({
  subagent_type: "app-store-reviewer",
  prompt: `
    Final App Store submission review.

    Reference skills:
    - release-review/
    - app-store/
    - security/privacy-manifests/

    ## Required Checks

    ### App Store Connect Requirements
    - [ ] App icon (1024x1024 PNG, no alpha)
    - [ ] Screenshots for all required sizes
    - [ ] App previews (optional but recommended)
    - [ ] App description (≤4000 chars)
    - [ ] Keywords (≤100 chars)
    - [ ] Support URL
    - [ ] Privacy Policy URL
    - [ ] Category selection
    - [ ] Age rating questionnaire

    ### App Review Guidelines Compliance

    **1.x Safety**
    - [ ] No objectionable content
    - [ ] User safety considered

    **2.x Performance**
    - [ ] App is complete (no placeholders)
    - [ ] No crashes or bugs
    - [ ] Metadata matches functionality

    **3.x Business**
    - [ ] IAP follows rules (if applicable)
    - [ ] Subscriptions have required info
    - [ ] No external payment links

    **4.x Design**
    - [ ] Original design (not copycat)
    - [ ] Sufficient functionality
    - [ ] Apple trademarks used correctly

    **5.x Legal**
    - [ ] Privacy manifest complete (iOS 17+)
    - [ ] Required reason APIs declared
    - [ ] Data collection accurate in nutrition labels
    - [ ] GDPR considerations (EU)
    - [ ] Localization complete for target markets (reference: generators/localization-setup)

    ### Common Rejection Reasons
    Check for these specific issues:

    - [ ] Guideline 2.1 - App crashes
    - [ ] Guideline 2.3.3 - Screenshots don't match app
    - [ ] Guideline 2.3.7 - Inaccurate app description
    - [ ] Guideline 4.0 - Design spam or copycat
    - [ ] Guideline 5.1.1 - Privacy policy issues
    - [ ] Guideline 5.1.2 - Missing data collection disclosure

    Report any issues that could cause rejection.
  `
})
```

## Submission Preparation

### Release Spec

Load the release spec skill for structured submission preparation:
```
Read: ~/.claude/swiftship-skills/product/release-spec/SKILL.md
```

Use this to generate release notes, version summary, and changelog.

### Legal Documents

Load the privacy policy skill for legal document generation:
```
Read: ~/.claude/swiftship-skills/legal/privacy-policy/SKILL.md
```

Verify privacy policy, terms of service, and GDPR/CCPA compliance.

### macOS Entitlements Check (if macOS app)

If APP.md indicates macOS platform:
```
Read: ~/.claude/swiftship-skills/macos/macos-capabilities/SKILL.md
```

Verify:
- [ ] All required entitlements are declared
- [ ] Sandbox configuration is correct
- [ ] Hardened Runtime is enabled
- [ ] Notarization requirements met (if distributing outside App Store)

## ASO Preparation

Create or update `.planning/ASO.md`:

```
Read template: ~/.claude/swiftship-templates/ASO.md
```

Invoke ASO skills:

```markdown
## App Store Optimization

For keyword research, use:
- app-store/keyword-optimizer skill

For description writing, use:
- app-store/app-description-writer skill

For screenshot planning, use:
- app-store/screenshot-planner skill

For overall marketing strategy, use:
- app-store/marketing-strategy skill

For Apple Search Ads optimization, use:
- app-store/apple-search-ads skill
```

Generate initial ASO.md based on APP.md:

```markdown
# App Store Optimization: [App Name]

## App Identity

### App Name
```
[from APP.md]
```

### Subtitle
```
[Suggest based on core-flow and differentiator]
```

## Keywords (100 chars)

Based on app concept:
```
[Generate relevant keywords]
```

[Continue with ASO template sections...]
```

## Submission Checklist

Present final checklist:

```markdown
## Final Submission Checklist

### Technical
- [ ] Build uploaded and processed
- [ ] No TestFlight crashes unaddressed
- [ ] Export compliance answered

### App Store Connect
- [ ] App Information complete
- [ ] Pricing and Availability set
- [ ] App Privacy questionnaire complete
- [ ] Age Rating set
- [ ] All screenshots uploaded
- [ ] App description finalized
- [ ] Keywords optimized
- [ ] Support and Privacy URLs valid

### Legal
- [ ] Privacy policy hosted and accessible
- [ ] Terms of service (if applicable)
- [ ] EULA (if custom terms needed)

### Final Verification
- [ ] All metadata reviewed for accuracy
- [ ] No placeholder text remaining
- [ ] Contact info correct for review team

Ready to submit?
```

## Update STATE.md

After submission:

```markdown
## App Store Status
- **Version:** [version]
- **Submitted:** [today]
- **Status:** Waiting for Review
- **Estimated Review:** ~24-48 hours (typical)
- **Notes:** [any special notes]
```

## Post-Submission Guidance

```markdown
## After Submission

### Review Process
- Typical review: 24-48 hours
- May be longer for first submission or complex features
- You'll receive email notification

### If Rejected
1. Read rejection reason carefully
2. Check specific guideline cited
3. Load rejection handling skill:
   Read: ~/.claude/swiftship-skills/app-store/rejection-handler/SKILL.md
4. Use app-store/review-response-writer skill for professional responses
5. Fix the issue and resubmit with notes explaining fix

### If Approved
1. Set release date (immediate or scheduled)
2. Prepare marketing materials
3. Monitor ratings and reviews
4. Respond to user reviews
```

## Optional handoff: pre-fill the version (then stop)

Per `~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md`, if the
`asc-metadata` MCP is available you can pre-fill the App Store version record
before the manual submit.

- **DETECT:** is `mcp__asc-metadata__create_version` available? If not, skip to
  the manual completion below.
- **PREVIEW:** `get_metadata` for the app; show the version string that would be
  created and any last metadata to push (reuse the per-field diff from
  `/apple:metadata` Step 7.5).
- **CONFIRM:** create the version + push approved metadata? (default: do it
  manually.)
- **ACT:** `create_version` for the release version; push only approved fields.
- **THEN STOP — hard gate.** Submitting for review is **not** automated: there is
  no submit API tool, and it is a reviewer-facing, rate-limited, hard-to-reverse
  action. Instruct the user to do the final **Submit for Review** themselves in
  the App Store Connect web UI.
- **FALL BACK:** unavailable or declined → the manual completion below.

## Completion Message

```
✅ Submission preparation complete!

Created/Updated:
- .planning/ASO.md - App Store Optimization content
- .planning/STATE.md - Submission status

Final Checklist Status:
- Technical: [✅/⚠️]
- App Store Connect: [✅/⚠️]
- Legal: [✅/⚠️]

[If all checks pass:]
🚀 Ready for submission!
Go to App Store Connect → Submit for Review

[If issues found:]
⚠️ Please address the following before submitting:
[List issues]

Estimated review time: 24-48 hours

Good luck! 🍀
```
