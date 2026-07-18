# Optional Tool Handoff Convention

Some SwiftShip steps can **act directly** on an external service — push App Store
metadata, capture a live screenshot, read sales numbers — instead of only
printing manual instructions. Wherever a command says **"Optional handoff:"**,
apply the five steps below in order.

**The manual path is ALWAYS the default and is never removed.** These handoffs
are a convenience layered on top; every command must still work with zero MCPs
or skills installed.

"Default" means the manual path always exists and always works — **not** that
it is suggested first. When DETECT succeeds, the direct path is the primary
path: reads happen silently, writes go preview → confirm → apply. Manual
instructions are the fallback for when detection fails — never ask the user to
click through a UI for something a detected tool can do (that's the bug this
convention exists to prevent, in both directions).

Loaded by commands via:
```
Read: ~/.claude/swiftship-templates/_conventions/TOOL-HANDOFF.md
```

---

## The five steps

### 1. DETECT (silently — no prompt)
Confirm the capability is actually available in THIS session before mentioning it:
- **MCP tool:** the EXACT tool name is in your available tools
  (e.g. `mcp__asc-metadata__get_metadata`). Not listed → skip straight to step 5.
- **Skill / CLI:** the skill or binary exists (`run-simulator` skill, `xcrun`,
  `screencapture`, `git`). Missing → step 5.
- **Credential/config:** if the tool needs config (e.g. `~/.asc-metadata-mcp/config.json`)
  and a read-only probe fails, treat it as unavailable → step 5.

Never assume availability. **Never invent or call a tool that isn't in your
listed tools.** If detection is uncertain, fall back — don't guess.

### 2. PREVIEW (read-only first)
Show exactly what WILL change, as a **before → after diff**:
- **Target:** name it unambiguously — app name + App Store Connect id / bundle id,
  or "iOS Simulator <name>" / "this Mac".
- **Current value:** fetched read-only THIS run (e.g. `get_metadata`,
  `list_beta_groups`) — never assumed or remembered.
- **Proposed value:** what SwiftShip would write.
- For any outward write, state plainly:
  > ⚠️ This is LIVE on App Store Connect and visible to [users / testers / reviewers].

### 3. CONFIRM (AskUserQuestion — safe default first)
```
Options:
  1. Do it manually (default)   ← the existing instructions
  2. Apply via [tool]
  3. Skip
```
**One confirmation per action.** A batch of changes needs an explicit "Apply all"
upgrade — never infer blanket consent from a single yes.

### 4. ACT (only on explicit yes)
Call the named tool with the previewed values. Echo the result / confirmation id
back to the user. For writes, **read the value back** with the same read-only
tool PREVIEW used and confirm it matches what was applied — ASC writes can
partially apply (e.g. per-locale); success is the read-back matching, not the
API's 200. On a mismatch, report exactly which fields/locales differ. On ANY
error, **do not retry blindly** — fall through to step 5 and surface what
failed.

### 5. FALL BACK
Unavailable, declined, or failed → print the command's existing **manual
instructions unchanged**. This is the baseline and must keep working with nothing
installed.

---

## Rules for command authors

- **Least privilege:** a command's `allowed-tools` frontmatter lists only the
  exact `mcp__*` tools that command calls — never a whole MCP server.
- **Reversibility gradient:** prefer wiring read-only and reversible actions
  first (read sales → update promo text → update description → create version →
  add testers). Irreversible or reviewer-facing actions (e.g. Submit for Review)
  stay manual even if an API existed.
- **Don't duplicate this logic** — reference this file; put only the
  command-specific bits (which tool, which preview call, which fields) in the
  command's "Optional handoff:" stub.
