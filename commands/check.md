---
description: "5-angle parallel code review (quality/simplification/silent-failure/type/security) → auto-fix CRITICAL/HIGH → build+lint+test verification → report next step. Git actions opt-in via --commit, --push, --pr. Supports --dry-run."
---

# /check — Parallel Code Review + Fix + Verify

Review changed code from 5 angles simultaneously, auto-fix issues, and verify. Git actions are opt-in.

## Arguments
- `--dry-run`: Run review only, no fix/commit
- `--commit`: Commit after verification
- `--push`: Commit if needed, then push
- `--pr`: Commit, push, and create PR
- (default): Review → Fix → Verify → Report next safe git step

## Execution

### 1. Collect Changed Files
`git diff --name-only HEAD` + `git diff --staged --name-only` → Exit if 0 files.

### 2. Parallel Review (5 agents invoked simultaneously)

Invoke 4 specialized agents + 1 security-focused general agent in a single message:

| Agent | Type | Role | Output |
|-------|------|------|--------|
| **code-reviewer** | built-in subagent | Quality: naming, DRY, complexity, error handling | `{file, line, severity, fix}[]` |
| **code-simplifier** | built-in subagent | Simplification: unnecessary abstraction, duplication, simpler alternatives | `{file, before, after}[]` |
| **silent-failure-hunter** | built-in subagent | Silent failures: empty catch, ignored return values, unhandled errors | `{file, line, risk}[]` |
| **type-design-analyzer** | built-in subagent | Types: unsafe as/any, missing generics, weak types | `{file, line, fix}[]` |
| **security** | general-purpose agent with security prompt | Security: CWE Top 25 + STRIDE threats, injection vectors, hardcoded secrets, auth gaps, sensitive data exposure | `{file, cwe, severity, fix}[]` |

Note: The first 4 are dedicated Agent subtypes. The 5th (security) uses a general-purpose agent dispatched with a focused security review prompt covering the project's security-checklist rules.

### 3. Auto-Fix
CRITICAL/HIGH → Fix with Edit tool. MEDIUM → Report only. LOW → Ignore.
Fix scope: affected lines only. Do not touch surrounding code (surgical changes principle).

### 4. Verify
Detect the project's build system and run verification commands in order:

```
package.json → npm/yarn/pnpm/bun (scripts: build, lint, test)
Makefile     → make build, make lint, make test
Cargo.toml   → cargo build, cargo clippy, cargo test
go.mod       → go build ./..., go vet ./..., go test ./...
pyproject.toml → ruff check, pytest
```

Skip any step if the command or config is not present.
On failure: auto-fix → re-verify (max 3 attempts). 3 failures → abort.

### 5. Git Handoff (opt-in)
Git actions require explicit flags. Do not commit, push, or create PRs unless the user passed the corresponding flag.

- **Default**: Report verified state and recommend the next safe git step. Do not touch git.
- `--dry-run`: Output review results only. Do not fix, commit, or push.
- `--commit`: `git add` relevant files → `git commit -m "<type>: <desc>"`.
- `--push`: Commit first if needed → `git push`.
- `--pr`: Commit and push → `gh pr create`.

## Abort Conditions
- Hardcoded secrets / SQL injection detected → abort immediately
- Build fails 3 times → abort
