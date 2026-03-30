---
name: harness-team
description: Parallel multi-worker build harness for `/harness-team` or `$harness-team` requests. Use when Codex needs the same Scout -> Architect -> Workers(N) -> Integrator -> QA workflow as the Claude command.
---

# Harness Team

## Overview

Run the Codex version of `/harness-team`. Treat `/harness-team` and `$harness-team` as the same workflow intent inside Codex.

This skill mirrors the Claude harness-team structure:

`SETUP -> SCOUT -> ARCHITECT -> USER APPROVAL -> WAVE BUILD -> INTEGRATE -> QA -> SUMMARY`

## Guard Clause

Before starting the protocol, confirm the request is a build or implementation task large enough to benefit from parallel workers.

Use `/harness-team` when the work spans multiple independent slices.
If the task is small or tightly coupled, prefer `/harness`.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$harness-team`
- `$harness-team --agents 2`
- `$harness-team --agents 4`
- `/harness-team`

## Required Artifacts

Use `.harness_codex/team-` in the target project directory.

- `.harness_codex/team-prompt.md`
- `.harness_codex/team-context.md`
- `.harness_codex/team-plan.md`
- `.harness_codex/team-worker-0-progress.md`
- `.harness_codex/team-worker-{1..N}-progress.md`
- `.harness_codex/team-integration-report.md`
- `.harness_codex/team-round-1-feedback.md`
- `.harness_codex/team-round-2-feedback.md`

## Arguments

- first argument: task description
- `--agents N`: number of parallel workers in Wave 2, default `3`, max `5`

## Phase 1. Setup

Create the working directory:

```bash
mkdir -p .harness_codex
```

Write the user's request and worker count to `.harness_codex/team-prompt.md`.

## Phase 2. Scout

Load `references/scout-prompt.md`.

Spawn a fresh scout subagent:

- scale guidance: treat team builds as large-scale
- output: `.harness_codex/team-context.md`

## Phase 3. Architect

Load `references/architect-prompt.md`.

Spawn a fresh architect subagent:

- codebase context: `.harness_codex/team-context.md`
- worker count
- output: `.harness_codex/team-plan.md`

After it finishes, summarize:

- worker assignments
- wave structure
- file ownership map
- key risks

Then ask exactly:

`빌드 계획을 검토해주세요. 진행할까요, 조정할 부분이 있나요?`

Stop and wait for approval.

## Phase 4. Build Waves

Load:

- `references/worker-prompt.md`
- `references/integrator-prompt.md`
- `references/qa-prompt.md`

Run at most 2 rounds.

### 4a. Wave 1: Foundation

If the plan includes Wave 1 tasks, spawn a fresh worker for the foundation slice:

- worker role: `Worker 0`
- brief source: `.harness_codex/team-plan.md`
- context: `.harness_codex/team-context.md`
- output: `.harness_codex/team-worker-0-progress.md`
- round 2: include prior QA feedback

Verify Wave 1 outputs exist before starting Wave 2.

### 4b. Wave 2: Parallel Workers

Spawn `N` fresh worker subagents in parallel.

Each worker must receive:

- owned slice from `.harness_codex/team-plan.md`
- codebase context: `.harness_codex/team-context.md`
- instruction not to edit files outside ownership
- output path: `.harness_codex/team-worker-{i}-progress.md`
- round 2: only the relevant QA findings

Do not proceed until all workers finish.

If a worker returns:

- `DONE` -> proceed
- `DONE_WITH_CONCERNS` -> include concerns for Integrator
- `NEEDS_CONTEXT` -> provide more context and re-dispatch
- `BLOCKED` -> assess and escalate if needed

### 4c. Wave 3: Integration

Spawn a fresh integrator subagent:

- architect plan: `.harness_codex/team-plan.md`
- worker progress files
- codebase context: `.harness_codex/team-context.md`
- output: `.harness_codex/team-integration-report.md`
- round 2: previous QA feedback

After it finishes, read the integration report and confirm whether the build is ready for QA.

### 4d. QA

Spawn a fresh QA subagent:

- product plan: `.harness_codex/team-plan.md`
- integration report: `.harness_codex/team-integration-report.md`
- round number
- output: `.harness_codex/team-round-{R}-feedback.md`
- if UI exists, include the app URL from the integration report

### 4e. Evaluate

After QA finishes:

1. Read `.harness_codex/team-round-{R}-feedback.md`.
2. Extract the scores.
3. Report:
   - round number
   - scores
   - pass/fail
   - key issues
4. Decide:
   - all criteria `>= 7` -> pass
   - any criterion `< 7` and `R < 2` -> run another round
   - otherwise stop

For round 2, re-dispatch only the workers whose owned files are implicated by QA findings. Cross-owner bugs go to the Integrator.

## Phase 5. Summary

Use this reporting shape:

```markdown
## Harness-Team Build Complete

**Rounds**: {R}/2
**Workers**: {N}
**Status**: PASS / PARTIAL

### Final Scores
| Criterion | Score |
|-----------|-------|
| ...       | X/10  |

### Worker Summary
| Worker | Files | Status | Key Output |
|--------|-------|--------|-----------|

### Integration Summary
[conflicts resolved, duplicates consolidated, wave 3 outcomes]

### Remaining Issues
[items from the last QA report]
```

## Execution Rules

1. Each phase agent must be a separate `spawn_agent` call with fresh context.
2. Never pass state between agents in chat. Use `.harness_codex/team-` files only.
3. Wave 2 workers must run in parallel.
4. No two workers may own the same file.
5. Wave 1 must complete before Wave 2 starts.
6. Always wait for explicit user approval after the Architect plan.
7. Workers cannot self-certify. Integrator and QA are the real gates.
