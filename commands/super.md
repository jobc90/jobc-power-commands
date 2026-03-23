---
description: "One-line idea → DISCOVER → PLAN → BUILD (/cowork) → CHECK (/check) → SHIP → DOCUMENT. --design for taste-skill integration, auto-detects design.md. --pr for PR creation."
---

# /super — Fully Automated Pipeline: Plan → Build → Review → Deploy

Combines `/cowork` (parallel implementation) + `/check` (review + deploy) + `/design` (design quality) into a full pipeline.
Halts only on CRITICAL security issues. Otherwise runs to completion.

## Arguments
- First argument: task description (required)
- `--pr`: create PR after push
- `--skip-discover`: start from Plan if PRD/spec already exists
- `--design <preset>`: activate frontend design rules (taste-skill integration)
  - `--design`: taste-skill defaults (V8/M6/D4)
  - `--design soft` / `--design landing`: agency-grade premium
  - `--design minimal` / `--design workspace`: editorial minimalism
  - `--design brutal` / `--design dashboard`: Swiss typography + terminal
  - `--design admin`: admin panel (V2/M3/D9)
  - `--design v3m8d2`: custom dials (V/M/D digits concatenated)

## Pipeline

```
DISCOVER → PLAN → BUILD → CHECK → SHIP → DOCUMENT
```

### Design System File Auto-Detection

Even without the `--design` flag, design mode activates automatically if a design system file exists in the project.

**Search patterns (in order):**
1. `design.md`, `DESIGN.md`
2. `designsystem.md`, `DESIGNSYSTEM.md`, `design-system.md`, `DESIGN-SYSTEM.md`
3. `docs/design.md`, `docs/DESIGN.md`, `docs/design-system.md`
4. `*DESIGN*.md`, `*design_system*.md` (Glob patterns — project-specific custom names)

Examples: `BENEEDS_DESIGN_SYSTEM.md`, `MyApp_Design.md`, etc. are all detected.

**Detection priority:**
1. `--design <preset>` specified → use that preset (takes precedence over file)
2. No `--design` flag + design system file exists → read `preset:` and dial values from file
3. No `--design` flag + no file → design mode disabled

This means once you create a design system file with `/design init`, subsequent `/super` calls automatically apply design rules.

---

### [1] DISCOVER — Structure Requirements

Analyze user input and auto-determine task scope.

**Criteria → PM command auto-routing:**

| Condition | Command | Output |
|-----------|---------|--------|
| New feature, 3+ files expected | `/write-prd` | PRD 8 sections (problem → goals → segments → solution → release) |
| Existing feature improvement, 1-2 files | `/write-stories` | INVEST-compliant user stories |
| High-risk task | `/pre-mortem` in parallel | Tiger / Paper Tiger / Elephant classification |
| Strategic decision needed | `/strategy` | Product Strategy Canvas 9 sections |
| Competitive analysis needed | `/competitive-analysis` | Competitor strengths/weaknesses + differentiation opportunities |

Save output to `prompt_plan.md`. **Proceed to next step without user confirmation.**

---

### [2] PLAN — Implementation Plan + Task Breakdown

**Scout:**
1. Explore agent → understand project architecture, directories, dependencies
2. `code-architect` (feature-dev) → analyze existing code patterns, conventions, key files
3. **Search for design system files** (design.md, DESIGN.md, designsystem.md, *DESIGN*.md, etc.) → if found, auto-activate design mode, read preset/dial values

**Breakdown:**
4. Split PRD/stories into implementation units:
   - `/prioritize-features` → prioritize by impact/effort/risk
   - `/test-scenarios` → QA scenarios per feature (happy/edge/error)
5. Arrange into Wave structure:
   - **Wave 1** (sequential): shared types, interfaces, utilities
   - **Wave 2** (parallel): data layer / UI components / tests
   - **Wave 3** (sequential): import cleanup, dead code removal
6. Specify **file paths + success criteria** per agent per Wave
7. If design mode is active: **include design rules in the task brief for frontend-assigned agents**

