---
description: "Conductor scouts the codebase and distributes tasks to agent teams in Wave structure (sequential → parallel → finalize). PM commands for planning, conflict merging, and build verification."
---

# /cowork — Conductor + Agent Teams Parallel Orchestration

The conductor (me) writes zero lines of code. Scout → Plan → Distribute → Consolidate → Verify only.

## Arguments
- First argument: task description (required)
- `--agents N`: number of parallel agents (default 3, max 5)

## Core Rules
1. Conductor uses Read/Grep/Glob only. Write/Edit forbidden (except for merging)
2. Before assigning tasks, use Explore agent to fully understand the codebase
3. Provide each agent with **file paths + success criteria + prohibitions**
4. No two agents may modify the same file
5. Shared files (types/utils) are handled first in Wave 1

## Execution

### Phase 1: Scout
Invoke Explore agent → understand architecture, directories, key files, dependencies.
+ `code-architect` (feature-dev) agent to analyze existing patterns.

### Phase 2: Plan
Auto-select PM skill based on task scope:

| Scope | Command |
|-------|---------|
| 3+ file new feature | `/write-prd` → write PRD → `/write-stories` → split into stories |
| Refactoring | `/write-stories` → split into tasks |
| Bug batch | `/test-scenarios` → scenarios + regression tests |
| High risk | `/pre-mortem` → identify risks then split |

Split result: `Wave 1 (sequential) → Wave 2 (parallel) → Wave 3 (finalize)` structure.

### Phase 3: Distribute
Task brief per agent:
```
You are {role}. Modify only the files below.
Context: {scout summary}
Target files: {file path list}
Success criteria: {checklist}
Prohibited: modifying files outside scope, breaking existing tests, importing uninstalled packages
```
After Wave 1 completes, invoke Wave 2 agents **simultaneously in a single message**.

### Phase 4: Consolidate
1. Check conflicts with `git diff`
2. Verify import consistency + type coherence
3. If conflicts exist, conductor merges with Edit

### Phase 5: Verify
`pnpm build` → `pnpm lint` → `pnpm test`.
On failure: send fix instructions to the responsible agent via SendMessage (max 3 attempts).
