# SwiftShip

This repository contains a workflow system for iOS/macOS app development with Claude Code.

## Repository Structure

```
commands/apple/   - Slash commands for workflow orchestration
agents/           - Specialized agents for task execution
templates/        - Planning file templates
```

## Commands

- `/apple:new-app [name]` - Start new app definition
- `/apple:roadmap` - Create development phases
- `/apple:plan [phase]` - Plan specific phase
- `/apple:build` - Execute current plan
- `/apple:review` - Run comprehensive review
- `/apple:testflight` - Prepare beta release
- `/apple:submit` - App Store submission

## Agents

- `swiftui-builder` - Modern SwiftUI patterns
- `storekit-expert` - StoreKit 2 implementation
- `cloudkit-expert` - iCloud sync
- `hig-reviewer` - HIG compliance
- `app-store-reviewer` - App Store Guidelines

## Integration

This system references skills from `claude-code-apple-skills`:
- Path: `/Users/ravishankar/Work/MyApps/claude-code-apple-skills/skills/`
- Skills: ios/, macos/, generators/, app-store/, release-review/

## Templates

Templates in `templates/` are copied to projects as `.planning/` files:
- APP.md - App specification
- ROADMAP.md - Development phases
- STATE.md - Current state
- PLAN.md - Phase tasks
- REVIEW.md - Review findings
- ASO.md - App Store optimization
- FEEDBACK.md - TestFlight feedback

## Usage

When working with this repo:
1. Commands are invoked via `/apple:*` syntax
2. Agents are spawned by commands as needed
3. Templates are copied to target projects

Do not modify files directly - use the commands.
