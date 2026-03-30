# Harness: Autonomous Builder (v3)

> Anthropic "Harness Design for Long-Running Apps" 5-agent architecture.
> Scout → Planner → Builder → Refiner → QA with file-based handoffs.

## User Request

$ARGUMENTS

## Phase 0: Triage

Classify the request into one of three scales. This determines the entire protocol path.

### Non-Build Requests (EXIT)

If the request is a question, audit, or configuration change (not a build/fix/implement request):
- Respond directly as a normal conversation
- Do NOT execute any harness phases

### Scale Classification

Analyze `$ARGUMENTS` and classify:

| Scale | Criteria | Examples |
|-------|----------|---------|
| **S** (Small) | Bug fix, typo, 1-2 file changes, config tweak | "Fix the login button 404", "Update the API timeout to 30s" |
| **M** (Medium) | Feature addition, 3-5 file changes, module-level work | "Add password reset flow", "Refactor auth to use JWT" |
| **L** (Large) | New application, major refactor, 6+ files, multi-module | "Build a dashboard app", "Rewrite the payment system" |

**Decision rule**: When in doubt between two scales, pick the smaller one. The QA loop will catch if more work is needed.

Announce the classification to the user:

```
Scale: [S/M/L] — [one-line rationale]
```

Then proceed to Phase 1 with the classified scale.

---

## Architecture Overview

```
/harness <prompt>
  |
  +- Phase 0: Triage         -> Scale S/M/L classification
  +- Phase 1: Setup           -> .harness/ directory + git init
  +- Phase 2: Scout           -> Scout agent -> .harness/build-context.md
  +- Phase 3: Planning        -> Planner agent -> .harness/build-spec.md
  |                           -> User reviews and approves
  +- Phase 4: Build-Refine-QA -> Up to S=1, M=2, L=3 rounds:
  |   +- Builder agent        -> implements/fixes -> .harness/build-progress.md
  |   +- Refiner agent        -> cleans/hardens  -> .harness/build-refiner-report.md
  |   +- QA agent             -> tests/scores    -> .harness/build-round-N-feedback.md
  |   +- Score check          -> all >= 7? done : next round
  +- Phase 5: Summary         -> Final report to user
```

---

## Phase 1: Setup

1. Identify or create the project directory.
2. Run:
   ```bash
   mkdir -p .harness
   git init 2>/dev/null || true
   ```
3. Write the user's original prompt (`$ARGUMENTS`) and the classified scale to `.harness/build-prompt.md`.

---

## Phase 2: Scout

Read the scout prompt template: `~/.claude/harness/scout-prompt.md`

The Scout explores the existing codebase BEFORE planning, so the Planner and Builder have full context.

### Scale S — Targeted Scan

Launch a **general-purpose Agent** with subagent_type `Explore`:
- **prompt**: The scout prompt template + context:
  - "Project directory: `{cwd}`"
  - "User's request: `{$ARGUMENTS}`"
  - "Scale: S — scan only the 2-5 files directly relevant to the request."
  - "Write output to `.harness/build-context.md`"
- **description**: "harness scout (S)"

### Scale M — Module Scan

Launch a **general-purpose Agent** with subagent_type `Explore`:
- **prompt**: The scout prompt template + context:
  - "Project directory: `{cwd}`"
  - "User's request: `{$ARGUMENTS}`"
  - "Scale: M — scan the relevant module(s), 5-15 files."
  - "Write output to `.harness/build-context.md`"
- **description**: "harness scout (M)"

### Scale L — Full Codebase Scan

Launch a **general-purpose Agent** with subagent_type `Explore`:
- **prompt**: The scout prompt template + context:
  - "Project directory: `{cwd}`"
  - "User's request: `{$ARGUMENTS}`"
  - "Scale: L — comprehensive codebase scan, 20-40 files."
  - "Write output to `.harness/build-context.md`"
- **description**: "harness scout (L)"

After Scout completes, briefly confirm to the user: **"Scout 완료. 코드베이스 컨텍스트를 수집했습니다."** (No approval needed — proceed to Planning.)

---

## Phase 3: Planning

Read the planner prompt template: `~/.claude/harness/planner-prompt.md`

### Scale S — Scope Note

Do NOT spawn a Planner agent. Instead, the orchestrator writes `.harness/build-spec.md` directly, informed by `.harness/build-context.md`:

