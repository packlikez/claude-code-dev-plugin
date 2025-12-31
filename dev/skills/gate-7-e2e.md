---
name: gate-7-e2e
description: Gate 7 exit criteria - E2E Tests with Mocked API (16 criteria)
---

# GATE 7: E2E Tests (Mocked API)

## Criteria (16 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | All API calls mocked | No real network calls |
| 2 | Mock responses match api-contract | Schema validation |
| 3 | data-testid first | Code review |
| 4 | id second | Code review |
| 5 | No CSS selectors | Grep |
| 6 | No XPath | Grep |
| 7 | Every AC tested | Map to spec |
| 8 | Every edge case tested | Map to spec |
| 9 | Happy path complete | Test exists |
| 10 | Error responses mocked (400,401,403,404,500) | Code review |
| 11 | Loading states tested | Test exists |
| 12 | Error recovery UI works | Test exists |
| 13 | All tests pass | Test run |
| 14 | 3x run stable | 3 runs |
| 15 | No flaky tests | Comparison |
| 16 | No skipped tests | Grep |

## API Mocking Pattern

```typescript
// ✅ CORRECT: Mock based on api-contract
await page.route('**/api/users', route => {
  route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify({
      id: '123',
      email: 'test@example.com',
      name: 'Test User'
    })
  });
});

// ✅ CORRECT: Mock error response
await page.route('**/api/users', route => {
  route.fulfill({
    status: 401,
    body: JSON.stringify({ error: 'Unauthorized' })
  });
});

// ❌ BLOCKED: Real API calls
// (no route interception = test hits real API)
```

## Element Selection Priority

```typescript
// ✅ PRIORITY 1: data-testid
await page.locator('[data-testid="submit-button"]').click();

// ✅ PRIORITY 2: id
await page.locator('#submit-button').click();

// ❌ BLOCKED: text, CSS, XPath
```

## Validation Commands

```bash
# Check for CSS selectors (BLOCKED)
grep -n "locator('\." tests/e2e/

# Check all routes are mocked
grep -n "page.route" tests/e2e/

# Verify no real API calls (should have route for all endpoints)
# Compare routes to api-contract endpoints

# Run 3x
npx playwright test tests/e2e/ --repeat-each=3
```

## Report Format

```
┌────────────────────────────────────────────────┐
│ GATE 7 VALIDATION: E2E Tests (Mocked API)      │
├────────────────────────────────────────────────┤
│ Feature: {name}                                │
│                                                │
│ API Mocking: All endpoints mocked ✓            │
│ Acceptance Criteria: {n}/{total} tested        │
│ Edge Cases: {n}/{total} tested                 │
│ Error Responses: 5/5 mocked                    │
│ Stability: 3/3 passed                          │
│                                                │
│ RESULT: {PASS/FAIL}                            │
│ Passed: {n}/16                                 │
└────────────────────────────────────────────────┘
```
