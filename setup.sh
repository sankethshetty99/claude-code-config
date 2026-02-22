#!/bin/bash
set -e

echo "============================================"
echo "  Claude Code Global Setup"
echo "============================================"
echo ""

# Check claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "ERROR: 'claude' CLI not found."
    echo "Install it first: https://docs.anthropic.com/en/docs/claude-code/overview"
    exit 1
fi

echo "Found claude CLI: $(which claude)"
echo ""

# ──────────────────────────────────────────────
# Install plugins at user scope (available in all projects)
# ──────────────────────────────────────────────

echo "Installing plugins (user scope — available across all projects)..."
echo ""

OFFICIAL_PLUGINS=(
    "superpowers@claude-plugins-official"
    "figma@claude-plugins-official"
    "claude-md-management@claude-plugins-official"
    "vercel@claude-plugins-official"
    "stripe@claude-plugins-official"
    "playground@claude-plugins-official"
    "posthog@claude-plugins-official"
    "supabase@claude-plugins-official"
    "claude-code-setup@claude-plugins-official"
)

KNOWLEDGE_PLUGINS=(
    "product-management@knowledge-work-plugins"
    "data@knowledge-work-plugins"
)

install_plugin() {
    local plugin="$1"
    echo "  Installing $plugin..."
    if claude plugin install "$plugin" --scope user 2>/dev/null; then
        echo "    Done."
    else
        echo "    Skipped (may already be installed or unavailable)."
    fi
}

echo "── Official Plugins ──"
for plugin in "${OFFICIAL_PLUGINS[@]}"; do
    install_plugin "$plugin"
done

echo ""
echo "── Knowledge Work Plugins ──"
for plugin in "${KNOWLEDGE_PLUGINS[@]}"; do
    install_plugin "$plugin"
done

echo ""
echo "============================================"
echo "  Setup Complete!"
echo "============================================"
echo ""
echo "Installed plugins are available in ALL your projects."
echo ""
echo "Next steps:"
echo "  1. cd into your project directory"
echo "  2. Run: $(dirname "$0")/init-project.sh"
echo "  3. Customize CLAUDE.md and .claude/skills/ for your project"
echo ""
