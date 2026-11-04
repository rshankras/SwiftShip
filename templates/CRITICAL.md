# Critical Paths Template

Copy this file to your project's `.planning/CRITICAL.md`.

```markdown
# Critical Paths

<!-- Code you must understand yourself, not just accept from an agent.
     /apple:build and /apple:autonomous PAUSE before committing any task
     that changes a matching path and show you the diff — even under
     --yes. Keep this to 3–5 areas: every entry costs a pause, and a list
     that pauses on everything gets rubber-stamped.
     Seeded by /apple:new-app or /apple:map; edit freely. Delete a row to
     stop pausing on it; delete the file to turn the feature off. -->

**Updated:** [date]

| Area | Paths (globs) | Why it matters |
|------|---------------|----------------|
| [Payments] | [Sources/Store/**, **/*Purchase*.swift] | [Money + entitlements — a bug charges users or gives away the app] |
| [Sync] | [**/*Sync*.swift, **/CloudKit/**] | [Conflict handling — a bug silently loses data across devices] |
| [Migrations] | [**/*Migration*.swift, **/Schema*.swift] | [Runs once on users' real data — no undo] |
| [User data] | [**/*Keychain*.swift, **/Export/**] | [Credentials, deletion, export — privacy + App Review] |
```

## How to Use

1. **Seeded by `/apple:new-app`** from APP.md's tech choices (StoreKit,
   CloudKit, SwiftData, auth), using likely paths, and **by `/apple:map`**
   from the real paths it found
2. **Checked by `/apple:build` Step 4c** (and so by `/apple:autonomous`):
   when a task's changed files match a glob, the build stops before the
   commit, shows the diff for those files, and waits for your OK
3. Globs match against repo-relative paths; `**` spans directories
4. Absent file = no critical-path pauses; every command works unchanged
