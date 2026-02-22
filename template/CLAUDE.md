# PM Simulator

A gamified, AI-powered PM training simulator where users complete scenario-based exercises chatting with AI stakeholders while a Mentor PM coaches them.

## Design System Rules
- **Dark mode only.** Background: #0F0F14, cards: #1A1A24, accent: #4F8CFF
- **Font:** Inter for all text
- **Border radius:** 8px cards, 6px buttons, 12px modals
- **Borders:** #2A2A3A (subtle dark)
- **All interactions must have Framer Motion animations.** No element should appear/disappear without a transition.
- Use shadcn/ui components as base, customize with dark theme
- Never use light mode colors or white backgrounds

## Architecture Rules
- Use Supabase RLS policies — never trust client-side auth alone
- Auth: Google OAuth only (no email/password)
- Stream Gemini responses to the client (don't wait for full response)
- Store all exercise content as JSONB in the database, not as files
- Keep system prompts for AI agents in `src/lib/gemini/prompts/`

## Engineering Preferences
- **DRY is important** — flag repetition aggressively
- **Well-tested code is non-negotiable** — too many tests > too few
- **"Engineered enough"** — not under-engineered (fragile, hacky) and not over-engineered (premature abstraction, unnecessary complexity)
- **Handle more edge cases, not fewer** — err on the side of coverage
- **Explicit over clever** — thoughtfulness > speed

## Code Review & Change Workflow
When reviewing code or proposing changes:
- For every issue: describe concretely with file and line references, present 2–3 options (including "do nothing" where reasonable), recommend one with rationale, and ask before proceeding
- **Large changes:** Work interactively one section at a time (Architecture → Code Quality → Tests → Performance), at most 4 top issues per section, pause after each section for feedback
- **Small changes:** One question per review section
- Number issues and letter options (e.g., "Issue 1, Option A") so choices are unambiguous
- Do not assume priorities on timeline or scale

## Important Context
- The spec document `PM_Simulator_Spec_v1.docx` in the project root contains the full product requirements
- Exercises have 3 phases: Phase 1 (observe replay), Phase 2 (guided chat), Phase 3 (independent chat)
- Each exercise has multiple AI stakeholders the user can chat with via tabs
- The Mentor PM AI watches all conversations and intervenes based on phase rules
- Progression is linear: users must complete skills in order within a track
- Scoring uses Gemini to evaluate the full conversation transcript against a rubric
