# Claude Code Config

Portable Claude Code configuration. Point Claude Code at this repo from any blank project folder and get a fully configured environment — no cloning required.

## Setup

Open Claude Code in a **blank project folder** and run:

```bash
curl -sL https://raw.githubusercontent.com/sankethshetty99/claude-code-config/main/bootstrap.sh | bash
```

Or tell Claude Code: *"Set up my project using https://github.com/sankethshetty99/claude-code-config — run the bootstrap script."*

That's it. One command does everything:
- Downloads all config files into your project
- Installs Claude Code plugins (project-scoped)
- Installs agent skills from Supabase and Vercel (visible in `.agents/skills/`)
- Sets up permissions with allow/ask safety model

## What Gets Installed

### Files (local to your project)

```
CLAUDE.md                              # Project instructions for Claude
.claude/
  .gitignore                           # Keeps local settings out of git
  settings.json                        # Plugins + permissions (allow/ask)
  settings.local.json                  # Personal overrides (gitignored)
  agents/
    code-reviewer.md                   # Automated code review agent
  commands/
    review.md                          # /review command — triggers code review
  skills/
    design-system.md                   # UI/design patterns
    supabase-api-patterns.md           # API route and DB patterns
    gemini-ai-patterns.md              # AI integration patterns
    supabase-postgres-best-practices/  # → symlink to .agents/skills/
    vercel-composition-patterns/       # → symlink to .agents/skills/
    vercel-react-best-practices/       # → symlink to .agents/skills/
    web-design-guidelines/             # → symlink to .agents/skills/
.agents/
  skills/                              # Agent skill packages (installed via npx skills)
    supabase-postgres-best-practices/
    vercel-composition-patterns/
    vercel-react-best-practices/
    web-design-guidelines/
```

### Permissions Model

`settings.json` uses an **allow/ask** structure:

| Level | What | Examples |
|-------|------|----------|
| **allow** | Safe, non-destructive ops — no confirmation needed | `Edit`, `Write`, `git add`, `npm run build`, `ls`, `grep`, `WebFetch` |
| **ask** | Potentially destructive — Claude asks before running | `git commit`, `git push`, `rm`, `npm install`, `docker`, `vercel` |

Personal overrides go in `settings.local.json` (gitignored).

### Agent Skills (project-scoped, visible in file tree)

Installed via `npx skills add` from GitHub repos. These create `.agents/skills/` directories with full knowledge packages and symlinks in `.claude/skills/`.

| Source | Skills Provided |
|--------|----------------|
| `supabase/agent-skills` | Postgres best practices, performance optimization |
| `vercel-labs/agent-skills` | React best practices, composition patterns, web design guidelines |

Add more: `npx -y skills add <github-org/repo> --agent claude-code --skill '*' -y`

### Plugins (project-scoped)

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

### Other Settings

| Setting | Value | What it does |
|---------|-------|--------------|
| `plansDirectory` | `./plans` | Stores Claude's plans in a visible folder you can review |
| `enableAllProjectMcpServers` | `true` | Auto-enables any MCP servers configured in the project |

## After Setup — Customize for Your Project

1. **CLAUDE.md** — Update project name, description, architecture rules, and context
2. **`.claude/skills/`** — Update patterns for your stack (or delete skills that don't apply)
3. **`.claude/agents/code-reviewer.md`** — Adjust review rules for your conventions
4. **`.claude/commands/`** — Add workflow commands (use `/project:review` to run the included one)
5. **`.claude/settings.json`** — Remove plugins you don't need, adjust permissions

## Template Stack

The default templates are configured for: **Next.js 15 + Tailwind + shadcn/ui + Supabase + Gemini AI + Vercel + Stripe + PostHog**. Customize everything after setup for your actual stack.

## Updating Templates

When you improve config in a project, push changes back to this repo:

```bash
# From your project directory
cp .claude/skills/design-system.md ~/claude-code-config/template/.claude/skills/
cp .claude/agents/code-reviewer.md ~/claude-code-config/template/.claude/agents/
cd ~/claude-code-config && git add -A && git commit -m "Update from project" && git push
```
