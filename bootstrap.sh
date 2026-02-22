#!/bin/bash
set -e

REPO_RAW="https://raw.githubusercontent.com/sankethshetty99/claude-code-config/main"

echo "============================================"
echo "  Claude Code Project Bootstrap"
echo "============================================"
echo ""
echo "Setting up Claude Code configuration in: $(pwd)"
echo ""

# ──────────────────────────────────────────────
# Check prerequisites
# ──────────────────────────────────────────────

if ! command -v claude &> /dev/null; then
    echo "ERROR: 'claude' CLI not found."
    echo "Install it first: https://docs.anthropic.com/en/docs/claude-code/overview"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "ERROR: 'curl' not found."
    exit 1
fi

echo "Found claude CLI: $(which claude)"
echo ""

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
# Download template files from GitHub
# ──────────────────────────────────────────────

echo "Downloading configuration files..."
echo ""

mkdir -p .claude/agents .claude/skills .claude/commands

# ──────────────────────────────────────────────
# Check for gcloud CLI (optional but recommended)
# ──────────────────────────────────────────────

if ! command -v gcloud &> /dev/null; then
    echo "NOTE: 'gcloud' CLI not found."
    echo "  Install it for GCP MCP server support: https://cloud.google.com/sdk/docs/install"
    echo ""
fi

# ──────────────────────────────────────────────
# Check for GEMINI_API_KEY (optional but recommended)
# ──────────────────────────────────────────────

if [ -z "$GEMINI_API_KEY" ]; then
    echo "NOTE: GEMINI_API_KEY not set."
    echo "  Get one at https://aistudio.google.com/apikey"
    echo "  Then: export GEMINI_API_KEY=your-key-here"
    echo ""
fi

download() {
    local src="$1"
    local dest="$2"
    if curl -sfL "$REPO_RAW/template/$src" -o "$dest"; then
        echo "  Created $dest"
    else
        echo "  FAILED to download $src"
        exit 1
    fi
}

# .claude/.gitignore
download ".claude/.gitignore" ".claude/.gitignore"

# Settings
download ".claude/settings.json" ".claude/settings.json"
download ".claude/settings.local.json" ".claude/settings.local.json"

# Agents
download ".claude/agents/code-reviewer.md" ".claude/agents/code-reviewer.md"

# Commands
download ".claude/commands/review.md" ".claude/commands/review.md"

# Skills
download ".claude/skills/design-system.md" ".claude/skills/design-system.md"
download ".claude/skills/supabase-api-patterns.md" ".claude/skills/supabase-api-patterns.md"
download ".claude/skills/gemini-ai-patterns.md" ".claude/skills/gemini-ai-patterns.md"
download ".claude/skills/gcloud-patterns.md" ".claude/skills/gcloud-patterns.md"

# MCP server config (only if it doesn't exist)
if [ -f ".mcp.json" ]; then
    echo ""
    echo "  .mcp.json already exists — skipping (not overwritten)."
else
    download ".mcp.json" ".mcp.json"
fi

# CLAUDE.md (only if it doesn't exist)
if [ -f "CLAUDE.md" ]; then
    echo ""
    echo "  CLAUDE.md already exists — skipping (not overwritten)."
else
    download "CLAUDE.md" "CLAUDE.md"
fi

# ──────────────────────────────────────────────
# Install plugins
# ──────────────────────────────────────────────

echo ""
echo "Installing Claude Code plugins..."
echo ""

PLUGIN_CACHE="$HOME/.claude/plugins/cache"

