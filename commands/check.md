---
description: "5-angle parallel code review (quality/simplification/silent-failure/type/security) → auto-fix CRITICAL/HIGH → build+lint+test verification → commit+push. Supports --dry-run, --pr."
---

# /check — Parallel Code Review + Fix + Verify + Deploy

Review changed code from 5 angles simultaneously, auto-fix issues, verify, and deploy.

## Arguments
- `--dry-run`: Run review only, no fix/commit
- `--pr`: Create PR after push
- (default): Review → Fix → Verify → Commit → Push

## Execution

### 1. Collect Changed Files
`git diff --name-only HEAD` + `git diff --staged --name-only` → Exit if 0 files.

### 2. Parallel Review (5 agents invoked simultaneously)

Invoke all 5 agents in a single message:

| Agent | Role | Output |
|-------|------|--------|
| **code-reviewer** (pr-review-toolkit) | Quality: naming, DRY, complexity, error handling | `{file, line, severity, fix}[]` |
| **code-simplifier** (pr-review-toolkit) | Simplification: unnecessary abstraction, duplication, simpler alternatives | `{file, before, after}[]` |
| **silent-failure-hunter** (pr-review-toolkit) | Silent failures: empty catch, ignored return values, unhandled errors | `{file, line, risk}[]` |
| **type-design-analyzer** (pr-review-toolkit) | Types: unsafe as/any, missing generics, weak types | `{file, line, fix}[]` |
| **security-review** | Security: CWE Top 25 + STRIDE threats | `{file, cwe, severity, fix}[]` |

### 3. Auto-Fix
CRITICAL/HIGH → Fix with Edit tool. MEDIUM → Report only. LOW → Ignore.
Fix scope: affected lines only. Do not touch surrounding code (surgical changes principle).

### 4. Verify
`pnpm build` → `pnpm lint` → `pnpm test` (skip if unavailable).
On failure: auto-fix → re-verify (max 3 attempts). 3 failures → abort.

### 5. Deploy
`git add` → `git commit -m "<type>: <desc>"` → `git push`.
With `--pr`: `gh pr create`.
With `--dry-run`: output review results only.

## Abort Conditions
- Hardcoded secrets / SQL injection detected → abort immediately
- Build fails 3 times → abort
