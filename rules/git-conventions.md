# Git Conventions

> 커밋과 PR의 일관된 규칙.

## 커밋 메시지 포맷

```
<type>: <description>

<optional body>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

## PR 워크플로우

PR 생성 시:
1. 전체 커밋 히스토리 분석 (최신 커밋만이 아닌)
2. `git diff [base-branch]...HEAD`로 전체 변경 확인
3. 종합적인 PR 요약 작성
4. 테스트 계획 포함
5. 새 브랜치면 `-u` 플래그로 푸시

## /check, /super 연동

- /check: 검증 후 `git add → git commit → git push`. `--pr` 시 `gh pr create`
- /super SHIP: 동일 흐름. `--pr` 시 PR 자동 생성
- 커밋 메시지는 위 포맷을 따름
