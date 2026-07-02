# Usage Log Convention

A local-only ledger of SwiftShip command runs, used to decide what to improve
(a future `/apple:insights` command reads it). **Nothing ever leaves the
machine.** No PII, no app content, no secrets — timestamps, command names,
counts, and enums only. Users can delete the ledger or stop writing it at any
time with no effect on SwiftShip.

## The ledger

- File: `~/.claude/swiftship-usage.jsonl` — one JSON object per line, append-only.
- Two event types share it:
  - `"event": "invoke"` — written automatically by the optional hook
    (`hooks/swiftship-usage-log.sh`, offered by `install.sh`). Zero token cost.
  - `"event": "outcome"` — written by workflow commands at completion (below).

## Which commands log an outcome

Multi-step workflow commands: `build`, `review`, `plan`, `autonomous`,
`verify`, `bugfix`, `test`, `ship`, `submit`. One-shot info commands
(`help`, `progress`, `ideas`) do not log.

## Outcome schema

Append exactly one line when the command finishes (success or not):

| Field | Type | Notes |
|---|---|---|
| `ts` | string | ISO 8601 UTC |
| `event` | string | always `"outcome"` |
| `cmd` | string | command name without prefix, e.g. `"build"` |
| `project` | string | basename of the working directory |
| `phase` | number | omit if not phase-scoped |
| `outcome` | string | `completed` \| `blocked` \| `partial` \| `cancelled` |
| `blocked_on` | string | only when blocked: `manual-task` \| `critical-finding` \| `build-failure` \| `verify-failure` \| `other` |
| `tasks_done`, `tasks_total` | number | build/autonomous only |
| `agents` | object | spawn counts by agent, e.g. `{"swift-generalist": 3, "swiftui-builder": 1}` |
| `findings` | object | review only, post-verification: `{"critical": 0, "high": 2, "medium": 5, "refuted": 1}` |

Omit fields that don't apply. Keep the line under ~250 chars.

## How to write it

One Bash append at the completion step — never rewrite the file, never read it
back during a run:

```bash
printf '%s\n' '{"ts":"2026-07-02T09:41:00Z","event":"outcome","cmd":"build","project":"StudySpark","phase":3,"outcome":"completed","tasks_done":4,"tasks_total":4,"agents":{"swift-generalist":3,"swiftui-builder":1}}' >> ~/.claude/swiftship-usage.jsonl
```

## Rules

1. Logging must never block or fail the task — if the write errors, continue
   silently.
2. Commands must work when this file or the ledger is absent (zero-install
   rule).
3. Never log file paths, app names beyond the project basename, code, or user
   text — schema fields only.