install_plugin() {
    local plugin="$1"
    local name="${plugin%@*}"
    local marketplace="${plugin#*@}"
    echo "  Installing $name..."
    local output
    if output=$(claude plugin install "$plugin" --scope project 2>&1); then
        echo "    Registered."
    else
        if echo "$output" | grep -qi "already installed"; then
            echo "    Already registered."
        else
            echo "    FAILED: $output"
            return 1
        fi
    fi

    # Copy plugin files into .claude/plugins/ so they're visible in the file tree
    local cache_dir="$PLUGIN_CACHE/$marketplace/$name"
    if [ -d "$cache_dir" ]; then
        # Find the versioned subdirectory (e.g., 4.3.1, 1.0.0)
        local version_dir
        version_dir=$(ls -d "$cache_dir"/*/ 2>/dev/null | head -1)
        if [ -n "$version_dir" ]; then
            mkdir -p ".claude/plugins/$name"
            cp -R "$version_dir"/* ".claude/plugins/$name/"
            echo "    Copied to .claude/plugins/$name/"
        fi
    fi
}

PLUGINS=(
    "superpowers@claude-plugins-official"
    "figma@claude-plugins-official"
    "claude-md-management@claude-plugins-official"
    "vercel@claude-plugins-official"
    "stripe@claude-plugins-official"
    "playground@claude-plugins-official"
    "posthog@claude-plugins-official"
    "supabase@claude-plugins-official"
    "claude-code-setup@claude-plugins-official"
    "product-management@knowledge-work-plugins"
    "data@knowledge-work-plugins"
)

for plugin in "${PLUGINS[@]}"; do
    install_plugin "$plugin"
done

# ──────────────────────────────────────────────
# Install agent skills (visible in .claude/skills/)
# ──────────────────────────────────────────────

echo ""
echo "Installing agent skills..."
echo ""

if ! command -v npx &> /dev/null; then
    echo "NOTE: 'npx' not found — skipping agent skills installation."
    echo "  Install Node.js to get agent skills: https://nodejs.org/"
    echo "  Then run manually:"
    echo "    npx -y skills add supabase/agent-skills --agent claude-code --skill '*' -y"
    echo "    npx -y skills add vercel-labs/agent-skills --agent claude-code --skill '*' -y"
    echo ""
else
    install_skill() {
        local source="$1"
        echo "  Installing skills from $source..."
        if npx -y skills add "$source" --agent claude-code --skill '*' -y 2>&1; then
            echo "    Done."
        else
            echo "    FAILED to install skills from $source"
            echo "    Run manually later: npx -y skills add $source --agent claude-code --skill '*' -y"
        fi
    }

    SKILL_SOURCES=(
        "supabase/agent-skills"
        "vercel-labs/agent-skills"
    )

    for source in "${SKILL_SOURCES[@]}"; do
        install_skill "$source"
    done
fi

echo ""
echo "============================================"
echo "  Bootstrap Complete!"
echo "============================================"
echo ""
echo "Your project now has:"
echo "  CLAUDE.md                                — Project instructions"
echo "  .mcp.json                                — MCP servers (gcloud + gemini)"
echo "  .claude/settings.json                    — Plugins + permissions (allow/ask)"
echo "  .claude/settings.local.json              — Personal overrides (gitignored)"
echo "  .claude/.gitignore                       — Keeps local settings out of git"
echo "  .claude/agents/code-reviewer.md          — Code review agent"
echo "  .claude/commands/review.md               — /review command"
echo "  .claude/plugins/                         — Plugin files (11 plugins)"
echo "  .claude/skills/                          — Template + agent skill packages"
echo "  .agents/skills/                          — Agent skills (supabase, vercel)"
echo ""
echo "Next steps — customize for this project:"
echo "  1. Edit CLAUDE.md with your project name, description, and architecture"
echo "  2. Edit/delete skills in .claude/skills/ for your stack"
echo "  3. Edit .claude/agents/code-reviewer.md for your conventions"
echo "  4. Edit .claude/settings.json to remove plugins you don't need"
echo "  5. Add personal permission overrides to .claude/settings.local.json"
echo "  6. Set GEMINI_API_KEY env var for the Gemini MCP server"
echo "  7. Run 'gcloud auth login' if you haven't already for the gcloud MCP server"
echo "  8. Run 'npx skills list' to see installed agent skills"
echo "  9. Run 'npx -y skills add <repo> --agent claude-code --skill \"*\" -y' to add more"
echo ""
