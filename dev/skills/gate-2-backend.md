---
name: gate-2-backend
description: Gate 2 exit criteria - Backend Complete (21 criteria)
---

# GATE 2: Backend Complete

## Criteria (21 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | Spec loaded and understood | Checklist exists |
| 2 | Implementation traces to spec | Code review |
| 3 | Spec updated if gaps discovered | No undocumented behavior |
| 4 | Pre-implementation checklist | File exists |
| 5 | All endpoints implemented | Compare to spec |
| 6 | All validation rules implemented | Code review |
| 7 | All error responses match spec | Code review |
| 8 | Database migrations (if needed) | File exists |
| 9 | No TODO/FIXME comments | Grep |
| 10 | No duplicate code | Scanner |
| 11 | Follows project patterns | Compare to project.md |
| 12 | Small functions (≤30 lines) | Code review |
| 13 | Meaningful names | Code review |
| 14 | Fail fast (validations at top) | Code review |
| 15 | Max 3 levels nesting | Code review |
| 16 | Common logic extracted | Scanner |
| 17 | **No empty functions** | Grep |
| 18 | **No empty catch blocks** | Grep |
| 19 | **No console.log/debug** | Grep |
| 20 | **No mock/placeholder data** | Grep |
| 21 | Build passes | npm run build |

## Validation Commands

```bash
# Check for TODO/FIXME
grep -rn "TODO\|FIXME" src/

# Incomplete code detection (MUST be zero)
grep -rEn "=> \{\}|\{[\s]*\}" src/           # Empty functions
grep -rEn "catch.*\{[\s]*\}" src/            # Empty catch
grep -rEn "console\.(log|debug)" src/        # Debug code
grep -rEn "(test@|fake|mock|dummy)" src/ | grep -v "\.test\.\|\.spec\."

# Check build
npm run build
```

## Report Format

```
GATE 2 VALIDATION: Backend Complete
Feature: {name}

- Spec loaded: OK
- All endpoints implemented: OK
- Build passes: OK
...

RESULT: {PASS/FAIL}
Passed: {n}/17
```

## Next Step

PASS → Proceed to Step 3 (Backend Unit Tests)
