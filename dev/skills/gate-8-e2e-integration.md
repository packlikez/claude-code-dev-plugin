---
name: gate-8-e2e-integration
description: Gate 8 exit criteria - E2E Integration with Real API FINAL (22 criteria)
---

# GATE 8: E2E Integration (Real API) - FINAL

## Criteria (22 total)

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
| 14 | **UI displays data matching DB state** | Assertions |
| 15 | **API response values verified in UI** | Code review |
| 16 | **No visibility-only assertions for data** | Grep |
| 17 | **End-to-end data flow proven** | Code review |
| 18 | All tests pass | Test run |
| 19 | 3x run stable | 3 runs |
| 20 | No flaky tests | Comparison |
| 21 | No skipped tests | Grep |
| 22 | Runtime <5 minutes | Timing |

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

## End-to-End Data Flow (CRITICAL)

**The test must prove: DB ↔ API ↔ UI are connected correctly**

### Complete Data Flow Verification

```
INPUT → API → DB → RESPONSE → UI

1. INPUT: User enters data → Assert form values
2. SUBMIT: Data sent → Assert request contains input
3. PERSIST: API saves → Assert DB matches input
4. RESPOND: API returns → Assert response matches DB
5. DISPLAY: UI shows → Assert UI matches DB

If ANY link breaks = feature BROKEN
Visibility-only tests miss links 2-5
```

### Required Assertion Pattern

```
// ❌ INSUFFICIENT - Only proves UI rendered something
expect(successMessage).toBeVisible();
expect(userCard).toExist();

// ✅ REQUIRED - Proves complete data flow
// 1. Capture input
const inputEmail = 'john@example.com';
const inputName = 'John Doe';

// 2. Perform action
await fillForm({ email: inputEmail, name: inputName });
await submit();

// 3. Verify DB received correct data
const dbRecord = await db.users.findOne({ email: inputEmail });
expect(dbRecord.name).toBe(inputName);

// 4. Verify UI displays DB data
expect(await page.textContent('[data-testid="user-name"]')).toBe(inputName);
expect(await page.textContent('[data-testid="user-email"]')).toBe(inputEmail);

// This proves: Input → API → DB → UI all connected
```

### Weak vs Strong Assertions

| Weak (BLOCKED) | Strong (REQUIRED) |
|----------------|-------------------|
| `element.isVisible()` | `element.hasText(expectedValue)` |
| `element.exists()` | `element.value === inputValue` |
| `list.length > 0` | `list[0].name === 'Expected Name'` |
| `response.ok` | `response.body.email === inputEmail` |
| `dbRecord !== null` | `dbRecord.field === expectedValue` |

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
grep -rn "page.route" tests/e2e-integration/
# Expected: no results

# Weak assertion scan (MUST be zero)
grep -rn "\.toBeVisible()" tests/e2e-integration/ | grep -v "toContainText\|textContent\|toBe("
grep -rEn "(toExist|toBeDefined)\(\)" tests/e2e-integration/
grep -rn "\.not\.toBeNull()" tests/e2e-integration/ | grep -v "\..*\."

# Check DB verification exists with specific values
grep -rn "findBy\|findById\|findOne" tests/e2e-integration/
grep -rn "\.toBe(\|\.toEqual(" tests/e2e-integration/ | grep -c "dbRecord\|dbUser"

# Check cleanup exists
grep -rn "beforeEach\|afterEach" tests/e2e-integration/

# Check backend health
curl http://localhost:3000/health

# Run 3x with timing
time (npx playwright test tests/e2e-integration/ && \
      npx playwright test tests/e2e-integration/ && \
      npx playwright test tests/e2e-integration/)
```

## Report Format

```
GATE 8 VALIDATION: E2E Integration (FINAL)
Feature: {name}

- Previous Gates: 7/7 passed
- Real API: No mocks
- DB Verification: OK
- UI/DB Match: Values verified
- Data Flow: End-to-end proven
- Test Cleanup: OK
- Auth Flow: OK
- Stability: 3/3 passed
- Runtime: {mm:ss} (<5:00)

RESULT: {PASS/FAIL}
Passed: {n}/22
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
