---
description: Show all SwiftShip commands and usage
allowed-tools: Read
---

# SwiftShip Help

Display all available commands, their purpose, and recommended workflow.

## Command Reference

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                              SWIFTSHIP COMMANDS                                ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  IDEA DISCOVERY                                                              ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:brainstorm [focus]  Brainstorm app ideas tailored to your skills     ║
║                             Creates: .planning/BRAINSTORM.md                 ║
║                                                                               ║
║  /apple:validate [idea]     Validate idea with market research & competitors  ║
║                             Creates: .planning/VALIDATION.md                  ║
║                                                                               ║
║  PROJECT SETUP                                                                ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:new-app [name]      Define app through guided questions               ║
║                             Creates: .planning/APP.md, CLAUDE.md              ║
║                                                                               ║
║  /apple:map                 Analyze existing codebase (brownfield)            ║
║                             Creates: .planning/CODEBASE.md                    ║
║                                                                               ║
║  PLANNING                                                                     ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:roadmap             Create 7-phase development roadmap                ║
║                             Creates: .planning/ROADMAP.md, STATE.md           ║
║                                                                               ║
║  /apple:discuss [phase]     Gather implementation preferences before planning ║
║                             Creates: .planning/PREFERENCES.md                 ║
║                                                                               ║
║  /apple:plan [phase]        Create detailed tasks for a phase                 ║
║                             Creates: .planning/PLAN.md                        ║
║                                                                               ║
║  BUILDING                                                                     ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:build               Execute tasks with specialized agents             ║
║                             Updates: .planning/STATE.md, PLAN.md              ║
║                                                                               ║
║  /apple:debug [issue]       Systematic debugging with state tracking          ║
║                             Creates: .planning/DEBUG.md                       ║
║                                                                               ║
║  /apple:bugfix [bug]        Quick fix for known bugs with regression test     ║
║                             Accepts: crash log, error msg, issue URL          ║
║                                                                               ║
║  QUALITY                                                                      ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:verify              Verify work against deliverables (UAT)            ║
║                             Creates: .planning/VERIFICATION.md                ║
║                                                                               ║
║  /apple:review              Run code, HIG, and App Store review               ║
║                             Creates: .planning/REVIEW.md                      ║
║                                                                               ║
║  /apple:security [focus]    Run security audit (storage, auth, network, etc.) ║
║                             Creates: .planning/SECURITY.md                    ║
║                                                                               ║
║  /apple:perf [problem]      Profile and diagnose performance issues           ║
║                             Creates: .planning/PERFORMANCE.md                 ║
║                                                                               ║
║  /apple:visual-qa [paths]   Screenshot-based visual QA or code UI audit      ║
║                             Creates: .planning/VISUAL-QA.md                  ║
║                                                                               ║
║  RELEASE                                                                      ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:metadata            Generate App Store content (keywords, description)║
║                             Creates: .planning/ASO.md                         ║
║                                                                               ║
║  /apple:screenshots         Plan and automate screenshot capture              ║
║                             Creates: .planning/SCREENSHOTS.md                 ║
║                                                                               ║
║  /apple:deploy              Set up Fastlane for automated deployment          ║
║                             Creates: fastlane/, .github/workflows/            ║
║                                                                               ║
║  /apple:testflight          Prepare and manage TestFlight beta                ║
║                             Creates: .planning/FEEDBACK.md                    ║
║                                                                               ║
║  /apple:release-notes       Generate release notes for App Store & TestFlight ║
║                             Creates: .planning/RELEASE-NOTES.md              ║
║                                                                               ║
║  /apple:submit              Final App Store submission checklist              ║
║                                                                               ║
║  VERSION & IDEAS                                                              ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:milestone           Complete version, archive docs, create git tag    ║
║                             Creates: .planning/archive/v[VERSION]/            ║
║                                                                               ║
║  /apple:next-version [name] Start planning the next app version               ║
║                             Updates: ROADMAP.md, STATE.md                     ║
║                                                                               ║
║  /apple:idea [description]  Capture idea quickly without disrupting work      ║
║                             Creates/Updates: .planning/IDEAS.md               ║
║                                                                               ║
║  /apple:ideas               Display and manage all captured ideas             ║
║                                                                               ║
║  SESSION MANAGEMENT                                                           ║
║  ───────────────────────────────────────────────────────────────────────────  ║
║  /apple:progress            Show current status and next steps                ║
║                                                                               ║
║  /apple:pause               Create handoff docs when stopping work            ║
║                             Creates: .planning/HANDOFF.md                     ║
║                                                                               ║
║  /apple:resume              Restore context from previous session             ║
║                                                                               ║
║  /apple:learn [lesson]      Capture mistake or pattern into skills            ║
║                                                                               ║
║  /apple:help                Show this help message                            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

## Recommended Workflow