```markdown
# Scope Note

## Scale: S
## Task: [one-line description]
## Files to Change: [list — informed by context.md]
## Existing Patterns to Follow: [key patterns from context.md]
## Success Criteria:
1. [testable criterion]
2. [testable criterion]
## Risks: [if any, otherwise "None"]
```

Present the scope note to the user and ask: **"Scope를 검토해주세요. 진행할까요?"**
**WAIT for user approval.**

### Scale M — Lite Planner

Launch a **general-purpose Agent**:
- **prompt**: The planner prompt template + `"MODE: LITE. Scale is M."` + the user's request.
  - "Codebase context is at `.harness/build-context.md` — read it first to understand existing patterns, conventions, and reusable assets."
- **description**: "harness lite planner"
- The planner MUST write its output to `.harness/build-spec.md`

After completion:
- Read `.harness/build-spec.md`
- Present summary: feature count, changed files, test criteria
- Ask: **"Spec을 검토해주세요. 진행할까요?"**
- **WAIT for user approval.**

### Scale L — Full Planner

Launch a **general-purpose Agent**:
- **prompt**: The planner prompt template + `"MODE: FULL. Scale is L."` + the user's request.
  - "Codebase context is at `.harness/build-context.md` — read it first to understand existing patterns, conventions, and reusable assets."
- **description**: "harness full planner"
- The planner MUST write its output to `.harness/build-spec.md`

After completion:
- Read `.harness/build-spec.md`
- Present summary: feature count, key features, tech stack, AI integrations
- Ask: **"Spec을 검토해주세요. 진행할까요, 수정할 부분이 있나요?"**
- **WAIT for user approval.**

---

## Phase 4: Build-Refine-QA Loop

Read the builder, refiner, and QA prompt templates from `~/.claude/harness/`.

### Max rounds by scale

| Scale | Max Rounds | Refiner | QA Method |
|-------|-----------|---------|-----------|
| S | 1 | Hygiene + pattern check only | Code review + build/test verification |
| M | 2 | Full checklist | Code review + build/test + Playwright (if UI exists) |
| L | 3 | Full checklist + security scan | Playwright mandatory |

### For each round N:

#### 4a. Build

Launch a **general-purpose Agent**:
- **prompt**: The builder prompt template + these context instructions:
  - "Codebase context: `.harness/build-context.md` — read it to understand existing patterns and reusable assets."
  - "Product spec: `.harness/build-spec.md` — your blueprint."
  - "Scale: {S/M/L}"
  - If N == 1: "This is a fresh build. Implement the changes described in the spec."
  - If N > 1: "Read QA feedback at `.harness/build-round-{N-1}-feedback.md` and Refiner report at `.harness/build-refiner-report.md`. Fix ALL reported issues."
  - "Write your progress to `.harness/build-progress.md`."
  - Scale M/L only: "Start the dev server in background and note the URL in progress.md."
- **description**: "harness builder round {N}"

#### 4b. Refine

Launch a **general-purpose Agent**:
- **prompt**: The refiner prompt template + these context instructions:
  - "Codebase context: `.harness/build-context.md`"
  - "Product spec: `.harness/build-spec.md`"
  - "Build progress: `.harness/build-progress.md`"
  - "Scale: {S/M/L}"
  - "Round: {N}"
  - If N > 1: "Previous QA feedback: `.harness/build-round-{N-1}-feedback.md`"
  - "Apply fixes directly to the code. Write your report to `.harness/build-refiner-report.md`."
- **description**: "harness refiner round {N}"

#### 4c. Verify (Scale M/L only)

After the refiner agent completes:
1. Read `.harness/build-progress.md` to find the dev server URL
2. Verify the server is responding: `curl -s -o /dev/null -w '%{http_code}' <URL>`
3. If server is not running, attempt to start it based on progress.md instructions
4. If still not running after M scale, note as critical failure for QA

#### 4d. QA

Launch a **general-purpose Agent**:
- **prompt**: The QA prompt template + these context instructions:
  - "Product spec: `.harness/build-spec.md`"
  - "Refiner report: `.harness/build-refiner-report.md`"
  - "Scale: {S/M/L}"
  - "Round number: {N}"
  - "Write your QA report to `.harness/build-round-{N}-feedback.md`"
  - Scale S: `"QA_MODE: CODE_REVIEW. No Playwright. Verify via code review, build output, and test results."`
  - Scale M: `"QA_MODE: STANDARD. Use Playwright if the app has UI. Otherwise code review + build/test."` + "App URL: `{URL from progress.md}`" (if available)
  - Scale L: `"QA_MODE: FULL. Playwright is MANDATORY."` + "App URL: `{URL from progress.md}`"
