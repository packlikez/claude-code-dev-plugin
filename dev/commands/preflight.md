---
name: dev:preflight
description: "Pre-implementation checklist - verify everything is ready before coding"
argument-hint: "<feature-name>"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

# Preflight Check

Run before starting any implementation to ensure everything is ready.

## When to Use

- Before `/dev:backend` (Step 2)
- Before `/dev:frontend` (Step 5)
- After long break from feature
- When joining existing feature work

## Process

### 1. Spec Validation

```bash
# Check spec exists
cat specs/*/{feature-name}.md

# Validate spec completeness
```

| Check | Status |
|-------|--------|
| Spec exists | □ |
| All sections filled | □ |
| Acceptance criteria clear | □ |
| API contract defined | □ |
| Edge cases listed | □ |
| UI Screens listed (if frontend) | □ |

### 2. Environment Check

```bash
# Dependencies installed
npm install

# Build works
npm run build

# Tests run
npm test

# Database accessible (if needed)
npm run db:status
```

| Check | Status |
|-------|--------|
| Dependencies installed | □ |
| Build passes | □ |
| Tests pass | □ |
| Database accessible | □ |
| Environment variables set | □ |

### 3. Dependencies Available

Run dependency-map skill:

```bash
cat skills/dependency-map.md
```

| Dependency | Type | Exists? | Action |
|------------|------|---------|--------|
| {service} | Backend | ? | ? |
| {component} | Frontend | ? | ? |
| {utility} | Shared | ? | ? |

### 4. No Blockers

```bash
# Check for blocking TODOs
grep -rn "TODO.*block\|FIXME.*block" src/

# Check for failing tests
npm test 2>&1 | grep -E "FAIL|Error"

# Check for uncommitted changes
git status
```

| Check | Status |
|-------|--------|
| No blocking TODOs | □ |
| All tests passing | □ |
| Clean git state | □ |
| No pending PRs on same files | □ |

### 5. Context Loaded

Verify Claude Code has loaded:
- [ ] Spec file
- [ ] Project patterns (.claude/project.md)
- [ ] Relevant existing code
- [ ] API contract (if exists)

## Output Report

```
PREFLIGHT: {feature-name}

- Spec: Complete
- Environment: Ready
- Dependencies: 3/3 available
- Blockers: None
- Context: Loaded

READY FOR: Step {N} - {step-name}
Command: /dev:{next-step} {feature-name}
```

## On Failure

If any check fails, stop and fix before proceeding:

```
Dependencies: MISSING
- AuthService (needed, not exist)
- validateEmail (needed, not exist)

ACTION: Create stubs first
See: skills/dependency-map.md
```

## Quick Preflight

For fast check (skip environment):

```
/dev:preflight {feature} --quick
```

Only checks:
- Spec exists and valid
- Dependencies mapped
- No blockers
