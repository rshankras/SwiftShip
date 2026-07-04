#!/bin/bash

# SwiftShip Installer
# Symlinks SwiftShip commands, agents, templates, and the skills library into
# Claude Code config using home-relative paths, so SwiftShip works on any machine.
#
# Skills location is resolved in this order:
#   1. $SWIFTSHIP_SKILLS_DIR environment variable
#   2. First argument to this script
#   3. A sibling checkout: ../claude-code-apple-skills (next to this repo)
# Either the repo root or its skills/ subdirectory is accepted.
#
# Usage:
#   ./install.sh
#   ./install.sh /path/to/claude-code-apple-skills
#   SWIFTSHIP_SKILLS_DIR=/path/to/claude-code-apple-skills ./install.sh
#   ./install.sh --uninstall

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# --- Uninstall ---------------------------------------------------------------
# Removes only SwiftShip's symlinks. Your own agents, settings.json entries,
# the usage ledger, and per-project .planning/ files are never touched.
if [ "${1:-}" = "--uninstall" ]; then
    echo "Uninstalling SwiftShip symlinks..."
    for dest in \
        "$CLAUDE_DIR/commands/apple" \
        "$CLAUDE_DIR/swiftship-templates" \
        "$CLAUDE_DIR/swiftship-skills" \
        "$CLAUDE_DIR/hooks/swiftship-usage-log.sh"; do
        if [ -L "$dest" ]; then
            rm "$dest"
            echo "  removed $dest"
        fi
    done
    # Agents: per-file links (current installs) or a whole-dir symlink (legacy).
    if [ -L "$CLAUDE_DIR/agents" ]; then
        rm "$CLAUDE_DIR/agents"
        echo "  removed legacy $CLAUDE_DIR/agents symlink"
        if [ -d "$CLAUDE_DIR/agents.backup" ]; then
            echo "  note: your pre-SwiftShip agents are in $CLAUDE_DIR/agents.backup —"
            echo "        move them back to $CLAUDE_DIR/agents/ to restore them."
        fi
    elif [ -d "$CLAUDE_DIR/agents" ]; then
        for f in "$REPO_DIR"/agents/*.md; do
            name="$(basename "$f")"
            if [ -L "$CLAUDE_DIR/agents/$name" ]; then
                rm "$CLAUDE_DIR/agents/$name"
                echo "  removed $CLAUDE_DIR/agents/$name"
            fi
        done
    fi
    echo ""
    echo "SwiftShip uninstalled. Left in place (yours to keep or delete):"
    echo "  - ~/.claude/swiftship-usage.jsonl (usage ledger, if present)"
    echo "  - hook entries in ~/.claude/settings.json (if you registered them)"
    echo "  - .planning/ directories and vendored .claude/agents/ in your projects"
    echo "Restart Claude Code sessions to unload the commands and agents."
    exit 0
fi

echo "Installing SwiftShip..."
echo "Repository: $REPO_DIR"
echo "Target:     $CLAUDE_DIR"
echo ""

# Replace an existing symlink, or back up a real file/dir, then create a fresh symlink.
link() {
    local src="$1" dest="$2"
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        echo "  Backing up existing $dest -> $dest.backup"
        mv "$dest" "$dest.backup"
    fi
    ln -s "$src" "$dest"
    echo "  $dest -> $src"
}

# --- Resolve the claude-code-apple-skills location -------------------------
SKILLS_SRC="${SWIFTSHIP_SKILLS_DIR:-${1:-}}"
if [ -z "$SKILLS_SRC" ]; then
    SKILLS_SRC="$REPO_DIR/../claude-code-apple-skills"
fi
# Accept either the repo root or the skills/ dir directly.
if [ -d "$SKILLS_SRC/skills" ]; then
    SKILLS_SRC="$SKILLS_SRC/skills"
fi
# Normalize to an absolute path if it exists.
if [ -d "$SKILLS_SRC" ]; then
    SKILLS_SRC="$(cd "$SKILLS_SRC" && pwd)"
fi

# --- Legacy cleanup --------------------------------------------------------
# Old installs symlinked the entire commands/ dir; remove that first since
# paths resolve through the symlink.
if [ -L "$CLAUDE_DIR/commands" ]; then
    echo "Removing legacy commands symlink..."
    rm "$CLAUDE_DIR/commands"
fi

mkdir -p "$CLAUDE_DIR/commands"

# --- Symlinks --------------------------------------------------------------
echo "Creating symlinks..."
link "$REPO_DIR/commands" "$CLAUDE_DIR/commands/apple"

# Agents are linked PER-FILE so any agents of your own in ~/.claude/agents/
# keep working alongside SwiftShip's six. (Older installs symlinked the whole
# directory, which displaced existing agents — migrate that first.)
if [ -L "$CLAUDE_DIR/agents" ]; then
    echo "Migrating legacy whole-directory agents symlink to per-file links..."
    rm "$CLAUDE_DIR/agents"
fi
mkdir -p "$CLAUDE_DIR/agents"
if [ -d "$CLAUDE_DIR/agents.backup" ]; then
    echo "  note: found $CLAUDE_DIR/agents.backup (from an older install) —"
    echo "        your original agents are there; move them back into $CLAUDE_DIR/agents/ anytime."
fi
for f in "$REPO_DIR"/agents/*.md; do
    link "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

link "$REPO_DIR/templates"      "$CLAUDE_DIR/swiftship-templates"

# --- Usage-log hook (opt-in) ------------------------------------------------
# The hook script is symlinked but does nothing until you register it in
# ~/.claude/settings.json yourself — the installer never edits user settings.
mkdir -p "$CLAUDE_DIR/hooks"
link "$REPO_DIR/hooks/swiftship-usage-log.sh" "$CLAUDE_DIR/hooks/swiftship-usage-log.sh"

if [ -d "$SKILLS_SRC" ]; then
    link "$SKILLS_SRC" "$CLAUDE_DIR/swiftship-skills"
    SKILLS_OK=1
else
    echo ""
    echo "  ⚠️  Skills library not found at: $SKILLS_SRC"
    echo "     Commands that reference ~/.claude/swiftship-skills/ will not work until"
    echo "     you point the installer at a claude-code-apple-skills checkout, e.g.:"
    echo "       SWIFTSHIP_SKILLS_DIR=/path/to/claude-code-apple-skills ./install.sh"
    SKILLS_OK=0
fi

echo ""
echo "SwiftShip installed successfully!"
if [ "$SKILLS_OK" = "1" ]; then
    echo "Skills:     ~/.claude/swiftship-skills -> $SKILLS_SRC"
fi
echo ""
echo "Optional — local usage log (nothing leaves your machine):"
echo "  To record which /apple:* commands you run, add both entries to the \"hooks\""
echo "  section of ~/.claude/settings.json (the installer never edits it):"
echo '    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "~/.claude/hooks/swiftship-usage-log.sh"}]}]'
echo '    "PostToolUse": [{"matcher": "Skill", "hooks": [{"type": "command", "command": "~/.claude/hooks/swiftship-usage-log.sh"}]}]'
echo "  (UserPromptSubmit catches commands you type; PostToolUse catches ones Claude invokes.)"
echo "  Ledger: ~/.claude/swiftship-usage.jsonl — delete anytime."
echo ""
echo "Available commands:"
echo "  /apple:new-app [name]  - Define a new iOS/macOS app"
echo "  /apple:roadmap         - Create development phases"
echo "  /apple:plan [phase]    - Plan a specific phase"
echo "  /apple:build           - Execute current plan"
echo "  /apple:review          - Run comprehensive review"
echo "  /apple:testflight      - Prepare TestFlight beta"
echo "  /apple:submit          - Final submission checklist"
echo "  /apple:help            - Show all commands"
echo ""
echo "To get started:"
echo "  1. cd to your project directory"
echo "  2. Run: /apple:new-app MyAppName"
echo ""
