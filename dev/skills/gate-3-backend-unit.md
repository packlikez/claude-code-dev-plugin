---
name: gate-3-backend-unit
description: Gate 3 exit criteria - Backend Unit Tests (20 criteria)
---

# GATE 3: Backend Unit Tests

## Criteria (20 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | Spec loaded and understood | Checklist exists |
| 2 | Tests trace to spec | Every AC has test |
| 3 | Spec updated if gaps | No undocumented tests |
| 4 | No lazy testing patterns | Code review |
| 5 | Clean tests (AAA, descriptive) | Code review |
| 6 | Reusable (fixtures, factories) | Code review |
| 7 | Reliable (mocked dates, random) | Code review |
| 8 | Line coverage ≥80% | Coverage report |
| 9 | Branch coverage ≥70% | Coverage report |
| 10 | All public functions tested | File comparison |
| 11 | Happy path tests | Code review |
| 12 | Empty input tests | Grep |
| 13 | Null/undefined tests | Grep |
| 14 | Boundary value tests | Grep |
| 15 | Error condition tests | Grep |
| 16 | Zero weak assertions | Grep patterns |
| 17 | No console.log in tests | Grep |
| 18 | All tests pass | Test run |
| 19 | No skipped tests | Grep |
| 20 | 3x run stable | 3 runs |

## Validation Commands

```bash
# Run tests with coverage
npm test -- --coverage

# Weak assertion scan (MUST be zero)
grep -n "\.toBeDefined()" tests/unit/
grep -n "\.toBeTruthy()" tests/unit/
grep -n "\.not\.toBeNull()" tests/unit/
grep -n "\.toHaveBeenCalled()" tests/unit/ | grep -v "CalledWith"

# Check for console.log
grep -n "console\.log" tests/unit/

# Check for skipped tests
grep -n "\.skip\|\.only\|xit\|xdescribe" tests/unit/

# Run 3x for stability
npm test && npm test && npm test
```

## Report Format

```
GATE 3 VALIDATION: Backend Unit Tests
Feature: {name}

Coverage:
- Line: {n}% (>=80%)
- Branch: {n}% (>=70%)

- Weak Assertions: {n} found
- Stability: 3/3 passed

RESULT: {PASS/FAIL}
Passed: {n}/20
```

## Next Step

PASS → Proceed to Step 4 (API Integration Tests)
