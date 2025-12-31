---
name: dev:e2e
description: "Step 7: E2E tests with mocked API - requires GATE 6 passed"
argument-hint: "<feature-name>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

# Step 7: E2E Tests (Mocked API)

## Prerequisites

```
□ GATE 6 PASSED (Frontend unit tests complete)
□ All frontend unit tests passing
□ API contract defined: api-contracts/{feature}.yaml
```

## Why Mocked API?

- **Fast**: No DB setup, no network latency
- **Stable**: No external dependencies, no flakiness
- **Edge cases**: Easy to simulate errors, timeouts, edge responses
- **Parallel**: Tests run independently

## Process

### 1. Load Context

```bash
cat specs/{type}/{feature-name}.md           # Spec (source of truth)
cat api-contracts/{feature}.yaml             # API contract for mocking
cat skills/test-patterns-ui.md               # UI/E2E test patterns
cat skills/ux-patterns.md                    # UX patterns
cat skills/gate-7-e2e.md                     # Gate 7 criteria
```

### 2. Setup API Mocks

```typescript
// Mock API responses based on api-contract
await page.route('**/api/users', route => {
  route.fulfill({
    status: 200,
    body: JSON.stringify({ id: '1', name: 'Test User' })
  });
});
```

### 3. Map User Journeys

| Journey | Mocked Responses | Status |
|---------|------------------|--------|
| Happy path login | 200 + user data | □ |
| Invalid credentials | 401 + error | □ |
| Server error | 500 + retry | □ |

### 4. Delegate to Test Writer

Use Task tool with `test-writer` agent:
```
Write E2E tests (mocked API) for {feature-name}:
- Mock all API calls based on api-contract
- Complete user journeys (UI only)
- Use data-testid for element selection
- Every acceptance criterion from spec
- Every edge case (mock error responses)
- Follow test-patterns-ui skill
- Follow ux-patterns skill
```

### 5. Key Requirements

**API Mocking:**
- All API calls mocked via route interception
- Response shapes match api-contract exactly
- Error responses for all error codes (400, 401, 403, 404, 500)

**Element Selection:**
- data-testid first priority
- id second priority
- No CSS/XPath selectors

**Coverage:**
- Every AC from spec
- Every edge case
- Loading states
- Error states + recovery

**Stability:**
- Run 3x → all pass
- No flaky tests
- Fast execution (mocked = fast)

### 6. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 7 for {feature-name}
```

See `gate-7-e2e` skill for all criteria.

## Output

- E2E tests: `tests/e2e/{feature}/`
- All API mocked, no real backend needed
