---
description: Run security audit on your Apple app
argument-hint: [focus-area]
allowed-tools: Read, Write, Glob, Grep
---

# Security Audit

Run a comprehensive security review of your Apple app, covering secure storage, authentication, network security, platform-specific concerns, and privacy manifests.

## Arguments

- `$ARGUMENTS`: Optional focus area — `storage`, `auth`, `network`, `platform`, `privacy`. If omitted, runs all phases.

## Prerequisites

Verify project has code to review:
```
Glob: **/*.swift
```

If no Swift files found:
```
⚠️ No Swift files found. Build your app first with /apple:build
```

## Read Context

```
Read: .planning/APP.md (if exists)
Read: .planning/STATE.md (if exists)
```

## Load Security Skills

Load the master security skill and privacy manifests skill:
```
Read: ~/.claude/swiftship-skills/security/SKILL.md
Read: ~/.claude/swiftship-skills/security/privacy-manifests/SKILL.md
```

## Execution Phases

Run all phases unless `$ARGUMENTS` specifies a focus area.

### Phase 1: Project Discovery

Scan the project to determine scope:
- Identify data storage patterns (Keychain, UserDefaults, files, SwiftData, Core Data)
- Identify authentication flows
- Identify network calls (URLSession, Alamofire, etc.)
- Identify platform entitlements and capabilities
- Check for third-party dependencies with security implications

### Phase 2: Secure Storage (focus: `storage`)

```
Read: ~/.claude/swiftship-skills/security/secure-storage.md
```

Audit:
- Keychain usage for sensitive data (tokens, passwords, API keys)
- UserDefaults misuse for sensitive data
- File protection levels
- SwiftData/Core Data encryption
- Hardcoded secrets in source code

### Phase 3: Authentication (focus: `auth`)

```
Read: ~/.claude/swiftship-skills/security/biometric-auth.md
```

Audit:
- Sign in with Apple implementation
- Biometric authentication (Face ID, Touch ID) correctness
- Token storage and refresh
- Session management
- Authentication bypass risks

### Phase 4: Network Security (focus: `network`)

```
Read: ~/.claude/swiftship-skills/security/network-security.md
```

Audit:
- App Transport Security (ATS) configuration
- Certificate pinning (if applicable)
- API key exposure in requests
- Data in transit protection
- WebView security (if applicable)

### Phase 5: Platform-Specific (focus: `platform`)

```
Read: ~/.claude/swiftship-skills/security/platform-specifics.md
```

Audit:
- Entitlements review (sandbox, capabilities)
- App Groups data sharing
- URL scheme handling (deep links)
- Extension security boundaries
- Clipboard data exposure

### Phase 6: Privacy Manifest Audit (focus: `privacy`)

Using the privacy-manifests skill:
- Check for `PrivacyInfo.xcprivacy` presence
- Validate Required Reason APIs are declared
- Verify data collection matches App Store privacy labels
- Check third-party SDK privacy manifests
- Flag missing tracking domain declarations

Also load the privacy policy skill for legal compliance:
```
Read: ~/.claude/swiftship-skills/legal/privacy-policy/SKILL.md
```

Verify privacy policy covers all collected data types and GDPR/CCPA requirements.

## Output

Generate `.planning/SECURITY.md`:

```markdown
# Security Audit: [App Name]

**Platform**: [from APP.md]
**Audit Date**: [today]
**Focus**: [all / specific area]

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| Critical | [count] | ⬜ Pending |
| High | [count] | ⬜ Pending |
| Medium | [count] | ⬜ Pending |
| Low | [count] | ⬜ Pending |

**Overall Risk Level:** [Low / Medium / High / Critical]

---

## 🔴 Critical Issues
[Issues that could lead to data breach or App Store rejection]

---

## 🟠 High Priority
[Significant security gaps]

---

## 🟡 Medium Priority
[Security improvements recommended]

---

## 🟢 Low Priority
[Hardening suggestions]

---

## ✅ Security Strengths
[Positive security findings]

---

## Privacy Manifest Status
- [ ] PrivacyInfo.xcprivacy present
- [ ] Required Reason APIs declared
- [ ] Tracking domains declared
- [ ] Data collection labels accurate

---

## Recommended Action Plan
[Prioritized list of fixes with effort estimates]
```

## Completion Message

```
🔒 Security audit complete!

Created: .planning/SECURITY.md

Summary:
- 🔴 Critical: [count]
- 🟠 High: [count]
- 🟡 Medium: [count]
- 🟢 Low: [count]

[If critical issues:]
⚠️ Critical security issues found - must fix before release.

[If no critical issues:]
✅ No critical security issues found.

Next steps:
- Review .planning/SECURITY.md for detailed findings
- Fix issues by priority (critical first)
- Run /apple:security again after fixes to verify
- Run /apple:review for full quality review
```
