# Code Quality Principles

> 깔끔하고 유지보수 가능한 코드를 위한 핵심 원칙.

## 1. 불변성 (CRITICAL)

객체를 수정하지 않는다. 항상 새 객체를 생성한다:

```javascript
// WRONG
function updateUser(user, name) {
  user.name = name
  return user
}

// CORRECT
function updateUser(user, name) {
  return { ...user, name }
}
```

성능이 문제라면 프로파일링으로 증명한 후에만 예외.

## 2. 작은 파일, 작은 함수

- 파일: 800줄 최대 (400줄부터 분할 검토)
- 함수: 50줄 최대
- 중첩: 4단계 최대
- 초과 시 분할

## 3. 에러 핸들링

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('Detailed user-friendly message')
}
```

## 4. 시스템 경계에서 검증

내부 코드는 신뢰하되, 사용자 입력과 외부 API 응답은 반드시 검증:

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## 5. Surgical Changes (외과적 변경)

요청된 것만 변경한다. 변경된 모든 줄은 사용자 요청에 직접 연결되어야 한다.

- 인접 코드, 코멘트, 포맷팅을 "개선"하지 않는다
- 기존 스타일을 따른다 (다르게 하고 싶어도)
- 관련 없는 데드코드: 언급만, 삭제하지 않음
- 자기 변경이 만든 고아(unused import 등)만 정리

## 6. 결론 우선, 이유는 나중

첫 문장에 결론. "왜냐하면..."은 그 후에.

## 7. 증거 기반 완료

"될 거야"는 증거가 아니다. 완료 주장 전에:
1. 테스트 결과 (통과/실패 수, 커버리지)
2. 빌드 성공 확인
3. 요구사항 체크리스트 증거 대조

금지: "문제 없을 거야", "이슈 예상 안 됨"
필수: "12 테스트 통과", "빌드 성공 (0 errors)"

## 8. 3+ 파일 변경 시 계획 먼저

3개 이상 파일 변경이 예상되면 구현 전에 계획을 세운다.
예외: 1-2 파일, 타이포/버그 패치.

## 코드 품질 체크리스트

완료 전 확인:
- [ ] 읽기 쉽고 잘 명명됨
- [ ] 함수 50줄 미만
- [ ] 파일 800줄 미만
- [ ] 깊은 중첩 없음 (4단계 이하)
- [ ] 에러 핸들링 적절
- [ ] console.log 없음
- [ ] 하드코딩된 값 없음
- [ ] 뮤테이션 없음 (불변 패턴 사용)
