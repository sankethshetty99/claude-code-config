# Claude Code Config

Portable Claude Code configuration. Clone this repo on any machine, run the setup, and get the full Claude Code experience on any project.

## Quick Start

### 1. New Machine Setup (one-time)

```bash
git clone https://github.com/sankethshetty/claude-code-config.git ~/claude-code-config
cd ~/claude-code-config
./setup.sh
```

This installs all plugins globally (available across every project):

| Plugin | Source | Purpose |
|--------|--------|---------|
| superpowers | claude-plugins-official | TDD, debugging, brainstorming, planning workflows |
| figma | claude-plugins-official | Figma design-to-code |
| claude-md-management | claude-plugins-official | CLAUDE.md auditing and improvement |
| vercel | claude-plugins-official | Deployment |
| stripe | claude-plugins-official | Payment integration |
| playground | claude-plugins-official | Interactive HTML playgrounds |
| posthog | claude-plugins-official | Analytics |
| supabase | claude-plugins-official | Database |
| claude-code-setup | claude-plugins-official | Setup recommendations |
| product-management | knowledge-work-plugins | PM skills (specs, roadmaps, research) |
| data | knowledge-work-plugins | Data analysis, SQL, dashboards |

### 2. New Project Setup (per project)

```bash
cd ~/my-new-project
~/claude-code-config/init-project.sh
```

This copies into your project:

```
.claude/
  settings.json            # Enables all plugins for the project
  settings.local.json      # Permission allowlist (gitignored)
  agents/
    code-reviewer.md       # Automated code review agent
  skills/
    design-system.md       # UI/design patterns
    supabase-api-patterns.md   # API route and DB patterns
    gemini-ai-patterns.md      # AI integration patterns
CLAUDE.md                  # Project instructions for Claude
```

### 3. Customize for Your Project

After running `init-project.sh`, edit these files for your specific project:

- **CLAUDE.md** - Change project name, description, architecture rules, and context
- **`.claude/skills/`** - Update patterns for your stack (or delete skills that don't apply)
- **`.claude/agents/code-reviewer.md`** - Adjust review rules
- **`.claude/settings.json`** - Remove plugins you don't need

## What's Included

### Skills (`.claude/skills/`)
- **design-system.md** - Dark theme tokens, Framer Motion animations, component patterns, anti-patterns
- **supabase-api-patterns.md** - API route structure, auth, RLS, queries, streaming, logging
- **gemini-ai-patterns.md** - Streaming/JSON/text AI calls, system prompts, error handling

### Agents (`.claude/agents/`)
- **code-reviewer.md** - Reviews code against project standards (design system, architecture, TypeScript, security)

### CLAUDE.md
Engineering preferences (DRY, explicit > clever, handle edge cases), code review workflow, design system rules, and architecture rules.

## Updating

When you improve your config in a project, copy the changes back:

```bash
# From your project directory
cp .claude/skills/design-system.md ~/claude-code-config/template/.claude/skills/
cp .claude/agents/code-reviewer.md ~/claude-code-config/template/.claude/agents/
cd ~/claude-code-config && git add -A && git commit -m "Update from project" && git push
```
