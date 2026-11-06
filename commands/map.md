---
description: Analyze existing codebase before adding SwiftShip workflow
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
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

### 3.6 Existing Helpers (reuse inventory)

Agents rebuild helpers that already exist — a second date formatter,
hand-formatted `Decimal` prices next to a `PriceFormatter`, a fresh
`URLSession` wrapper beside the real client. Inventory what's meant to be
shared so `/apple:build` can hand it to every agent:

```
Grep: "Formatter|formatted\(" in *.swift            # formatters (number, date, currency, measurement)
Grep: "URLSession|class.*Client|struct.*Client|protocol.*Client" in *.swift   # networking
Grep: "ModelContainer|ModelContext|Repository|Store\b" in *.swift            # persistence helpers
Grep: "extension Color|extension Font|enum Spacing|Theme|DesignTokens" in *.swift   # design tokens
Grep: "Logger\(|os_log" in *.swift                  # logging
Grep: "struct .*: ViewModifier|extension View" in *.swift   # shared modifiers
```

Keep only code **meant to be reused** (used from 2+ files, or clearly a
utility by name/location). For each: name, path, one-line purpose. Skip
one-off private helpers — the list is passed to every build agent, so short
beats complete.

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

### 4.4 Design Debt (SwiftUI projects)

How expensive a future redesign is depends on how much styling bypasses the
tokens: raw font sizes, raw colours, numeric spacing/radius, and case or
tracking applied at call sites. Measure it per area (the folder holding each
view file; token/style folders and tests are excluded) so any redesign quote
starts from a number:

```bash
bash ~/.claude/swiftship-templates/_scripts/design-debt.sh
```
It prints a table per area (raw font, colour, spacing and call-site case
counts; debt %; files over 300/500 lines; identifiers vs interactive
controls), the overall **Design debt score**, and any font declared in
Info.plist but missing from the repo. The script is tested against fixture
projects in SwiftShip's CI. If the script is missing, SwiftShip is out of date: tell the user to update it (`claude plugin update apple@indie-apple-stack`, or `git pull` for a manual install). Don't retype the program from memory.

Read the result as an **estimate**, not an audit: system styles
(`.headline`, `.secondary`) count as tokens, and `.uppercased()` in
non-UI logic inflates the call-site column. What matters is the score and
which areas lead the table.
- **Score < 15%**: styling is mostly tokenized, so a restyle is mostly token edits.
- **15–40%**: mixed, and restyling costs real hours in the top areas.
- **> 40%**: most styling is hand-set, so a redesign means touching nearly every
  view. Recommend a design-system pass first.
- **Declared-but-missing fonts** are a live bug: the app is silently on the
  system font. Report them under Technical Debt regardless of the score.

Skip this step for projects with no SwiftUI view files (the script says so).

## Step 5: Generate Codebase Map

Create `.planning/CODEBASE.md`:

