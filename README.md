# SwiftShip

Spec-Driven Development for iOS/macOS Apps with Claude Code.

SwiftShip combines [GSD's workflow methodology](https://github.com/glittercowboy/get-shit-done) with deep Apple platform expertise to guide you from app idea to App Store submission.

## Quick Start

```bash
# Install
./install.sh

# Validate your idea first (recommended)
/apple:validate "habit tracking app with AI"

# If GO, define the app
/apple:new-app MyAwesomeApp

# Create development phases
/apple:roadmap

# Plan first phase
/apple:plan 1

# Build it
/apple:build

# Review before release
/apple:review

# Prepare TestFlight
/apple:testflight

# Submit to App Store
/apple:submit
```

## How It Works

```
┌─────────────────────────────────────────────────────────────────────────┐
│  COMMANDS (You invoke these)                                             │
│  /apple:validate → /apple:new-app → /apple:roadmap → /apple:plan → ...  │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  PLANNING FILES (Persistent context)                                     │
│  .planning/VALIDATION.md | APP.md | ROADMAP.md | STATE.md | PLAN.md      │
└─────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  AGENTS (Specialized execution)                              │
│  swiftui-builder | storekit-expert | hig-reviewer            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  SKILLS (Domain knowledge from claude-code-apple-skills)     │
│  ios/ | macos/ | generators/ | app-store/ | release-review/  │
└─────────────────────────────────────────────────────────────┘
```

## Commands

### Idea & Setup
| Command | Description |
|---------|-------------|
| `/apple:validate [idea]` | Validate idea with market research & competitive analysis |
| `/apple:new-app [name]` | Define a new app through guided questions |
| `/apple:map` | Analyze existing codebase (brownfield projects) |

### Planning
| Command | Description |
|---------|-------------|
| `/apple:roadmap` | Create 7-phase development roadmap |
| `/apple:discuss [phase]` | Gather implementation preferences before planning |
| `/apple:plan [phase]` | Create detailed tasks for a phase |

### Building
| Command | Description |
|---------|-------------|
| `/apple:build` | Execute tasks with specialized agents |
| `/apple:debug [issue]` | Systematic debugging with state tracking |
| `/apple:bugfix [bug]` | Quick fix for known bugs with regression test |

### Quality
| Command | Description |
|---------|-------------|
| `/apple:verify` | Verify completed work against deliverables |
| `/apple:review` | Run code, HIG, App Store, performance, and security review |
| `/apple:security [focus]` | Run security audit (storage, auth, network, privacy) |
| `/apple:perf [problem]` | Profile and diagnose performance issues |

### Release
| Command | Description |
|---------|-------------|
| `/apple:metadata` | Generate App Store content (name, keywords, description) |
| `/apple:screenshots` | Plan and automate screenshot capture |
| `/apple:deploy` | Set up Fastlane for automated deployment |
| `/apple:testflight` | Prepare and manage TestFlight beta |
| `/apple:submit` | Final App Store submission checklist |

### Version & Ideas
| Command | Description |
|---------|-------------|
| `/apple:milestone` | Complete version, archive docs, create git tag |
| `/apple:next-version [name]` | Start planning the next app version |
| `/apple:idea [desc]` | Capture an idea quickly without disrupting work |
| `/apple:ideas` | Display and manage all captured ideas |

### Session Management
| Command | Description |
|---------|-------------|
| `/apple:progress` | Show current status and next steps |
| `/apple:pause` | Create handoff docs when stopping work |
| `/apple:resume` | Restore context from previous session |
| `/apple:help` | Show all commands and usage |

## Agents

| Agent | Expertise |
|-------|-----------|
| `swiftui-builder` | Modern SwiftUI, @Observable, NavigationStack |
| `storekit-expert` | StoreKit 2, subscriptions, IAP |
| `cloudkit-expert` | iCloud sync, conflict resolution |
| `hig-reviewer` | Human Interface Guidelines compliance |
| `app-store-reviewer` | App Store Review Guidelines |

## Planning Files

When you run the commands, these files are created in your project:

```
.planning/
├── VALIDATION.md    # Idea validation (market research, competitors)
├── APP.md           # App specification (concept, architecture, scope)
├── ROADMAP.md       # Development phases with tasks
├── STATE.md         # Current position and status
├── PLAN.md          # Detailed tasks for current phase
├── VERIFICATION.md  # Verification results and issues
├── REVIEW.md        # Review findings and fixes
├── SECURITY.md      # Security audit findings
├── PERFORMANCE.md   # Performance analysis results
├── ASO.md           # App Store Optimization content
├── FEEDBACK.md      # TestFlight feedback tracking
├── IDEAS.md         # Captured ideas for future development
└── archive/         # Completed milestone archives
```

## Prerequisites

1. **Claude Code** installed and working
2. **claude-code-apple-skills** installed for domain knowledge:
   ```bash
   # Your Apple skills should be at:
   # /Users/[you]/Work/MyApps/claude-code-apple-skills/
   ```

## Installation

```bash
cd /path/to/swiftship
chmod +x install.sh
./install.sh
```

This creates symlinks in `~/.claude/` to enable the commands globally.

## Configuration

For smoother workflow, configure allowed tools at the user level. Edit `~/.claude.json`:

```json
{
  "allowedTools": [
    "Read",
    "Bash(ls:*)",
    "Bash(cat:*)",
    "Bash(find:*)",
    "Bash(head:*)",
    "Bash(tail:*)",
    "Bash(grep:*)",
    "Bash(wc:*)",
    "Bash(git status:*)",
    "Bash(git log:*)",
    "Bash(git diff:*)",
    "Bash(git branch:*)"
  ]
}
```

This allows SwiftShip agents to read files and run common commands without prompting for permission each time.

## Workflow Example

### 0. Validate Your Idea (Recommended)

```
> /apple:validate "menu bar app for focus and health"

Claude researches:
- Market size (TAM/SAM/SOM)
- Growth trends
- Top competitors
- Feature gaps
- Revenue potential
- Risk assessment

Output: GO / PIVOT / NO-GO recommendation

Creates: .planning/VALIDATION.md
```

### 1. Define Your App

```
> /apple:new-app [AppName]

Claude asks about:
- Platform (iOS, macOS, both)
- Problem it solves
- Target users
- Core features
- Monetization
- Apple frameworks needed

Creates: .planning/APP.md, CLAUDE.md
```

### 2. Create Roadmap

```
> /apple:roadmap

Creates 7 phases based on your app:
1. Foundation - Project setup
2. Core Features - MVP functionality
3. Polish - UX and platform features
4. Monetization - StoreKit (if applicable)
5. Quality - Testing
6. Pre-Release - App Store prep
7. Submission - Final review

Creates: .planning/ROADMAP.md, STATE.md
```

### 3. Plan Each Phase

```
> /apple:plan 1

Creates detailed tasks:
- Task 1: Create Xcode project (manual)
- Task 2: Define data models (auto - uses swiftui-builder)
- Task 3: Set up architecture (auto)
- Task 4: Implement navigation (auto)

Creates: .planning/PLAN.md
```

### 4. Build

```
> /apple:build

Executes each task:
- Spawns appropriate agent
- Creates/modifies files
- Verifies completion
- Commits changes
- Updates STATE.md
```

### 5. Verify

```
> /apple:verify

Checks completed work:
- Automated: Build, tests, file existence
- Manual: UI/UX, functionality, platform integration
- Diagnoses failures and creates fix tasks

Output: PASS / FAIL / PARTIAL

Creates: .planning/VERIFICATION.md
```

### 6. Review

```
> /apple:review

Runs 5 parallel reviews:
- Code quality (with concurrency pattern checks)
- HIG compliance (with accessibility and navigation)
- App Store Guidelines
- Performance (with Instruments guidance)
- Security quick-check

Creates: .planning/REVIEW.md
```

### 7. Ship

```
> /apple:testflight
# Prepare and upload beta

> /apple:submit
# Final submission checklist
```

## Integration with Apple Skills

SwiftShip references skills from `claude-code-apple-skills`:

| When... | Uses... |
|---------|---------|
| Validating idea | `product/market-research`, `product/competitive-analysis` |
| Defining app | `ios/app-planner`, `macos/app-planner` |
| Building SwiftUI views | `ios/coding-best-practices`, `macos/coding-best-practices` |
| Building Apple Intelligence | `apple-intelligence/app-intents`, `apple-intelligence/foundation-models` |
| Building animations/Liquid Glass | `design/animation-patterns`, `design/liquid-glass` |
| Building with concurrency | `swift/concurrency-patterns` |
| Adding settings screen | `generators/settings-screen` |
| Implementing paywall | `generators/paywall-generator` |
| Reviewing HIG | `ios/ui-review`, `macos/ui-review-tahoe`, `ios/navigation-patterns` |
| Running security audit | `security/`, `security/privacy-manifests` |
| Profiling performance | `performance/profiling`, `performance/swiftui-debugging` |
| Optimizing keywords | `app-store/keyword-optimizer` |
| Writing description | `app-store/app-description-writer` |
| Preparing release | `product/release-spec`, `macos/macos-capabilities` |

## Directory Structure

```
swiftship/
├── commands/apple/     # Workflow commands (25 total)
│   ├── validate.md     # Idea validation
│   ├── new-app.md      # App definition
│   ├── map.md          # Codebase analysis
│   ├── roadmap.md      # Phase planning
│   ├── discuss.md      # Implementation preferences
│   ├── plan.md         # Task planning
│   ├── build.md        # Task execution
│   ├── debug.md        # Systematic debugging
│   ├── verify.md       # Work verification
│   ├── review.md       # Quality review
│   ├── security.md     # Security audit
│   ├── perf.md         # Performance profiling
│   ├── metadata.md     # App Store content
│   ├── screenshots.md  # Screenshot automation
│   ├── deploy.md       # Fastlane setup
│   ├── testflight.md   # Beta preparation
│   ├── submit.md       # App Store submission
│   ├── milestone.md    # Complete version & archive
│   ├── next-version.md # Plan next version
│   ├── idea.md         # Capture ideas quickly
│   ├── ideas.md        # Manage all ideas
│   ├── progress.md     # Status display
│   ├── pause.md        # Session handoff
│   ├── resume.md       # Session restore
│   └── help.md         # Command reference
│
├── agents/             # Specialized agents
│   ├── swiftui-builder.md
│   ├── storekit-expert.md
│   ├── cloudkit-expert.md
│   ├── hig-reviewer.md
│   └── app-store-reviewer.md
│
├── templates/          # Planning file templates
│   ├── VALIDATION.md   # Market research & competitors
│   ├── APP.md
│   ├── ROADMAP.md
│   ├── STATE.md
│   ├── PLAN.md
│   ├── VERIFICATION.md # Work verification results
│   ├── REVIEW.md
│   ├── ASO.md
│   └── FEEDBACK.md
│
├── README.md
├── CLAUDE.md
└── install.sh
```

## Philosophy

1. **Spec-Driven**: Every app starts with a clear specification
2. **Phased Execution**: Work in focused phases, not overwhelming scope
3. **Agent Specialization**: Right agent for each task type
4. **Persistent Context**: Planning files maintain context across sessions
5. **Apple-First**: Built specifically for iOS/macOS development

## License

MIT
