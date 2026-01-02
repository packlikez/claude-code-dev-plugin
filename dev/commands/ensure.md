---
name: dev:ensure
description: "Deep verification that feature/module works end-to-end according to spec"
argument-hint: "<target> (feature name, module, endpoint, component)"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
  - TodoWrite
---

# Ensure End-to-End Working

Deep verification that target works completely according to spec or understood functionality.

**Supports large features with checkpointing and context management.**

## Process Overview

```
EXPLORE → CLARIFY → CONFIRM → VERIFY (chunked) → REPORT
```

---

## Context Management (Large Features)

### Before Starting

Estimate feature size:

| Size | Files | Action |
|------|-------|--------|
| Small | <5 | Execute directly |
| Medium | 5-15 | Chunk verification, checkpoint after each |
| Large | 15+ | Delegate exploration to agents, chunk all phases |

### Chunking Strategy

Break verification into independent chunks:

```
CHUNK 1: Spec & Backend verification
CHUNK 2: Frontend verification
CHUNK 3: Test verification
CHUNK 4: Data flow verification
CHUNK 5: Edge cases & error handling
```

After each chunk:
1. Save progress to `.claude/ensure-progress.md`
2. Summarize findings
3. Continue or pause if context heavy

### Progress File Format

Write to `.claude/ensure-progress.md`:

```markdown
# Ensure Progress: {target}
Updated: {timestamp}

## Completed Chunks
- [x] Chunk 1: Spec & Backend - 8/8 passed
- [x] Chunk 2: Frontend - 5/5 passed
- [ ] Chunk 3: Tests - IN PROGRESS

## Current Chunk
Chunk: 3 - Test verification
Progress: 12/20 checks
Last check: API test for POST /users

## Findings So Far
- PASS: All AC implemented
- PASS: All endpoints exist
- FAIL: Missing test for password reset
- WARN: E2E test flaky (1/3 fails)

## Remaining
- Chunk 3: 8 more checks
- Chunk 4: Data flow (15 checks)
- Chunk 5: Edge cases (10 checks)

## Context Reload (if resuming)
Read: specs/features/{target}.md
Read: .claude/ensure-progress.md
```

### Resume Command

If context compacts or new session:

```bash
/dev:ensure {target} --resume
```

This reads `.claude/ensure-progress.md` and continues from last checkpoint.

---

## Phase 1: Explore

Thoroughly explore the target to understand every detail.

### 1.0 Size Check First

```bash
# Count related files
find . -name "*{target}*" | wc -l
```

| Count | Action |
|-------|--------|
| <5 | Explore directly |
| 5-15 | Use grep summaries, read key files only |
| 15+ | Delegate to Explore agent |

### 1.1 For Large Features: Delegate Exploration

Use Task tool with Explore agent:

```
"Explore all files related to {target} feature.
Find: specs, backend code, frontend code, tests.
Return: file list with brief purpose of each.
Do not read full content, just identify files."
```

### 1.2 Find All Related Files

```bash
# Spec
find . -name "*{target}*" -path "*/specs/*"

# Backend (just list, don't read yet)
find . -name "*{target}*" -path "*/src/*" -name "*.ts" | grep -v test

# Frontend
find . -name "*{target}*" -path "*/src/*" -name "*.tsx"

# Tests
find . -name "*{target}*" -path "*/tests/*"

# API routes (grep for mentions)
grep -rln "{target}" src/routes/ src/api/ 2>/dev/null
```

### 1.3 Smart Reading (Token Efficient)

Don't read full files. Extract key info:

```bash
# Get function names only
grep -n "export.*function\|export.*const.*=" {file}

# Get endpoint definitions only
grep -n "router\.\|app\.\|@Get\|@Post" {file}

# Get component names only
grep -n "export.*function\|export default" {file}

# Get test names only
grep -n "describe\|it\|test(" {file}
```

Only read full file when needed for specific check.

### 1.4 Build Understanding Map

```
TARGET: {name}
Files found: {n} (Small/Medium/Large)

SPEC SUMMARY:
- AC count: {n}
- Edge cases: {n}
- Screens: {n}

IMPLEMENTATION SUMMARY:
- Endpoints: {n} in {files}
- Components: {n} in {files}
- Services: {n} in {files}

TESTS SUMMARY:
- Unit: {n} files, {n} tests
- API: {n} files, {n} tests
- E2E: {n} files, {n} tests

INITIAL GAPS:
- {any obvious missing pieces}
```

Save to `.claude/ensure-progress.md` before continuing.

---

## Phase 2: Clarify

Use AskUserQuestion to understand what exactly needs verification.

### Questions to Ask

1. **Scope**: "What aspect do you want to ensure?"
   - Full end-to-end flow
   - Specific functionality
   - Edge cases only
   - Performance/security

2. **Depth**: "How thorough should verification be?"
   - Quick check (run existing tests)
   - Standard (run tests + manual checks)
   - Deep (trace every code path)

3. **Focus areas**: "Any specific concerns?"
   - Data validation
   - Error handling
   - UI behavior
   - API responses
   - Database state

---

## Phase 3: Confirm

Present findings and get confirmation before proceeding.

### Show Summary

```
ENSURE: {target}

FOUND:
- Spec: {file} with {n} acceptance criteria
- Backend: {n} endpoints in {files}
- Frontend: {n} components in {files}
- Tests: {n} unit, {n} API, {n} E2E

WILL VERIFY:
1. All {n} acceptance criteria from spec
2. All endpoints respond correctly
3. All components render with correct data
4. Data flows: Input → API → DB → Response → UI
5. Error cases handled
6. Edge cases covered

ESTIMATED: {n} checks

Proceed? (Yes/No/Modify scope)
```

