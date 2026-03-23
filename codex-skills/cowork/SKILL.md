---
name: cowork
description: Use when a task spans multiple mostly independent files or subsystems and the user wants delegation, subagents, or parallel implementation with a single Codex controller coordinating planning, ownership, integration, and verification.
---

# Cowork

## Overview

Run the Codex version of `/cowork`. Act as the conductor: understand the codebase, split the work into safe slices, delegate only when allowed, integrate the results, and verify the whole change.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$cowork`
- `$cowork --agents 2`
- `$cowork --agents 4`

If the user invokes `$cowork`, treat that as explicit permission for subagent-based delegation. Without that kind of explicit request, keep the same planning discipline but execute locally.

## Core Rules

- Build the task graph before writing code.
- Split work by ownership. Two workers must not edit the same file set.
- Put shared types, contracts, and utilities in an earlier wave.
- Do not delegate the immediate blocking task if the controller needs that answer right now.
- When workers are active, the controller focuses on integration, verification, and uncovered gaps instead of duplicating their work.

## Workflow

### Phase 1. Recon

Inspect the repository and map:

- relevant modules and entry points
- existing conventions and boundaries
- shared files that could become contention points
- verification commands that will prove the finished change

### Phase 2. Plan

Turn the request into explicit success criteria, then pick the lightest planning route that fits the work.

| Task shape | PM skill route | Result |
|-----------|----------------|--------|
| 3+ file new feature | `create-prd` -> `user-stories` | scope and story breakdown |
| Refactor | `user-stories` | task slices and acceptance criteria |
| Bug bundle or regression-heavy change | `test-scenarios` | failure paths and regression cases |
| High-risk or ambiguous work | `pre-mortem` | risk list before slicing |

Then decompose the work into waves:

- Wave 1: shared contracts, schema, utility, or cross-cutting setup
- Wave 2: independent feature slices that can run in parallel
- Wave 3: final integration, cleanup, and regression checks

For each slice, define these fields explicitly:

- Slice name
- Owned files or directories
- Dependencies on earlier slices
- Success criteria
- Verification command
- Forbidden edits outside the owned slice

If the task is too coupled for safe parallelism, say so and fall back to a single-thread implementation plan.

### Phase 3. Dispatch

When subagents are allowed, dispatch workers with a concrete ownership template:

```text
Role: {worker role}
Context: {short recon summary}
Owned files: {exact paths}
Goal: {what this slice must achieve}
Success criteria:
- {criterion 1}
- {criterion 2}
Verify with: {command}
Do not:
- edit files outside ownership
- revert others' changes
- add unapproved dependencies
```

Use a small number of workers. Prefer 2-4 well-scoped tasks over many shallow tasks.

### Phase 4. Integrate

Review returned diffs before merging ideas together:

- check for overlap and hidden coupling
- resolve imports, type contracts, and shared interface drift
- add any missing glue code locally

### Phase 5. Verify

Run the real verification commands for the full change:

- focused tests
- broader tests, lint, and build as needed
- repeat repair and re-verify up to 3 times

If the parallel plan is breaking down, stop forcing concurrency and finish the remaining work locally.

## Fallback Mode

If subagents are unavailable or not explicitly requested:

- keep the same wave structure
- execute the slices in order in the current session
- preserve ownership boundaries mentally so the change does not sprawl

## Output Shape

Use this structure when reporting:

1. Recon: what was mapped
2. Plan: selected route and wave structure
3. Dispatch: slices and ownership
4. Integration: conflicts or glue resolved
5. Verification: commands run and outcomes

## Red Flags

- Parallel workers touching the same file
- A worker changing shared contracts without being assigned that responsibility
- The conductor rewriting a worker's slice before reviewing it
- Skipping the final full verification because each slice passed alone
- Treating "large task" as permission to over-engineer the plan

## Quick Prompts

- `Use $cowork to add refunds to the payment flow.`
- `Use $cowork --agents 4 for this refactor.`
- `Use $cowork, but keep the database layer in Wave 1 and parallelize the UI and tests after that.`
