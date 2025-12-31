---
name: dev:backend-unit
description: "Step 3: Backend unit tests - requires GATE 2 passed"
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

# Step 3: Backend Unit Tests

## Prerequisites

```
□ GATE 2 PASSED (backend implementation complete)
□ Spec exists: specs/{type}/{feature-name}.md
```

## Process

### 1. Load Context

```bash
cat specs/{type}/{feature-name}.md     # Spec (source of truth)
cat src/services/{feature}Service.ts   # Implementation
cat skills/test-patterns-unit.md       # Unit test patterns
cat skills/gate-3-backend-unit.md      # Gate 3 criteria
```

### 2. Create Test Checklist from Spec

| From Spec | Tests to Write |
|-----------|----------------|
| Acceptance Criteria | Each GIVEN/WHEN/THEN becomes test |
| Validation Rules | Test pass and fail cases |
| Edge Cases | Test EVERY edge case in spec |
| Error Responses | Test EVERY error from spec |

### 3. Delegate to Test Writer

Use Task tool with `test-writer` agent:
```
Write backend unit tests for {feature-name}:
- Every acceptance criterion
- Every edge case from spec
- Every error response from spec
- Follow test-patterns-unit skill
```

### 4. Key Requirements

From `test-patterns-unit` skill:
- Strong assertions only (no toBeDefined alone)
- AAA pattern (Arrange-Act-Assert)
- Fixtures and factories
- Mock dates and random values
- ZERO weak assertions

From spec:
- Every public function tested
- Every edge case tested
- Every error condition tested

### 5. Spec Gap Protocol

If gaps discovered during testing:
```
Use AskUserQuestion:
"Found gap in spec: {issue}
Options:
1. Update spec to {A}
2. Update spec to {B}"
```

Update spec first, then write tests.

### 6. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 3 for {feature-name}
```

See `gate-3-backend-unit` skill for all 20 criteria.

## Output

- Test files: `tests/unit/services/`
- Fixtures: `tests/fixtures/`
- Coverage report
