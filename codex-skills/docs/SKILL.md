---
name: docs
description: Use when Codex needs to create, update, summarize, or improve documentation such as PRDs, READMEs, architecture docs, release notes, runbooks, meeting notes, interview summaries, or project-wide documentation from code and existing source material.
---

# Docs

## Overview

Run the Codex version of `/docs`. Detect the document type, gather only the needed source material, draft with the right structure, and review from grammar, accuracy, and completeness before delivering the final document.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$docs`
- `$docs --type <kind>`
- `$docs --output <path>`
- `$docs --dry-run`
- `$docs --lang <ko|en>`

If the user asks for documentation work without the token, this skill still applies.

## Pipeline

`DETECT -> RESEARCH -> STRUCTURE -> DRAFT -> REVIEW -> DELIVER`

## Phase 1. DETECT

Classify the document type from user input and available source material.

| Type | Triggers | Skill route | Output |
|------|----------|-------------|--------|
| PRD | plan, feature, requirements | `create-prd`, `user-stories`, `test-scenarios` | `PRD-{name}.md` |
| Technical doc | architecture, API, design | focused repo reads | `docs/{name}.md` |
| README | README, install, getting started | focused repo reads | `README.md` |
| Release notes | release, changelog, shipped | `release-notes` + git history | `RELEASE-{version}.md` |
| Meeting summary | meeting, transcript | `summarize-meeting` | `Meeting-{date}-{topic}.md` |
| Interview summary | interview, user research | `summarize-interview` | `Interview-{date}-{subject}.md` |
| Strategy doc | strategy, GTM, vision | `product-strategy`, `gtm-strategy` | `Strategy-{name}.md` |
| Runbook | runbook, deploy guide, operations | focused repo reads | `docs/RUNBOOK.md` |
| Project-wide docs | document everything | mixed route | `docs/` set |
| Proofread | improve, polish, review existing doc | `grammar-check` | patch existing file |

## Phase 2. RESEARCH

Gather source material with the lightest tools that preserve accuracy.

- For pure writing, rewriting, summarization, or transcript work, avoid shell by default.
- Use shell only when needed to discover files, inspect git history, or verify facts from the repo.
- For code-based docs, collect exact paths, commands, and behavior from the source before writing prose.
- For user-provided text, summarize from the provided material first.

Parallel research is appropriate when the sources are independent, for example:

- repository structure
- git history
- existing docs
- transcript or note files

Rule:

- extract only confirmed facts
- mark unknowns as `[TODO: 확인 필요]`

## Phase 3. STRUCTURE

Select the template or skill output shape that fits the detected type.

Principles:

- conclusion first, details second
- background or purpose before implementation detail
- action items in tables
- keep the output proportional to the request

### Built-in templates

#### README

```markdown
# {project-name}
> {one-line summary}

## Overview
## Tech Stack
## Getting Started
## Project Structure
## Scripts
## Environment Variables
## Contributing
```

#### Technical document

```markdown
# {document-title}
> Date: {date}

## Background
## Current State
## Architecture
## Key Decisions
## Implementation Details
## Constraints and Caveats
## References
```

#### RUNBOOK

```markdown
# {service-name} Runbook

## Service Overview
## Infrastructure
## Deployment Procedure
## Monitoring and Alerts
## Incident Response
## Rollback
## Contacts
```

#### Project-wide docs set

```text
docs/
├── README.md
├── architecture.md
├── api-reference.md
└── RUNBOOK.md
```

If `--dry-run` is present, stop here and report the planned structure and file outputs.

## Phase 4. DRAFT

Prefer these skill routes when they apply:

- PRD -> `create-prd`
- user stories -> `user-stories`
- test appendix or QA framing -> `test-scenarios`
- release notes -> `release-notes`
- meeting summaries -> `summarize-meeting`
- interview summaries -> `summarize-interview`
- strategy docs -> `product-strategy` or `gtm-strategy`
- proofreading -> `grammar-check`

For code-based docs, write directly from confirmed repo facts and the templates above.

For project-wide documentation, generate files sequentially only if the user actually asked for full documentation coverage.

## Phase 5. REVIEW

Review from 3 angles before delivery.

| Angle | Goal | Checklist |
|------|------|-----------|
| Grammar and readability | clear writing | grammar, flow, ambiguity, repetition, awkward phrasing |
| Accuracy | factual correctness | paths exist, commands match repo, versions are real, APIs and behavior align with source |
| Completeness | document usefulness | required sections present, no orphan TODOs, no empty headings, next steps are explicit when needed |

### Review checklist

1. Grammar issues fixed
2. Inconsistent terminology removed
3. File paths verified
4. Commands verified
5. Versions or environment facts verified
6. Source-backed claims distinguished from assumptions
7. Missing sections added
8. Empty sections removed or marked with `[TODO: 확인 필요]`
9. Language matches requested output language

Auto-fix grammar and factual errors when the source is clear. Report judgment calls instead of inventing facts.

## Phase 6. DELIVER

- Respect `--dry-run`: show structure only, do not write files.
- When updating an existing doc, patch only what the request justifies.
- When the user asked for language, produce the document in that language.

Use this final reporting shape:

1. Type: detected document type
2. Sources: what was used as the source of truth
3. Created: new files
4. Updated: changed files
5. Review: grammar, accuracy, completeness fixes
6. Next: recommended follow-up if any TODOs remain

## Red Flags

- Making up facts not confirmed from code, git, or provided text
- Using stale docs as the only source of truth when code disagrees
- Overusing shell on pure document tasks
- Rewriting an entire document when a targeted update is enough
- Leaving unresolved placeholders without explicitly marking them as `[TODO: 확인 필요]`