- **description**: "harness QA round {N}"

#### 4e. Evaluate

After QA agent completes:
1. Read `.harness/build-round-{N}-feedback.md`
2. Extract scores for each criterion
3. Report to user briefly: round number, scores, pass/fail, key issues
4. **Decision**:
   - ALL criteria >= 7/10 → **PASS** → exit loop, go to Phase 5
   - ANY criterion < 7/10 → **FAIL** → continue to round N+1
   - N == max rounds for this scale → exit loop regardless, go to Phase 5

---

## Phase 5: Summary

### Scale S — Compact Report

```
## Harness Complete (Scale S)

**Status**: PASS / PARTIAL
**Changes**: [files changed]
**Refiner**: [issues found/fixed]
**Verification**: [build/test results]
**Remaining**: [issues if any, otherwise "None"]
**Next**: Run `/harness-review` to review and commit, or `/harness-review --commit` to auto-commit.
```

### Scale M — Standard Report

```
## Harness Complete (Scale M)

**Rounds**: {N}/2
**Status**: PASS / PARTIAL

### Scores
| Criterion | Score |
|-----------|-------|
| Completeness | X/10 |
| Functionality | X/10 |
| Code Quality | X/10 |

### Changes
[List of files changed with brief description]

### Refiner Summary
[Issues found and fixed by Refiner]

### Remaining Issues
[From last QA report if any]

### Next Step
Run `/harness-review` to review and commit, or `/harness-review --pr` to create a PR.
```

### Scale L — Full Report

```
## Harness Build Complete (Scale L)

**Rounds**: {N}/3
**Status**: PASS / PARTIAL

### Final Scores
| Criterion      | Score | Status |
|----------------|-------|--------|
| Product Depth  | X/10  |        |
| Functionality  | X/10  |        |
| Visual Design  | X/10  |        |
| Code Quality   | X/10  |        |

### Features Delivered
[List from spec with PASS/PARTIAL/FAIL per feature]

### Refiner Summary
[Total issues found/fixed across all rounds]

### Remaining Issues
[From last QA report — actionable items]

### Artifacts
- Context: `.harness/build-context.md`
- Spec: `.harness/build-spec.md`
- Refiner: `.harness/build-refiner-report.md`
- Final QA: `.harness/build-round-{N}-feedback.md`
- Progress: `.harness/build-progress.md`
- Git log: `git log --oneline`

### Next Step
Run `/harness-review` to review and commit, or `/harness-review --pr` to create a PR.
```

---

## Critical Rules

1. **Each agent = separate Agent tool call** with fresh context. Never share conversation history between agents.
2. **ALL inter-agent communication through `.harness/` files only.** Do not pass information verbally between agent calls.
3. **Scout runs FIRST.** The Planner and Builder depend on `.harness/build-context.md`.
4. **Refiner runs AFTER Builder, BEFORE QA.** The Refiner cleans code; QA evaluates the cleaned result.
5. **The Builder CANNOT self-certify completion.** Always run Refiner + QA after every build.
6. **The Refiner does NOT add features.** It only cleans, hardens, and aligns with existing patterns.
7. **ALWAYS present the spec/scope to the user and wait for approval** before starting Phase 4.
8. **Scale S does NOT require Playwright.** Code review + build/test is sufficient.
9. **Scale M uses Playwright only if the app has UI.** Backend-only changes use code review + test.
10. **Scale L requires Playwright** for live app testing.
11. **Read prompt templates from `~/.claude/harness/`** before spawning each agent.
12. **When in doubt on scale, pick smaller.** The QA loop catches under-estimation; over-estimation wastes tokens.

## Cost Awareness

| Scale | Typical Duration | Agent Calls |
|-------|-----------------|-------------|
| S | 5-15 min | 4 (scout + builder + refiner + QA) |
| M | 20-50 min | 5-8 (scout + planner + [builder + refiner + QA] × 1-2) |
| L | 1-4 hours | 8-14 (scout + planner + [builder + refiner + QA] × 1-3) |
