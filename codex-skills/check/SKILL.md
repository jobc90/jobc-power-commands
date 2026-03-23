---
name: check
description: Use when implementation is already in progress or finished and Codex needs to review the current diff, apply small safe fixes, verify results, and prepare the next git step such as commit, push, or PR creation.
---

# Check

## Overview

Run a Codex-native finish pass for the current diff. This is the port of `/check`, adapted for Codex's stricter verification rules and safer git behavior.

## Input Modes

Treat these literal tokens in the user's prompt as workflow hints:

- `$check`
- `$check --dry-run`
- `$check --commit`
- `$check --push`
- `$check --pr`

If no token is present but the request clearly means "review the current changes before I ship them", this skill still applies.

## Core Rules

- Review the actual diff first. Do not comment on files that are unchanged.
- Fix only issues you can defend with concrete evidence. Do not churn style-only code unless the user asked.
- Keep edits surgical and inside the existing change scope.
- Do not commit, push, or open a PR unless the user explicitly requested that action in the current prompt.
- Do not claim success without fresh verification output.

## Workflow

### 1. Identify the target diff

Collect the current change set with git status and diff commands. Include staged and unstaged changes.

If there is no diff:

- Report that there is nothing to review.
- Stop without touching git history.

### 2. Run the review pass

Start with a local review in Codex's normal code-review mode:

- Bugs and regressions
- Missing or weak tests
- Silent failures and error handling gaps
- Type safety issues
- Security problems
- Simpler alternatives when the current code is overbuilt

If the user explicitly asks for deep, parallel, or multi-agent review, it is valid to spawn reviewer agents with distinct angles. Keep them read-only reviewers. Do not delegate fixes to the reviewer agents.

### 3. Apply safe fixes

Fix issues that are clearly worth changing now:

- Critical and high-confidence correctness issues
- Security problems
- Straightforward reliability and type-safety fixes
- Missing narrow tests needed to prove the fix

Report medium or low-priority suggestions instead of silently broadening scope.

### 4. Verify

Run the narrowest commands that prove the edited code is correct:

- Focused test first
- Then broader test, lint, or build commands if relevant and available
- Repeat fix and verify up to 3 times if verification fails

If verification still fails after 3 loops, stop and report the failure evidence.

## Git Handoff Rules

### `--dry-run`

- Review and report findings
- Do not edit unless the user separately asked for fixes
- Do not commit, push, or create PRs

### Default

- Review, fix, and verify
- Stop after reporting the verified state and suggested next git command

### `--commit`

- Stage only the relevant files
- Create one non-interactive commit after verification

### `--push`

- Commit first if needed
- Push the current branch after verification

### `--pr`

- Commit and push only after verification
- Create a PR only if the repository is connected to GitHub CLI and the user asked for it

## Stop Conditions

Stop immediately and report if any of these appear:

- Hardcoded secret or credential leak
- Clear injection vulnerability
- Verification failure after 3 repair loops
- Dirty unrelated worktree state that makes automatic git actions risky

## Good Output Shape

When reporting back, keep it concise:

1. What was reviewed
2. Findings fixed
3. Findings left as recommendations
4. Verification commands and results
5. Git action taken, or the next safe git step

## Quick Prompts

- `Use $check on the current diff.`
- `Use $check --dry-run and tell me only the risky issues.`
- `Use $check --commit after fixing anything clearly broken.`
- `Use $check --pr for the branch after verification passes.`
