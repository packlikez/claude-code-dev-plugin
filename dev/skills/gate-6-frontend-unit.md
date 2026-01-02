---
name: gate-6-frontend-unit
description: Gate 6 exit criteria - Frontend Unit Tests (24 criteria)
---

# GATE 6: Frontend Unit Tests

## Criteria (24 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | Context awareness | Spec + frontend + API |
| 2 | Tests trace to spec | Every AC tested |
| 3 | Spec updated if gaps | No undocumented |
| 4 | No lazy testing | Code review |
| 5 | Clean tests (AAA) | Code review |
| 6 | Reusable (fixtures) | Code review |
| 7 | Reliable (mocked) | Code review |
| 8 | Line coverage ≥80% | Report |
| 9 | Branch coverage ≥70% | Report |
| 10 | All components tested | File comparison |
| 11 | All hooks tested | File comparison |
| 12 | Default render tested | Code review |
| 13 | Loading state tested | Code review |
| 14 | Error state tested | Code review |
| 15 | Empty state tested | Code review |
| 16 | Interactions with exact assertions | Code review |
| 17 | Keyboard navigation tested | Code review |
| 18 | Screen reader tested | Code review |
| 19 | jest-axe passes | Test output |
| 20 | Zero weak assertions | Grep |
| 21 | No console errors | Test output |
| 22 | All tests pass | Test run |
| 23 | No skipped tests | Grep |
| 24 | 3x run stable | 3 runs |

## Validation Commands

```bash
# Run tests with coverage
npm test -- --coverage

# Weak assertion scan
grep -n "\.toBeDefined()" tests/unit/components/
grep -n "\.toBeInTheDocument()$" tests/unit/components/
grep -n "\.toHaveBeenCalled()" tests/unit/components/ | grep -v "CalledWith"

# Check accessibility tests exist
grep -n "axe\|toHaveNoViolations" tests/unit/components/

# Check keyboard tests exist
grep -n "userEvent.tab\|toHaveFocus" tests/unit/components/

# Run 3x
npm test && npm test && npm test
```

## Report Format

```
GATE 6 VALIDATION: Frontend Unit Tests
Feature: {name}

Coverage:
- Line: {n}% (>=80%)
- Branch: {n}% (>=70%)

- Accessibility: axe OK, keyboard OK
- Weak Assertions: 0
- Stability: 3/3 passed

RESULT: {PASS/FAIL}
Passed: {n}/24
```

## Next Step

PASS → Proceed to Step 7 (UI Tests)
