---
description: "3-dial system (Variance/Motion/Density) + presets (landing/dashboard/workspace) for frontend design quality control. init creates/updates design system, auto-integrates with /super."
---

# /design — Frontend Design Quality Control

Control design tone with 3 dials (Variance, Motion, Density), using presets or custom combinations to generate frontend code.
Serves as a single entry point to the taste-skill ecosystem.

## Arguments

### Subcommands
- `init`: interactive design.md generator (auto-detects new project vs. redesign)

### Presets (by style name)
- `--soft`: agency-grade premium
- `--minimal`: editorial minimalism
- `--brutal`: Swiss typography + military terminal
- `--redesign`: analyze existing site → upgrade

### Presets (by use case) — aliases for style names
- `--landing`: = `--soft` (V7/M8/D3)
- `--dashboard`: = `--brutal` (V6/M2/D8)
- `--workspace`: = `--minimal` (V4/M3/D5)
- `--portfolio`: = `--soft` (V8/M7/D2)
- `--admin`: = taste-skill (V2/M3/D9)

### Custom Dials
- `--v N` / `--variance N`: layout experimentalism (1-10, default 8)
- `--m N` / `--motion N`: animation intensity (1-10, default 6)
- `--d N` / `--density N`: screen fill density (1-10, default 4)

### Options
- `--output-guard`: prevent code truncation/omission (combinable with any preset)

---

## /design init — Interactive Design System Generator/Updater

Auto-detect project state and proceed in one of 3 modes.

### Design System File Search

Search the project for the following patterns in order. Use the first file found as the design system file.

```
1. design.md, DESIGN.md
2. designsystem.md, DESIGNSYSTEM.md, design-system.md, DESIGN-SYSTEM.md
3. docs/design.md, docs/DESIGN.md, docs/design-system.md
4. *DESIGN*.md, *design_system*.md (Glob patterns — project-specific custom names)
```

Examples: `BENEEDS_DESIGN_SYSTEM.md`, `MyApp_Design.md`, `docs/design-tokens.md` are all detected.

### Execution Flow

```
Does a design system file already exist?
├── YES → Update mode
│   1. Read existing file (understand current preset, dials, colors, fonts, etc.)
│   2. Ask: "How would you like to change it?"
│      → "More vibrant" → recommend VARIANCE↑ MOTION↑
│      → "Cleaner" → recommend VARIANCE↓ MOTION↓ DENSITY↓
│      → "Switch to dashboard" → recommend brutal preset
│      → "Change preset" → select new preset
│      → Specify custom dial values directly
│   3. Diff-update existing file (not full overwrite)
│      → Update only changed items (preset, dials, colors, motion, etc.)
│      → Preserve existing custom component rules
│
├── NO + frontend code exists → Redesign mode
│   1. Scan: analyze framework, CSS approach, current fonts/colors/layout
│   2. Diagnose: 79-item audit → summarize key issues
│   3. Ask: "What direction for the redesign?"
│      → Select preset or provide reference URL
│   4. Generate design system file (current issues + target preset + dials)
│
└── NO + no frontend code → New project mode
    1. Ask: "What kind of project?"
       → SaaS landing / dashboard / workspace / portfolio / commerce / other
    2. Ask: "Any reference sites?" (optional)
    3. Auto-recommend preset matching the use case
    4. Generate design.md (preset + dials + color palette + fonts)
```

### Update Mode Details

Recommend direction based on existing design system file's dial values:

| User Intent | Recommendation (from V5/M4/D5 baseline) |
|-------------|----------------------------------------|
| "More vibrant" | V→8, M→7 (asymmetric layout + stronger motion) |
| "Calmer" | V→3, M→2 (tidy grid + minimal motion) |
| "More spacious" | D→2 (gallery mode, wide margins) |
| "More dense" | D→8 (cockpit mode, dividers instead of cards) |
| "Luxury feel" | V→8, M→7, D→2 |
| "Practical" | V→3, M→3, D→7 |

When changing presets, update associated color/font/motion rules together.

### Generated design.md Structure

