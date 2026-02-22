# Project: claude-code-config

A portable Claude Code configuration repo. Users point Claude Code at this repo from any blank project and run `bootstrap.sh` to get a fully configured environment.

## Structure

- `bootstrap.sh` — Downloads template files into a target project and installs plugins
- `template/` — All files that get copied into target projects:
  - `CLAUDE.md` — Template project instructions (NOT this file)
  - `.claude/settings.json` — Plugins + allow/ask permissions
  - `.claude/settings.local.json` — Personal overrides template
  - `.claude/agents/code-reviewer.md` — Code review agent
  - `.claude/commands/review.md` — /review command
  - `.claude/skills/` — Stack-specific pattern skills
- `README.md` — Setup instructions and documentation

## Key Distinction

- **This file** (`/CLAUDE.md`) — Instructions for working on this repo itself
- **`template/CLAUDE.md`** — Template that gets deployed to other projects; do not confuse the two

## Working on This Repo

- The bootstrap script is hosted on GitHub and fetched via `curl` — changes to `bootstrap.sh` or anything in `template/` affect all future project setups
- The default template stack is **Next.js 15 + Tailwind + shadcn/ui + Supabase + Gemini AI + Vercel + Stripe + PostHog** — keep templates generic enough to be easily customized
- `template/.claude/settings.json` defines the plugin list and permission model — test changes carefully since this controls what Claude can do without asking
- Template files should use placeholder comments (e.g., `<!-- Update this section -->`) where project-specific customization is expected
- `bootstrap.sh` skips `CLAUDE.md` if one already exists in the target project — preserve this safety behavior

## Engineering Preferences

- Keep the bootstrap script simple and portable (bash, curl — no extra dependencies)
- Template files should be self-documenting with clear section headers
- Permissions follow allow/ask model: safe ops auto-allowed, destructive ops require confirmation
- When adding new template files, update both `bootstrap.sh` (download step + summary) and `README.md`
