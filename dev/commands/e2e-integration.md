---
name: dev:e2e-integration
description: "Step 8: E2E Integration with real API - FINAL VALIDATION"
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

# Step 8: E2E Integration Tests (Real API) - FINAL GATE

## Prerequisites

```
□ GATE 7 PASSED (E2E with mocked API complete)
□ Backend running
□ Database accessible
□ All previous gates passed (1-7)
```

## Why Real API?

- **True integration**: Verify frontend ↔ backend ↔ database work together
- **Data persistence**: Confirm data saves correctly
- **Auth flow**: Real tokens, sessions, permissions
- **Final validation**: Catch integration bugs before production

## Process

### 1. Load Context (FINAL REVIEW)

```bash
cat specs/{type}/{feature-name}.md           # Spec (source of truth)
cat api-contracts/{feature}.yaml             # API contract
cat tests/e2e/{feature}/*.spec.ts            # E2E tests (mocked)
cat skills/gate-8-e2e-integration.md         # Gate 8 criteria
```

### 2. Environment Setup

```bash
# Ensure backend is running
curl http://localhost:3000/health

# Ensure database is accessible
# Run migrations if needed
npm run db:migrate

# Seed test data if needed
npm run db:seed:test
```

### 3. Convert Mocked Tests to Integration

| E2E Test (Mocked) | Integration Version |
|-------------------|---------------------|
| tests/e2e/login.spec.ts | tests/e2e-integration/login.spec.ts |
| Remove: page.route() | Use: real API calls |
| Add: DB verification | Add: cleanup |

### 4. Delegate to Test Writer

Use Task tool with `test-writer` agent:
```
Write E2E Integration tests for {feature-name}:
- Copy from tests/e2e/ as base
- Remove ALL route mocks (use real API)
- Add database state verification
- Add test data cleanup (beforeEach/afterEach)
- Add auth token handling if needed
- Verify data persists correctly
```

### 5. Key Requirements

**Real Integration:**
- No mocked API calls
- Real database operations
- Real auth tokens
- Real file uploads (if applicable)

**Database Verification:**
```typescript
// After mutation, verify DB state
const res = await request.post('/api/users').send(data);
const dbUser = await db.users.findById(res.body.id);
expect(dbUser.email).toBe(data.email);
```

**Test Isolation:**
```typescript
beforeEach(async () => {
  await db.users.deleteMany({ email: /@test\.com$/ });
});

afterEach(async () => {
  await db.users.deleteMany({ email: /@test\.com$/ });
});
```

**Stability:**
- Run 3x → all pass
- No flaky tests
- Handle race conditions
- Total runtime < 5 minutes

### 6. Validate Gate (FINAL)

Use Task tool with `gate-keeper` agent:
```
Validate GATE 8 for {feature-name}
```

See `gate-8-e2e-integration` skill for all criteria.

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

## Output

- Integration tests: `tests/e2e-integration/{feature}/`
- Final validation report
- Progress update: COMPLETE
