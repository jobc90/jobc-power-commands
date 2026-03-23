# Git Conventions

> Consistent rules for commits and PRs.

## Commit Message Format

```
<type>: <description>

<optional body>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## PR Workflow

When creating a PR:
1. Analyze the full commit history (not just the latest commit)
2. Use `git diff [base-branch]...HEAD` to review all changes
3. Write a comprehensive PR summary
4. Include a test plan
5. Push with `-u` flag for new branches

## Integration with /check and /super

- /check: after verification, runs `git add → git commit → git push`. With `--pr`: `gh pr create`
- /super SHIP: same flow. With `--pr`: auto-creates PR
- Commit messages follow the format above
