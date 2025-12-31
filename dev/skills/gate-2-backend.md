---
name: gate-2-backend
description: Gate 2 exit criteria - Backend Complete (17 criteria)
---

# GATE 2: Backend Complete

## Criteria (17 total)

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
| 17 | Build passes | npm run build |

## Validation Commands

```bash
# Check for TODO/FIXME
grep -rn "TODO\|FIXME" src/

# Check build
npm run build

# Check function lengths
# Manual review for functions >30 lines
```

## Report Format

```
┌────────────────────────────────────────────────┐
│ GATE 2 VALIDATION: Backend Complete            │
├────────────────────────────────────────────────┤
│ Feature: {name}                                │
│                                                │
│ ✓ Spec loaded                                  │
│ ✓ All endpoints implemented                   │
│ ✓ Build passes                                 │
│ ...                                            │
│                                                │
│ RESULT: {PASS/FAIL}                            │
│ Passed: {n}/17                                 │
└────────────────────────────────────────────────┘
```

## Next Step

PASS → Proceed to Step 3 (Backend Unit Tests)
