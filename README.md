# jobc-power-commands

Claude Code용 3개 파워 커맨드 플러그인.

## 커맨드

| 커맨드 | 용도 | 사용 시점 |
|--------|------|---------|
| `/check` | 병렬 코드 리뷰 + 자동 수정 + 검증 + 배포 | 코드 작성 후 커밋 전 |
| `/cowork` | 지휘자 + Agent Teams 병렬 오케스트레이션 | 여러 파일을 동시에 수정할 때 |
| `/super` | 기획 → 구현 → 리뷰 → 배포 전자동 파이프라인 | 대규모 신규 기능 개발 |

## /check — 병렬 코드 리뷰 + 배포

변경 코드를 **5개 에이전트가 동시에** 리뷰하고, 이슈를 자동 수정한 뒤 커밋+푸시합니다.

```
5 에이전트 병렬 리뷰:
  ├─ code-reviewer      (품질: 네이밍, DRY, 복잡도)
  ├─ code-simplifier    (간결화: 불필요 추상화, 중복)
  ├─ silent-failure-hunter (무음 실패: 빈 catch, 미처리 에러)
  ├─ type-design-analyzer (타입: 불안전 as/any, 약한 타입)
  └─ security-review     (보안: CWE Top 25 + STRIDE)
```

```bash
/check              # 리뷰 → 수정 → 검증 → 커밋 → 푸시
/check --dry-run    # 리뷰만 (수정/커밋 안 함)
/check --pr         # 푸시 후 PR도 생성
```

## /cowork — Agent Teams 병렬 오케스트레이션

지휘자(Conductor)가 코드베이스를 파악하고 작업을 분배합니다. **지휘자는 코드를 한 줄도 쓰지 않습니다.**

```
Phase 1: 정찰 (Explore + code-architect)
Phase 2: 계획 (PM 스킬로 작업 분할)
Phase 3: 분배 (Wave별 에이전트 동시 호출)
Phase 4: 취합 (충돌 해결 + 병합)
Phase 5: 검증 (빌드 + 린트 + 테스트)
```

```bash
/cowork 결제 모듈에 환불 기능 추가
/cowork --agents 4 대규모 리팩토링
```

## /super — 전자동 파이프라인

기획부터 배포까지 한 번에. `/cowork` + `/check`를 조합한 풀 파이프라인.

```
DISCOVER → PLAN → BUILD → CHECK → SHIP → DOCUMENT
   PM       PM    /cowork  /check  git     PM
```

```bash
/super 로그인에 2FA 추가
/super --pr 결제 모듈 리팩토링
/super --skip-discover PRD가 이미 있으니 Plan부터
```

## 의존성

이 플러그인은 아래 플러그인이 설치되어 있을 때 최대 성능을 발휘합니다:

| 플러그인 | 필수 | 활용 |
|---------|------|------|
| **Claude Forge** | 권장 | verification-engine, /plan, /tdd, /sync-docs |
| **claude-plugins-official** | 권장 | pr-review-toolkit (6 에이전트), feature-dev, code-simplifier |
| **pm-skills** | 선택 | /write-prd, /write-stories, /pre-mortem, /test-scenarios, release-notes |

의존 플러그인 없이도 동작하지만, 에이전트/스킬이 없는 단계는 기본 패턴으로 대체됩니다.

## 설치

```bash
# 1. Clone
git clone https://github.com/jobc90/jobc-power-commands.git

# 2. 커맨드 복사
cp jobc-power-commands/commands/*.md ~/.claude/commands/

# 3. (선택) 플러그인 카탈로그 규칙 복사
cp jobc-power-commands/rules/*.md ~/.claude/rules/
```

## 라이선스

MIT
