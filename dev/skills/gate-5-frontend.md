---
name: gate-5-frontend
description: Gate 5 exit criteria - Frontend Complete (30 criteria)
---

# GATE 5: Frontend Complete

## Criteria (30 total)

| # | Criterion | Check |
|---|-----------|-------|
| 1 | Context awareness | Spec + API + backend |
| 2 | Spec gap protocol | AskUserQuestion used |
| 3 | API contract loaded | File read |
| 4 | Types from contract | File exists |
| 5 | Pre-implementation checklist | File exists |
| 6 | All screens implemented | Compare to spec |
| 7 | Forms match backend validation | Code review |
| 8 | All error cases handled | Code review |
| 9 | Loading states (skeleton) | Code review |
| 10 | Empty states handled | Code review |
| 11 | Clean components (≤150 lines) | Code review |
| 12 | Fail fast in components | Early returns |
| 13 | Reusable hooks | No duplicate fetch |
| 14 | Accessibility (keyboard, ARIA) | Code review |
| 15 | Responsive (mobile-first) | Code review |
| 16 | UX best practices | Optimistic, confirm |
| 17 | Performance (lazy, memo) | Code review |
| 18 | Error boundaries | Implemented |
| 19 | Form protection (auto-save) | Code review |
| 20 | Focus management | Code review |
| 21 | Network status awareness | Code review |
| 22 | No native components | Use UI library |
| 23 | No duplicate components | Scanner |
| 24 | Reused existing | Code review |
| 25 | No console.log | Grep |
| 26 | **No empty event handlers** | Grep |
| 27 | **No empty functions** | Grep |
| 28 | **No TODO/FIXME** | Grep |
| 29 | **No mock/placeholder data** | Grep |
| 30 | Build passes | npm run build |

## Screen Verification (CRITICAL)

Before passing Gate 5, verify ALL screens from spec exist:

```bash
# 1. Extract screens from spec
grep -E "^###.*Screen|^###.*Page|/[a-z]" specs/{type}/{feature}.md

# 2. Check routes exist
grep -rn "path:" src/routes/ src/App.tsx

# 3. Compare: Every spec screen must have a route + component
```

**Example verification:**
| Spec Screen | Route | Component | Status |
|-------------|-------|-----------|--------|
| Projects List | /projects | ProjectsPage | ❌ MISSING |
| Kanban Board | /projects/:id/board | KanbanBoardPage | ✅ |

**If ANY screen missing → GATE FAILS**

## Validation Commands

```bash
# Check console.log
grep -rn "console\.log" src/components/{feature}/

# Check native components (BLOCKED)
grep -rn "confirm(\|alert(\|prompt(" src/components/
grep -rn "<select\|<input type=\"file\"\|<input type=\"date\"" src/components/

# Incomplete code detection (MUST be zero)
grep -rEn "on[A-Z].*=>[\s]*\{\}" src/          # Empty event handlers
grep -rEn "=> \{\}|\{[\s]*\}" src/              # Empty functions
grep -rEn "(TODO|FIXME|HACK)" src/              # Unfinished work
grep -rEn "(test@|fake|mock|dummy)" src/ | grep -v "\.test\.\|\.spec\."

# Check component sizes
wc -l src/components/{feature}/*.tsx

# Build
npm run build
```

## Report Format

```
GATE 5 VALIDATION: Frontend Complete
Feature: {name}

- Components: {n} implemented
- Screens: All from spec
- Largest: {file} ({n} lines)
- Empty handlers: 0
- Placeholder code: 0
- Native components: 0
- Build: PASS

RESULT: {PASS/FAIL}
Passed: {n}/30
```

## Next Step

PASS → Proceed to Step 6 (Frontend Unit Tests)
