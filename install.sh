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

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

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
link "$REPO_DIR/commands/apple" "$CLAUDE_DIR/commands/apple"
link "$REPO_DIR/agents"         "$CLAUDE_DIR/agents"
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
