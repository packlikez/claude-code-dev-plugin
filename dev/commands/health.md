---
name: dev:health
description: "Project health dashboard - overall status, coverage, issues"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
---

# Project Health Dashboard

Comprehensive view of project health across all dimensions.

## Process

### 1. Test Health

```bash
# Run all tests with coverage
npm run test:coverage 2>&1 | tail -20

# Count passing/failing
npm test 2>&1 | grep -E "Tests:.*passed|failed"
```

| Metric | Value | Status |
|--------|-------|--------|
| Unit Tests | ?/? passing | ? |
| API Tests | ?/? passing | ? |
| E2E Tests | ?/? passing | ? |
| Coverage | ?% | ? |

### 2. Code Quality

```bash
# TODOs and FIXMEs
grep -rn "TODO\|FIXME" src/ | wc -l

# Console.logs
grep -rn "console\.log" src/ | wc -l

# Type errors
npx tsc --noEmit 2>&1 | grep -c "error"

# Lint errors
npm run lint 2>&1 | grep -c "error"
```

| Metric | Count | Status |
|--------|-------|--------|
| TODOs/FIXMEs | ? | ? |
| Console.logs | ? | ? |
| Type errors | ? | ? |
| Lint errors | ? | ? |

### 3. Feature Progress

```bash
# Count specs
ls specs/**/*.md 2>/dev/null | wc -l

# Check .claude/progress.md
cat .claude/progress.md 2>/dev/null
```

| Feature | G1 | G2 | G3 | G4 | G5 | G6 | G7 | G8 |
|---------|----|----|----|----|----|----|----|----|
| {name} | ✓ | ✓ | ✓ | ? | ? | ? | ? | ? |

### 4. Dependency Health

```bash
# Outdated packages
npm outdated 2>/dev/null | head -10

# Security vulnerabilities
npm audit 2>/dev/null | grep -E "vulnerabilities|found"

# Unused dependencies
npx depcheck 2>/dev/null | head -10
```

| Metric | Count | Status |
|--------|-------|--------|
| Outdated packages | ? | ? |
| Security issues | ? | ? |
| Unused deps | ? | ? |

### 5. Learnings & Issues

```bash
# Recent learnings
ls .claude/learnings/*.md 2>/dev/null | wc -l

# Unresolved issues
grep -l "Status: Open" .claude/learnings/*.md 2>/dev/null | wc -l
```

## Output Report

```
PROJECT HEALTH DASHBOARD

TESTS
- Unit: 45/45 passing (100%)
- API: 12/12 passing (100%)
- E2E: 8/8 passing (100%)
- Coverage: 78% (target: 80%) [WARNING]

CODE QUALITY
- TODOs: 3 remaining [WARNING]
- Console: 0
- Type errors: 0
- Lint errors: 0

FEATURES
- Complete: 4/6 features
- In Progress: 2 features
- Next Gate: user-profile (G5)

DEPENDENCIES
- Outdated: 2 packages
- Security: 0 vulnerabilities
- Unused: 1 package

LEARNINGS
- Captured: 12 items
- Unresolved: 2 issues

OVERALL: GOOD (minor issues)

TOP ACTIONS:
1. Increase coverage to 80%
2. Resolve 3 TODOs
3. Update 2 outdated packages
```

## Health Levels

| Level | Criteria |
|-------|----------|
| 🟢 EXCELLENT | All tests pass, coverage >80%, no TODOs, no issues |
| 🟡 GOOD | All tests pass, minor issues (TODOs, coverage <80%) |
| 🟠 WARNING | Some tests failing OR security issues |
| 🔴 CRITICAL | Build fails OR many tests failing |

## Quick Health

For fast check:

```bash
/dev:health --quick
```

Only shows:
- Test pass/fail
- Build status
- Critical issues
