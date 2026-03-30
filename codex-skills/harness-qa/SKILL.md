---
name: harness-qa
description: Functional QA harness for `/harness-qa` or `$harness-qa` requests. Use when Codex needs the same Scout -> Scenario Writer -> Test Executor -> Analyst -> Reporter workflow as the Claude command.
---

# Harness QA

## Overview

Run the Codex version of `/harness-qa`. Treat `/harness-qa` and `$harness-qa` as the same workflow intent inside Codex.

This skill mirrors the Claude harness-qa structure:

`SETUP -> SCOUT -> SCENARIOS -> USER APPROVAL -> EXECUTE -> ANALYZE -> REPORT`

## Guard Clause

Before starting the protocol, confirm the request is a QA or testing request against a real running application.

Proceed when the user wants to:

- test a running or deployed application
- run QA scenarios against a live environment
- verify features end to end
- find bugs in an existing application
- produce a QA report with actionable fix items

## Required Information

The user must provide:

1. target URL
2. credentials for the relevant user types

Never store raw credentials in harness files. Refer to them as provided in the task description or by environment variable name.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$harness-qa`
- `$harness-qa --focus <area>`
- `$harness-qa --user-types <types>`
- `$harness-qa --quick`
- `/harness-qa`

## Required Artifacts

Use `.harness_codex/qa-` in the target project directory.

- `.harness_codex/qa-prompt.md`
- `.harness_codex/qa-context.md`
- `.harness_codex/qa-scenarios.md`
- `.harness_codex/qa-results.md`
- `.harness_codex/qa-analysis.md`
- `.harness_codex/qa-report.md`

## Phase 1. Setup

Create the working directory:

```bash
mkdir -p .harness_codex
```

Write the user's request, target URL, non-secret credential references, and options to `.harness_codex/qa-prompt.md`.

## Phase 2. Scout

Load `references/scout-prompt.md`.

Spawn a fresh scout subagent:

- focus on routes, user types, core features, auth model, and data flows relevant to QA
- write `.harness_codex/qa-context.md`

After it finishes, briefly report the discovered route count, user types, and key features.

## Phase 3. Scenarios

Load `references/scenario-writer-prompt.md`.

Spawn a fresh scenario-writer subagent:

- codebase context: `.harness_codex/qa-context.md`
- target URL
- credential references
- focus area and user types
- quick mode if specified
- output: `.harness_codex/qa-scenarios.md`

After it finishes, summarize:

- scenario count
- coverage matrix
- CRITICAL/HIGH/MEDIUM breakdown
- any credential gaps

Then ask exactly:

`테스트 시나리오를 검토해주세요. 진행할까요, 추가/수정할 시나리오가 있나요?`

Stop and wait for approval.

## Phase 4. Execute-Analyze Loop

Load:

- `references/test-executor-prompt.md`
- `references/analyst-prompt.md`
- `references/qa-reporter-prompt.md`

Run one round by default. A second round is only for re-test after fixes.

### 4a. Execute

Spawn a fresh test-executor subagent:

- test scenarios: `.harness_codex/qa-scenarios.md`
- target URL
- credential references
- output: `.harness_codex/qa-results.md`
- round 2: focus on previously failing scenarios
- require Playwright MCP browser tools for UI testing

### 4b. Analyze

Spawn a fresh analyst subagent:

- test results: `.harness_codex/qa-results.md`
- test scenarios: `.harness_codex/qa-scenarios.md`
- codebase context: `.harness_codex/qa-context.md`
- output: `.harness_codex/qa-analysis.md`

### 4c. Evaluate

After the Analyst finishes:

1. Read `.harness_codex/qa-analysis.md`.
2. Report:
   - overall pass rate
   - critical bug count
   - bug patterns
   - missing feature count
3. Decide:
   - if the user wants to fix and re-test, run round 2
   - otherwise proceed to Report

## Phase 5. Report

Load `references/qa-reporter-prompt.md`.

Spawn a fresh reporter subagent:

- analysis: `.harness_codex/qa-analysis.md`
- test results: `.harness_codex/qa-results.md`
- scenarios: `.harness_codex/qa-scenarios.md`
- codebase context: `.harness_codex/qa-context.md`
- output: `.harness_codex/qa-report.md`

After it finishes, present the user-facing summary and point to the full report.

## Execution Rules

1. Each phase agent must be a separate `spawn_agent` call with fresh context.
2. Never pass state between agents in chat. Use `.harness_codex/qa-` files only.
3. Test Executor must use Playwright MCP tools for UI testing.
4. Never store raw credentials in `.harness_codex/qa-` files.
5. Always wait for explicit user approval after the scenario phase.
6. The Test Executor does not fix bugs.
7. The Analyst does not re-test.