**Proceed to next step without user confirmation.**

---

### [3] BUILD — Parallel Implementation Using /cowork Pattern

**Execute the conductor pattern from `/cowork` as-is.** (See cowork.md for details)

Key points:
- Conductor writes no code. Pass **file paths + success criteria + prohibitions** to agents
- Wave 1 sequential → Wave 2 agents **invoked simultaneously in one message** → Wave 3 finalize
- On conflict: conductor merges with Edit
- On failure: SendMessage to the responsible agent for retry (max 3 attempts)

#### Additional BUILD Rules When Design Mode Is Active

When design mode is active (`--design` specified or design.md auto-detected), append the following to every frontend-assigned agent's task brief:

**1. Design skill activation:**
- `--design soft` → apply soft-skill rules
- `--design minimal` → apply minimalist-skill rules
- `--design brutal` → apply brutalist-skill rules
- `--design` or `--design v{N}m{N}d{N}` → taste-skill (pass dial values)

**2. Design context to include in agent brief:**
```
Design rules: {preset name} mode active.
Reference file: {detected design system file path}
Dials: VARIANCE={V}, MOTION={M}, DENSITY={D}
Mandatory compliance:
- Follow color, typography, and component rules defined in design.md
- No violations of /design command's common prohibited patterns (AI Tells)
- Inter font banned → use Geist, Outfit, Cabinet Grotesk, Satoshi
- Single accent color, saturation < 80%, base Zinc/Slate
- Single-column collapse below 768px
- Loading/Empty/Error/Tactile states required
```

**3. Backend-only agents do not need design rules** — apply only to agents handling frontend files (.tsx, .jsx, .css, .html).

---

### [4] CHECK — Review + Verify Using /check Pattern

**Execute the 5-agent parallel review from `/check` as-is.** (See check.md for details)

Key points:
- 5 agents review simultaneously (quality / simplification / silent-failure / type / security)
- Auto-fix CRITICAL/HIGH → build/lint/test verification
- Abort after 3 failures + detailed report

#### Additional CHECK Rules When Design Mode Is Active

Add a **6th angle: design quality** to the 5-angle code review:

| Check Item | Verification |
|------------|-------------|
| AI Tells | Inter font, pure #000000, neon glow, 3-column equal cards, generic names |
| Design system compliance | Color palette, typographic scale, component rules match the design system file |
| Dial consistency | Layout/animation/density match VARIANCE/MOTION/DENSITY values |
| Responsive | Single-column collapse below 768px, no horizontal scroll |
| Interactive states | Loading/Empty/Error/Tactile — all 4 present |
| Accessibility | Focus rings, semantic HTML, touch targets 44px+ |

CRITICAL/HIGH design issues are also included in auto-fix targets.

---

### [5] SHIP — Commit + Push

```
git add <changed files> → git commit -m "<type>: <desc>" → git push origin <branch>
```
With `--pr`: `gh pr create --title "<title>" --body "## Summary\n<change summary>"`.

---

### [6] DOCUMENT — Auto-Update Documentation

| Task | Command | Output |
|------|---------|--------|
| Release notes | `/sprint` (release-notes) | Commit-based categorized change summary |
| CLAUDE.md update | `/revise-claude-md` | Reflect session learnings |
| Doc sync | `/sync-docs` | Update prompt_plan.md, spec.md |

---

## Abort Conditions
- CRITICAL security issue → abort immediately
- Build fails 3 times → abort + detailed report

## Usage Examples
```bash
# Basic (no design)
/super Add 2FA to login
/super --pr Refactor payment module
/super --skip-discover PRD already exists, start from Plan

# Explicit design preset
/super --design soft Read the spec and design.md, implement the full service
/super --design dashboard --pr Implement admin dashboard and create PR

# Auto-detect design.md (most convenient)
# 1. Run /design init to create design.md (once)
# 2. Then just use /super — it auto-detects design.md
/super Implement the full service
/super Refactor the design
```
