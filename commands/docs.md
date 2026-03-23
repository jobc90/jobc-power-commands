---
description: "Auto-detect document type (PRD/README/release notes/meeting notes, 10 types) → research → structure → draft → 3-angle review. PM command auto-routing, --dry-run supported."
---

# /docs — Systematic Documentation Pipeline

For any documentation task, auto-detect the type, then execute research → structure → draft → review.

## Arguments
- First argument: documentation task description (required)
- `--type <TYPE>`: force document type (auto by default)
- `--output <PATH>`: specify output path (default: project root or docs/)
- `--dry-run`: outline structure only, do not create files
- `--lang <ko|en>`: output language (default: ko)

## Core Rules
1. Source of truth first: extract facts only from code, git log, and existing documents
2. No speculation: mark unverifiable information as `[TODO: needs confirmation]`
3. Auto-route to the optimal command per document type
4. Final output must pass grammar-check

---

## Phase 1: DETECT — Auto-Detect Document Type

Analyze user input + project state to determine document type.

### Detection Table

| Type | Trigger Keywords/Conditions | Commands/Tools Used | Output |
|------|----------------------------|--------------------|---------|
| **PRD** | "spec", "PRD", "requirements", "feature definition", new feature | `/write-prd`, `/write-stories`, `/test-scenarios` | PRD-{name}.md |
| **Technical doc** | "architecture", "API", "design", "technical", code change analysis | Explore + code-architect | docs/{name}.md |
| **README** | "README", "getting started", "install", "onboarding" | Explore + code analysis | README.md |
| **Release notes** | "release", "deploy", "changelog" | `/sprint` (release-notes) + git log | RELEASE-{version}.md |
| **Meeting notes** | "meeting", "minutes", transcript input | `/meeting-notes` (summarize-meeting) | Meeting-{date}-{topic}.md |
| **Interview summary** | "interview", "user research", "customer interview" | `/interview` (summarize-interview) | Interview-{date}-{subject}.md |
| **Strategy doc** | "strategy", "vision", "roadmap", "GTM" | `/strategy` (product-strategy, gtm-strategy) | Strategy-{name}.md |
| **Operations doc** | "operations", "runbook", "deploy guide", "monitoring" | Explore + code analysis | docs/RUNBOOK.md |
| **Project documentation** | "document", "organize", "audit" | Explore + code-architect + full scan | docs/ directory batch |
| **Proofread/improve** | "proofread", "review", "improve", existing .md file specified | `/proofread` (grammar-check) | Original file modified |

Override with `--type`. On auto-detection, report the result in one line then proceed.

---

## Phase 2: RESEARCH — Gather Sources (Parallel)

Invoke research agents **simultaneously** based on document type.

### Research Strategy by Type

**Code-based documents** (technical doc, README, operations doc, project documentation):
| Agent | Collection Target |
|-------|------------------|
| **Explore** (quick) | Directory structure, entry points, framework |
| **code-architect** (feature-dev) | Patterns, conventions, dependencies, data flow |
| **Bash** (git log) | Recent changes, commit history, contributors |

**Planning documents** (PRD, strategy):
| Agent | Collection Target |
|-------|------------------|
| **Explore** (quick) | Read existing PRD/spec/CLAUDE.md |
| **Read** | User-provided materials (transcripts, notes, URLs) |

**Existing document proofreading**:
| Agent | Collection Target |
|-------|------------------|
| **Read** | Full target document |
| **Explore** (quick) | Related code (for accuracy verification) |

Store research results as **internal context** (no file saved).

---

## Phase 3: STRUCTURE — Design Document Skeleton

Determine document structure based on research results.

### Structuring Rules

1. **Use PM skill templates when available**: apply create-prd, release-notes, etc. templates directly
2. **Code-based documents use facts only**: exclude speculation, state only what is confirmed in code
3. **Section design principles**:
   - Conclusion/summary → details (conclusion-first principle)
   - Lead with background/purpose so the reader understands "why" first
   - Action items in tables (Owner, Deadline, Status)
4. **File naming conventions**:
   - PRD: `PRD-{product-or-feature}.md`
   - Release: `RELEASE-{version}.md`
   - Meeting notes: `Meeting-{YYYY-MM-DD}-{topic}.md`
   - Technical: `docs/{kebab-case-name}.md`
   - README: `README.md`

If `--dry-run`, output the skeleton here and stop.

---

## Phase 4: DRAFT — Write

### PM Skill-Based Documents

Invoke the corresponding PM command via **Skill tool**:

| Type | Command → Skill |
|------|----------------|
| PRD | `/write-prd` → create-prd skill |
| User stories | `/write-stories` → user-stories skill |
| Release notes | `/sprint` → release-notes skill |
| Meeting notes | `/meeting-notes` → summarize-meeting skill |
| Interview summary | `/interview` → summarize-interview skill |
| Strategy | `/strategy` → product-strategy skill |
| Test scenarios | `/test-scenarios` → test-scenarios skill |

### Code-Based Documents (technical doc, README, operations, project documentation)

Write directly following these template structures:

**README template:**
```markdown
# {Project Name}
> {One-line description}

## Overview
## Tech Stack
## Getting Started (install → run)
## Project Structure
## Key Scripts
## Environment Variables
## Contributing Guide
```

**Technical doc template:**
```markdown
# {Document Title}
> Created: {date} | Author: {author}

## Background (why this document is needed)
## Current State
## Architecture / Design
## Key Decisions (ADR format)
## Implementation Details
## Constraints / Caveats
## References
```

**Operations doc (RUNBOOK) template:**
```markdown
# {Service Name} Operations Guide

## Service Overview
## Infrastructure Layout
## Deployment Procedure
## Monitoring / Alerts
## Incident Response (by scenario)
## Rollback Procedure
## Contacts
```

**Project documentation** (full scan):
```markdown
docs/
├── README.md            — Project overview + getting started
├── architecture.md      — Architecture + data flow
├── api-reference.md     — API endpoints (extracted from code)
└── RUNBOOK.md           — Operations guide
```
Create each file sequentially. If a file already exists, update via diff.

---

## Phase 5: REVIEW — Quality Check (Parallel)

Review the drafted document from **3 angles simultaneously**:

| Review Angle | Method | Checks |
|-------------|--------|--------|
| **Grammar/readability** | Apply `grammar-check` skill pattern | Grammar errors, logical gaps, flow breaks, excessive passive voice |
| **Accuracy** | Cross-reference with source (code/git) | File path existence, API spec match, version number accuracy |
| **Completeness** | Compare against template | Missing required sections, remaining TODOs, empty sections |

### Auto-Fix Criteria
- **Grammar errors**: auto-fix
- **Factual errors** (path/version mismatch): auto-fix (correct answer verifiable from source)
- **Structural gaps**: add empty section + `[TODO: content needed]` marker
- **Judgment required**: report only (no auto-fix)

---

## Phase 6: DELIVER — Deliver Output

1. **Save file**: Write tool to `--output` path
2. **Existing document update**: Apply diff with Edit tool (no full overwrite)
3. **Output summary report**:
   ```
   [DOCS] Complete
   ├── Type: {detected type}
   ├── Created: {list of new files}
   ├── Updated: {list of modified files}
   ├── Review: grammar {N} fixes, accuracy {N} fixes, TODO {N} items
   └── Next steps: {recommended actions}
   ```

## Abort Conditions
- No source material (no code, no input) → abort immediately, advise on required materials
- Review fails 3 times → abort + save current draft
