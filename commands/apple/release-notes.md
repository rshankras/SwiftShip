---
description: Generate release notes for App Store, TestFlight, and changelog
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
---

# Release Notes Generator

Generate release notes for multiple channels from git history and planning files.

## Step 1: Load Context

Read all available context:

```
Read: .planning/STATE.md (required — current version, milestone info)
Read: .planning/ROADMAP.md (if exists — phase names for grouping)
Read: .planning/FEEDBACK.md (if exists — beta feedback addressed)
Read: .planning/ASO.md (if exists — current "What's New" section)
Read: .planning/APP.md (if exists — app name and description)
```

Detect version range from git tags:

```bash
# Get the latest tag
git describe --tags --abbrev=0 2>/dev/null

# Get the previous tag (for range)
git tag --sort=-version:refname | head -5
```

If no tags exist, ask the user:

```
No git tags found. How should I determine the commit range?

1. All commits since a specific date
2. Last N commits
3. All commits on current branch
4. Specific commit range (hash..hash)
```

Also check for archived milestone docs:

```
Glob: .planning/archive/v*/MILESTONE.md
```

## Step 2: Gather Commit History

Get commits in the determined range:

```bash
# If tags exist
git log --oneline v[PREV]..HEAD

# Get detailed info for categorization
git log --format="%h %s" v[PREV]..HEAD
```

If the range has more than 50 commits, also get a summary:

```bash
git shortlog -s -n v[PREV]..HEAD
git diff --stat v[PREV]..HEAD
```

## Step 3: Categorize Changes

Group commits into user-facing categories:

| Category | Commit Indicators |
|----------|-------------------|
| **New Features** | `feat:`, `add:`, `new:`, introduces new files/views |
| **Improvements** | `improve:`, `enhance:`, `update:`, `refactor:` with user-visible change |
| **Bug Fixes** | `fix:`, `bugfix:`, `resolve:`, `crash:` |
| **Performance** | `perf:`, performance-related changes |
| **Internal** | `chore:`, `ci:`, `docs:`, `test:`, `refactor:` with no user-visible change |

If commits don't follow conventional commit format, categorize by reading the diff:

```bash
# For ambiguous commits, check what changed
git show --stat [hash]
```

Cross-reference with `.planning/ROADMAP.md` phase names to group features by theme.

## Step 4: Confirm with User

Present the categorized changes and ask:

```
## Categorized Changes

### New Features
- [feature 1]
- [feature 2]

### Improvements
- [improvement 1]

### Bug Fixes
- [fix 1]
- [fix 2]

### Internal (won't appear in user-facing notes)
- [internal change 1]

---

Questions:
1. Is this categorization correct? (move items between categories if needed)
2. Any changes to highlight or downplay?
3. What tone should I use?
   - Professional (default for App Store)
   - Casual (friendly, conversational)
   - Playful (fun, emoji-friendly)
4. Which outputs should I generate?
   - App Store "What's New" (4000 char limit)
   - TestFlight notes (for beta testers)
   - Changelog (developer-facing)
   - Social/Slack announcement (brief)
```

## Step 5: Generate Outputs

Generate each requested format:

### App Store "What's New"

Rules:
- Maximum 4000 characters
- User-facing language only — no technical jargon, no file names, no API references
- Lead with the most impactful feature
- Group related changes under themes when possible
- End with a warm sign-off or encouragement to update
- Match the app's tone from APP.md if available

Format:
```
[Theme or headline — what's exciting about this update]

• [Feature/improvement in user terms]
• [Feature/improvement in user terms]
• [Bug fix described as improvement: "Fixed" → "Now works correctly"]

[Optional closing line]
```

### TestFlight Notes

Rules:
- More technical than App Store — testers want specifics
- Include what to test and known issues
- Reference specific screens/flows affected
- Include build/version info

Format:
```
Build [version] ([build number])

What's New:
- [Change with specific screen/flow references]
- [Change with technical context]

What to Test:
- [Specific flows to exercise]
- [Edge cases to try]

Known Issues:
- [Any remaining issues]

Feedback: Use TestFlight feedback or [contact method]
```

### Changelog

Rules:
- Developer-facing, technical detail is fine
- Include file/component references where helpful
- Follow Keep a Changelog format
- Group by category

Format:
```markdown
## [Version] - [Date]

### Added
- [Feature]: [description] ([files/components affected])

### Changed
- [What changed]: [why] ([files affected])

### Fixed
- [Bug]: [root cause and fix] ([files affected])

### Internal
- [Refactoring/CI/test changes]
```

### Social/Slack Announcement

Rules:
- 2-3 sentences maximum
- Lead with the single most exciting change
- Include version number
- Casual, upbeat tone

Format:
```
[App Name] [version] is here! [Headline feature in one sentence]. [Secondary highlights]. Update now on the App Store.
```

### Press Release (optional)

For press outreach on major releases:
```
Read: ~/.claude/swiftship-skills/growth/press-media/SKILL.md
```

### Community Announcement (optional)

For building-in-public and community updates:
```
Read: ~/.claude/swiftship-skills/growth/community-building/SKILL.md
```

## Step 6: Write Output

Save all generated content to `.planning/RELEASE-NOTES.md`:

```markdown
# Release Notes: [App Name] [Version]

Generated: [today's date]
Range: [previous-tag]..HEAD ([N] commits)

---

## App Store "What's New"

[generated content]

---

## TestFlight Notes

[generated content]

---

## Changelog

[generated content]

---

## Social/Slack Announcement

[generated content]
```

## Step 7: Update ASO.md

If `.planning/ASO.md` exists, update its "What's New" section with the App Store release notes:

```
Read: .planning/ASO.md
Edit the "What's New" section with the generated App Store text.
```

## Completion

```
✅ Release notes generated!

Created: .planning/RELEASE-NOTES.md

Includes:
- [list which formats were generated]

Version: [version]
Commits covered: [N] ([range])

Next steps:
1. Review and edit the notes in .planning/RELEASE-NOTES.md
2. Copy App Store text to App Store Connect
3. Copy TestFlight notes when uploading build
4. /apple:submit when ready to ship
```