```markdown
# Design System: {Project Name}

## Current State (redesign mode only)
- Font: {current font} (→ needs replacement)
- Colors: {current issues}
- Layout: {current issues}
- Motion: {current state}
- States: {Loading/Empty/Error existence}

## Goals
preset: {preset name}
variance: {N}
motion: {N}
density: {N}

## Color Palette
- Canvas: {hex}
- Surface: {hex}
- Text: {hex}
- Accent: {hex} (single only)
- Base: {Zinc or Slate}

## Typography
- Display: {font}, {scale}
- Body: {font}, {scale}
- Mono: {font}
- Banned: Inter, Roboto, Arial, Open Sans

## Component Rules
(Card, button, input, navigation styles matching the preset)

## Motion
(Transition, animation, interaction rules matching dial values)

## Responsive
- Mobile collapse: single column below 768px
- Touch targets: 44px+
- Typography scaling: clamp()
```

After `/design init` completes, guide the user to the next step:
```
{filename} created/updated.
Next step: /super Implement the service
(The design system file will be auto-detected and design rules will be applied)
```

In update mode, keep the existing filename (e.g., `BENEEDS_DESIGN_SYSTEM.md` → update the same file).

---

## 3-Dial System

### DESIGN_VARIANCE — Layout Experimentalism

| Range | Style | Characteristics |
|-------|-------|----------------|
| 1-3 | Orderly grid | 12-column, symmetric, uniform padding |
| 4-7 | Offset | Margin overlap, varied ratios, left-aligned headers |
| 8-10 | Asymmetric | Masonry, fractional grid, broken-grid, wide margins |

Mobile override: ranges 4-10 collapse to single column below 768px (`w-full`, `px-4`).

### MOTION_INTENSITY — Animation Intensity

| Range | Style | Characteristics |
|-------|-------|----------------|
| 1-3 | Static | hover/active states only. No auto-animation |
| 4-7 | Fluid CSS | `cubic-bezier(0.16,1,0.3,1)`, delay cascades, transform+opacity |
| 8-10 | Choreographed | Scroll triggers, Framer Motion, parallax, persistent micro-animations |

### VISUAL_DENSITY — Screen Fill Density

| Range | Style | Characteristics |
|-------|-------|----------------|
| 1-3 | Gallery | Wide margins, large section gaps, luxury |
| 4-7 | Standard app | Normal web/app level |
| 8-10 | Cockpit | Tight padding, dividers instead of cards, monospace numbers, dashboard |

---

## Preset Mapping

| Preset (Style) | Preset (Use Case) | V | M | D | Skill | Use Case |
|----------------|-------------------|---|---|---|-------|----------|
| (default) | — | 8 | 6 | 4 | taste-skill | General frontend |
| `--soft` | `--landing` | 7 | 8 | 3 | soft-skill | Landing, SaaS |
| `--soft` | `--portfolio` | 8 | 7 | 2 | soft-skill | Portfolio |
| `--minimal` | `--workspace` | 4 | 3 | 5 | minimalist-skill | Workspace |
| `--brutal` | `--dashboard` | 6 | 2 | 8 | brutalist-skill | Dashboard |
| — | `--admin` | 2 | 3 | 9 | taste-skill | Admin panel |
| `--redesign` | `--redesign` | (analyzed) | (analyzed) | (analyzed) | redesign-skill | Existing site upgrade |

---

## Execution

### 1. Determine Mode

1. `init` subcommand → run design.md generator
2. Preset flag (style name or use case name) → activate corresponding skill
3. Custom dials (`--v`, `--m`, `--d`) → taste-skill dial override
4. No flags → taste-skill defaults (V8/M6/D4)

### 2. Skill Routing

| Mode | Activated Skill |
|------|----------------|
| Default / custom dials / `--admin` | taste-skill (DESIGN_VARIANCE={V}, MOTION_INTENSITY={M}, VISUAL_DENSITY={D}) |
| `--soft` / `--landing` / `--portfolio` | soft-skill |
| `--minimal` / `--workspace` | minimalist-skill |
| `--brutal` / `--dashboard` | brutalist-skill |
| `--redesign` | redesign-skill (Scan → Diagnose → Fix sequence) |

When `--output-guard` is specified, **co-activate** output-skill — blocks code omission/placeholder patterns.

### 3. Base Design Rules (All Modes)

When taste-skill is installed, it provides detailed rules.
The following base rules apply regardless of taste-skill availability.

