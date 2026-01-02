---
name: gate-7-e2e
description: Gate 7 exit criteria - E2E Tests with Mocked API (20 criteria)
---

# GATE 7: E2E Tests (Mocked API)

## Criteria (20 total)

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
| 13 | **Data assertions verify actual values** | Code review |
| 14 | **No visibility-only assertions for data elements** | Grep |
| 15 | **Input → Output verified (form data appears in result)** | Code review |
| 16 | **Mock data values asserted in UI** | Code review |
| 17 | All tests pass | Test run |
| 18 | 3x run stable | 3 runs |
| 19 | No flaky tests | Comparison |
| 20 | No skipped tests | Grep |

## Data Verification (CRITICAL)

**Passing tests ≠ Working feature**

Tests must verify DATA FLOWS correctly, not just that elements exist.

### Assertion Hierarchy

| Level | What It Proves | Example |
|-------|----------------|---------|
| 1. Exists | Element rendered | `element.exists()` |
| 2. Visible | Element displayed | `element.isVisible()` |
| 3. **Has Content** | **Data flows to UI** | `element.hasText('John')` |
| 4. **Has Exact Value** | **Correct data displayed** | `element.value === 'john@test.com'` |

**Minimum acceptable: Level 3 (Has Content) for all data elements**

### Blocked Patterns (Weak Assertions)

```
❌ BLOCKED - Proves nothing about data flow:

// Element exists but could show "undefined", empty, or wrong data
expect(element).toExist()
expect(element).toBeVisible()
expect(element).toBeDefined()
expect(element).not.toBeNull()
expect(list.length).toBeGreaterThan(0)  // Items exist but content unknown
```

### Required Patterns (Strong Assertions)

```
✅ REQUIRED - Proves data flows correctly:

// Assert specific values that came from input/API
expect(element).toHaveText('John Doe')           // Name from form
expect(element).toContainText('john@test.com')   // Email from input
expect(element).toHaveValue('2024-01-15')        // Date that was set
expect(items[0].name).toBe('Project Alpha')      // Specific data

// Assert computed/transformed values
expect(totalElement).toHaveText('$150.00')       // Calculated from items
expect(statusElement).toHaveText('Active')       // Derived from state
```

### Data Flow Verification Pattern

```
INPUT → PROCESS → OUTPUT (all three must connect)

1. User enters: "John Doe" in name field
2. Submits form
3. Assert: Success message shows "John Doe" (not just "Success!")
4. Assert: List now contains "John Doe" (not just "1 item")

If step 3-4 only check visibility, the test passes even when:
- API endpoint is wrong (404)
- Auth header missing (401)
- Data transformation broken (undefined)
- Response not parsed correctly (empty)
```

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
grep -rn "locator('\." tests/e2e/

# Check all routes are mocked
grep -rn "page.route" tests/e2e/

# Weak assertion scan (MUST be zero for data elements)
grep -rn "\.toBeVisible()" tests/e2e/ | grep -v "toContainText\|toHaveText\|toHaveValue"
grep -rEn "(toExist|toBeDefined)\(\)" tests/e2e/
grep -rn "toBeGreaterThan(0)" tests/e2e/

# Verify input values appear in assertions
# Search for form fill, then check assertion uses same value

# Run 3x
npx playwright test tests/e2e/ --repeat-each=3
```

## Report Format

```
GATE 7 VALIDATION: E2E Tests (Mocked API)
Feature: {name}

- API Mocking: All endpoints mocked
- Acceptance Criteria: {n}/{total} tested
- Edge Cases: {n}/{total} tested
- Error Responses: 5/5 mocked
- Data Assertions: Strong (values verified)
- Input/Output Flow: Verified
- Stability: 3/3 passed

RESULT: {PASS/FAIL}
Passed: {n}/20
```
