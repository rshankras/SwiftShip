#!/bin/bash
# SwiftShip usage hook — logs /apple:* command invocations to a local ledger.
# Registered as two Claude Code hooks (opt-in; install.sh prints the snippet):
#   - UserPromptSubmit: catches commands the user types ("/apple:build ...")
#   - PostToolUse on the Skill tool: catches commands Claude invokes itself
# User-typed slash commands never reach the Skill tool (they are expanded
# client-side), so both registrations are needed for full coverage. A given
# invocation only ever matches one shape, so nothing is double-logged.
# Zero token cost — runs outside the model. Local-only; never transmits anything.
#
# Ledger: ~/.claude/swiftship-usage.jsonl (see templates/_conventions/USAGE-LOG.md)
input=$(cat)

# PostToolUse(Skill) shape: .tool_input.skill = "apple:map"
cmd=$(printf '%s' "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null)

# UserPromptSubmit shape: .prompt = "/apple:map [args]"
if [ -z "$cmd" ]; then
  prompt=$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null)
  case "$prompt" in
    /apple:*)
      cmd=${prompt#/}           # "/apple:map args" -> "apple:map args"
      cmd=${cmd%%[[:space:]]*}  # first word only   -> "apple:map"
      ;;
  esac
fi

case "$cmd" in
  apple:*)
    mkdir -p "$HOME/.claude" 2>/dev/null
    (
      jq -cn \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg cmd "${cmd#apple:}" \
        --arg project "$(basename "$(printf '%s' "$input" | jq -r '.cwd // "unknown"')")" \
        '{ts:$ts, event:"invoke", cmd:$cmd, project:$project}' \
        >> "$HOME/.claude/swiftship-usage.jsonl"
    ) 2>/dev/null
    ;;
esac
exit 0  # never block the prompt or tool call, regardless of what happened above
