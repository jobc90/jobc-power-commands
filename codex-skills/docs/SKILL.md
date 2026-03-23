---
name: docs
description: Use when Codex needs to create, update, summarize, or improve documentation such as PRDs, READMEs, architecture docs, release notes, runbooks, meeting notes, interview summaries, or project-wide documentation from code and existing source material.
---

# Docs — Systematic Documentation Pipeline

Run a documentation-first workflow for Codex. Detect the document type, gather only the source material needed, draft with the right structure, and review for accuracy before delivering the final document.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$docs`
- `$docs --type <kind>`
- `$docs --output <path>`
- `$docs --dry-run`
- `$docs --lang <ko|en>`

If the user asks for documentation work without the token, this skill still applies.

## Pipeline

```
DETECT → RESEARCH → STRUCTURE → DRAFT → REVIEW → DELIVER
```

## Phase 1: DETECT

Classify the document type from user input and the available source material.

| Type | Triggers | Primary Skills |
|------|----------|---------------|
| PRD | "plan", "feature", "requirements" | create-prd, user-stories, test-scenarios |
| Technical | "architecture", "API", "design" | code search, focused file reads |
| README | "README", "getting started" | code search, focused file reads |
| Release Notes | "release", "changelog" | release-notes, git log |
| Meeting Notes | "meeting", "transcript" | summarize-meeting |
| Interview | "interview", "user research" | summarize-interview |
| Strategy | "strategy", "vision", "GTM" | product-strategy, gtm-strategy |
| Operations | "runbook", "deploy guide" | code search, focused file reads |
| Full Project | "document everything" | all of the above |
| Proofread | "review", "improve", existing .md | grammar-check |

## Phase 2: RESEARCH

Gather source material with the lightest tools that preserve accuracy.

- For pure writing, rewriting, summarization, or transcript work, avoid shell by default.
- Use shell only when needed to discover files, inspect git history, or verify facts from the repository.
- For code-based docs, collect exact paths, commands, and facts from the repo before writing prose.
- For user-provided text, summarize from the provided material first instead of searching the repo unnecessarily.

Parallel research is appropriate when the sources are independent, for example:

- repository structure
- git history
- existing docs
- transcript or note files

Rule: Extract only confirmed facts. Mark unknowns as `[TODO]`.

## Phase 3: STRUCTURE

Select template based on detected type. Apply PM skill templates when available.

Principles:
- Conclusion first, details second
- Background/purpose before implementation
- Action items in tables (Owner | Deadline | Status)
- Keep the output proportional to the request. Do not turn a small README fix into a full documentation suite.

## Phase 4: DRAFT

- PM skill available -> invoke the matching installed skill
- Code-based -> write directly using structured templates
- Full project -> generate files sequentially only if the user asked for project-wide documentation

Prefer these skill routes:

- PRD -> `create-prd`
- user stories -> `user-stories`
- test coverage or QA appendix -> `test-scenarios`
- release notes -> `release-notes`
- meeting summaries -> `summarize-meeting`
- interview summaries -> `summarize-interview`
- strategy docs -> `product-strategy` or `gtm-strategy`
- proofreading -> `grammar-check`

## Phase 5: REVIEW

Three parallel checks:
1. **Grammar/readability** — grammar-check pattern
2. **Accuracy** — verify paths, versions, API specs against source code
3. **Completeness** — check all template sections filled, no orphan TODOs

Auto-fix grammar and factual errors. Report judgment calls.

## Phase 6: DELIVER

- Respect `--dry-run`: show the structure and planned outputs, but do not write files.
- When updating an existing document, preserve useful content and patch only what the request justifies.
- When the user asked for language, produce the document in that language.

Save files and report a concise summary:
```
[DOCS] Complete
├── Type: {detected type}
├── Created: {new files}
├── Updated: {modified files}
├── Review: {fixes applied}
└── Next: {recommended actions}
```

## Red Flags

- Making up repository facts not confirmed from code, git, or provided text
- Using stale docs as the only source of truth when code disagrees
- Overusing shell on pure document tasks
- Rewriting an entire document when a targeted update is enough
- Leaving unresolved placeholders without explicitly marking them as `[TODO]`
