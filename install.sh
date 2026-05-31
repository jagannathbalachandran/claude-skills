#!/bin/bash
# Installs all Claude Code skills to ~/.claude/commands/
# Run this on any machine after cloning the repo.

set -e

COMMANDS_DIR="$HOME/.claude/commands"
SKILLS_DIR="$(cd "$(dirname "$0")/commands" && pwd)"

mkdir -p "$COMMANDS_DIR"

count=0
for skill in "$SKILLS_DIR"/*.md; do
  [ -f "$skill" ] || continue
  cp "$skill" "$COMMANDS_DIR/"
  echo "  installed: $(basename "$skill")"
  count=$((count + 1))
done

echo ""
echo "$count skill(s) installed to $COMMANDS_DIR"
echo "Restart Claude Code to pick up new skills."