#### Typography

**Recommended fonts** (Inter, Roboto, Arial, Open Sans banned):
- Display/Headlines: `Geist`, `Outfit`, `Cabinet Grotesk`, `Satoshi`
- Body: existing project font or select from the list above
- Monospace: `Geist Mono`, `JetBrains Mono`
- Serif: creative/editorial only. Banned in dashboards/software UI

**Typographic scale:**
- Display: `text-4xl md:text-6xl tracking-tighter leading-none`
- Body: `text-base text-gray-600 leading-relaxed max-w-[65ch]`
- Pure `#000000` banned → use off-black (`#111111`, `zinc-950`)

#### Color

- Maximum **1 accent color**, saturation < 80%
- Base: Zinc or Slate neutral tones
- "AI purple/blue" banned — no purple button glow, no neon gradients
- No mixing warm/cool grays in a project — pick one and unify

#### Layout

- 3-column equal cards banned → use 2-column zigzag, asymmetric grid, horizontal scroll
- `h-screen` banned → `min-h-[100dvh]` (prevents iOS Safari viewport jump)
- Complex flexbox calc banned → use CSS Grid
- Center-aligned Hero banned when VARIANCE > 4
- Card containers banned when DENSITY > 7 → use `border-t`, `divide-y`, negative space for grouping

#### Motion Defaults

- Transition: `transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1)`
- Spring physics: `stiffness: 100, damping: 20`
- Tactile feedback: `:active` with `-translate-y-[1px]` or `scale-[0.98]`
- Animate only `transform` and `opacity`. Never animate `top`, `left`, `width`, `height`
- When MOTION > 5 and using Framer Motion: use `useMotionValue`/`useTransform` (no React useState)

#### Content

- Generic names banned: "John Doe", "Acme", "Nexus"
- Fake round numbers banned: `99.99%`, `50%` → use `47.2%`, `+1 (312) 847-1928`
- AI cliches banned: "Elevate", "Seamless", "Unleash"
- Broken Unsplash links banned → use `picsum.photos/seed/{id}/800/600` or SVG avatars

#### Technical

- Default shadcn/ui banned — must customize radius, color, shadow
- React/Next.js: Server Components by default. Global state only inside `"use client"` wrappers
- Tailwind: mind v3/v4 syntax differences. Check project version before writing
- Check package.json before importing dependencies — no uninstalled package imports
- Emojis fully banned — use `@phosphor-icons/react` or `@radix-ui/react-icons`

#### Required States

- Loading: skeleton loader matching layout size (circular spinners banned)
- Empty: composed empty state screen
- Error: inline error reporting
- Tactile: `:active` with `-translate-y-[1px]` or `scale-[0.98]`
- Single-column collapse below 768px, no horizontal scroll

### 4. Redesign Mode Execution Order

When `--redesign` is specified:
1. **Scan** — read codebase, identify framework/styling approach
2. **Diagnose** — 79-item checklist audit (typography, color, layout, interaction, content, components, icons, code quality)
3. **Fix** — prioritized fixes:
   1. Font replacement (highest impact, lowest risk)
   2. Color palette cleanup
   3. Add hover/active states
   4. Layout/spacing adjustments
   5. Replace generic components
   6. Add Loading/Empty/Error states
   7. Typography/spacing polish

Preserve functionality. Improve design only.

---

## Usage Examples

```bash
# Create design.md (once)
/design init

# Presets (by style name)
/design --soft SaaS landing page
/design --minimal Notion-style workspace
/design --brutal Real-time monitoring dashboard

# Presets (by use case) — more intuitive
/design --landing SaaS landing page
/design --dashboard Real-time monitoring
/design --workspace Team collaboration tool
/design --portfolio Designer portfolio
/design --admin Admin panel

# Custom dials
/design --v 2 --m 3 --d 9 Admin dashboard
/design --v 8 --m 7 --d 2 Luxury brand landing

# Redesign
/design --redesign Upgrade this project's design

# Combinations
/design --landing --output-guard Landing page (full code output)
```

## Dependencies

The [taste-skill](https://github.com/Leonxlnx/taste-skill) plugin must be installed for full functionality.
Without it, base design rules and the 3-dial system still apply, but per-preset detailed rules are reduced.
