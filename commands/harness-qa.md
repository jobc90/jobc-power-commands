# Harness-QA: Functional QA Pipeline (v1)

> 5-agent harness for comprehensive functional testing against live/deployed environments.
> Scout → Scenario Writer → Test Executor → Analyst → Reporter with Playwright-based verification.

## User Request

$ARGUMENTS

## Phase 0: Guard Clause

If the request is NOT a QA/testing request:
- Respond directly as a normal conversation
- Do NOT execute any harness phases

Proceed when the user wants to:
- Test a deployed/running application
- Run QA scenarios against a live environment
- Verify features work end-to-end
- Find bugs in an existing application
- Generate a QA report with actionable fix items

### Required Information

The user MUST provide (ask if missing):
1. **Target URL**: The application URL to test against
2. **Credentials**: Login accounts for each user type (or test account info)

Optional but helpful:
- Database connection info (for data verification)
- Specific areas to focus on
- Known issues to skip

## Architecture Overview

```
/harness-qa <target-url> [options]
  |
  +- Phase 1: Setup             -> .harness/qa- directory
  +- Phase 2: Scout              -> Scout agent -> .harness/qa-context.md
  +- Phase 3: Scenarios           -> Scenario Writer -> .harness/qa-scenarios.md
  |                               -> User reviews and approves
  +- Phase 4: Execute-Analyze     -> Up to 2 rounds:
  |   +- Test Executor            -> Playwright testing -> .harness/qa-results.md
  |   +- Analyst                  -> Bug classification -> .harness/qa-analysis.md
  |   +- Score check              -> pass rate acceptable? done : next round
  +- Phase 5: Report              -> Reporter -> .harness/qa-report.md
```

## Arguments

- First argument: target URL or task description (required)
- `--focus <area>`: focus testing on specific module/feature
- `--user-types <types>`: limit to specific user types (comma-separated)
- `--quick`: CRITICAL scenarios only (skip HIGH/MEDIUM)

---

## Phase 1: Setup

```bash
mkdir -p .harness
```

Write the user's request, target URL, credentials, and options to `.harness/qa-prompt.md`.

**CRITICAL**: Never write raw credentials (passwords, tokens) to files. Reference them as "provided in task description" or use environment variable names.

---

## Phase 2: Scout

Read the scout prompt template: `~/.claude/harness/scout-prompt.md`

Launch a **general-purpose Agent** with subagent_type `Explore`:
- **prompt**: The scout prompt template + context:
  - "Project directory: `{cwd}`"
  - "User's request: `{$ARGUMENTS}`"
  - "Scale: L — comprehensive scan for QA purposes. Focus on: all routes/pages, all user types/roles, all API endpoints, database schema, auth/permission system."
  - "Write output to `.harness/qa-context.md`"
  - "ADDITIONAL QA FOCUS: Map every page/route accessible to each user type. List all form inputs, all CRUD operations, all state transitions."
- **description**: "harness-qa scout"

After Scout completes, briefly confirm: **"Scout 완료. [X]개 라우트, [Y]개 유저 타입, [Z]개 핵심 기능 감지."**

---

## Phase 3: Scenarios

Read the scenario writer prompt template: `~/.claude/harness/scenario-writer-prompt.md`

Launch a **general-purpose Agent**:
- **prompt**: The scenario writer prompt template + context:
  - "Codebase context: `.harness/qa-context.md`"
  - "Target URL: `{URL}`"
  - "Test credentials: `{provided credentials — pass securely}`"
  - "Focus area: `{--focus value if provided, otherwise 'all features'}`"
  - "User types: `{--user-types value if provided, otherwise 'all types from context'}`"
  - "Quick mode: `{--quick if specified}`"
  - "Write output to `.harness/qa-scenarios.md`"
- **description**: "harness-qa scenario writer"

After completion:
- Read `.harness/qa-scenarios.md`
- Present summary to user:
  - Total scenarios count
  - Coverage matrix (feature × user type)
  - CRITICAL/HIGH/MEDIUM breakdown
  - Any CREDENTIALS NEEDED flags
- Ask: **"테스트 시나리오를 검토해주세요. 진행할까요, 추가/수정할 시나리오가 있나요?"**
- **WAIT for user approval.**

---

## Phase 4: Execute-Analyze Loop

