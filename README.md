# claudex-power-commands

[English](README.en.md) | **한국어**

> [Claude Code](https://claude.ai/code)와 Codex에서 사용할 수 있는 파워 커맨드/스킬 7종

Claude Code용 slash command와 Codex용 skill을 따로 관리하는 수준이 아니라,
실제로 같은 작업 흐름을 양쪽에서 거의 동일한 감각으로 돌릴 수 있게 맞춘 7종 세트입니다.

이번에 특히 밀어붙인 부분은, 기존에 흩어져 있던 좋은 베이스들을 그냥 "가져다 붙인" 게 아니라
실전에서 더 쓰기 쉬운 형태로 다시 재구성했다는 점입니다.

taste-skill 기반 디자인 워크플로우를 /design 하나로 통합
design.md 자동 감지 + /super --design 연동
Superpowers/PM Skills 흐름을 Codex에서도 바로 쓰게 포팅
검증/코드 품질/보안/git 규칙을 스킬 내부에 직접 내장
git 액션은 opt-in으로 바꿔서 자동 커밋/푸시 사고 방지
/super, /cowork, /docs 안에서 상황별 PM 스킬 자동 라우팅
병렬 작업도 wave, ownership, verification 기준으로 통제
즉, 베이스로 사용한

taste-skill
Superpowers Plugin (claude-plugins-official)
PM Plugin Suite (pm-skills)
의 장점은 살리고,
실제로 써보면 불편했던

툴마다 다른 사용감
외부 규칙 의존
과한 수동 스킬 선택
자동 git 액션 불안정성
같은 부분은 꽤 많이 줄였습니다.
AI 코딩 툴을 "한두 개의 명령으로 안정적으로 굴리는 쪽"에 관심 있으면 한 번 보셔도 좋습니다.

---

## 한눈에 보기

```
/check        — 코드 작성 끝 → 리뷰 → 수정 → 검증 → 다음 단계 안내 (5분)
/cowork       — 큰 작업 → 에이전트 팀 분배 → 병렬 구현 → 취합 → 검증 (15분)
/super        — 아이디어 → 기획 → 구현 → 리뷰 → 배포 → 문서화 (30분+)
/docs         — 문서 유형 자동 판별 → 리서치 → 구조화 → 작성 → 검수 (10분)
/design       — 3-다이얼(V/M/D) + 프리셋으로 프론트엔드 디자인 품질 제어
/harness      — 3-에이전트(Planner→Builder→QA) 자율 앱 빌드 (1-4시간)
/harness-docs — 3-에이전트(Researcher→Writer→Reviewer) 자율 문서 생성 (10-30분)
```

### 언제 뭘 쓸까?

#### /check — 코드 다 짰고, 리뷰+검증 받고 싶을 때

```bash
/check                          # 리뷰 → 수정 → 검증 → 다음 단계 안내
/check --dry-run                # 리뷰만 보기 (수정/커밋 안 함)
/check --commit                 # 검증 후 커밋
/check --push                   # 검증 후 커밋+푸시
/check --pr                     # 검증 후 커밋+푸시+GitHub PR 생성
```

#### /cowork — 큰 작업을 팀으로 나눠서

```bash
/cowork 결제 모듈에 환불 기능 추가
/cowork --agents 4 대규모 리팩토링     # 에이전트 4명 동시 투입
```

#### /super — 아이디어 하나로 끝까지

```bash
# 기본: 기획 → 구현 → 리뷰 → 배포
/super 로그인에 2FA 추가
/super --pr 결제 모듈 리팩토링

# 기획서가 이미 있을 때
/super --skip-discover PRD가 이미 있으니 Plan부터

# 디자인까지 포함해서 서비스 구현 (가장 강력)
/super --design soft 기획서와 design.md를 읽고 서비스 전체 구현
/super --design dashboard --pr 관리자 대시보드 구현 후 PR까지

# design.md가 프로젝트에 있으면 자동 감지 (플래그 불필요)
/super 서비스 전체 구현해줘
```

#### /docs — 문서 작성/갱신/정리

```bash
/docs 이 프로젝트 README 작성해줘
/docs --type prd 결제 모듈 기능 기획
/docs 지난 회의 트랜스크립트 정리해줘
/docs --dry-run 아키텍처 문서 구조만 잡아줘
/docs 프로젝트 전체 문서화
```

#### /design — 프론트엔드 디자인

```bash
# 디자인 시스템 생성 (최초 1회)
/design init                             # 프로젝트 분석 → design.md 생성

# 용도별로 바로 사용
/design --landing SaaS 랜딩페이지         # 에이전시급 프리미엄
/design --dashboard 실시간 모니터링        # 대시보드/터미널
/design --workspace 팀 협업 도구          # 미니멀 에디토리얼
/design --admin 관리자 패널               # 빽빽한 데이터 UI

# 커스텀 다이얼로 세밀하게
/design --v 8 --m 7 --d 2 럭셔리 브랜드 랜딩

# 기존 프로젝트 디자인 업그레이드
/design init                             # "더 화려하게" → design.md 업데이트
/design --redesign 디자인 리팩토링

# /super와 연동 (가장 편한 방법)
/design init                             # design.md 생성
/super 서비스 구현해줘                     # design.md 자동 감지 → 디자인 적용
```

#### /harness — 수 시간짜리 풀스택 앱을 자율 빌드

```bash
# 기본: Planner → Builder → QA 피드백 루프 (최대 3라운드)
/harness Build a fully featured DAW in the browser using the Web Audio API
/harness 2D 레트로 게임 메이커 (스프라이트 에디터, 레벨 에디터, 플레이 모드)

# AI 기능이 내장된 풀스택 앱
/harness 팀 프로젝트 관리 도구 (AI 일정 추천, 리스크 예측 포함)
```

> Anthropic의 [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)에서 영감. GAN 구조처럼 생성자(Builder)와 평가자(QA)를 분리하여 품질을 끌어올립니다. QA는 Playwright MCP로 실제 브라우저에서 테스트합니다.

#### /harness-docs — 프로젝트 탐색 → 문서 자율 생성

```bash
# 프로젝트 전체 아키텍처 문서화
/harness-docs 이 프로젝트의 전체 구조와 아키텍처를 문서화해줘

# 온보딩 가이드
/harness-docs 새로운 개발자를 위한 온보딩 문서를 만들어줘

# 특정 모듈 API 명세
/harness-docs apps/api의 features 모듈별 API 명세서를 작성해줘

# 마이그레이션 가이드
/harness-docs v1에서 v2로의 마이그레이션 현황과 남은 작업을 정리해줘
```

> Reviewer가 문서의 모든 주장을 소스코드 대조로 팩트체크합니다. "NestJS 사용"이라 썼으면 package.json을 열어서 확인합니다.

#### 추천 워크플로우

```bash
# 새 서비스 처음부터 끝까지
/design init                    # Step 1: 디자인 시스템 정의
/super 기획서 읽고 구현해줘       # Step 2: 기획→구현→리뷰→배포 (디자인 자동 적용)

# 기존 서비스 디자인 리뉴얼
/design init                    # Step 1: 현재 디자인 분석 → 목표 설정
/super 디자인 리팩토링해줘        # Step 2: 디자인만 변경 (기능 유지)

# 빠른 기능 추가 후 커밋
(코딩 완료 후)
/check --pr                     # 리뷰→수정→검증→PR 한 번에

# 큰 앱을 처음부터 자율로 만들기
/harness 브라우저 기반 음악 프로덕션 DAW

# 프로젝트 전체 문서화 (리서치 → 작성 → 팩트체크)
/harness-docs 이 프로젝트의 전체 구조를 문서화해줘
```

### Codex 버전

이 저장소에는 `Claude Code`용 slash command 원본과, `Codex`용 skill 포트가 함께 들어 있습니다.

- Claude Code 원본: `commands/`
- Codex 포트: `codex-skills/`

Codex에서는 slash command 대신 아래처럼 스킬을 부릅니다:

```text
Use $check ...
Use $cowork ...
Use $super ...
Use $docs ...
Use $design ...
Use $harness ...
Use $harness-docs ...
```

### Codex 전용 추가 스킬

Codex 포트에는 아래 2개 스킬도 포함됩니다.

- `harness`: `.harness_codex/` 아래에 `prompt_codex.md`, `spec_codex.md`, `progress_codex.md` 등을 만들어 구현과 QA를 분리하는 자율 앱 빌드 스킬
- `harness-docs`: `.harness-docs_codex/` 아래에 `request_codex.md`, `research_codex.md`, `draft_codex.md` 등을 만들어 문서 작성과 리뷰를 분리하는 자율 문서 생성 스킬

```text
Use $harness to autonomously build a substantial application with planner, builder, and QA rounds.
Use $harness-docs to research a codebase, draft documentation, and fact-check it before finalizing.
```

---

## /check — 병렬 코드 리뷰 + 자동 수정 + 검증

변경 코드를 **5개 에이전트가 동시에** 리뷰합니다. CRITICAL/HIGH 이슈는 자동 수정하고, 빌드 검증 후 다음 단계를 안내합니다. Git 액션(커밋/푸시/PR)은 명시적 플래그가 있을 때만 실행합니다.

### 5개 리뷰 에이전트

| 에이전트 | 유형 | 검사 영역 |
|---------|------|---------|
| code-reviewer | built-in subagent | 네이밍, DRY, 복잡도, 에러 핸들링 |
| code-simplifier | built-in subagent | 불필요한 추상화, 중복 로직, 더 단순한 대안 |
| silent-failure-hunter | built-in subagent | 빈 catch, 무시된 반환값, 미처리 Promise |
| type-design-analyzer | built-in subagent | 불안전 `as`/`any`, 누락 제네릭, 약한 타입 |
| security | general-purpose (보안 프롬프트) | CWE Top 25 + STRIDE 위협 모델링 |

### 실행 흐름

```
변경 파일 수집 → 5 에이전트 동시 리뷰 → 자동 수정 → 빌드+린트+테스트 → 검증 결과 보고
```

### 사용법

```bash
/check              # 리뷰 → 수정 → 검증 → 다음 단계 안내
/check --dry-run    # 리뷰 결과만 보기 (수정/커밋 안 함)
/check --commit     # 검증 후 커밋
/check --push       # 검증 후 커밋+푸시
/check --pr         # 검증 후 커밋+푸시+GitHub PR 생성
```

---

## /cowork — 지휘자 + Agent Teams 병렬 오케스트레이션

지휘자(Conductor)가 코드베이스를 파악하고, 작업을 에이전트 팀에 분배합니다.

**핵심 규칙:** 지휘자는 코드를 한 줄도 쓰지 않습니다. 정찰 → 계획 → 분배 → 취합 → 검증만.

### 6단계 실행

| Phase | 역할 | 활용 커맨드/도구 |
|-------|------|----------------|
| **1. 정찰** | 코드베이스 구조 파악 | Explore 에이전트 + code-architect |
| **2. 계획** | 작업을 독립 단위로 분할 | PM 커맨드 (/write-prd, /write-stories, /test-scenarios) |
| **3. 분배** | Wave별 에이전트 동시 호출 + 모델 선택 | Agent 도구 병렬 실행 (haiku/sonnet/opus 태스크별) |
| **3.5 슬라이스 리뷰** | 각 워커 결과 spec 준수 + 소유권 검증 | diff 체크 + 수정 지시 |
| **4. 취합** | 충돌 확인 + 병합 | git diff + Edit |
| **5. 검증** | 빌드 + 린트 + 테스트 | 빌드 시스템 자동 감지 |

### Wave 구조

```
Wave 1 (순차): 공유 타입, 인터페이스, 유틸리티
Wave 2 (병렬): 데이터 레이어 / UI 컴포넌트 / 테스트
Wave 3 (순차): import 정리, 미사용 코드 제거
```

### 사용법

```bash
/cowork 결제 모듈에 환불 기능 추가
/cowork --agents 4 대규모 리팩토링
```

---

## /super — 기획 → 구현 → 리뷰 → 배포 전자동 파이프라인

아이디어 한 줄에서 배포까지. `/cowork`(병렬 구현) + `/check`(리뷰+배포) + `/design`(디자인 품질)을 조합한 풀 파이프라인.

**원칙:** CRITICAL 보안 이슈에서만 중단. 그 외에는 끝까지.

### 6단계 파이프라인

| 단계 | 역할 | 활용 커맨드/도구 |
|------|------|----------------|
| **DISCOVER** | 요구사항 구조화 | /write-prd, /write-stories, /pre-mortem, /strategy |
| **PLAN** | 구현 계획 + 작업 분할 + design.md 수집 | Explore, code-architect, /prioritize-features, /test-scenarios |
| **BUILD** | 병렬 구현 (/cowork + /design + TDD 연동) | Agent Teams, Wave 분배, 디자인 규칙 주입, RED→GREEN 검증 |
| **CHECK** | 5-angle 리뷰 + 디자인 품질 체크 | 5+1 에이전트 리뷰, 빌드/린트/테스트 |
| **SHIP** | 커밋 + 푸시 + PR | git, gh CLI |
| **DOCUMENT** | 릴리즈 노트 + 문서 갱신 | /sprint, /revise-claude-md, /sync-docs |

### design.md 자동 감지

프로젝트에 디자인 시스템 파일(`design.md`, `designsystem.md`, `*DESIGN*.md` 등)이 있으면 `--design` 플래그 없이도 디자인 규칙이 자동 적용됩니다. `--design <프리셋>`으로 명시 지정하면 자동 감지보다 우선합니다.

Codex 포트 기준 `--design` 프리셋은 `landing`, `dashboard`, `workspace`, `portfolio`, `admin`, `soft`, `minimal`, `brutal`, `redesign` 를 사용합니다. `--design`만 쓰면 디자인 모드만 켜고, 실제 프리셋은 감지된 디자인 시스템 파일이나 현재 제품 유형으로 결정합니다.

### 사용법

```bash
# 기본 (디자인 없이)
/super 로그인에 2FA 추가
/super --pr 결제 모듈 리팩토링

# 디자인 명시 지정
/super --design landing 기획서 기반 서비스 구현
/super --design dashboard --pr 관리자 대시보드

# design.md 자동 감지 (가장 편한 방법)
/design init                    # 최초 1회 — design.md 생성
/super 서비스 전체 구현해줘      # design.md 자동 감지
/super 디자인 리팩토링해줘       # 리디자인도 동일
```

---

## /docs — 체계적 문서화 파이프라인

문서 유형을 **자동 판별**하고, 소스(코드/git/기존 문서)에서 사실을 추출하여 체계적으로 작성합니다.

**핵심 규칙:** 추측 금지. 확인 불가한 정보는 `[TODO]`로 표시. 최종 산출물은 문법 검수 통과.

### 10가지 문서 유형 자동 감지

| 유형 | 트리거 | 활용 커맨드 |
|------|--------|-----------|
| PRD | "기획", "요구사항" | /write-prd, /write-stories |
| 기술 문서 | "아키텍처", "설계" | Explore, code-architect |
| README | "시작하기", "설치" | Explore + 코드 분석 |
| 릴리즈 노트 | "배포", "changelog" | /sprint + git log |
| 회의록 | "회의", "미팅" | /meeting-notes |
| 인터뷰 요약 | "인터뷰", "고객 조사" | /interview |
| 전략 문서 | "전략", "GTM" | /strategy |
| 운영 문서 | "runbook", "배포 가이드" | Explore + 코드 분석 |
| 프로젝트 문서화 | "전체 문서화" | 전체 커맨드 조합 |
| 교정/개선 | "교정", "리뷰" | /proofread |

### 6단계 파이프라인

```
DETECT → RESEARCH → STRUCTURE → DRAFT → REVIEW → DELIVER
```

### 사용법

```bash
/docs 이 프로젝트 README 작성해줘
/docs --type prd 결제 모듈 기능 기획
/docs 지난 회의 트랜스크립트 정리해줘
/docs --dry-run 아키텍처 문서 구조만 잡아줘
/docs 프로젝트 전체 문서화
```

---

## /design — 프론트엔드 디자인 품질 제어

3개 다이얼로 디자인 톤을 제어합니다. [taste-skill](https://github.com/Leonxlnx/taste-skill) 생태계를 통합 진입점 하나로 활용합니다.

### /design init — 디자인 시스템 생성/업데이트

```bash
/design init
# → 디자인 시스템 파일 있으면: 업데이트 모드 ("더 화려하게", "프리셋 변경" 등)
# → 파일 없음 + 코드 있으면: 리디자인 모드 (스캔 → 감사 → 목표)
# → 파일 없음 + 코드 없음: 새 프로젝트 모드 (용도 질문 → 생성)
```

`design.md`, `designsystem.md`, `BENEEDS_DESIGN_SYSTEM.md` 등 커스텀 이름도 자동 감지합니다.

### 3-다이얼 시스템

| 다이얼 | 1-3 | 4-7 | 8-10 |
|--------|-----|-----|------|
| **VARIANCE** (레이아웃) | 정돈된 그리드 | 오프셋, 겹침 | 비대칭, 넓은 여백 |
| **MOTION** (애니메이션) | hover 정도 | 페이드인, 스크롤링 | 마그네틱, 스프링 물리 |
| **DENSITY** (채움도) | 럭셔리, 여유 | 일반 앱 수준 | 대시보드, 빽빽함 |

### 프리셋 — 스타일명 또는 용도명

| 스타일명 | 용도명 | V | M | D | 용도 |
|---------|--------|---|---|---|------|
| (기본) | — | 8 | 6 | 4 | 범용 프론트엔드 |
| `--soft` | `--landing` | 7 | 8 | 3 | 랜딩, SaaS |
| `--soft` | `--portfolio` | 8 | 7 | 2 | 포트폴리오 |
| `--minimal` | `--workspace` | 4 | 3 | 5 | 워크스페이스, 에디토리얼 |
| `--brutal` | `--dashboard` | 6 | 2 | 8 | 대시보드, 데이터 헤비 |
| — | `--admin` | 2 | 3 | 9 | 관리자 패널 |
| `--redesign` | `--redesign` | (분석) | (분석) | (분석) | 기존 사이트 업그레이드 |

### 사용법

```bash
# design.md 생성 (최초 1회)
/design init

# 용도명으로 바로 사용 (직관적)
/design --landing SaaS 랜딩페이지
/design --dashboard 실시간 모니터링
/design --workspace 팀 협업 도구
/design --admin 관리자 패널

# 커스텀 다이얼
/design --v 8 --m 7 --d 2 럭셔리 브랜드 랜딩

# 리디자인
/design --redesign 디자인 업그레이드
```

---

## /harness — 3-에이전트 자율 앱 빌드

Anthropic의 [Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps) 패턴 구현. GAN에서 영감받은 **생성자-평가자 분리 구조**로, 수 시간에 걸쳐 풀스택 앱을 자율 빌드합니다.

### 3-에이전트 아키텍처

| 에이전트 | 역할 | 핵심 |
|---------|------|------|
| **Planner** | 1-4문장 → 15-25 기능의 풀 프로덕트 스펙 | 야심찬 스코프, 세부 구현은 지정 안 함 |
| **Builder** | 스펙 기반 풀스택 구현 + git 관리 | QA 핸드오프 전 자체 테스트 필수 |
| **QA** | Playwright MCP로 실사용 테스트 + 채점 | 회의적 튜닝, 4기준 × 7/10 하드 임계값 |

### 실행 흐름

```
Planner → spec.md → [사용자 승인] → Builder → QA → feedback
                                      ↑                  ↓
                                      └── 7/10 미달 시 ──┘
                                          (최대 3라운드)
```

### QA 평가 기준

| 기준 | 가중치 | 설명 |
|------|--------|------|
| Product Depth | HIGH | 실제 제품 vs 기술 데모 |
| Functionality | HIGH | 클릭해서 진짜 작동하는가 |
| Visual Design | MEDIUM | 일관된 디자인 아이덴티티 |
| Code Quality | LOW | 코드 구조와 패턴 |

### 사용법

```bash
/harness Build a fully featured DAW in the browser
/harness 2D 레트로 게임 메이커 만들어줘
```

> **비용 주의:** 풀 하네스 실행은 1-4시간, 토큰 비용 $100-$200 수준.

---

## /harness-docs — 3-에이전트 자율 문서 생성

하네스 패턴을 문서 작업에 적용. **Reviewer가 모든 주장을 소스코드 대조로 팩트체크**합니다.

### 3-에이전트 아키텍처

| 에이전트 | 역할 | 핵심 |
|---------|------|------|
| **Researcher** | 코드베이스 탐색 → 구조/패턴/컨텍스트 수집 | 실제 파일을 읽고, 추측하지 않음 |
| **Writer** | 리서치 기반 문서 초안 작성 | 모든 주장에 파일 경로 인용 |
| **Reviewer** | 소스코드 대조 팩트체크 + 채점 | 정확성 > 완성도, 거짓은 탈락 |

### 실행 흐름

```
Researcher → research.md → [사용자 승인] → Writer → Reviewer → feedback
                                              ↑                    ↓
                                              └── 7/10 미달 시 ───┘
                                                  (최대 3라운드)
```

### Reviewer 평가 기준

| 기준 | 가중치 | 설명 |
|------|--------|------|
| Completeness | HIGH | 요청한 범위를 모두 커버하는가 |
| Accuracy | HIGH | 소스코드와 일치하는가 (팩트체크) |
| Logical Coherence | MEDIUM | 구조와 흐름이 논리적인가 |
| Clarity | MEDIUM | 대상 독자가 이해하고 행동할 수 있는가 |

### 사용법

```bash
/harness-docs 이 프로젝트의 전체 구조와 아키텍처를 문서화해줘
/harness-docs 새로운 개발자를 위한 온보딩 가이드를 만들어줘
/harness-docs apps/api의 API 명세서를 작성해줘
```

---

## 설치

### 플러그인 매니저 (권장)

```bash
claude plugin install --git https://github.com/jobc90/claudex-power-commands
```

새 세션에서 `/check`, `/cowork`, `/super`, `/docs`, `/design`, `/harness`, `/harness-docs` 가 보이면 성공.

### 수동 설치

```bash
# 1. Clone
git clone https://github.com/jobc90/claudex-power-commands.git

# 2. 커맨드 복사
cp claudex-power-commands/commands/*.md ~/.claude/commands/

# 3. 하네스 프롬프트 템플릿 복사 (/harness, /harness-docs용)
mkdir -p ~/.claude/harness
cp claudex-power-commands/harness/*.md ~/.claude/harness/

# 4. (선택) 규칙 복사
cp claudex-power-commands/rules/*.md ~/.claude/rules/

# 5. 확인 — 새 세션에서
#    /check, /cowork, /super, /docs, /design, /harness, /harness-docs 가 보이면 성공
```

### Codex 설치

```bash
# 1. Clone
git clone https://github.com/jobc90/claudex-power-commands.git

# 2. Codex skill 디렉토리 생성
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"

# 3. Codex skill 복사
cp -R claudex-power-commands/codex-skills/check "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R claudex-power-commands/codex-skills/cowork "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R claudex-power-commands/codex-skills/super "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R claudex-power-commands/codex-skills/docs "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R claudex-power-commands/codex-skills/design "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R claudex-power-commands/codex-skills/harness "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R claudex-power-commands/codex-skills/harness-docs "${CODEX_HOME:-$HOME/.codex}/skills/"

# 4. 확인 — 새 Codex 세션에서
#    $check, $cowork, $super, $docs, $design, $harness, $harness-docs 를 명시하거나 관련 작업을 요청
```

### Codex 사용 예시

```text
Use $check on the current diff.
Use $check --pr after verification passes.
Use $cowork --agents 4 for this refactor.
Use $super --skip-discover because the PRD already exists.
Use $super --design dashboard for the admin UI.
Use $docs to create a README for this project.
Use $docs --type prd for the payment module feature.
Use $docs --dry-run to outline architecture documentation.
Use $design init for this frontend project.
Use $harness to build a browser-based DAW with planner, builder, and QA rounds.
Use $harness-docs to document this repository's architecture with research, writing, and review rounds.
```

### Codex 포트 차이점

- slash command가 아니라 skill 기반이다.
- Codex 스킬은 외부 Forge 규칙 파일 없이도 동작하도록 검증, 코드품질, 보안, git 관례를 스킬 내부에 내재화했다.
- commit/push/PR은 기본 자동 실행이 아니라, 명시적으로 요청했을 때만 수행한다.
- `cowork`, `super`는 병렬 에이전트가 유효한 경우에만 delegation을 사용하고, 아니면 같은 파이프라인을 단일 세션으로 축소 실행한다.
- `$super` 단독 호출은 병렬 위임 허가가 아니다. 병렬 실행은 사용자가 명시적으로 요청하거나 `$cowork`를 호출했을 때만 사용한다.
- 검증 없는 완료 선언을 막기 위해 "검증 증거 없이 완료 선언 금지" 규칙을 기본 반영했다.
- `docs`는 문서 작업에서 shell 사용을 최소화하고, 실제 설치된 Codex 스킬 이름(`create-prd`, `user-stories`, `release-notes` 등)에 맞춰 라우팅한다.
- `design`은 taste-skill의 핵심 개념(프리셋, 3-다이얼, design.md 감지)을 Codex용 단일 스킬로 내재화했다.
- `harness`는 Claude용 `.harness/`와 충돌하지 않도록 `.harness_codex/`와 `_codex` 접미사 파일 아티팩트를 사용하는 Codex 전용 앱 빌드 파이프라인이다.
- `harness-docs`는 Claude용 `.harness-docs/`와 충돌하지 않도록 `.harness-docs_codex/`와 `_codex` 접미사 파일 아티팩트를 사용하는 Codex 전용 문서화 파이프라인이다.

### 삭제

```bash
# 플러그인 매니저로 설치한 경우 (한 줄로 완전 제거)
claude plugin uninstall claudex-power-commands

# 수동 설치한 경우
rm ~/.claude/commands/{check,cowork,super,docs,design,harness,harness-docs}.md
rm -rf ~/.claude/harness/
rm ~/.claude/rules/{code-quality,git-conventions,plugins-catalog,security-checklist,verification}.md

# Codex
rm -rf "${CODEX_HOME:-$HOME/.codex}"/skills/{check,cowork,super,docs,design,harness,harness-docs}
```

### 업데이트

```bash
# 플러그인 매니저로 설치한 경우
claude plugin update claudex-power-commands

# 수동 설치한 경우
cd claudex-power-commands && git pull
cp commands/*.md ~/.claude/commands/
cp harness/*.md ~/.claude/harness/
cp rules/*.md ~/.claude/rules/

# Codex
cp -R codex-skills/check "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R codex-skills/cowork "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R codex-skills/super "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R codex-skills/docs "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R codex-skills/design "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R codex-skills/harness "${CODEX_HOME:-$HOME/.codex}/skills/"
cp -R codex-skills/harness-docs "${CODEX_HOME:-$HOME/.codex}/skills/"
```

---

## 의존성 (선택)

이 플러그인은 **단독으로도 동작**합니다. 아래 플러그인이 있으면 더 강력합니다:

Codex 포트도 동일하게 자립형이다. `super`, `check` 등 핵심 스킬은 검증/코드품질/보안/git 규칙을 스킬 본문에 내장하고 있으므로 Forge 계열 플러그인을 전제로 하지 않는다.

| 플러그인 | 필수 여부 | 역할 | 없으면? |
|---------|---------|------|--------|
| [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | 권장 | pr-review-toolkit (4 리뷰 에이전트), feature-dev, code-simplifier | /check 리뷰 에이전트 감소 |
| [pm-skills](https://github.com/phuryn/pm-skills) | 선택 | write-prd, write-stories, pre-mortem, test-scenarios, release-notes | PM 단계 생략, 바로 구현 |
| [taste-skill](https://github.com/Leonxlnx/taste-skill) | /design 권장 | taste-skill, soft-skill, minimalist-skill, brutalist-skill, redesign-skill, output-skill | 공통 금지 패턴만 적용, 프리셋 상세 규칙 축소 |
| [@playwright/mcp](https://github.com/anthropics/playwright-mcp) | /harness 권장 | QA 에이전트가 브라우저로 실사용 테스트 | QA가 코드 리뷰만 수행 (브라우저 테스트 불가) |

---

## 파일 구조

```
claudex-power-commands/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 매니페스트
├── commands/
│   ├── check.md             # /check (64줄)
│   ├── cowork.md            # /cowork (77줄)
│   ├── design.md            # /design (334줄)
│   ├── docs.md              # /docs (206줄)
│   ├── super.md             # /super (196줄)
│   ├── harness.md           # /harness — 자율 앱 빌드 오케스트레이터
│   └── harness-docs.md      # /harness-docs — 자율 문서 생성 오케스트레이터
├── harness/                  # 하네스 에이전트 프롬프트 템플릿 (→ ~/.claude/harness/)
│   ├── planner-prompt.md    # /harness: Planner 에이전트
│   ├── builder-prompt.md    # /harness: Builder 에이전트
│   ├── qa-prompt.md         # /harness: QA 에이전트 (평가 기준 + few-shot)
│   ├── researcher-prompt.md # /harness-docs: Researcher 에이전트
│   ├── writer-prompt.md     # /harness-docs: Writer 에이전트
│   └── reviewer-prompt.md   # /harness-docs: Reviewer 에이전트 (팩트체크)
├── codex-skills/
│   ├── check/
│   │   ├── SKILL.md            # Codex 스킬 정의
│   │   └── agents/openai.yaml  # Codex 에이전트 설정
│   ├── cowork/
│   │   ├── SKILL.md
│   │   └── agents/openai.yaml
│   ├── design/
│   │   ├── SKILL.md
│   │   └── agents/openai.yaml
│   ├── docs/
│   │   ├── SKILL.md
│   │   └── agents/openai.yaml
│   ├── harness/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   ├── harness-docs/
│   │   ├── SKILL.md
│   │   ├── agents/openai.yaml
│   │   └── references/
│   └── super/
│       ├── SKILL.md
│       └── agents/openai.yaml
├── hooks/
│   └── check-deps.sh        # SessionStart: 권장 플러그인 3종 설치 여부 감지
├── rules/
│   ├── code-quality.md      # 코드 품질 원칙 (불변성, surgical changes, 검증)
│   ├── git-conventions.md   # 커밋 포맷, PR 워크플로우
│   ├── plugins-catalog.md   # 설치된 플러그인 카탈로그 (참조용)
│   ├── security-checklist.md # 보안 체크리스트 (CWE, 시크릿, 인젝션)
│   └── verification.md      # 검증 없이 완료 선언 금지, Red-Green 검증
├── README.md
└── LICENSE
```

## 라이선스

MIT
