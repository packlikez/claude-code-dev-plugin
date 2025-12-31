---
name: dev:init
description: Initialize project, analyze existing code, identify gaps in 8-step workflow
argument-hint: "[focus-area]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
  - Write
---

# Initialize & Analyze Project

Understand the project AND identify gaps according to the 8-step Quality Gate workflow.

---

## Phase 1: Project Discovery

### 1.1 Detect Project Stack

```bash
# Package manager and dependencies
cat package.json 2>/dev/null | head -50

# Top-level structure
ls -la

# Source structure
find . -type d -name "src" -o -name "app" -o -name "lib" 2>/dev/null | head -10
```

### 1.2 Load Pattern Discovery

```bash
cat skills/project-patterns.md
```

### 1.3 Extract Current Patterns

Follow `project-patterns` skill detection commands:
- File naming
- Import order
- Error handling
- Validation approach
- Testing patterns

---

## Phase 2: Gap Analysis

### 2.1 Scan Existing Artifacts

```bash
# Specs
echo "=== SPECS ===" && ls specs/**/*.md 2>/dev/null | wc -l

# Backend implementations
echo "=== BACKEND ===" && ls src/services/*.ts src/routes/*.ts 2>/dev/null | wc -l

# API contracts
echo "=== API CONTRACTS ===" && ls api-contracts/*.yaml 2>/dev/null | wc -l

# Unit tests
echo "=== UNIT TESTS ===" && ls tests/unit/**/*.test.ts 2>/dev/null | wc -l

# Integration tests
echo "=== API TESTS ===" && ls tests/integration/**/*.test.ts 2>/dev/null | wc -l

# UI tests
echo "=== UI TESTS ===" && ls tests/ui/**/*.spec.ts 2>/dev/null | wc -l

# E2E tests
echo "=== E2E TESTS ===" && ls tests/e2e/**/*.spec.ts 2>/dev/null | wc -l
```

### 2.2 Feature Inventory

Map existing features to workflow steps:

```bash
# Find all service files (likely features)
ls src/services/*.ts 2>/dev/null | sed 's/.*\///' | sed 's/Service.ts//'

# Find all route files
ls src/routes/*.ts 2>/dev/null | sed 's/.*\///' | sed 's/.ts//'

# Find all spec files
ls specs/**/*.md 2>/dev/null | sed 's/.*\///' | sed 's/.md//'
```

### 2.3 Gap Detection Matrix

For each discovered feature, check:

| Feature | Spec | Backend | Unit Test | API Test | Frontend | FE Test | UI Test | E2E |
|---------|------|---------|-----------|----------|----------|---------|---------|-----|
| {name}  | ?    | ?       | ?         | ?        | ?        | ?       | ?       | ?   |

Detection commands:

```bash
# For each feature, check existence
FEATURE="user"

# Has spec?
ls specs/**/*${FEATURE}*.md 2>/dev/null

# Has backend?
ls src/services/*${FEATURE}*.ts src/routes/*${FEATURE}*.ts 2>/dev/null

# Has unit tests?
ls tests/unit/**/*${FEATURE}*.test.ts 2>/dev/null

# Has API tests?
ls tests/integration/*${FEATURE}*.test.ts 2>/dev/null

# Has frontend?
ls src/components/*${FEATURE}*/*.tsx src/pages/*${FEATURE}*.tsx 2>/dev/null

# Has frontend tests?
ls tests/unit/components/*${FEATURE}*/*.test.tsx 2>/dev/null

# Has UI tests?
ls tests/ui/*${FEATURE}*/*.spec.ts 2>/dev/null

# Has E2E tests?
ls tests/e2e/*${FEATURE}*/*.spec.ts 2>/dev/null
```

---

## Phase 3: Quality Analysis

### 3.1 Test Quality Check

```bash
# Weak assertions (should be 0)
grep -r "\.toBeDefined()\|\.toBeTruthy()\|\.toBeFalsy()" tests/ 2>/dev/null | wc -l

# Console.log in production code (should be 0)
grep -r "console\.log\|console\.error" src/ 2>/dev/null | wc -l

# TODO comments (tech debt)
grep -r "TODO\|FIXME\|HACK" src/ tests/ 2>/dev/null | wc -l

# Hardcoded secrets (critical)
grep -r "password\s*=\s*['\"]|api_key\s*=\s*['\"]|secret\s*=\s*['\"]" src/ 2>/dev/null | wc -l
```

### 3.2 Coverage Gaps

```bash
# Check for coverage report
cat coverage/lcov-report/index.html 2>/dev/null | grep -o 'Total.*%' | head -1

# Or coverage summary
cat coverage/coverage-summary.json 2>/dev/null
```

### 3.3 Documentation Gaps

```bash
# README exists?
ls README.md 2>/dev/null

# API docs?
ls docs/api*.md api/*.md 2>/dev/null | wc -l

# Code comments ratio (rough estimate)
grep -r "^[[:space:]]*//" src/ 2>/dev/null | wc -l
```

