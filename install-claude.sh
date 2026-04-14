#!/usr/bin/env bash
set -euo pipefail

# QA Pipeline Installer for Claude Code
# Copies agents, instructions, commands, and MCP config into a target repo
# without overwriting existing files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"
TARGET_DIR="${1:-.}"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Verify target is a git repo
if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Error: $TARGET_DIR is not a git repository."
    echo "Usage: ./install-claude.sh [path-to-your-repo]"
    exit 1
fi

echo ""
echo "  QA Pipeline Installer (Claude Code)"
echo "  Target: $TARGET_DIR"
echo ""

INSTALLED=0
SKIPPED=0

install_file() {
    local src="$1"
    local dst="$2"
    mkdir -p "$(dirname "$dst")"

    if [ -f "$dst" ]; then
        echo "  SKIP  ${dst#$TARGET_DIR/}  (already exists)"
        SKIPPED=$((SKIPPED + 1))
    else
        cp "$src" "$dst"
        echo "  ADD   ${dst#$TARGET_DIR/}"
        INSTALLED=$((INSTALLED + 1))
    fi
}

# --- Agents ---
echo "  Agents:"
for f in "$TEMPLATE_DIR/.github/agents/"*.agent.md; do
    [ -f "$f" ] || continue
    install_file "$f" "$TARGET_DIR/.github/agents/$(basename "$f")"
done

# --- Instructions (rubrics) ---
echo ""
echo "  Instructions:"
for f in "$TEMPLATE_DIR/.github/instructions/"*.instructions.md; do
    [ -f "$f" ] || continue
    install_file "$f" "$TARGET_DIR/.github/instructions/$(basename "$f")"
done

# --- Claude Code Commands ---
echo ""
echo "  Commands:"
for f in "$TEMPLATE_DIR/.claude/commands/"*.md; do
    [ -f "$f" ] || continue
    install_file "$f" "$TARGET_DIR/.claude/commands/$(basename "$f")"
done

# --- MCP config (.claude/settings.json) ---
echo ""
echo "  MCP config:"
if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    # Check if context7 is already configured
    if command -v jq &>/dev/null && jq -e '.mcpServers.context7' "$TARGET_DIR/.claude/settings.json" &>/dev/null; then
        echo "  SKIP  .claude/settings.json  (context7 already configured)"
        SKIPPED=$((SKIPPED + 1))
    elif command -v jq &>/dev/null; then
        # Merge context7 into existing settings
        jq '.mcpServers.context7 = {"command":"npx","args":["-y","@upstash/context7-mcp@latest"]}' \
            "$TARGET_DIR/.claude/settings.json" > "$TARGET_DIR/.claude/settings.json.tmp" \
            && mv "$TARGET_DIR/.claude/settings.json.tmp" "$TARGET_DIR/.claude/settings.json"
        echo "  MERGE .claude/settings.json  (added context7 server)"
        INSTALLED=$((INSTALLED + 1))
    else
        echo "  WARN  .claude/settings.json already exists (jq not found for auto-merge)."
        echo "        Add this to your mcpServers section:"
        echo ""
        echo '        "context7": {'
        echo '          "command": "npx",'
        echo '          "args": ["-y", "@upstash/context7-mcp@latest"]'
        echo '        }'
        echo ""
        SKIPPED=$((SKIPPED + 1))
    fi
else
    install_file "$TEMPLATE_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
fi

# --- Summary ---
echo ""
echo "  Done. $INSTALLED installed, $SKIPPED skipped."
echo ""
echo "  Next steps:"
echo "    /qa-init    Customize rubrics for your project's stack"
echo "    /qa         Review current changes"
echo ""
