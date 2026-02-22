---
name: gemini-ai-patterns
description: Gemini API, AI agents, streaming, chat, evaluation, scoring, system prompts, multi-agent, stakeholder conversations, mentor AI, LLM, generative AI. Use when creating or modifying AI-powered features, chat endpoints, or evaluation logic.
---

# Gemini AI Integration Patterns

## Client Functions

The Gemini client at `src/lib/gemini/client.ts` provides three functions:

### `streamGeminiResponse(systemPrompt, messages)` — Streaming text
- Use for: **chat conversations** (stakeholder chat, mentor interventions)
- Returns: `AsyncGenerator<string>` yielding text chunks
- Temperature: 0.8 (creative, conversational)
- Max tokens: 1024
- Model: `gemini-3.1-pro-preview`

### `generateGeminiResponse(systemPrompt, messages)` — Non-streaming text
- Use for: **single responses** where you need the full text at once
- Returns: `Promise<string>`
- Temperature: 0.8
- Max tokens: 1024

### `generateGeminiJSON<T>(systemPrompt, messages)` — Structured JSON
- Use for: **evaluation, scoring, structured data** extraction
- Returns: `Promise<T>` (parsed JSON)
- Temperature: 0.3 (deterministic, precise)
- Max tokens: 2048
- Sets `responseMimeType: "application/json"` automatically
- ALWAYS validate the parsed response shape at runtime

## When to Use Each

| Use Case | Function | Why |
|----------|----------|-----|
| Stakeholder chat | `streamGeminiResponse` | User needs real-time feedback |
| Mentor intervention | `streamGeminiResponse` | Real-time coaching |
| Exercise evaluation | `generateGeminiJSON` | Need structured scores |
| Scoring rubric | `generateGeminiJSON` | Need JSON response |
| Single reply | `generateGeminiResponse` | Need full text, no streaming |

## Message Format

All functions take the same message format:
```typescript
const messages: { role: "user" | "model"; content: string }[] = [
  { role: "user", content: "What are the key metrics?" },
  { role: "model", content: "The key metrics are..." },
];
```

**Important**: Gemini uses `"model"` not `"assistant"`. Convert from our `Message` type:
```typescript
const geminiMessages = conversationHistory.map((m) => ({
  role: (m.role === "user" ? "user" : "model") as "user" | "model",
  content: m.content,
}));
```

## System Prompt Location

All system prompts live in `src/lib/gemini/prompts/`:
- `stakeholder.ts` — `getStakeholderSystemPrompt()` for exercise chat
- `scoring.ts` — scoring/evaluation prompts
- Create new files for new prompt types

### System Prompt Pattern
```typescript
export function getMySystemPrompt(params: {
  // typed parameters
}): string {
  return `You are...

## Context
${params.context}

## Instructions
1. ...
2. ...

## Output Format
Return a JSON object with the following structure:
...`;
}
```

## Streaming SSE Pattern (for chat routes)

```typescript
import { streamGeminiResponse } from "@/lib/gemini/client";

const encoder = new TextEncoder();
const stream = new ReadableStream({
  async start(controller) {
    let chunkCount = 0;
    try {
      for await (const chunk of streamGeminiResponse(systemPrompt, messages)) {
        chunkCount++;
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

## JSON Evaluation Pattern

```typescript
import { generateGeminiJSON } from "@/lib/gemini/client";
import type { ScoreResult } from "@/types/database";

// ScoreResult is the existing type for evaluation results:
// { score, grade, strengths, improvements, radar_scores, qualitative_summary }

const result = await generateGeminiJSON<ScoreResult>(systemPrompt, [
  { role: "user", content: `Evaluate:\n\n${transcript}` },
]);

// ALWAYS validate the response
if (typeof result.score !== "number" || result.score < 0 || result.score > 100) {
  throw new Error("Invalid score from AI");
}
```

### Grade Values (from `ScoreResult` type)
```typescript
type Grade = "Excellent" | "Good" | "Needs Work" | "Retry Recommended";
```

## Client-Side Streaming Consumption

```typescript
const res = await fetch(`/api/exercises/${exerciseId}/chat`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ stakeholderId, message, conversationHistory }),
});

const reader = res.body?.getReader();
const decoder = new TextDecoder();

if (reader) {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    const text = decoder.decode(value);
    const lines = text.split("\n");

    for (const line of lines) {
      if (line.startsWith("data: ")) {
        const data = line.slice(6);
        if (data === "[DONE]") break;
        try {
          const parsed = JSON.parse(data);
          if (parsed.text) appendToMessage(parsed.text);
          if (parsed.error) handleError(parsed.error);
        } catch {
          // Skip invalid JSON chunks
        }
      }
    }
  }
}
```

## Exercise Context

### Stakeholder Configuration
Each exercise has multiple AI stakeholders defined in `StakeholderConfig`:
```typescript
interface StakeholderConfig {
  id: string;
  name: string;
  role: string;
  personality: string;
  communication_style: string;
  available_information: string;
  avatar_icon: string;
}
```

### Building Stakeholder Prompts
```typescript
import { getStakeholderSystemPrompt } from "@/lib/gemini/prompts/stakeholder";

const systemPrompt = getStakeholderSystemPrompt({
  name: stakeholder.name,
  role: stakeholder.role,
  companyName: ex.scenario.company_name,
  context: ex.scenario.context,
  personality: stakeholder.personality,
  availableInformation: stakeholder.available_information,
});
```

## Error Handling for AI Calls

Always wrap Gemini calls with:
```typescript
try {
  const result = await generateGeminiJSON<T>(systemPrompt, messages);
  log.info("AI call completed", { durationMs: Date.now() - startTime });
  // Validate result shape
} catch (error) {
  log.error("AI call failed", {
    error: error instanceof Error ? error.message : String(error),
    stack: error instanceof Error ? error.stack : undefined,
    durationMs: Date.now() - startTime,
    apiKeySet: !!process.env.GEMINI_API_KEY,
  });
  return NextResponse.json({ error: "AI evaluation failed" }, { status: 500 });
}
```
