---
name: design-system
description: UI components, styling, dark theme, colors, Tailwind CSS, Framer Motion animations, shadcn/ui, cards, buttons, modals, layout, design tokens, spacing, hover states. Use when creating or modifying any visual component.
---

# PM Simulator Design System

## Color Tokens (Dark Theme Only)

| Token | Hex | CSS Variable | Usage |
|-------|-----|-------------|-------|
| Background | `#0F0F14` | `bg-background` | Page backgrounds |
| Card | `#1A1A24` | `bg-card` | Cards, panels, dropdowns |
| Accent | `#4F8CFF` | `text-primary`, `bg-primary` | Buttons, links, highlights |
| Border | `#2A2A3A` | `border-border` | All borders, dividers |
| Text | white | `text-foreground` | Primary text |
| Muted text | gray | `text-muted-foreground` | Secondary text, labels |

### Opacity Patterns
- `bg-primary/10` — Icon containers, subtle accent backgrounds
- `bg-primary/5` — Decorative glows, very subtle accent
- `hover:border-primary/30` — Card/item hover state borders
- `bg-background/80` — Overlay backdrop with blur
- `border-border/50` — Subtle dividers (half opacity)
- `text-muted-foreground/70` — De-emphasized labels

## Border Radius
- **Cards**: `rounded-[8px]`
- **Buttons**: `rounded-[6px]`
- **Modals**: `rounded-[12px]`
- **Icon containers (circular)**: `rounded-full`
- **Inputs/textareas**: `rounded-[6px]`

## Typography
- **Font family**: Inter — use `font-sans` class (maps to `var(--font-inter)`)
- **Headings**: `text-foreground font-bold` (sizes: `text-3xl` h1, `text-2xl` h2, `text-lg` h3)
- **Body**: `text-sm text-foreground leading-relaxed`
- **Labels/meta**: `text-xs text-muted-foreground`
- **Uppercase labels**: `text-xs font-medium uppercase tracking-wider text-muted-foreground/70`

## Spacing Conventions
- Card padding: `p-5` (standard cards), `p-8` (featured/modal cards)
- Section gaps: `space-y-2` (tight lists), `space-y-4` (standard), `space-y-6` (sections)
- Gap between items: `gap-2` (compact), `gap-3` (standard), `gap-4` (spacious)
- Margin between sections: `mb-8` (large), `mb-6` (medium), `mb-4` (small)

## Framer Motion Animations

### Required: EVERY element that appears/disappears must be animated.

### Standard Patterns

**Fade + slide up (most common)**:
```tsx
<motion.div
  initial={{ opacity: 0, y: 10 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3 }}
>
```

**Staggered list items** (use `delay: index * 0.02`):
```tsx
<motion.div
  initial={{ opacity: 0, y: 10 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3, delay: index * 0.02 }}
>
```

**Card hover** (subtle lift):
```tsx
<motion.div whileHover={{ y: -1 }}>
```

**Spring entrance** (for icons/badges):
```tsx
<motion.div
  initial={{ scale: 0 }}
  animate={{ scale: 1 }}
  transition={{ type: "spring", stiffness: 400, damping: 15 }}
>
```

**Overlay/modal** (with exit animations):
```tsx
<motion.div
  className="fixed inset-0 z-50 bg-background/80 backdrop-blur-sm"
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  exit={{ opacity: 0 }}
>
  <motion.div
    className="rounded-[12px] border border-border bg-card"
    initial={{ opacity: 0, scale: 0.9, y: 20 }}
    animate={{ opacity: 1, scale: 1, y: 0 }}
    exit={{ opacity: 0, scale: 0.9, y: 20 }}
    transition={{ type: "spring", stiffness: 300, damping: 24 }}
  >
```

## Component Patterns

### Standard Card
```tsx
<motion.div
  className="rounded-[8px] border border-border bg-card p-5 transition-colors hover:border-primary/30 cursor-pointer"
  initial={{ opacity: 0, y: 10 }}
  animate={{ opacity: 1, y: 0 }}
  whileHover={{ y: -1 }}
>
```

### Icon Container
```tsx
<div className="flex h-14 w-14 items-center justify-center rounded-[8px] bg-primary/10 text-primary">
  <Icon className="h-7 w-7" />
</div>
```

Small variant:
```tsx
<div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-primary">
```

### Button (shadcn/ui base)
```tsx
import { Button } from "@/components/ui/button";

// Primary action
<Button size="lg" className="w-full gap-2">
  Label <ArrowRight className="h-4 w-4" />
</Button>

// Icon button
<Button size="icon" className="h-11 w-11" disabled={isLoading}>
  <Send className="h-4 w-4" />
</Button>
```

### Badge (shadcn/ui base)
```tsx
import { Badge } from "@/components/ui/badge";

<Badge variant="default" className="text-xs cursor-pointer">Start</Badge>
```
Only use variants that exist in our Badge component: `default`, `secondary`, `outline`, `destructive`.

### Input/Textarea
```tsx
<textarea
  className="flex-1 resize-none rounded-[6px] border border-border bg-card px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground focus:border-primary focus:outline-none"
  rows={1}
/>
```

### Empty State (centered)
```tsx
<motion.div
  className="mx-auto max-w-md text-center"
  initial={{ opacity: 0, y: 10 }}
  animate={{ opacity: 1, y: 0 }}
>
  <p className="text-sm font-medium text-foreground">Title</p>
  <p className="text-xs text-muted-foreground">Subtitle</p>
  <p className="mt-3 text-sm text-muted-foreground">Description</p>
</motion.div>
```

### Section Divider
```tsx
<div className="flex items-center gap-3">
  <div className="h-px flex-1 bg-border/50" />
  <span className="text-xs font-medium uppercase tracking-wider text-muted-foreground/70 whitespace-nowrap">
    Section Name
  </span>
  <div className="h-px flex-1 bg-border/50" />
</div>
```

## Anti-Patterns (NEVER do these)
- Never use white (`#fff`) or light backgrounds
- Never use `bg-white`, `bg-gray-50`, or any Tailwind light color
- Never skip Framer Motion animation on appearing elements
- Never use `rounded-lg` or `rounded-xl` — always use explicit pixel values
- Never use Badge variants not defined in our component (`success`, `warning`, etc.)
- Never hardcode colors — always use CSS variables or Tailwind theme classes

## Icons
- Use `lucide-react` exclusively
- Standard icon sizes: `h-4 w-4` (inline), `h-7 w-7` (featured)
- Always pair with proper color: `text-primary`, `text-muted-foreground`, etc.
