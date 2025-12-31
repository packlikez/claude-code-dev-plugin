---
name: dev:api-test
description: "Step 4: API integration tests - requires GATE 3 passed"
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

# Step 4: API Integration Tests

## Prerequisites

```
□ GATE 3 PASSED (backend unit tests complete)
□ All unit tests passing with ≥80% coverage
```

## Process

### 1. Load Context

```bash
cat specs/{type}/{feature-name}.md           # Spec (source of truth)
cat src/routes/{feature}.ts                  # Route implementation
cat tests/unit/services/{feature}*.test.ts   # Unit tests (what's tested)
cat skills/test-patterns-api.md              # API test patterns
cat skills/gate-4-api-test.md                # Gate 4 criteria
```

### 2. Build Context Map

```markdown
## What Unit Tests Cover
- Service layer logic
- Validation rules (mocked DB)

## What API Tests Must Cover
- Full HTTP request/response cycle
- Real database (no mocks)
- Auth middleware integration
- Response format matches spec
- Database state after mutations
```

### 3. Delegate to Test Writer

Use Task tool with `test-writer` agent:
```
Write API integration tests for {feature-name}:
- Real database (no mocks)
- Every endpoint from spec
- Every error response from spec
- Isolated seed data per test
- Follow test-patterns-api skill
```

### 4. Key Requirements

**Real Infrastructure (no mocks):**
- Real database (test DB)
- Real services
- Real auth middleware
- Only mock external APIs

**Per Endpoint:**
- Success response (200/201)
- Validation error (400)
- Unauthorized (401)
- Forbidden (403) if roles
- Not found (404)
- Conflict (409) if unique

**Database Verification:**
- Check state after mutations
- Verify rollback on errors

### 5. Spec Gap Protocol

If response doesn't match spec:
```
Use AskUserQuestion:
"API response doesn't match spec:
Spec says: {expected}
API returns: {actual}
Options:
1. Fix implementation
2. Update spec"
```

### 6. Generate API Contract

Load `api-contract` skill for format:
```bash
cat skills/api-contract.md
```

After tests pass, generate contract following the skill format.

### 7. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 4 for {feature-name}
```

See `gate-4-api-test` skill for all 26 criteria.

## Output

- Tests: `tests/integration/api/`
- Seeds: `tests/seeds/`
- Contract: `api-contracts/{feature}.yaml`
