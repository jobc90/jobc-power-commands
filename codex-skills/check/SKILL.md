---
name: check
description: Use when implementation is already in progress or finished and Codex needs to review the current diff, apply small safe fixes, verify results, and prepare the next git step such as commit, push, or PR creation.
---

# Check

## Overview

Run the Codex version of `/check`. This keeps the Claude workflow shape, but replaces Claude-only named reviewer agents with a built-in 5-angle review checklist, keeps git actions opt-in, and requires fresh verification evidence before any ship claim.

This skill is self-contained. Do not assume external Forge rule files are available. Internalize verification, code-quality, security, and git conventions directly while reviewing the diff.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$check`
- `$check --dry-run`
- `$check --commit`
- `$check --push`
- `$check --pr`

If no token is present but the request clearly means "review the current changes before shipping", this skill still applies.

## Core Rules

- Review the real diff first. Do not spend time on unchanged files.
- Fix only issues you can defend with evidence.
- Keep edits surgical and inside the existing change scope.
- Validate external input and other trust boundaries instead of adding broad defensive code everywhere.
- Do not commit, push, or open a PR unless the user explicitly requested that action.
- Do not claim success without fresh verification output.

## Workflow

### 1. Identify the target diff

Collect staged and unstaged changes with git status and diff commands.

If there is no diff:

- Report that there is nothing to review.
- Stop without touching git history.

### 2. Run the 5-angle review

Codex does not have the same named Claude reviewer agents, so internalize the review as 5 explicit angles.

| Angle | Goal | Checks |
|------|------|--------|
| Quality | Keep code maintainable and coherent | naming, duplication, complexity, error handling, boundary clarity |
| Simplification | Remove needless weight | unnecessary abstraction, one-off indirection, dead branches, over-configuration, simpler alternative |
| Silent Failure | Catch hidden breakage | swallowed exceptions, ignored return values, missing awaits, unchecked nullish paths, skipped failure states |
| Type Design | Tighten correctness contracts | unsafe `any`, unsafe casts, missing generics, weak unions, mismatch between runtime and types |
| Security | Block risky behavior | secrets, injection, auth gaps, trust-boundary mistakes, unsafe file or network handling |

### 3. Use the 5-angle checklist

Run this checklist against the changed files. The items intentionally mirror the Claude review angles.

| Angle | Checklist |
|------|-----------|
| Quality | 1. Naming matches intent  2. No duplicated logic introduced  3. Control flow stays readable  4. Error handling is explicit  5. Tests cover the changed behavior |
| Simplification | 6. No unnecessary abstraction added  7. No optionality without a real use case  8. New helper count is justified  9. Existing code path could not stay simpler  10. No broad refactor hidden inside the fix |
| Silent Failure | 11. No empty catch or silent rescue  12. No ignored async or Promise result  13. No unchecked parse/IO/network failure  14. No hidden fallback that masks bad state  15. Failure path is testable or reported |
| Type Design | 16. No unnecessary `any`  17. No unsafe cast without runtime guard  18. Interfaces match actual data shape  19. Nullable paths are handled deliberately  20. Public contracts stay consistent |
| Security | 21. No hardcoded secrets  22. No injection vector added  23. Authz/authn assumptions are explicit  24. External input is validated at boundaries  25. Sensitive data is not leaked to logs or output |

### 4. Severity classification

Use this severity table when deciding what to change now.

| Severity | Meaning | Action |
|---------|---------|--------|
| Critical | Security issue, data corruption risk, or guaranteed production break | Stop and report immediately. Fix only if the path is clear and safe. |
| High | Likely bug, regression, or correctness hole | Fix now and verify. |
| Medium | Real quality issue but not release-blocking | Report by default. Fix only if narrowly scoped. |
| Low | Minor cleanup or preference | Usually report only. |

### 5. Apply safe fixes

Fix issues that clearly deserve action now:

- Critical issues when the remediation is safe and obvious
- High-confidence correctness issues
- Security problems
- Straightforward reliability or type-safety fixes
- Narrow tests required to prove the fix

Do not silently widen scope to chase medium or low suggestions.

### 6. Verify

Detect verification commands in this order:

1. Project or package-specific focused test command for the changed area
2. Narrow lint/typecheck command for the touched package or app
3. Broader repo-level lint or build
4. Broader test suite

Use the narrowest command that proves the fix first, then expand only as needed.

If verification fails:

- Fix the issue
- Re-run the relevant command
- Repeat up to 3 loops

If verification still fails after 3 loops, stop and report the failure evidence.

## Git Handoff Rules

### `--dry-run`

- Review and report findings
- Do not edit unless the user separately asked for fixes
- Do not commit, push, or create PRs

### Default

- Review, fix, and verify
- Stop after reporting the verified state and the next safe git step

### `--commit`

- Stage only the relevant files
- Create one non-interactive commit after verification
- Use a conventional commit prefix such as `fix:`, `feat:`, `docs:`, or `refactor:`

### `--push`

- Commit first if needed
- Push the current branch after verification

### `--pr`

- Commit and push only after verification
- Create a PR only if GitHub CLI is available and the user asked for it
- Base the PR summary on the actual branch diff and verification evidence

## Stop Conditions

Stop immediately and report if any of these appear:

- Hardcoded secret or credential leak
- Clear injection vulnerability
- Verification failure after 3 repair loops
- Dirty unrelated worktree state that makes automatic git actions risky

## Output Shape

Use this shape for final reporting:

1. Reviewed: files or diff scope
2. Fixed: issues resolved now
3. Recommended: medium or low findings left as follow-up
4. Verified: commands run and outcomes
5. Git: action taken, or next safe step

## Quick Prompts

- `Use $check on the current diff.`
- `Use $check --dry-run and tell me only the risky issues.`
- `Use $check --commit after fixing anything clearly broken.`
- `Use $check --pr for the branch after verification passes.`