---

## Phase 4: Verify (Chunked)

Systematically verify every detail. Use TodoWrite to track progress.

### 4.0 Initialize Verification Todos

Use TodoWrite to create verification checklist:

```
Todos:
- [ ] Chunk 1: Spec vs Backend
- [ ] Chunk 2: Frontend verification
- [ ] Chunk 3: Test coverage
- [ ] Chunk 4: Data flow
- [ ] Chunk 5: Edge cases & errors
```

### Chunk 1: Spec vs Implementation

For each acceptance criterion:

```
AC: "User can register with email and password"

CHECK:
[ ] API endpoint exists: POST /api/auth/register
[ ] Endpoint accepts: { email, password }
[ ] Endpoint validates: email format, password length
[ ] Endpoint returns: { user: { id, email }, token }
[ ] DB stores: users table with hashed password
[ ] Frontend form: email input, password input, submit
[ ] Frontend shows: success/error message
```

After chunk: Update `.claude/ensure-progress.md`, mark todo complete.

### Chunk 2: Frontend Verification

```
[ ] All screens from spec exist
[ ] Components render correctly
[ ] Forms have proper validation
[ ] Loading states shown
[ ] Error states handled
```

After chunk: Checkpoint progress.

### Chunk 3: Test Coverage

```
[ ] Unit tests exist for all functions
[ ] API tests cover all endpoints
[ ] E2E tests cover all user flows
[ ] No weak assertions (run detection)
[ ] Tests actually pass
```

```bash
# Run tests
npm test -- --grep "{target}"

# Weak assertion check
grep -rEn "(toBeDefined|toExist|toBeTruthy)\(\)" tests/**/*{target}*
```

After chunk: Checkpoint progress.

### Chunk 4: Data Flow Verification

Trace ONE complete flow (don't read all files):

```
INPUT: email="test@example.com"

1. FRONTEND → grep for form submit handler
2. API → grep for endpoint handler
3. DB → grep for database call
4. RESPONSE → check response shape
5. UI → check success display

Verify input value appears at each step.
```

After chunk: Checkpoint progress.

### Chunk 5: Edge Cases & Error Handling

```
EDGE CASES:
[ ] Empty inputs handled
[ ] Invalid format handled
[ ] Boundary values handled

ERRORS:
[ ] 400: Validation errors shown
[ ] 401: Redirect to login
[ ] 403: Access denied
[ ] 404: Not found
[ ] 500: Generic error
[ ] Network: Offline handling
```

### Chunk 6: Incomplete Code Detection (CRITICAL)

Use `incomplete-code-detection` skill. Scan for placeholder/mock code:

```bash
# Empty functions
grep -rEn "=> \{\}|\{[\s]*\}" src/**/*{target}*

# TODO/FIXME left in code
grep -rEn "(TODO|FIXME|HACK)" src/**/*{target}*

# Empty event handlers (onClick={() => {}})
grep -rEn "on[A-Z].*=>[\s]*\{\}" src/**/*{target}*

# Console.log (debug code)
grep -rEn "console\.(log|debug)" src/**/*{target}*

# Mock/test data in production
grep -rEn "(test@|example\.com|fake|mock)" src/**/*{target}* | grep -v "\.test\.\|\.spec\."

# Empty catch blocks
grep -rEn "catch.*\{[\s]*\}" src/**/*{target}*

# Hardcoded values
grep -rEn "localhost|127\.0\.0\.1" src/**/*{target}*
```

**ANY match = FAIL** (unless intentional with documented reason)

### 4.5 Run Tests

```bash
# Run related tests
npm test -- --grep "{target}"

# E2E specific
npx playwright test --grep "{target}"
```

### After All Chunks

Update final progress:

```markdown
# Ensure Complete: {target}

All chunks verified:
- [x] Chunk 1: Spec vs Backend - PASS
- [x] Chunk 2: Frontend - PASS
- [x] Chunk 3: Tests - 1 FAIL (weak assertion)
- [x] Chunk 4: Data flow - PASS
- [x] Chunk 5: Edge cases - PASS
```

---

## Phase 5: Report

### Success Report

```
ENSURE COMPLETE: {target}

VERIFIED:
- Acceptance Criteria: 8/8
- Endpoints: 3/3
- Components: 5/5
- Data Flow: Verified (Input → DB → UI)
- Edge Cases: 6/6
- Error Handling: All codes covered
- Tests: 24/24 passing

STATUS: FULLY WORKING

All functionality works end-to-end according to spec.
```

### Failure Report

```
ENSURE FAILED: {target}

PASSED: 18/24 checks

FAILED:
1. AC3: "Password reset email" - Not implemented
   - Missing: POST /api/auth/reset-password
   - Missing: ResetPasswordForm component
   - Action: Implement password reset flow

2. Edge case: "Expired token" - No handling
   - API returns 401 but UI shows generic error
   - Action: Add specific expired token UI

3. E2E: "login-flow.spec.ts" - Flaky
   - Fails 1/3 runs
   - Action: Add proper wait conditions

NEXT STEPS:
1. /dev:backend user-registration (implement reset)
2. Fix token expiry UI
3. Stabilize E2E test
```

---

## Key Principles

1. **Every detail matters**: Don't skip anything in spec
2. **Trace data flow**: Input must appear in output
3. **Test assertions matter**: Visibility ≠ Working
4. **Ask when unclear**: Use AskUserQuestion
5. **Report gaps**: Missing items are failures
