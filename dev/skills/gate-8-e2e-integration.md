---
name: gate-8-e2e-integration
description: Gate 8 exit criteria - E2E Integration with Real API FINAL (18 criteria)
---

# GATE 8: E2E Integration (Real API) - FINAL

## Criteria (18 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | All 7 previous gates passed | Progress check |
| 2 | No mocked API calls | Grep for page.route |
| 3 | Backend running | Health check |
| 4 | Database accessible | Connection test |
| 5 | data-testid first | Code review |
| 6 | No CSS/XPath selectors | Grep |
| 7 | Every AC tested | Map to spec |
| 8 | Every edge case tested | Map to spec |
| 9 | DB state verified after mutations | Assertions |
| 10 | Test data cleanup (before/after) | Code review |
| 11 | Auth flow works (real tokens) | Test exists |
| 12 | Happy path complete | Test exists |
| 13 | Error recovery works | Test exists |
| 14 | All tests pass | Test run |
| 15 | 3x run stable | 3 runs |
| 16 | No flaky tests | Comparison |
| 17 | No skipped tests | Grep |
| 18 | Runtime <5 minutes | Timing |

## No Mocking Allowed

```typescript
// ❌ BLOCKED in integration tests
await page.route('**/api/*', ...);

// ✅ REQUIRED: Real API calls
// (no route interception)
```

## Database Verification Pattern

```typescript
// ✅ CORRECT: Verify DB state after mutation
test('creates user in database', async ({ page, request }) => {
  // UI action
  await page.fill('[data-testid="email"]', 'test@test.com');
  await page.click('[data-testid="submit"]');

  // Wait for API response
  await page.waitForResponse('**/api/users');

  // Verify in database
  const dbUser = await db.users.findOne({ email: 'test@test.com' });
  expect(dbUser).toBeDefined();
  expect(dbUser.email).toBe('test@test.com');
});
```

## Test Isolation Pattern

```typescript
// ✅ CORRECT: Clean up test data
test.beforeEach(async () => {
  await db.users.deleteMany({ email: /@test\.com$/ });
});

test.afterEach(async () => {
  await db.users.deleteMany({ email: /@test\.com$/ });
});
```

## Validation Commands

```bash
# Check NO mocked routes (should return nothing)
grep -n "page.route" tests/e2e-integration/
# Expected: no results

# Check DB verification exists
grep -n "findBy\|findById\|findOne" tests/e2e-integration/

# Check cleanup exists
grep -n "beforeEach\|afterEach" tests/e2e-integration/

# Check backend health
curl http://localhost:3000/health

# Run 3x with timing
time (npx playwright test tests/e2e-integration/ && \
      npx playwright test tests/e2e-integration/ && \
      npx playwright test tests/e2e-integration/)
```

## Report Format

```
┌────────────────────────────────────────────────┐
│ GATE 8 VALIDATION: E2E Integration (FINAL)     │
├────────────────────────────────────────────────┤
│ Feature: {name}                                │
│                                                │
│ Previous Gates: 7/7 passed ✓                   │
│ Real API: No mocks ✓                           │
│ DB Verification: ✓                             │
│ Test Cleanup: ✓                                │
│ Auth Flow: ✓                                   │
│ Stability: 3/3 passed                          │
│ Runtime: {mm:ss} (<5:00)                       │
│                                                │
│ RESULT: {PASS/FAIL}                            │
│ Passed: {n}/18                                 │
└────────────────────────────────────────────────┘
```

## Completion

When GATE 8 passes:

```markdown
## {feature-name}
- [x] Step 1: Spec (GATE 1 ✓)
- [x] Step 2: Backend (GATE 2 ✓)
- [x] Step 3: Backend Unit Tests (GATE 3 ✓)
- [x] Step 4: API Tests (GATE 4 ✓)
- [x] Step 5: Frontend (GATE 5 ✓)
- [x] Step 6: Frontend Unit Tests (GATE 6 ✓)
- [x] Step 7: E2E Tests (GATE 7 ✓)
- [x] Step 8: E2E Integration (GATE 8 ✓)

STATUS: ✅ FEATURE COMPLETE
```

Feature ready for: code review → merge → deploy
