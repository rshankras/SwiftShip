#!/bin/bash
# SwiftShip usage hook — logs /apple:* skill invocations to a local ledger.
# Registered as a Claude Code PostToolUse hook on the Skill tool (opt-in;
# install.sh prints the registration snippet). Zero token cost — runs outside
# the model. Local-only; never transmits anything.
#
# Ledger: ~/.claude/swiftship-usage.jsonl (see templates/_conventions/USAGE-LOG.md)
input=$(cat)
skill=$(printf '%s' "$input" | jq -r '.tool_input.skill // empty' 2>/dev/null)
case "$skill" in
  apple:*)
    mkdir -p "$HOME/.claude" 2>/dev/null
    (
      jq -cn \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg cmd "${skill#apple:}" \
        --arg project "$(basename "$(printf '%s' "$input" | jq -r '.cwd // "unknown"')")" \
        '{ts:$ts, event:"invoke", cmd:$cmd, project:$project}' \
        >> "$HOME/.claude/swiftship-usage.jsonl"
    ) 2>/dev/null
    ;;
esac
exit 0  # never block the tool call, regardless of what happened above
