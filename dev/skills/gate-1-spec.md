---
name: gate-1-spec
description: Gate 1 exit criteria - Spec Complete (18 criteria)
---

# GATE 1: Spec Complete

## Criteria (18 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | User Story (As a/I want/So that) | Manual |
| 2 | Acceptance Criteria ≥3 | Count |
| 3 | All AC in GIVEN/WHEN/THEN | Pattern |
| 4 | Tech stack confirmed | AskUserQuestion |
| 5 | Library versions verified (latest) | npm view |
| 6 | Code structure confirmed | AskUserQuestion |
| 7 | Coding principles documented | Section exists |
| 8 | API Contract with endpoints | Section exists |
| 9 | All success responses | Check each |
| 10 | All error responses (400,401,403,404,409,500) | Check each |
| 11 | Data Model with constraints (3NF) | Section exists |
| 12 | Edge Cases ≥5 | Count |
| 13 | Related Features section | Section exists |
| 14 | Shared Resources section | Section exists |
| 15 | No conflicts with existing specs | Cross-check |
| 16 | Out of Scope section | Section exists |
| 17 | Each criterion testable | Manual |
| 18 | No ambiguous words | Grep |

## Validation Commands

```bash
# Check existing specs for conflicts
ls specs/features/ specs/api/
grep -r "{feature-keyword}" specs/

# Check for ambiguous words
grep -i "should\|might\|maybe\|probably" specs/{feature}.md
```

## Report Format

```
GATE 1 VALIDATION: Spec Complete
Feature: {name}

- User Story present: OK
- Acceptance Criteria: {n} (>=3)
- All in GIVEN/WHEN/THEN format: OK
...

RESULT: {PASS/FAIL}
Passed: {n}/18
```

## Next Step

PASS → Proceed to Step 2 (Backend Implementation)
