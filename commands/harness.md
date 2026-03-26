# Harness: Autonomous Application Builder

> Anthropic "Harness Design for Long-Running Apps" 3-agent architecture.
> Planner -> Builder -> QA feedback loop with file-based handoffs.

## User Request

$ARGUMENTS

## Guard Clause

Before executing the harness protocol, check if `$ARGUMENTS` is actually a request to BUILD an application.

If the user's request is:
- A question about the harness ("how does this work?")
- A request to verify/audit the harness files
- A request to modify the harness configuration
- Not an application build request

Then: **Do NOT execute the harness protocol.** Instead, respond directly to the user's request as a normal conversation. Only proceed with the phases below when the user provides an application description to build.

## Architecture Overview

```
/harness <prompt>
  |
  +- Phase 1: Setup        -> .harness/ directory + git init
  +- Phase 2: Planning      -> Planner agent -> .harness/spec.md
  |                         -> User reviews and approves
  +- Phase 3: Build-QA Loop -> Up to 3 rounds:
  |   +- Builder agent      -> implements/fixes -> .harness/progress.md
  |   +- QA agent           -> Playwright test  -> .harness/round-N-feedback.md
  |   +- Score check        -> all >= 7? done : next round
  +- Phase 4: Summary       -> Final report to user
```

## Execution Protocol

Follow this protocol exactly. Do not skip or reorder steps.

---

### Phase 1: Setup

1. Identify or create the project directory.
2. Run:
   ```bash
   mkdir -p .harness
   git init 2>/dev/null || true
   ```
3. Write the user's original prompt (`$ARGUMENTS`) to `.harness/prompt.md`.

---

### Phase 2: Planning

1. Read the planner prompt template: `~/.claude/harness/planner-prompt.md`
2. Launch a **general-purpose Agent** (subagent):
   - **prompt**: Combine the planner prompt template content with the user's request.
   - **description**: "harness planner phase"
   - The planner MUST write its output to `.harness/spec.md`
3. After the planner agent completes:
   - Read `.harness/spec.md`
   - Present a **concise summary** to the user: feature count, key features, tech stack, AI integrations
   - Ask: **"Spec을 검토해주세요. 진행할까요, 수정할 부분이 있나요?"**
   - **WAIT for user approval** before continuing. Do NOT proceed automatically.

---

### Phase 3: Build-QA Loop (max 3 rounds)

Read the builder and QA prompt templates from `~/.claude/harness/`.

**For each round N (1, 2, 3):**

#### 3a. Build

Launch a **general-purpose Agent**:
- **prompt**: The builder prompt template + these context instructions:
  - "Product spec is at: `.harness/spec.md` — read it first."
  - If N == 1: "This is a fresh build. Implement the full application."
  - If N > 1: "Read QA feedback at `.harness/round-{N-1}-feedback.md` and fix ALL reported issues."
  - "Write your progress to `.harness/progress.md`."
  - "Start the dev server in background and note the URL in progress.md."
- **description**: "harness builder round {N}"

#### 3b. Verify Dev Server

After the builder agent completes:
1. Read `.harness/progress.md` to find the dev server URL
2. Verify the server is responding: `curl -s -o /dev/null -w '%{http_code}' <URL>`
3. If server is not running, attempt to start it based on progress.md instructions
4. If still not running, note this as a critical failure for QA

#### 3c. QA

Launch a **general-purpose Agent**:
- **prompt**: The QA prompt template + these context instructions:
  - "Product spec: `.harness/spec.md`"
  - "App URL: `{URL from progress.md}`"
  - "Round number: {N}"
  - "Write your QA report to `.harness/round-{N}-feedback.md`"
  - "You MUST use Playwright MCP tools (mcp__playwright__*) to test the live app."
- **description**: "harness QA round {N}"

#### 3d. Evaluate

After QA agent completes:
1. Read `.harness/round-{N}-feedback.md`
2. Extract scores for each criterion
3. Report to user briefly:
   - Round number
   - Scores per criterion
   - Pass/fail status
   - Key issues found
4. **Decision**:
   - ALL criteria >= 7/10 -> **PASS** -> exit loop, go to Phase 4
   - ANY criterion < 7/10 -> **FAIL** -> continue to round N+1
   - N == 3 -> exit loop regardless, go to Phase 4

---

### Phase 4: Final Summary

Present to the user:

```
## Harness Build Complete

**Rounds**: {N}/3
**Status**: PASS / PARTIAL (if exited at round 3 with failures)

### Final Scores
| Criterion      | Score | Status |
|----------------|-------|--------|
| Product Depth  | X/10  |        |
| Functionality  | X/10  |        |
| Visual Design  | X/10  |        |
| Code Quality   | X/10  |        |

### Features Delivered
[List from spec with PASS/PARTIAL/FAIL per feature]

### Remaining Issues
[From last QA report — actionable items]

### Artifacts
- Spec: `.harness/spec.md`
- Final QA: `.harness/round-{N}-feedback.md`
- Progress: `.harness/progress.md`
- Git log: `git log --oneline`
```

---

## Critical Rules

1. **Each agent = separate Agent tool call** with fresh context. Never share conversation history between agents.
2. **ALL inter-agent communication through `.harness/` files only.** Do not pass information verbally between agent calls.
3. **The builder CANNOT self-certify completion.** Always run QA after every build.
4. **The QA MUST use Playwright MCP** (`mcp__playwright__*` tools) to test the live application. Code review alone is not sufficient.
5. **ALWAYS present the spec to the user and wait for approval** before starting the build phase.
6. **If the dev server is not running, QA cannot proceed.** Fix it first.
7. **Read prompt templates from `~/.claude/harness/`** before spawning each agent. Pass the template content as part of the agent prompt.

## Cost Warning

This harness spawns multiple long-running agents. A full run may take 1-4 hours and consume significant tokens. The user should be aware of this before starting Phase 3.
