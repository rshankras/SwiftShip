#!/bin/bash

# SwiftShip Installer
# Symlinks SwiftShip commands and agents into Claude Code config

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing SwiftShip..."
echo "Repository: $REPO_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Create .claude directory if it doesn't exist
mkdir -p "$CLAUDE_DIR"

# Handle commands directory
if [ -L "$CLAUDE_DIR/commands" ]; then
    echo "Removing existing commands symlink..."
    rm "$CLAUDE_DIR/commands"
elif [ -d "$CLAUDE_DIR/commands" ]; then
    echo "Warning: $CLAUDE_DIR/commands is a directory."
    echo "Backing up to $CLAUDE_DIR/commands.backup"
    mv "$CLAUDE_DIR/commands" "$CLAUDE_DIR/commands.backup"
fi

# Handle agents directory
if [ -L "$CLAUDE_DIR/agents" ]; then
    echo "Removing existing agents symlink..."
    rm "$CLAUDE_DIR/agents"
elif [ -d "$CLAUDE_DIR/agents" ]; then
    echo "Warning: $CLAUDE_DIR/agents is a directory."
    echo "Backing up to $CLAUDE_DIR/agents.backup"
    mv "$CLAUDE_DIR/agents" "$CLAUDE_DIR/agents.backup"
fi

# Create symlinks
echo "Creating symlinks..."
ln -sf "$REPO_DIR/commands" "$CLAUDE_DIR/commands"
ln -sf "$REPO_DIR/agents" "$CLAUDE_DIR/agents"

echo ""
echo "✅ SwiftShip installed successfully!"
echo ""
echo "Available commands:"
echo "  /apple:new-app [name]  - Define a new iOS/macOS app"
echo "  /apple:roadmap         - Create development phases"
echo "  /apple:plan [phase]    - Plan a specific phase"
echo "  /apple:build           - Execute current plan"
echo "  /apple:review          - Run comprehensive review"
echo "  /apple:testflight      - Prepare TestFlight beta"
echo "  /apple:submit          - Final submission checklist"
echo ""
echo "To get started:"
echo "  1. cd to your project directory"
echo "  2. Run: /apple:new-app MyAppName"
echo ""
