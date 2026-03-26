# Harness-Docs: Autonomous Documentation Builder

> Anthropic harness pattern adapted for documentation tasks.
> Researcher -> Writer -> Reviewer feedback loop with file-based handoffs.

## User Request

$ARGUMENTS

## Guard Clause

Check if `$ARGUMENTS` is a documentation or analysis request.

If the user's request is:
- A question about harness-docs itself ("how does this work?")
- A request to build/code an application (use `/harness` instead)
- An unrelated task

Then: **Do NOT execute the protocol.** Respond directly to the user.

Proceed when the user asks to: document a project, create a spec/PRD, write an architecture overview, analyze codebase structure, create onboarding docs, write a migration guide, or any document-generation task that requires deep project understanding.

## Architecture

```
/harness-docs <request>
  |
  +- Phase 1: Setup          -> .harness-docs/ directory
  +- Phase 2: Research        -> Researcher agent -> .harness-docs/research.md
  |                           -> User reviews scope
  +- Phase 3: Write-Review Loop -> Up to 3 rounds:
  |   +- Writer agent         -> drafts/revises  -> .harness-docs/draft.md
  |   +- Reviewer agent       -> fact-checks     -> .harness-docs/round-N-review.md
  |   +- Score check          -> all >= 7? done : next round
  +- Phase 4: Finalize        -> Copy to user-specified location
  +- Phase 5: Summary
```

## Execution Protocol

---

### Phase 1: Setup

1. Identify the target project directory. If the user specifies a project, `cd` there first.
2. Create the working directory:
   ```bash
   mkdir -p .harness-docs
   ```
3. Write the user's request to `.harness-docs/request.md`:
   - What document type is requested
   - What scope/depth is expected
   - Who is the target audience (if specified)

---

### Phase 2: Research

Read the researcher prompt template: `~/.claude/harness/researcher-prompt.md`

Launch a **general-purpose Agent** with subagent_type `Explore` (or general-purpose if Explore is unavailable):
- **prompt**: The researcher prompt template + these context instructions:
  - "Project directory: `{current working directory}`"
  - "User's request: `{$ARGUMENTS}`"
  - "Write your research output to `.harness-docs/research.md`"
- **description**: "harness-docs researcher"

After the researcher completes:
1. Read `.harness-docs/research.md`
2. Present a **scope summary** to the user:
   - Project name and type
   - Key areas discovered
   - Proposed document structure (table of contents)
   - Estimated document size
3. Ask: **"리서치 범위와 문서 구조를 검토해주세요. 진행할까요, 조정할 부분이 있나요?"**
4. **WAIT for user approval** before continuing.

---

### Phase 3: Write-Review Loop (max 3 rounds)

Read the writer and reviewer prompt templates from `~/.claude/harness/`.

**For each round N (1, 2, 3):**

#### 3a. Write

Launch a **general-purpose Agent**:
- **prompt**: The writer prompt template + these context instructions:
  - "Research file: `.harness-docs/research.md` — your primary source."
  - "User's request: `{$ARGUMENTS}`"
  - If N == 1: "Write the full document draft to `.harness-docs/draft.md`."
  - If N > 1: "Read reviewer feedback at `.harness-docs/round-{N-1}-review.md` and revise `.harness-docs/draft.md` to address ALL issues."
  - "You may read source code files directly to fill gaps in the research."
- **description**: "harness-docs writer round {N}"

#### 3b. Review

Launch a **general-purpose Agent**:
- **prompt**: The reviewer prompt template + these context instructions:
  - "Document to review: `.harness-docs/draft.md`"
  - "Research baseline: `.harness-docs/research.md`"
  - "User's original request: `{$ARGUMENTS}`"
  - "Round number: {N}"
  - "Write your review to `.harness-docs/round-{N}-review.md`"
  - "You MUST fact-check claims by reading actual source code and config files."
- **description**: "harness-docs reviewer round {N}"

#### 3c. Evaluate

After reviewer completes:
1. Read `.harness-docs/round-{N}-review.md`
2. Extract scores for each criterion
3. Report to user briefly:
   - Round number, scores per criterion, pass/fail
   - Key issues found (if any)
4. **Decision**:
   - ALL criteria >= 7/10 -> **PASS** -> exit loop
   - ANY criterion < 7/10 -> **FAIL** -> next round
   - N == 3 -> exit loop regardless

---

### Phase 4: Finalize

1. Read the final `.harness-docs/draft.md`
2. Ask the user where to save the final document:
   - Default: project root or `docs/` directory
   - User may specify a custom path
3. Copy/move the final document to the specified location
4. Clean up or preserve `.harness-docs/` based on user preference

---

### Phase 5: Summary

```
## Harness-Docs Complete

**Rounds**: {N}/3
**Status**: PASS / PARTIAL

### Final Scores
| Criterion         | Score | Status |
|-------------------|-------|--------|
| Completeness      | X/10  |        |
| Accuracy          | X/10  |        |
| Logical Coherence | X/10  |        |
| Clarity           | X/10  |        |

### Document Stats
- Sections: X
- Approximate length: X lines / X words
- Source files referenced: X

### Artifacts
- Research: `.harness-docs/research.md`
- Final document: `{final path}`
- Last review: `.harness-docs/round-{N}-review.md`
```

---

## Critical Rules

1. **Each agent = separate Agent tool call** with fresh context.
2. **ALL inter-agent communication through `.harness-docs/` files only.**
3. **The writer CANNOT self-certify quality.** Always run the reviewer.
4. **The reviewer MUST fact-check against actual source code.** Reading the draft alone is insufficient.
5. **ALWAYS present the research scope to the user and wait for approval** before writing.
6. **The researcher must explore the ACTUAL codebase**, not guess from file names.
7. **Documents are written in the language matching the user's request.** If the user writes in Korean, the document should be in Korean. If English, then English.
