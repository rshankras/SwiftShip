---
description: Analyze existing codebase before adding SwiftShip workflow
allowed-tools: Read, Glob, Grep, Bash
---

# Map Existing Codebase

Analyze an existing iOS/macOS project to understand its structure before integrating SwiftShip workflow. Essential for brownfield projects.

## When to Use

- Adding SwiftShip to an existing project
- Taking over a project from someone else
- Returning to a project after a long break
- Before major refactoring

## Step 1: Detect Project Type

Look for project indicators:

```bash
# Check for Xcode project
ls -la *.xcodeproj *.xcworkspace 2>/dev/null

# Check for Swift Package
ls -la Package.swift 2>/dev/null

# Check for existing planning
ls -la .planning/ 2>/dev/null
```

## Step 2: Analyze Project Structure

### 2.1 Directory Structure

```bash
# Get directory tree (excluding build artifacts)
find . -type d -not -path "*/.*" -not -path "*/DerivedData/*" -not -path "*/build/*" | head -50
```

### 2.2 File Inventory

```bash
# Count files by type
echo "Swift files:" && find . -name "*.swift" -not -path "*/.*" | wc -l
echo "SwiftUI views:" && grep -rl "struct.*View" --include="*.swift" . 2>/dev/null | wc -l
echo "Tests:" && find . -name "*Tests.swift" -o -name "*Test.swift" | wc -l
```

### 2.3 Architecture Detection

Use Grep to identify patterns:

```
# Check for architecture patterns
Grep: "@Observable" in *.swift       # Modern SwiftUI
Grep: "ObservableObject" in *.swift  # Legacy SwiftUI
Grep: "@MainActor" in *.swift        # Concurrency
Grep: "@Model" in *.swift            # SwiftData
Grep: "NSManagedObject" in *.swift   # Core Data
Grep: "import Combine" in *.swift    # Reactive
Grep: "import ComposableArchitecture" in *.swift  # TCA
```

## Step 3: Identify Key Components

### 3.1 App Entry Point

```
Glob: *App.swift
Read: [AppName]App.swift
```

### 3.2 Main Views

```
Grep: "struct.*View.*:.*View" in *.swift
```

### 3.3 Data Models

```
Grep: "@Model|struct.*:.*Codable|class.*:.*NSManagedObject" in *.swift
```

### 3.4 Services/Managers

```
Grep: "class.*Manager|class.*Service|struct.*Client" in *.swift
```

### 3.5 External Dependencies

```bash
# Check for SPM dependencies
cat Package.swift 2>/dev/null || cat *.xcodeproj/project.pbxproj | grep "repositoryURL" | head -20

# Check for CocoaPods
cat Podfile 2>/dev/null
```

## Step 4: Assess Code Quality

### 4.1 Test Coverage

```bash
# Count test files vs implementation files
echo "Implementation:" && find . -name "*.swift" -not -name "*Test*" -not -path "*/Tests/*" | wc -l
echo "Tests:" && find . -name "*Test*.swift" -o -path "*/Tests/*.swift" | wc -l
```

### 4.2 Code Smells

```
Grep: "TODO|FIXME|HACK|XXX" in *.swift
Grep: "force unwrap|!" in *.swift (review for force unwraps)
Grep: "print\(" in *.swift (debug prints)
```

### 4.3 Documentation

```
Grep: "///" in *.swift (doc comments)
```

## Step 5: Generate Codebase Map

Create `.planning/CODEBASE.md`:

```markdown
# Codebase Map

**Project:** [Name from .xcodeproj]
**Analyzed:** [date]

---

## Project Overview

| Metric | Value |
|--------|-------|
| Swift files | X |
| Lines of code | ~X |
| Test files | X |
| Test coverage | ~X% (estimated) |

## Structure

```
[Directory tree]
```

## Architecture

**Pattern:** [Detected: MVVM / MVC / TCA / Mixed]
**State Management:** [@Observable / ObservableObject / Combine / Mixed]
**Data Persistence:** [SwiftData / Core Data / UserDefaults / None]
**Navigation:** [NavigationStack / NavigationView / UIKit / Mixed]

## Key Files

### Entry Point
- `[App].swift` - App entry, scene configuration

### Main Views
| View | Purpose | Location |
|------|---------|----------|
| [View1] | [Purpose] | `path/to/file.swift` |
| [View2] | [Purpose] | `path/to/file.swift` |

### Data Models
| Model | Type | Location |
|-------|------|----------|
| [Model1] | [SwiftData/@Model] | `path/to/file.swift` |
| [Model2] | [Codable struct] | `path/to/file.swift` |

### Services
| Service | Purpose | Location |
|---------|---------|----------|
| [Service1] | [Purpose] | `path/to/file.swift` |

## Dependencies

### Swift Package Manager
| Package | Purpose |
|---------|---------|
| [Package1] | [Purpose] |

### Frameworks Used
- [x] SwiftUI
- [ ] UIKit
- [x] SwiftData
- [ ] Core Data
- [ ] CloudKit
- [ ] HealthKit
- [ ] WidgetKit
- [ ] App Intents

## Code Quality

### Technical Debt
| Issue | Count | Severity |
|-------|-------|----------|
| TODOs | X | Low |
| FIXMEs | X | Medium |
| Force unwraps | X | Review needed |
| Debug prints | X | Clean before release |

### Testing
- Unit tests: [X files]
- UI tests: [X files]
- Estimated coverage: [X%]

## Patterns Identified

### Good Patterns
- [Pattern 1] - [Where used]
- [Pattern 2] - [Where used]

### Areas for Improvement
- [Area 1] - [Why/recommendation]
- [Area 2] - [Why/recommendation]

---

## Recommendations

### Before Continuing Development

1. [ ] [Recommendation 1]
2. [ ] [Recommendation 2]

### Integration with SwiftShip

To add SwiftShip workflow to this project:

1. Run `/apple:new-app [name]` - Creates APP.md from existing code
2. The questionnaire will be pre-filled based on this analysis
3. Run `/apple:roadmap` - Creates phases for remaining work

---

*Generated by SwiftShip /apple:map*
```

## Step 6: Vendor Agents (optional, recommended for cloud/remote work)

Apply `~/.claude/swiftship-templates/_conventions/AGENT-VENDORING.md`: offer to
copy SwiftShip's six pinned agents into this project's `.claude/agents/` (or
refresh stale vendored copies) so they load in any environment — cloud, CI,
remote-launched sessions. Skip silently if the convention file or the source
agents are absent. If the user accepts, remind them that agents load at
session start: the vendored copies won't spawn until a fresh session, so
restart before running `/apple:build` or `/apple:review`.

## Step 7: Completion

```
Codebase mapped!

Created: .planning/CODEBASE.md

Summary:
- [X] Swift files found
- Architecture: [Detected pattern]
- Data: [Detected storage]
- Tests: [X] files ([X]% estimated coverage)

Recommendations:
1. [Key recommendation 1]
2. [Key recommendation 2]

Next steps:
- Review .planning/CODEBASE.md for accuracy
- Run /apple:new-app [name] to create app specification
- SwiftShip will use this analysis to inform the workflow
```
