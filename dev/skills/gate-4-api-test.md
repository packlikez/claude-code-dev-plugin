---
name: gate-4-api-test
description: Gate 4 exit criteria - API Integration Tests (26 criteria)
---

# GATE 4: API Integration Tests

## Criteria (26 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | Context awareness | Spec + impl + unit reviewed |
| 2 | Tests trace to spec | Every endpoint tested |
| 3 | Spec updated if gaps | No undocumented |
| 4 | Real database used | No jest.mock for DB |
| 5 | Real services used | No jest.mock |
| 6 | Seed data matches spec | Data model check |
| 7 | Each test isolated seed | No shared beforeAll |
| 8 | Concurrent execution support | No dependencies |
| 9 | Every endpoint tested | Compare to spec |
| 10 | Success response tested | Code review |
| 11 | Response body exact | Assertions |
| 12 | No extra fields leaked | Object.keys check |
| 13 | 400 validation tested | Test exists |
| 14 | 401 unauthorized tested | Test exists |
| 15 | 403 forbidden tested | Test exists |
| 16 | 404 not found tested | Test exists |
| 17 | 409 conflict tested | Test exists |
| 18 | Auth edge cases tested | Expired/malformed |
| 19 | Pagination tested | Test exists |
| 20 | Response time assertions | Threshold check |
| 21 | Idempotency tested | Duplicate request |
| 22 | Backward compatibility | Required fields |
| 23 | Database state verified | Assertions |
| 24 | API contract generated | File exists |
| 25 | All tests pass | Test run |
| 26 | 3x run stable | 3 runs |

## Validation Commands

```bash
# Check for mocked database (NOT ALLOWED)
grep -n "jest\.mock.*db\|mock.*Database" tests/integration/

# Check for shared state (NOT ALLOWED)
grep -n "beforeAll.*seed\|beforeAll.*create" tests/integration/

# Check API contract exists
ls api-contracts/{feature}.yaml

# Run tests 3x
npm run test:integration && npm run test:integration && npm run test:integration
```

## Report Format

```
GATE 4 VALIDATION: API Integration Tests
Feature: {name}

- Endpoints: {n}/{total} tested
- Error codes: 400, 401, 403, 404, 409 all tested
- DB verification: OK
- API contract: api-contracts/{feature}.yaml

RESULT: {PASS/FAIL}
Passed: {n}/26
```

## Next Step

PASS → Proceed to Step 5 (Frontend Implementation)
