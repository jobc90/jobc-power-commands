# Security Checklist

> Verify before every commit. Halt immediately on security issues.

## Mandatory Security Checks

Before committing:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (HTML sanitized)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Error messages do not expose sensitive information

## Secret Management

```typescript
// NEVER
const apiKey = "sk-proj-xxxxx"

// ALWAYS
const apiKey = process.env.OPENAI_API_KEY

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

## Security Issue Response

When a security issue is found:
1. **Halt immediately**
2. Fix CRITICAL issues first
3. Rotate any exposed secrets
4. Review the entire codebase for similar issues

## /check Security Angle Reference

The 5th angle (Security) of the /check command inspects:
- Injection vectors (SQL, command, HTML, URL)
- Hardcoded secrets
- Authentication/authorization gaps
- Sensitive data exposure (logs, error messages, API responses)
- New dependencies with known CVEs
