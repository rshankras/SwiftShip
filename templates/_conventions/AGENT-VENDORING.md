# Agent Vendoring Convention

SwiftShip's six agents live in `~/.claude/agents/` — machine-local, installed
by `install.sh`. **Project-level `.claude/agents/` outranks user-level and
travels with the git repo** — cloud sessions, CI, remote-launched sessions,
and other machines all load it. Vendoring copies the agents into the target
project so `/apple:build` and `/apple:review` keep their pinned-Sonnet agents
in every environment, not just where `install.sh` ran.

Why it matters: in a session without `~/.claude/agents/`, the pin silently
disappears — build tasks run inline on the session model (premium rates) and
review degrades to a single-pass self-review instead of the 5-agent +
adversarial-verification gate.

The six agents, by name:
`swift-generalist`, `swiftui-builder`, `storekit-expert`, `cloudkit-expert`,
`hig-reviewer`, `app-store-reviewer`.

## The step (referenced by `new-app` and `map`)

1. **DETECT** — confirm the six files exist in `~/.claude/agents/`. Missing →
   skip this step silently (zero-install rule).
2. **Already vendored?** If the project has `.claude/agents/` containing the
   marker file `.swiftship-agents`: `diff -q` each of the six against the
   source. All identical → note "vendored agents up to date" and move on.
   Any differ → offer a refresh, listing which files changed.
3. **Not vendored → ask once** (AskUserQuestion): "Vendor SwiftShip's 6 pinned
   agents into this project's `.claude/agents/` so cloud/remote/CI sessions
   can use them? (Recommended if you ever work outside this machine.)" State
   the trade-off plainly: vendored copies drift when SwiftShip updates its
   agents — re-run `/apple:map` (or accept the refresh offer) after upgrading.
4. **On yes:**
   - `mkdir -p .claude/agents`
   - copy the six files from `~/.claude/agents/`
   - write `.claude/agents/.swiftship-agents` — one JSON line:
     `{"vendored":"<date -u +%Y-%m-%dT%H:%M:%SZ>","source":"SwiftShip install"}`
   - suggest committing `.claude/agents/` with the project
5. **Never touch non-SwiftShip files** in `.claude/agents/` — manage only the
   six by name, and refresh only when the marker file is present.

## Degraded-mode guard (referenced by `build` and `review`)

If an agent spawn fails because the subagent type is unavailable (no
`~/.claude/agents/`, no vendored `.claude/agents/` — common in cloud/remote
sessions):

1. Tell the user immediately which agents are missing, that pinned-model
   execution / the full review gate can't run here, and that vendoring (above)
   or a local session fixes it.
2. Ask before proceeding in degraded mode — never silently substitute inline
   work for the agent architecture.
3. If proceeding: label all output prominently as **DEGRADED** (in
   `REVIEW.md`, use a banner at the top), and log the ledger outcome per
   `USAGE-LOG.md` with `"outcome":"partial"` and `"degraded":"no-agents"` —
   a degraded run must never be indistinguishable from the full gate.
