#!/usr/bin/env bash
set -euo pipefail

# QA Pipeline Installer
# Copies agents, instructions, skills, and MCP config into a target repo
# without overwriting existing files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"
TARGET_DIR="${1:-.}"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Verify target is a git repo
if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Error: $TARGET_DIR is not a git repository."
    echo "Usage: ./install.sh [path-to-your-repo]"
    exit 1
fi

echo ""
echo "  QA Pipeline Installer"
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

# --- Skills ---
echo ""
echo "  Skills:"
install_file "$TEMPLATE_DIR/.github/skills/qa/SKILL.md" \
             "$TARGET_DIR/.github/skills/qa/SKILL.md"
install_file "$TEMPLATE_DIR/.github/skills/qa-init/SKILL.md" \
             "$TARGET_DIR/.github/skills/qa-init/SKILL.md"
install_file "$TEMPLATE_DIR/.github/skills/qa-tune/SKILL.md" \
             "$TARGET_DIR/.github/skills/qa-tune/SKILL.md"
install_file "$TEMPLATE_DIR/.github/skills/qa-fixit/SKILL.md" \
             "$TARGET_DIR/.github/skills/qa-fixit/SKILL.md"

# --- MCP config ---
echo ""
echo "  MCP config:"
if [ -f "$TARGET_DIR/.vscode/mcp.json" ]; then
    echo "  WARN  .vscode/mcp.json already exists."
    echo "        Merge this into your existing servers section:"
    echo ""
    echo '        "context7": {'
    echo '          "command": "npx",'
    echo '          "args": ["-y", "@upstash/context7-mcp@latest"]'
    echo '        }'
    echo ""
    SKIPPED=$((SKIPPED + 1))
else
    install_file "$TEMPLATE_DIR/.vscode/mcp.json" "$TARGET_DIR/.vscode/mcp.json"
fi

# --- Summary ---
echo ""
echo "  Done. $INSTALLED installed, $SKIPPED skipped."
echo ""
echo "  Next steps:"
echo "    VS Code:      Select 'qa-orchestrator' from Copilot agent dropdown"
echo "    Claude Code:   /qa-init  then  /qa"
echo ""
echo "  Run qa-init first to customize rubrics for your project's stack."
echo ""
