---
name: super
description: Use when the user wants an idea, feature request, or large change carried from discovery through planning, implementation, review, verification, git handoff, and light documentation in one Codex-guided workflow.
---

# Super

## Overview

Run the Codex version of `/super`. This is the end-to-end orchestrator that routes a request through design, planning, implementation, review, verification, and release-ready handoff while respecting Codex's safety and git rules.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$super`
- `$super --skip-discover`
- `$super --commit`
- `$super --push`
- `$super --pr`

If the user gives a raw feature request that clearly means "take this from idea to done", this skill also applies even without the literal token.

## Pipeline

`DISCOVER -> PLAN -> BUILD -> CHECK -> SHIP -> DOCUMENT`

## Stage Rules

### 1. DISCOVER

Clarify the goal, scope, constraints, and success criteria.

- For new features or behavior changes, route through the existing design discipline first.
- Use a short design when the task is small.
- Use a fuller spec or PM skill when the task is large, ambiguous, or product-heavy.
- If `--skip-discover` is present and requirements already exist, start from PLAN.

### 2. PLAN

Produce a concrete execution plan before touching code:

- Files likely to change
- Verification strategy
- Risk areas
- Whether the work is sequential or parallelizable

Use the smallest planning artifact that still makes execution reliable.

### 3. BUILD

Choose the implementation mode that fits the task:

- Small or tightly coupled work: implement locally
- Larger work with clean ownership boundaries: use the `$cowork` style delegation flow when the user explicitly asked for it

Do not force subagents into work that is too coupled or too small to benefit.

### 4. CHECK

Run the `$check` workflow on the resulting diff:

- Review
- Safe fixes
- Verification
- Report any remaining recommendations

### 5. SHIP

Git actions are opt-in, not automatic:

- `--commit`: commit after verification
- `--push`: commit if needed, then push
- `--pr`: commit, push, and create a PR if possible

Without an explicit shipping flag or explicit user instruction, stop at a verified ready-to-ship state and report the next safe git step.

### 6. DOCUMENT

Update only the docs that are directly affected by the change:

- Plan or design notes created during the task
- Small developer-facing docs that would otherwise become stale
- Release-note style summary if the user asked for it

Do not invent documentation work that the request does not justify.

## Decision Rules

- Prefer existing installed process skills instead of re-inventing them.
- Prefer the simplest complete path over the flashiest path.
- Stop for critical security issues or repeated verification failure.
- If reality changes, re-plan instead of pushing through the stale plan.

## Recommended Skill Routing

Use these as the default building blocks inside the workflow:

- Discovery: `superpower`, `brainstorming`, relevant PM skill if needed
- Planning: `writing-plans`
- Implementation: local execution or `subagent-driven-development` style slices
- Review: `requesting-code-review` and `$check`
- Verification: `verification-before-completion`
- Completion: `finishing-a-development-branch` when the user wants git integration options

## Red Flags

- Starting implementation before the request is clear enough to verify
- Carrying out irreversible git actions without explicit instruction
- Letting "end-to-end" become an excuse for broad unrelated refactors
- Claiming the full pipeline is done without fresh evidence from the real verification commands

## Quick Prompts

- `Use $super to add 2FA to login.`
- `Use $super --skip-discover because the PRD already exists.`
- `Use $super --pr for this feature from plan through ready-to-review branch.`
