---
description: Prepare and manage TestFlight beta
allowed-tools: Read, Write, Bash
---

# TestFlight Preparation

Prepare your app for TestFlight beta testing.

## Prerequisites

```
Read: .planning/APP.md
Read: .planning/STATE.md
Read: .planning/REVIEW.md (if exists)
```

## Load Skills

Read the beta testing strategy skill:
```
Read: ~/.claude/swiftship-skills/product/beta-testing/SKILL.md
```

Apply for tester segmentation, feedback collection, and go/no-go criteria.

Check for critical issues:
```
If REVIEW.md exists and has Critical issues:
⚠️ Critical issues found in last review. Fix these before TestFlight:
[List critical issues]

Run /apple:review after fixing to verify.
```

## Pre-Flight Checklist

Display and verify checklist:

```markdown
## Pre-Flight Checklist

### App Store Connect Setup (Manual)
- [ ] App record created in App Store Connect
- [ ] Bundle ID matches: [bundle-id from APP.md]
- [ ] App Information filled (name, subtitle, category)
- [ ] Pricing set (even for free apps)

### Build Requirements
- [ ] Version number set correctly in Xcode
- [ ] Build number incremented from last upload
- [ ] All required app icons present (1024x1024 + app sizes)
- [ ] Launch screen configured

### TestFlight Information
- [ ] Beta App Description written
- [ ] Test Information added (what to test)
- [ ] Contact information for testers
- [ ] Beta App Review Information (if new entitlements)

Reply with any items you need help with, or "ready" to proceed.
```

## Version & Build Number Check

```bash
# Check current version info (if project exists)
grep -A1 "MARKETING_VERSION" *.xcodeproj/project.pbxproj | head -5
grep -A1 "CURRENT_PROJECT_VERSION" *.xcodeproj/project.pbxproj | head -5
```

Suggest version strategy:
```
Current version: [detected]
Current build: [detected]

For TestFlight:
- Version: Keep same for beta iterations
- Build: Increment for each upload (e.g., [current+1])

Would you like me to update the build number?
```

## Create/Update FEEDBACK.md

Initialize feedback tracking:

```
Read template: ~/.claude/swiftship-templates/FEEDBACK.md
```

Create `.planning/FEEDBACK.md`:

```markdown
# TestFlight Feedback: [App Name]

## Current Build

- **Version**: [from project]
- **Build**: [from project]
- **Uploaded**: [pending]
- **Expires**: [pending]
- **Testers**: 0 internal, 0 external

---

## Feedback Summary

| Category | Count | Status |
|----------|-------|--------|
| Crashes | 0 | - |
| Bugs | 0 | - |
| Feature Requests | 0 | - |
| Positive | 0 | - |

---

## Build History

| Build | Date | Testers | Crashes | Notes |
|-------|------|---------|---------|-------|
| [pending] | [date] | - | - | Initial beta |

---

[Rest of template...]
```

## Archive Instructions

Provide archive guidance:

```markdown
## Archive and Upload

### Option 1: Xcode (Recommended for first-time)

1. Select "Any iOS Device" as destination
2. Product → Archive
3. In Organizer: Distribute App → App Store Connect → Upload
4. Wait for processing (5-30 minutes)

### Option 2: Command Line

```bash
# Build archive
xcodebuild -scheme [AppName] \
  -configuration Release \
  -archivePath build/[AppName].xcarchive \
  archive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath build/[AppName].xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist

# Upload
xcrun altool --upload-app \
  -f build/export/[AppName].ipa \
  -t ios \
  -u [APPLE_ID] \
  -p @keychain:AC_PASSWORD
```

### Option 3: Fastlane (If configured)

```bash
fastlane beta
```
```

## Update STATE.md

After user confirms upload:

```markdown
## TestFlight Status
- **Latest Build:** [build number]
- **Upload Date:** [today]
- **Status:** Processing
- **Internal Testers:** [count]
- **External Testers:** 0
- **Expires:** [today + 90 days]
```

## Post-Upload Checklist

```markdown
## After Upload

### Processing (5-30 minutes)
- [ ] Build appears in App Store Connect
- [ ] Processing completes without errors
- [ ] Build is ready for testing

### Internal Testing
- [ ] Add internal testers (App Store Connect users)
- [ ] Testers receive notification
- [ ] Confirm install works

### External Testing (Optional)
- [ ] Create external testing group
- [ ] Add beta description
- [ ] Submit for Beta App Review (first build only)
- [ ] After approval, add external testers

### Collect Feedback
- [ ] Monitor TestFlight feedback in App Store Connect
- [ ] Check for crash reports
- [ ] Update .planning/FEEDBACK.md with findings
```

## Completion Message

```
✅ TestFlight preparation complete!

Created/Updated:
- .planning/FEEDBACK.md - Feedback tracking
- .planning/STATE.md - TestFlight status

Next steps:
1. Archive and upload your build
2. Add testers in App Store Connect
3. Collect feedback and update FEEDBACK.md
4. When ready: /apple:submit for App Store release
```

## Subsequent Runs

On subsequent runs, show:

```
## TestFlight Status

Previous builds:
| Build | Date | Status | Crashes |
|-------|------|--------|---------|
[from FEEDBACK.md build history]

Current feedback:
- Crashes: [count]
- Bugs: [count]

Options:
1. Upload new build (increment build number)
2. Review current feedback
3. Address feedback and rebuild

What would you like to do?
```
