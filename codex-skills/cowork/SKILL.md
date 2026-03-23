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

- Relevant modules and entry points
- Existing conventions and boundaries
- Shared files that could become contention points
- Verification commands that will prove the finished change

### Phase 2. Plan

Turn the request into explicit success criteria, then decompose the work into waves:

- Wave 1: shared contracts, schema, or utility changes
- Wave 2: independent feature slices that can run in parallel
- Wave 3: final integration, cleanup, and regression checks

For each slice, define:

- Exact files or directories owned
- Success criteria
- Verification command
- Forbidden edits outside the owned slice

If the task is too coupled for safe parallelism, say so and fall back to a single-thread implementation plan.

### Phase 3. Dispatch

When subagents are allowed, dispatch workers with:

- Ownership boundaries
- The relevant context only
- A reminder that they are not alone in the codebase
- A warning not to revert other edits

Use a small number of workers. Prefer 2-4 well-scoped tasks over many shallow tasks.

### Phase 4. Integrate

Review returned diffs before merging ideas together:

- Check for overlap and hidden coupling
- Resolve imports, type contracts, and shared interface drift
- Add any missing glue code locally

### Phase 5. Verify

Run the real verification commands for the full change:

- Focused tests
- Broader tests, lint, and build as needed
- Repeat repair and re-verify up to 3 times

If the parallel plan is breaking down, stop forcing concurrency and finish the remaining work locally.

## Fallback Mode

If subagents are unavailable or not explicitly requested:

- Keep the same wave structure
- Execute the slices in order in the current session
- Preserve ownership boundaries mentally so the change does not sprawl

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
