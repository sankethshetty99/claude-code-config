#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/template"

echo "============================================"
echo "  Claude Code Project Init"
echo "============================================"
echo ""
echo "Target directory: $(pwd)"
echo ""

# Check template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "ERROR: Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

# ──────────────────────────────────────────────
# Safety check: warn if .claude/ already exists
# ──────────────────────────────────────────────

if [ -d ".claude" ]; then
    echo "WARNING: .claude/ directory already exists in this project."
    read -p "Overwrite? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# ──────────────────────────────────────────────
# Copy .claude/ directory (always)
# ──────────────────────────────────────────────

echo "Copying .claude/ configuration..."

mkdir -p .claude/agents .claude/skills

cp "$TEMPLATE_DIR/.claude/settings.json" .claude/settings.json
echo "  Created .claude/settings.json (plugin enablement)"

cp "$TEMPLATE_DIR/.claude/settings.local.json" .claude/settings.local.json
echo "  Created .claude/settings.local.json (permissions)"

cp "$TEMPLATE_DIR/.claude/agents/code-reviewer.md" .claude/agents/code-reviewer.md
echo "  Created .claude/agents/code-reviewer.md"

for skill in "$TEMPLATE_DIR"/.claude/skills/*.md; do
    filename=$(basename "$skill")
    cp "$skill" ".claude/skills/$filename"
    echo "  Created .claude/skills/$filename"
done

# ──────────────────────────────────────────────
# Copy CLAUDE.md (only if it doesn't exist)
# ──────────────────────────────────────────────

if [ -f "CLAUDE.md" ]; then
    echo ""
    echo "CLAUDE.md already exists — skipping (not overwritten)."
    echo "  Your template is at: $TEMPLATE_DIR/CLAUDE.md"
else
    cp "$TEMPLATE_DIR/CLAUDE.md" CLAUDE.md
    echo "  Created CLAUDE.md"
fi

# ──────────────────────────────────────────────
# Add settings.local.json to .gitignore
# ──────────────────────────────────────────────

if [ -f ".gitignore" ]; then
    if ! grep -q "settings.local.json" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Claude Code local settings (personal permissions)" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
        echo "  Added .claude/settings.local.json to .gitignore"
    fi
else
    echo "# Claude Code local settings (personal permissions)" > .gitignore
    echo ".claude/settings.local.json" >> .gitignore
    echo "  Created .gitignore with .claude/settings.local.json"
fi

echo ""
echo "============================================"
echo "  Project Init Complete!"
echo "============================================"
echo ""
echo "Next steps — customize for this project:"
echo ""
echo "  1. CLAUDE.md"
echo "     - Update project name and description"
echo "     - Adjust design system rules for your stack"
echo "     - Update architecture rules"
echo "     - Add project-specific context"
echo ""
echo "  2. .claude/skills/"
echo "     - design-system.md — update colors, tokens, component patterns"
echo "     - supabase-api-patterns.md — update table names, schemas"
echo "     - gemini-ai-patterns.md — update AI model, prompt patterns"
echo "     - Delete skills that don't apply to this project's stack"
echo ""
echo "  3. .claude/agents/code-reviewer.md"
echo "     - Update review rules for this project's conventions"
echo ""
echo "  4. .claude/settings.json"
echo "     - Remove plugins you don't need for this project"
echo ""
