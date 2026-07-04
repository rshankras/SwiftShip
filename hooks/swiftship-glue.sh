#!/bin/bash
# SwiftShip plugin glue — keeps the two runtime file contracts valid for
# PLUGIN installs by maintaining symlinks in ~/.claude:
#   ~/.claude/swiftship-templates -> <this plugin>/templates
#   ~/.claude/swiftship-skills    -> <apple-skills plugin>/skills
# Registered as a SessionStart hook in hooks/hooks.json; $1 is the plugin
# root (passed via ${CLAUDE_PLUGIN_ROOT} substitution — it is NOT an env var).
#
# GUARD: a symlink is only (re)created when the target is missing, dangling,
# or already points inside ~/.claude/plugins/ (i.e. we own it). A symlink to
# a real git checkout (created by install.sh) is NEVER touched — the
# clone+symlink install always wins over plugin glue.
# This script must never block a session: every path ends in exit 0.

PLUGIN_ROOT="$1"
CLAUDE_DIR="$HOME/.claude"

# Returns 0 (yes, safe to write) per the guard rule above.
safe_to_link() {
    local dest="$1"
    if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then return 0; fi          # missing
    if [ -L "$dest" ] && [ ! -e "$dest" ]; then return 0; fi            # dangling
    if [ -L "$dest" ]; then
        case "$(readlink "$dest")" in
            "$CLAUDE_DIR/plugins/"*) return 0 ;;                        # ours (cache)
        esac
    fi
    return 1                                                            # real file/dir or checkout symlink
}

# --- templates: this plugin ships them -------------------------------------
if [ -n "$PLUGIN_ROOT" ] && [ -d "$PLUGIN_ROOT/templates" ]; then
    if safe_to_link "$CLAUDE_DIR/swiftship-templates"; then
        ln -sfn "$PLUGIN_ROOT/templates" "$CLAUDE_DIR/swiftship-templates" 2>/dev/null
    fi
fi

# --- skills: resolve the installed apple-skills plugin ----------------------
SKILLS_ROOT=""
IPJ="$CLAUDE_DIR/plugins/installed_plugins.json"
if [ -f "$IPJ" ] && command -v jq >/dev/null 2>&1; then
    ip=$(jq -r '.plugins["apple-skills@indie-apple-stack"][0].installPath // empty' "$IPJ" 2>/dev/null)
    [ -n "$ip" ] && [ -d "$ip/skills" ] && SKILLS_ROOT="$ip/skills"
fi
if [ -z "$SKILLS_ROOT" ]; then
    # Fallback: newest cache slot for an apple-skills plugin in any marketplace.
    # shellcheck disable=SC2012
    SKILLS_ROOT=$(ls -dt "$CLAUDE_DIR"/plugins/cache/*/apple-skills/*/skills 2>/dev/null | head -1)
fi
if [ -n "$SKILLS_ROOT" ] && [ -d "$SKILLS_ROOT" ]; then
    if safe_to_link "$CLAUDE_DIR/swiftship-skills"; then
        ln -sfn "$SKILLS_ROOT" "$CLAUDE_DIR/swiftship-skills" 2>/dev/null
    fi
fi

exit 0
