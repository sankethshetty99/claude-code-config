---
name: supabase-api-patterns
description: API routes, Supabase queries, authentication, RLS, database operations, server-side data fetching, error handling, logging patterns, user progress, exercises, skills, tracks. Use when creating or modifying API routes or server-side data access.
---

# Supabase & API Route Patterns

## API Route Structure

Every API route follows this pattern:

```typescript
import { NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createLogger } from "@/lib/logger";
import type { /* types */ } from "@/types/database";

const log = createLogger("api.feature.action");

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const startTime = Date.now();
  const { id } = await params;
  log.info("Request received", { id });

  // 1. Auth check
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    log.warn("Unauthorized request", { id });
    return new Response("Unauthorized", { status: 401 });
  }

  // 2. Business logic with error handling
  // 3. Return response with timing
  log.info("Request completed", { id, durationMs: Date.now() - startTime });
}
```

## Key Imports

```typescript
// Server-side Supabase client (ALWAYS use this in API routes)
import { createClient } from "@/lib/supabase/server";

// Logger (namespaced by feature)
import { createLogger } from "@/lib/logger";

// Types from central type definitions
import type { Exercise, UserProgress, Skill, Track, Message } from "@/types/database";
```

## Authentication Pattern

Always authenticate FIRST in every API route:

```typescript
const supabase = await createClient();
const { data: { user } } = await supabase.auth.getUser();
if (!user) {
  log.warn("Unauthorized request", { featureId });
  return new Response("Unauthorized", { status: 401 });
}
```

## Supabase Query Patterns

### Single record (use `.single()`)
```typescript
const { data: exercise, error } = await supabase
  .from("exercises")
  .select("*")
  .eq("id", exerciseId)
  .single();

if (error) {
  log.error("Failed to fetch exercise", {
    exerciseId,
    error: error.message,
    code: error.code,
  });
}

if (!exercise) {
  return new Response("Exercise not found", { status: 404 });
}

// IMPORTANT: Cast JSONB fields through unknown
const ex = exercise as unknown as Exercise;
```

### Multiple records
```typescript
const { data: exercises, error } = await supabase
  .from("exercises")
  .select("*")
  .eq("skill_id", skillId)
  .order("sort_order");

if (error) {
  log.error("Failed to fetch exercises", {
    skillId,
    error: error.message,
    code: error.code,
  });
  return new Response("Internal error", { status: 500 });
}
```

### Filtering by multiple IDs
```typescript
const exerciseIds = exercises.map(e => e.id);
const { data: progress, error } = await supabase
  .from("user_progress")
  .select("*")
  .eq("user_id", user.id)  // Defense-in-depth alongside RLS
  .in("exercise_id", exerciseIds);
```

### Upsert pattern
```typescript
const { error } = await supabase
  .from("user_progress")
  .upsert({
    user_id: user.id,
    exercise_id: exerciseId,
    status: "completed",
    score,
    completed_at: new Date().toISOString(),
  }, {
    onConflict: "user_id,exercise_id",
  });
```

## RLS + Defense-in-Depth

- RLS policies on `user_progress` automatically scope queries to the authenticated user
- ALWAYS add explicit `.eq("user_id", user.id)` as defense-in-depth
- Reference tables (`skills`, `exercises`, `tracks`) are public read and don't need user filtering
- Comment the defense-in-depth pattern: `// RLS + explicit user filter`

## Error Response Patterns

Use `new Response()` for simple errors (matching existing codebase):
```typescript
return new Response("Unauthorized", { status: 401 });
return new Response("Exercise not found", { status: 404 });
return new Response("Internal error", { status: 500 });
```

For JSON error responses (when client expects JSON):
```typescript
import { NextResponse } from "next/server";
return NextResponse.json({ error: "Skill not found" }, { status: 404 });
```

## Logging Conventions

### Logger creation (namespaced by feature path)
```typescript
const log = createLogger("api.exercise.chat");
const log = createLogger("api.exercise.complete");
const log = createLogger("api.skills.progress");
```

### Structured logging with context
```typescript
// Info - request lifecycle
log.info("Request received", { exerciseId, userId: user.id });
log.info("Request completed", { exerciseId, durationMs: Date.now() - startTime });

// Warn - auth/access issues
log.warn("Unauthorized request", { exerciseId });

// Error - with full Supabase error details
log.error("Failed to fetch exercise", {
  exerciseId,
  error: error.message,
  code: error.code,
});

// Error - with stack trace
log.error("Unexpected error", {
  error: error instanceof Error ? error.message : String(error),
  stack: error instanceof Error ? error.stack : undefined,
  durationMs: Date.now() - startTime,
});
```

### Always log timing
```typescript
const startTime = Date.now();
// ... do work ...
log.info("Completed", { durationMs: Date.now() - startTime });
```

## Streaming Response Pattern (for Gemini)

```typescript
import { streamGeminiResponse } from "@/lib/gemini/client";

const encoder = new TextEncoder();
const stream = new ReadableStream({
  async start(controller) {
    try {
      for await (const chunk of streamGeminiResponse(systemPrompt, messages)) {
        controller.enqueue(
          encoder.encode(`data: ${JSON.stringify({ text: chunk })}\n\n`)
        );
      }
      controller.enqueue(encoder.encode("data: [DONE]\n\n"));
      controller.close();
    } catch (error) {
      controller.enqueue(
        encoder.encode(
          `data: ${JSON.stringify({ error: "Failed to generate response" })}\n\n`
        )
      );
      controller.close();
    }
  },
});

return new Response(stream, {
  headers: {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  },
});
```

## Database Schema Reference

### Key Tables
- `tracks` — PM specialization tracks (id, name, slug, description, icon, skill_count)
- `skills` — Skills within tracks (id, track_id, name, description, sort_order, module, sub_dimensions)
- `exercises` — Exercises within skills (id, skill_id, phase, exercise_number, scenario JSONB, stakeholders JSONB)
- `user_progress` — User completion data (user_id, exercise_id, status, score, conversation_log JSONB)
- `users` — User profiles (id, email, display_name, current_streak, total_time_minutes)
- `subscriptions` — Stripe subscription status

### JSONB Fields (require type casting)
- `exercises.scenario` → `Scenario`
- `exercises.stakeholders` → `StakeholderConfig[]`
- `exercises.evaluation_rubric` → `EvaluationRubric`
- `user_progress.conversation_log` → `ConversationLog`
- `user_progress.radar_scores` → `Record<string, number>`
- `skills.intro_content` → `IntroContent`

### Type Casting Pattern
```typescript
// Supabase returns JSONB as `unknown`, cast through `unknown`
const ex = exercise as unknown as Exercise;
const stakeholder = ex.stakeholders.find(s => s.id === stakeholderId);
```

## Next.js 15 Dynamic Route Params

Always use the async params pattern:
```typescript
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
```

Do NOT use the old synchronous pattern:
```typescript
// WRONG - Next.js 14 pattern
{ params }: { params: { id: string } }
```