Read the test executor and analyst prompt templates from `~/.claude/harness/`.

### Max rounds: 2

Round 2 is only triggered if the user requests re-testing after fixes are applied.

#### 4a. Execute

Launch a **general-purpose Agent**:
- **prompt**: The test executor prompt template + context:
  - "Test scenarios: `.harness/qa-scenarios.md`"
  - "Target URL: `{URL}`"
  - "Test credentials: `{provided credentials}`"
  - "Write output to `.harness/qa-results.md`"
  - If round 2: "This is a re-test after fixes. Focus on previously FAIL/PARTIAL scenarios. Reference `.harness/qa-analysis.md` for what was fixed."
  - "You MUST use Playwright MCP tools (mcp__playwright__*) to test the live app."
- **description**: "harness-qa test executor round {R}"

After completion:
- Read `.harness/qa-results.md`
- Briefly report: **"테스트 실행 완료. [X]개 시나리오 중 PASS: [N], FAIL: [N], PARTIAL: [N], BLOCKED: [N]."**

#### 4b. Analyze

Launch a **general-purpose Agent**:
- **prompt**: The analyst prompt template + context:
  - "Test results: `.harness/qa-results.md`"
  - "Test scenarios: `.harness/qa-scenarios.md`"
  - "Codebase context: `.harness/qa-context.md`"
  - "Write output to `.harness/qa-analysis.md`"
- **description**: "harness-qa analyst"

#### 4c. Evaluate

After Analyst completes:
1. Read `.harness/qa-analysis.md`
2. Report to user:
   - Overall pass rate
   - CRITICAL bug count
   - Pattern count
   - Missing feature count
3. **Decision**:
   - If user wants to fix and re-test → proceed to round 2 (user fixes bugs, then re-runs Phase 4)
   - Otherwise → proceed to Phase 5

---

## Phase 5: Report

Read the qa-reporter prompt template: `~/.claude/harness/qa-reporter-prompt.md`

Launch a **general-purpose Agent**:
- **prompt**: The qa-reporter prompt template + context:
  - "Analysis: `.harness/qa-analysis.md`"
  - "Test results: `.harness/qa-results.md`"
  - "Test scenarios: `.harness/qa-scenarios.md`"
  - "Codebase context: `.harness/qa-context.md`"
  - "Write output to `.harness/qa-report.md`"
- **description**: "harness-qa reporter"

After completion:
- Read `.harness/qa-report.md`
- Present user-facing summary:

```
## QA Complete

**Grade**: [A/B/C/D/F] ([score]%)
**Verdict**: [READY / READY_WITH_ISSUES / NOT_READY]
**Scenarios**: [X] tested | PASS: [N] | FAIL: [N] | BLOCKED: [N]
**Bugs**: CRITICAL: [N] | HIGH: [N] | MEDIUM: [N]

**Top Issues**:
1. [one-line]
2. [one-line]
3. [one-line]

Full report: `.harness/qa-report.md`
```

- Ask: **"QA 리포트를 확인해주세요. 수정 후 재테스트가 필요하면 `/harness-qa` 를 다시 실행해주세요."**

---

## Critical Rules

1. **Each agent = separate Agent tool call** with fresh context.
2. **ALL inter-agent communication through `.harness/qa-` files only.**
3. **Test Executor MUST use Playwright MCP** (`mcp__playwright__*`) for all UI testing. Code reading alone is NOT testing.
4. **NEVER store raw credentials in `.harness/qa-` files.** Reference them by variable name or "provided in task description."
5. **ALWAYS present scenarios to the user and wait for approval** before executing tests.
6. **The Test Executor does NOT fix bugs.** It tests and reports.
7. **The Analyst does NOT re-test.** It analyzes results from the Executor.
8. **Read prompt templates from `~/.claude/harness/`** before spawning each agent.
9. **Quick mode (`--quick`)**: Scenario Writer generates only CRITICAL scenarios. Test Executor skips HIGH/MEDIUM.

## Cost Awareness

| Mode | Duration | Agent Calls |
|------|---------|-------------|
| `--quick` | 10-20 min | 4 (scout + scenario + executor + analyst + reporter) |
| default | 20-45 min | 5 (scout + scenario + executor + analyst + reporter) |
| re-test (round 2) | +15-30 min | +2 (executor + analyst) |
