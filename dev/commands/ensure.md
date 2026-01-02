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
---

# Ensure End-to-End Working

Deep verification that target works completely according to spec or understood functionality.

## Process Overview

```
EXPLORE → CLARIFY → CONFIRM → VERIFY → REPORT
```

---

## Phase 1: Explore

Thoroughly explore the target to understand every detail.

### 1.1 Find All Related Files

```bash
# Spec
find . -name "*{target}*" -path "*/specs/*"

# Backend
find . -name "*{target}*" -path "*/src/*" -name "*.ts" | grep -v test

# Frontend
find . -name "*{target}*" -path "*/src/*" -name "*.tsx"

# Tests
find . -name "*{target}*" -path "*/tests/*"

# API routes
grep -rn "{target}" src/routes/ src/api/ src/pages/api/
```

### 1.2 Read and Understand

Read each file found:
- Spec: Extract all acceptance criteria, edge cases, screens
- Backend: Extract all functions, endpoints, business logic
- Frontend: Extract all components, pages, user interactions
- Tests: Extract what's currently tested vs what should be

### 1.3 Build Understanding Map

```
TARGET: {name}

SPEC REQUIREMENTS:
- AC1: {description}
- AC2: {description}
- Edge cases: {list}
- Screens: {list}

IMPLEMENTATION:
- Endpoints: {list with paths}
- Components: {list with files}
- Functions: {list with files}

TESTS EXIST:
- Unit: {list}
- API: {list}
- E2E: {list}

GAPS FOUND:
- {missing tests}
- {missing implementation}
- {spec vs code mismatch}
```

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

## Phase 4: Verify

Systematically verify every detail.

### 4.1 Spec vs Implementation

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
[ ] E2E test exists and passes
```

### 4.2 Data Flow Verification

Trace data through entire system:

```
INPUT: email="test@example.com"

1. FRONTEND
   [ ] Input field accepts value
   [ ] Validation runs (format check)
   [ ] Submit sends to API

2. API
   [ ] Request received with correct body
   [ ] Validation runs
   [ ] Business logic executes
   [ ] Database called

3. DATABASE
   [ ] Record created/updated
   [ ] Correct fields stored
   [ ] Query in assertion: SELECT * WHERE email='test@example.com'

4. RESPONSE
   [ ] API returns correct shape
   [ ] Contains expected data
   [ ] Status code correct

5. UI UPDATE
   [ ] Success message shows "test@example.com"
   [ ] User redirected / state updated
   [ ] No stale data displayed
```

### 4.3 Edge Case Verification

For each edge case in spec:
```
EDGE: "Empty email should show validation error"

[ ] Frontend shows error before submit
[ ] API returns 400 if bypassed
[ ] Error message is user-friendly
[ ] Form is not cleared on error
```

### 4.4 Error Handling Verification

```
ERRORS:
[ ] 400: Validation errors shown to user
[ ] 401: Redirect to login
[ ] 403: Access denied message
[ ] 404: Not found page/message
[ ] 500: Generic error with retry option
[ ] Network: Offline handling
```

### 4.5 Run Tests

```bash
# Run related tests
npm test -- --grep "{target}"

# Check coverage for target files
npm run test:coverage -- --collectCoverageFrom="**/*{target}*"

# E2E specific
npx playwright test --grep "{target}"
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
