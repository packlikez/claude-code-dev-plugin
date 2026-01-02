---
name: dev:ensure
description: "Ensure a feature/module/component is complete - runs all relevant gates"
argument-hint: "<target> (feature name, module, or 'all')"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
---

# Ensure Complete

Verify that a feature, module, or component is fully complete by running all relevant gates.

## Usage

```bash
/dev:ensure user-registration    # Check specific feature
/dev:ensure src/components/Auth  # Check specific module
/dev:ensure all                  # Check entire project
```

## Process

### 1. Identify Target Type

```bash
# Feature (has spec)
ls specs/*/{target}*.md

# Module (directory)
ls -d src/*/{target}* 2>/dev/null

# Component (file)
ls src/**/{target}*.tsx 2>/dev/null
```

### 2. For Feature: Run All Gates

If target is a feature with spec:

| Gate | Check | Command |
|------|-------|---------|
| G1 | Spec complete | Validate spec-convention |
| G2 | Backend complete | Check implementation exists |
| G3 | Backend unit tests | Run tests |
| G4 | API tests | Run tests |
| G5 | Frontend complete | Check all screens |
| G6 | Frontend unit tests | Run tests |
| G7 | E2E tests | Run tests |
| G8 | E2E Integration | Run tests |

```bash
# Quick validation
npm run test -- --grep "{feature}"
npm run build
```

### 3. For Module: Check Completeness

| Check | Command |
|-------|---------|
| Has tests | `ls tests/**/{module}*` |
| Tests pass | `npm test -- {module}` |
| No TODOs | `grep -r "TODO\|FIXME" {module}/` |
| Build passes | `npm run build` |
| No unused exports | `npx ts-unused-exports` |

### 4. For All: Project Health

Run full project validation:

```bash
# All tests pass
npm test

# Build passes
npm run build

# No TODOs in src
grep -rn "TODO\|FIXME" src/

# Coverage check
npm run test:coverage
```

## Output Report

```
ENSURE: {target}
Type: Feature / Module / Component

- Spec: Complete
- Backend: Implemented
- Frontend: All screens
- Unit Tests: 45/45 passing
- API Tests: 12/12 passing
- E2E Tests: 8/8 passing
- Build: Passes
- TODOs: None

STATUS: COMPLETE
```

## On Failure

If any check fails:
1. Report which gate/check failed
2. Show specific errors
3. Recommend next action

```
E2E Tests: FAILED 6/8 passing

FAILED: tests/e2e/login.spec.ts
- "should redirect after login" timeout

ACTION: Run /dev:e2e user-registration
```