---

## Phase 4: Generate Reports

### 4.1 Create Project Context

Save to `.claude/project.md`:

```markdown
# Project: {name}

## Stack
| Component | Technology |
|-----------|------------|
| Runtime | {node/go/python} |
| Framework | {next/express/etc} |
| Database | {postgres/etc} |
| Testing | {jest/vitest/etc} |
| UI | {tailwind/shadcn/etc} |

## Structure
| Purpose | Path |
|---------|------|
| API | {path} |
| Components | {path} |
| Tests | {path} |
| Utils | {path} |

## Patterns
| Pattern | Convention |
|---------|------------|
| File naming | {pattern} |
| Error handling | {pattern} |
| API structure | {pattern} |

## Reusable Code
- {list utilities, components, hooks}
```

### 4.2 Create Gap Report

Save to `.claude/gaps.md`:

```markdown
# Gap Analysis Report

Generated: {timestamp}

## Feature Coverage

| Feature | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | Completion |
|---------|---|---|---|---|---|---|---|---|------------|
| user-auth | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ | ✗ | ✗ | 25% |
| products | ✓ | ✓ | ✓ | ✓ | ✗ | ✗ | ✗ | ✗ | 50% |

## Missing Items by Step

### Step 1: Specs Missing
- {list features without specs}

### Step 3: Backend Unit Tests Missing
- {list implementations without unit tests}

### Step 4: API Tests Missing
- {list routes without integration tests}

### Step 6: Frontend Unit Tests Missing
- {list components without tests}

### Step 7-8: UI/E2E Tests Missing
- {list features without browser tests}

## Quality Issues

### Critical (Fix Immediately)
- [ ] {hardcoded secrets if found}
- [ ] {critical security issues}

### High (Fix Soon)
- [ ] {weak assertions count}: tests with weak assertions
- [ ] {console.log count}: console statements in production

### Medium (Tech Debt)
- [ ] {TODO count}: TODO/FIXME comments
- [ ] {uncovered features}: features without tests

## Recommendations

### Quick Wins (High ROI)
1. {specific recommendation}
2. {specific recommendation}

### Next Priority
1. {specific recommendation}
2. {specific recommendation}
```

### 4.3 Create Progress Tracker

Save to `.claude/progress.md`:

```markdown
# Development Progress

## Features

### {feature-1}
- [ ] Step 1: Spec
- [ ] Step 2: Backend
- [ ] Step 3: Backend Unit Tests
- [ ] Step 4: API Tests
- [ ] Step 5: Frontend
- [ ] Step 6: Frontend Unit Tests
- [ ] Step 7: UI Tests
- [ ] Step 8: E2E Tests

### {feature-2}
...

## Recommendations

Based on gap analysis, recommended next actions:

1. **Highest Priority:** {specific action}
   Command: `/dev:{step} {feature}`

2. **Second Priority:** {specific action}
   Command: `/dev:{step} {feature}`
```

---

## Output Summary

After running `/dev:init`:

```
╔══════════════════════════════════════════════════════════════════════╗
║                      PROJECT INITIALIZATION COMPLETE                  ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  Project: {name}                                                      ║
║  Stack: {framework} + {database} + {testing}                         ║
║                                                                       ║
║  ────────────────────────────────────────────────────────────────────║
║                                                                       ║
║  COVERAGE SUMMARY                                                     ║
║  ─────────────────                                                    ║
║  Features discovered: 5                                               ║
║  With specs: 3/5 (60%)                                               ║
║  With full tests: 1/5 (20%)                                          ║
║  Quality issues: 12                                                   ║
║                                                                       ║
║  ────────────────────────────────────────────────────────────────────║
║                                                                       ║
║  GAPS FOUND                                                           ║
║  ───────────                                                          ║
║  • 2 features missing specs                                           ║
║  • 4 features missing unit tests                                      ║
║  • 5 features missing API tests                                       ║
║  • 5 features missing UI/E2E tests                                    ║
║                                                                       ║
║  ────────────────────────────────────────────────────────────────────║
║                                                                       ║
║  RECOMMENDED NEXT ACTION                                              ║
║  ───────────────────────                                              ║
║  /dev:spec {highest-priority-feature}                                ║
║                                                                       ║
║  Files created:                                                       ║
║  • .claude/project.md    (patterns & structure)                      ║
║  • .claude/gaps.md       (gap analysis)                              ║
║  • .claude/progress.md   (workflow tracker)                          ║
║                                                                       ║
╚══════════════════════════════════════════════════════════════════════╝
```

---

## Usage

```bash
/dev:init              # Full project scan + gap analysis
/dev:init backend      # Focus on backend gaps
/dev:init frontend     # Focus on frontend gaps
/dev:init {feature}    # Analyze specific feature only
```
