# Security Checklist

> 커밋 전 반드시 확인. 보안 이슈 발견 시 즉시 중단.

## 필수 보안 체크

커밋 전:
- [ ] 하드코딩된 시크릿 없음 (API 키, 비밀번호, 토큰)
- [ ] 사용자 입력 검증됨
- [ ] SQL 인젝션 방지 (파라미터화된 쿼리)
- [ ] XSS 방지 (HTML 새니타이즈)
- [ ] CSRF 보호 활성화
- [ ] 인증/인가 확인
- [ ] 에러 메시지에 민감 정보 노출 없음

## 시크릿 관리

```typescript
// NEVER
const apiKey = "sk-proj-xxxxx"

// ALWAYS
const apiKey = process.env.OPENAI_API_KEY

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

## 보안 이슈 대응

보안 이슈 발견 시:
1. **즉시 중단**
2. CRITICAL 이슈 우선 수정
3. 노출된 시크릿 로테이션
4. 코드베이스 전체에 유사 이슈 검토

## /check 보안 앵글 참조

/check 커맨드의 5번째 앵글(Security)에서 아래를 검사:
- 인젝션 벡터 (SQL, 커맨드, HTML, URL)
- 하드코딩된 시크릿
- 인증/인가 갭
- 민감 데이터 노출 (로그, 에러 메시지, API 응답)
- CVE 있는 새 의존성