```markdown
# Codebase Map

**Project:** [Name from .xcodeproj]
**Analyzed:** [date]

**In plain words:** [Two or three sentences a non-developer could follow: what the app is built with, what's in good shape, and the biggest risk.]

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

## Folder Rules

What each folder is for, and the lines it must not cross (Step 5.7).
Known exceptions are files that broke the rule before it existed; the list
only shrinks.

| Folder | For | Must not | Enforced by | Known exceptions |
|--------|-----|----------|-------------|------------------|
| [App/Views/] | [screens] | [use CloudKit, StoreKit or URLSession directly] | [SwiftLint `folder_views_no_data` / FolderRuleTests / not enforced] | [none / 2 files] |

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

### Design Debt
**Score: [X]%** ([raw] raw style values of [total] style calls across [N] view files) — measured [date]

[Per-area table from Step 4.4, top 10 rows by debt %]

- Custom fonts: [all bundled | ⚠️ declared but missing: …]
- View files over 300 / 500 lines: [n] / [n]
- Interactive elements with accessibilityIdentifier: ~[ids] of ~[interactive]

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

## Step 5.5: Write the Helpers Inventory

Write `.planning/UTILITIES.md` from the Step 3.6 results using the template
at `~/.claude/swiftship-templates/UTILITIES.md` (one table row per helper:
name → path → use for; drop empty sections). If the file already exists,
merge — add newly found helpers, keep existing rows, never delete rows the
user added. If Step 3.6 found nothing shareable, skip the file and say so in
the completion message.

## Step 5.6: Seed the Critical Paths

Find the areas a developer must understand rather than hand to agents:
```bash
grep -rlE "import StoreKit|Transaction\.|Product\.purchase" --include=*.swift . | grep -v -e /Tests/ -e .build/ | head
grep -rlE "import CloudKit|CKContainer|cloudKitDatabase" --include=*.swift . | grep -v -e /Tests/ -e .build/ | head
grep -rlE "SchemaMigrationPlan|VersionedSchema|NSMigrationManager" --include=*.swift . | grep -v -e /Tests/ -e .build/ | head
grep -rlE "SecItem|Keychain|deleteAccount|DataExport" --include=*.swift . | grep -v -e /Tests/ -e .build/ | head
```
Write `.planning/CRITICAL.md` from the template at
`~/.claude/swiftship-templates/CRITICAL.md` with one row per area found,
using the **real** directories/files as globs (prefer a directory glob over
listing every file). 3–5 rows at most; no hits → skip the file. If the file
already exists, add only new areas — never remove or rewrite the user's rows.

## Step 5.7: Folder Rules ("must not")

Agents copy whatever patterns they see and put code wherever it works.
CODEBASE.md says what each folder holds; this step adds the lines a folder
must not cross ("Views must not talk to CloudKit", "Models must not import
SwiftUI", "only Payments/ uses StoreKit"), and turns each one you keep into
a check that fails when it's broken.

**1. Survey** which frameworks each folder uses:
```bash
bash ~/.claude/swiftship-templates/_scripts/folder-imports.sh               # folder <tab> framework <tab> files
bash ~/.claude/swiftship-templates/_scripts/folder-imports.sh --files CloudKit   # which files use one
```
Names starting `api:` are direct calls (`api:URLSession`,
`api:CKContainer`, `api:Product.purchase`) that need no import of their
own. If the script is missing, SwiftShip is out of date: tell the user to
update it (`claude plugin update apple@indie-apple-stack`, or `git pull`
for a manual install), and skip this step.

**2. Suggest 3–6 rules** the survey supports. Common shapes:
- a views folder (`Views/`, `Screens/`, `Features/*/Views`) must not use
  CloudKit, StoreKit or networking directly (data goes through a service or store)
- a models folder must not import SwiftUI, UIKit or AppKit
- only one folder uses StoreKit / CloudKit / `URLSession` (pick the folder
  that holds most of it today)

For each, say whether it's **true today** or **broken in N files** (list
them with `--files`). Don't suggest a rule broken in most of the files it
covers: that's how the app is built, not an exception. No folder structure
to speak of (everything in one folder) → skip this step and say so.

**3. Ask once** (`AskUserQuestion`, multiSelect) which rules to keep, each
with its plain status ("true today" / "broken in 3 files; they'd be listed
as known exceptions"). Nothing chosen → skip to step 5 and write the table
with "not enforced".

**4. Turn each kept rule into a check**, the way `/apple:learn` does
(its "For Enforcement" section):
- **One folder, one framework** → a SwiftLint custom rule in `.swiftlint.yml`:
  ```yaml
  custom_rules:
    folder_models_no_ui:          # folder rule: Models must not import SwiftUI
      name: "Models must not import SwiftUI"
      regex: '^\s*(@\w+\s+)*import\s+(SwiftUI|UIKit|AppKit)\b'
      included: ["App/Models/"]
      excluded: ["App/Models/Legacy Note\\.swift"]   # known exceptions; this list only shrinks
      message: "Models stay UI-free; put view code in Views/."
      severity: error
  ```
  For a direct-call rule, match the call (`URLSession`, `CKContainer`) too.
- **"Only X may use Y"** → a fitness-function test (import-boundary
  allowlist plus API scan) in the app's test target:
  ```
  Read: ~/.claude/swiftship-skills/testing/fitness-functions/SKILL.md
  ```
  The allowlist is folder X plus the known exceptions.
- **Known exceptions:** files that break the rule today are listed in the
  rule itself (`excluded:` or the allowlist), each with a comment that the
  list only shrinks. The rule then passes today and fails on any new break.
- **Prove each check**, without touching the user's files:
  - *Passes on the real code:* `swiftlint lint --strict --quiet`, or the
    fitness test by name.
  - *Fails on a new break:* plant the forbidden import in a file inside
    the folder, in a throwaway copy, with the new rule copied in:
    ```bash
    bash ~/.claude/swiftship-templates/_scripts/expect-red.sh --no-build-check \
      --copy .swiftlint.yml --swap "<a file in the folder>" 'import Foundation' $'import Foundation\nimport CloudKit' \
      -- swiftlint lint --strict --quiet
    ```
    (For a fitness test: `--copy` the test file, drop `--no-build-check`,
    and run the test by name.) `RED` = proven. Anything else: fix the rule
    and try again; still not red → don't install it, and mark the rule
    "not enforced (check didn't work)".
- No SwiftLint and no test target → keep the rule in the table as "not
  enforced yet" and suggest `/apple:test` to set up a test target.

**5. Write the table** into CODEBASE.md's `## Folder Rules` section (see
Step 5's template): one row per folder that has a purpose worth stating,
with the rules kept. Build agents and `/apple:review` read this table.

## Step 6: Vendor Agents (optional, recommended for cloud/remote work)

Apply `~/.claude/swiftship-templates/_conventions/AGENT-VENDORING.md`: offer to
copy SwiftShip's six pinned agents into this project's `.claude/agents/` (or
refresh stale vendored copies) so they load in any environment — cloud, CI,
remote-launched sessions. Skip silently if the convention file or the source
agents are absent. If the user accepts, remind them that agents load at
session start: the vendored copies won't spawn until a fresh session, so
restart before running `/apple:build` or `/apple:review`.

## Step 6.5: Agent Rule in CLAUDE.md (optional)

Agents follow whichever tool is handy; for Simulator work that's screenshots,
which are expensive and make tap positions a guess. Offer to add one line to
the project's `CLAUDE.md` (create a minimal one if absent):

```markdown
## Agent Rules
- Navigate the Simulator using the accessibility tree (AXe `describe-ui`, filtered); take screenshots only to check the result, never to find tap positions
```

Show the diff and add it only on an explicit yes. Skip if an equivalent rule
is already present. Never rewrite other parts of an existing `CLAUDE.md`.

## Step 7: Completion

**Wording:** write the completion message and CODEBASE.md's top line per `~/.claude/swiftship-templates/_conventions/PLAIN-OUTPUT.md` (the `reader:` line in PREFERENCES.md; default plain: one plain first sentence, terms explained, a closing "You need to decide" line). Skip if the file is absent.

```
Codebase mapped!

[One plain sentence: what kind of app this is, how healthy the code looks, and the one thing to know first.]

Created: .planning/CODEBASE.md
         .planning/UTILITIES.md  ([N] shared helpers agents will reuse — or "none found")
         .planning/CRITICAL.md   ([areas] — /apple:build pauses for review on these — or "none found")
         Folder rules: [n] kept, [n] enforced by a check ([n] known exceptions) — or "none"

Summary:
- [X] Swift files found
- Architecture: [Detected pattern]
- Data: [Detected storage]
- Tests: [X] files ([X]% estimated coverage)
- Design debt: [X]% raw styling ([top area]) — or "n/a (no SwiftUI views)"

Recommendations:
1. [Key recommendation 1]
2. [Key recommendation 2]

Next steps:
- Review .planning/CODEBASE.md for accuracy
- Run /apple:new-app [name] to create app specification
- SwiftShip will use this analysis to inform the workflow
```
