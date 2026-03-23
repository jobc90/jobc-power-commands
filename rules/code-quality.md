# Code Quality Principles

> Core principles for clean, maintainable code.

## 1. Immutability (CRITICAL)

Never mutate objects. Always create new ones:

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

Exception only after profiling proves a performance issue.

## 2. Small Files, Small Functions

- File: 800 lines max (review for splitting at 400+)
- Function: 50 lines max
- Nesting: 4 levels max
- Split when exceeded

## 3. Error Handling

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('Detailed user-friendly message')
}
```

## 4. Validate at System Boundaries

Trust internal code, but always validate user input and external API responses:

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## 5. Surgical Changes

Change only what was requested. Every changed line must trace directly to the user's request.

- Do not "improve" adjacent code, comments, or formatting
- Match existing style (even if you would do it differently)
- Unrelated dead code: mention it, do not delete it
- Clean up only orphans (unused imports, etc.) created by your own changes

## 6. Conclusion First, Reasoning Second

Lead with the conclusion in the first sentence. Add "because..." after.

## 7. Evidence-Based Completion

"It should work" is not evidence. Before claiming completion:
1. Test results (pass/fail count, coverage)
2. Build success confirmed
3. Requirements checklist verified against evidence

Banned: "No issues expected", "Should work fine"
Required: "12 tests passed", "Build success (0 errors)"

## 8. Plan Before Changing 3+ Files

If 3 or more files are expected to change, create a plan before implementing.
Exception: 1-2 files, typo/bug patches.

## Code Quality Checklist

Verify before completion:
- [ ] Readable and well-named
- [ ] Functions under 50 lines
- [ ] Files under 800 lines
- [ ] No deep nesting (4 levels or fewer)
- [ ] Proper error handling
- [ ] No console.log statements
- [ ] No hardcoded values
- [ ] No mutation (immutable patterns used)