```
NEW PROJECT                          EXISTING PROJECT
───────────                          ─────────────────
     │                                      │
     ▼                                      ▼
/apple:brainstorm                     /apple:map
"What should I build?"                "Understand the codebase"
     │                                      │
     ▼                                      │
/apple:validate                             │
"Is this worth building?"                   │
     │                                      │
     ▼                                      │
/apple:new-app ◄────────────────────────────┘
"Define the app"
     │
     ▼
/apple:roadmap
"Create 7-phase plan"
     │
     ▼
┌─────────────────────────────────────────────┐
│            FOR EACH PHASE                   │
│                                             │
│  /apple:discuss  →  Gather preferences      │
│       │                                     │
│       ▼                                     │
│  /apple:plan     →  Create tasks            │
│       │                                     │
│       ▼                                     │
│  /apple:build    →  Implement               │
│       │                                     │
│       ▼                                     │
│  /apple:verify   →  Check it works          │
│       │                                     │
│       ▼                                     │
│  /apple:review   →  Quality check           │
│                                             │
└─────────────────────────────────────────────┘
     │
     ▼
/apple:testflight
"Beta testing"
     │
     ▼
/apple:submit
"Ship it!"
```

## Quick Reference

| I want to... | Command |
|--------------|---------|
| Find an app idea | `/apple:brainstorm "health"` |
| Validate an app idea | `/apple:validate "idea"` |
| Define my app | `/apple:new-app AppName` |
| See my progress | `/apple:progress` |
| Plan next phase | `/apple:plan [N]` |
| Build features | `/apple:build` |
| Check if it works | `/apple:verify` |
| Review code quality | `/apple:review` |
| Run security audit | `/apple:security` |
| Diagnose performance | `/apple:perf "slow scrolling"` |
| Check visual quality | `/apple:visual-qa ~/Desktop/screen.png` |
| Set up CI/CD | `/apple:deploy` |
| Prepare App Store content | `/apple:metadata` |
| Plan screenshots | `/apple:screenshots` |
| Ship to TestFlight | `/apple:testflight` |
| Submit to App Store | `/apple:submit` |
| Complete a version | `/apple:milestone` |
| Start next version | `/apple:next-version` |
| Capture an idea quickly | `/apple:idea "description"` |
| Review all ideas | `/apple:ideas` |
| Stop for today | `/apple:pause` |
| Continue tomorrow | `/apple:resume` |
| Generate release notes | `/apple:release-notes` |
| Capture a lesson learned | `/apple:learn "always use weak self in closures"` |
| Fix a known bug quickly | `/apple:bugfix "crash in settings"` |
| Investigate a mystery bug | `/apple:debug "description"` |

## Planning Files

All planning files are stored in `.planning/`:

| File | Purpose | Created By |
|------|---------|------------|
| `BRAINSTORM.md` | Ranked idea shortlist | `/apple:brainstorm` |
| `VALIDATION.md` | Market research, competitors | `/apple:validate` |
| `APP.md` | App specification | `/apple:new-app` |
| `CODEBASE.md` | Existing code analysis | `/apple:map` |
| `ROADMAP.md` | Development phases | `/apple:roadmap` |
| `STATE.md` | Current position | `/apple:roadmap` |
| `PREFERENCES.md` | Implementation choices | `/apple:discuss` |
| `PLAN.md` | Current phase tasks | `/apple:plan` |
| `DEBUG.md` | Debug session log | `/apple:debug` |
| `VERIFICATION.md` | UAT results | `/apple:verify` |
| `REVIEW.md` | Quality findings | `/apple:review` |
| `SECURITY.md` | Security audit findings | `/apple:security` |
| `PERFORMANCE.md` | Performance analysis | `/apple:perf` |
| `VISUAL-QA.md` | Visual QA findings | `/apple:visual-qa` |
| `ASO.md` | App Store content | `/apple:metadata` |
| `SCREENSHOTS.md` | Screenshot plan | `/apple:screenshots` |
| `FEEDBACK.md` | Beta feedback | `/apple:testflight` |
| `RELEASE-NOTES.md` | Release text for all channels | `/apple:release-notes` |
| `IDEAS.md` | Captured ideas | `/apple:idea` |
| `HANDOFF.md` | Session handoff | `/apple:pause` |
| `archive/` | Completed versions | `/apple:milestone` |

## Specialized Agents

SwiftShip uses these agents during `/apple:build`:

| Agent | Expertise |
|-------|-----------|
| `swiftui-builder` | Modern SwiftUI, @Observable, NavigationStack |
| `storekit-expert` | StoreKit 2, subscriptions, IAP |
| `cloudkit-expert` | iCloud sync, conflict resolution |
| `hig-reviewer` | Human Interface Guidelines |
| `app-store-reviewer` | App Store Review Guidelines |

## Getting Help

- **Documentation:** https://github.com/[repo]/swiftship
- **Issues:** https://github.com/[repo]/swiftship/issues
- **Skills reference:** `claude-code-apple-skills` repository

## Tips

1. **Always validate first** - `/apple:validate` saves wasted effort
2. **Use progress often** - `/apple:progress` keeps you oriented
3. **Capture ideas instantly** - `/apple:idea "thought"` keeps you focused
4. **Pause properly** - `/apple:pause` preserves context for tomorrow
5. **Verify before review** - `/apple:verify` catches functional issues
6. **Review before ship** - `/apple:review` catches quality issues
7. **Archive versions** - `/apple:milestone` preserves history for reference
