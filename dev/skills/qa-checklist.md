---
name: qa-checklist
description: QA validation against requirements - flow tracing, step verification, gap detection
---

# QA Checklist

**Verify every requirement. Trace every flow. Find every gap.**

## The Problem

```markdown
❌ Common QA Failures:

1. "Tests pass but feature doesn't work"
   → Tests don't match actual user flow

2. "Missed edge case in production"
   → Acceptance criteria not fully verified

3. "User can't complete the flow"
   → Missing step between actions

4. "Works on my machine"
   → No end-to-end verification
```

---

## 1. Requirements Traceability Matrix (RTM)

### Purpose
Map every spec requirement to implementation and verification.

### Template

```markdown
## Requirements Traceability: {feature-name}

| ID | Requirement (from spec) | Implementation | Test | Status |
|----|------------------------|----------------|------|--------|
| AC-1 | GIVEN visitor WHEN valid form THEN account created | userService.create() | user.create.test.ts:15 | ✅ |
| AC-2 | GIVEN visitor WHEN invalid email THEN show error | validateEmail() | user.validation.test.ts:23 | ✅ |
| AC-3 | GIVEN visitor WHEN duplicate email THEN show conflict | userRepo.findByEmail() | user.conflict.test.ts:10 | ❌ Missing |
| EC-1 | Empty email → "Email is required" | schema.email.required | user.validation.test.ts:30 | ✅ |
| EC-2 | Network failure → retry button | ErrorState component | ❌ No test | ⚠️ Untested |
```

### Process

1. **Extract requirements from spec:**
```bash
# Get acceptance criteria
grep -A 3 "GIVEN\|WHEN\|THEN" specs/features/{feature}.md

# Get edge cases
grep -n "Edge Case\|Error\|Empty\|Invalid" specs/features/{feature}.md

# Get error messages
grep -n "Return 4\|Return 5\|message:" specs/features/{feature}.md
```

2. **Map to implementation:**
```bash
# Find handler/controller
grep -rn "router\.\|app\." src/routes/ | grep "{feature}"

# Find service
ls src/services/{feature}*.ts

# Find component
ls src/components/{Feature}*.tsx src/pages/{Feature}*.tsx
```

3. **Map to tests:**
```bash
# Find test files
ls src/**/*.test.ts src/**/*.spec.ts | grep -i "{feature}"

# Find specific test cases
grep -rn "it('\|test('\|describe('" tests/ | grep -i "{feature}"
```

---

## 2. Flow Verification

### Purpose
Trace complete user journey from start to end, verify each step works.

### Flow Diagram Template

```markdown
## Flow: User Registration

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: User lands on /register                                 │
├─────────────────────────────────────────────────────────────────┤
│ Expected: Registration form displayed                           │
│ Verify:   □ Route exists  □ Component renders  □ Form visible   │
│ Code:     src/pages/RegisterPage.tsx                            │
│ Test:     register.e2e.ts:10                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: User enters email                                       │
├─────────────────────────────────────────────────────────────────┤
│ Expected: Email field accepts input, validates on blur          │
│ Verify:   □ Input works  □ Blur validates  □ Error shows        │
│ Code:     src/components/EmailInput.tsx                         │
│ Test:     register.validation.test.ts:25                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: User enters password                                    │
├─────────────────────────────────────────────────────────────────┤
│ Expected: Password field, strength indicator updates            │
│ Verify:   □ Input works  □ Strength shows  □ Toggle works       │
│ Code:     src/components/PasswordInput.tsx                      │
│ Test:     register.password.test.ts:15                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: User clicks Submit                                      │
├─────────────────────────────────────────────────────────────────┤
│ Expected: Form validates, loading state, API call               │
│ Verify:   □ Validates all  □ Shows loading  □ Disables form     │
│ Code:     src/pages/RegisterPage.tsx:handleSubmit               │
│ Test:     register.submit.test.ts:20                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
            ┌─────────────────┴─────────────────┐
            ↓                                   ↓
┌───────────────────────────┐     ┌───────────────────────────┐
│ STEP 5a: API Success      │     │ STEP 5b: API Error        │
├───────────────────────────┤     ├───────────────────────────┤
│ Expected: Redirect to     │     │ Expected: Show error,     │
│ dashboard, show welcome   │     │ keep form data, focus     │
│ Verify:                   │     │ Verify:                   │
│ □ Redirect works          │     │ □ Error displayed         │
│ □ Toast shows             │     │ □ Form data preserved     │
│ □ User in context         │     │ □ Focus on error field    │
│ Code: RegisterPage:65     │     │ Code: RegisterPage:72     │
│ Test: register.e2e.ts:50  │     │ Test: register.error.ts:30│
└───────────────────────────┘     └───────────────────────────┘
```

### Flow Verification Commands

```bash
# Step 1: Verify route exists
grep -rn "path.*register\|/register" src/

# Step 2-3: Verify form fields exist
grep -rn "email\|password" src/pages/Register*.tsx src/components/Register*.tsx

# Step 4: Verify submit handler
grep -rn "handleSubmit\|onSubmit" src/pages/Register*.tsx

# Step 5a: Verify success flow
grep -rn "redirect\|navigate\|push" src/pages/Register*.tsx

# Step 5b: Verify error handling
grep -rn "catch\|error\|setError" src/pages/Register*.tsx
```

---

## 3. Step-by-Step Verification

### For Each Step, Verify:

```markdown
### Step Verification Checklist

#### Input Verification
□ Input field exists in component
□ Input has correct type (text, email, password)
□ Input has validation rules
□ Input shows error state when invalid
□ Input clears error when corrected

#### Processing Verification
□ Handler function exists
□ Handler calls correct service/API
□ Handler passes correct parameters
□ Handler handles loading state

#### Output Verification
□ Success case handled
□ Error case handled
□ Loading state shown
□ User feedback provided (toast, message)
□ Navigation occurs if needed

#### Edge Case Verification
□ Empty input handled
□ Invalid format handled
□ Network failure handled
□ Timeout handled
□ Concurrent request handled
```

### Verification Script

```bash
#!/bin/bash
# qa-verify-step.sh

FEATURE=$1
STEP=$2

echo "=== Verifying Step: $STEP for $FEATURE ==="

# Check component exists
echo "Component:"
ls src/components/${FEATURE}*.tsx src/pages/${FEATURE}*.tsx 2>/dev/null

# Check handler exists
echo "Handler:"
grep -rn "handle${STEP}\|on${STEP}" src/ | head -5

# Check service call
echo "Service call:"
grep -rn "${FEATURE}Service\|${FEATURE}Api" src/ | head -5

# Check error handling
echo "Error handling:"
grep -rn "catch\|error" src/pages/${FEATURE}*.tsx | head -5

# Check test exists
echo "Tests:"
grep -rn "describe.*${STEP}\|it.*${STEP}" tests/ src/**/*.test.ts | head -5
```

---

## 4. Missing Step Detection

### Common Missing Steps

| Flow Point | Often Missing | How to Detect |
|------------|---------------|---------------|
| Form submit | Loading state | No `isLoading` or `isSubmitting` |
| API call | Error handling | No `catch` or `onError` |
| Success | User feedback | No toast/message after action |
| Navigation | Loading between pages | No skeleton on target page |
| Auth check | Redirect if unauthorized | No auth guard on protected route |
| Form | Validation feedback | No error messages shown |
| List | Empty state | No check for `data.length === 0` |
| List | Pagination | Returns all without `limit`/`offset` |

### Detection Commands

```bash
# Missing loading states
echo "=== Missing Loading States ==="
grep -rL "isLoading\|loading\|isSubmitting" src/pages/*.tsx

# Missing error handling
echo "=== Missing Error Handling ==="
grep -rL "catch\|onError\|error" src/services/*.ts

# Missing empty states
echo "=== Missing Empty States ==="
grep -rL "length === 0\|isEmpty\|empty" src/components/*List*.tsx

# Missing auth guards
echo "=== Missing Auth Guards ==="
grep -rL "isAuthenticated\|requireAuth\|ProtectedRoute" src/pages/*.tsx

# Missing validation
echo "=== Missing Validation ==="
grep -rL "validate\|schema\|zodSchema" src/pages/*Form*.tsx
```

### Gap Analysis Template

```markdown
## Gap Analysis: {feature-name}

### Flow: Login → Dashboard

| Step | Spec Says | Implementation | Gap |
|------|-----------|----------------|-----|
| 1. Show login form | ✅ In spec | ✅ LoginPage.tsx | None |
| 2. Validate email | ✅ "Invalid email format" | ✅ validateEmail() | None |
| 3. Validate password | ✅ "Password required" | ✅ schema.password | None |
| 4. Show loading | ✅ "Button shows spinner" | ❌ No loading state | **GAP** |
| 5. Call API | ✅ POST /api/auth/login | ✅ authService.login() | None |
| 6. Handle 401 | ✅ "Invalid credentials" | ❌ Generic error only | **GAP** |
| 7. Handle 429 | ✅ "Too many attempts" | ❌ Not implemented | **GAP** |
| 8. Store token | ✅ "Save to localStorage" | ✅ setToken() | None |
| 9. Redirect | ✅ "Navigate to /dashboard" | ✅ navigate('/dashboard') | None |

### Gaps Identified

1. **Step 4: Missing loading state**
   - Spec: "Button shows spinner, fields disabled"
   - Current: No loading indicator
   - Fix: Add `isSubmitting` state to form

2. **Step 6: Generic error message**
   - Spec: Show specific "Invalid credentials" for 401
   - Current: Shows generic "Something went wrong"
   - Fix: Parse error response, show specific message

3. **Step 7: Rate limiting not handled**
   - Spec: 429 → "Too many attempts, try again in X seconds"
   - Current: Not implemented
   - Fix: Check for 429, show countdown message
```

---

## 5. End-to-End Verification

### Purpose
Verify the complete flow works in actual runtime.

### E2E Test Checklist

```markdown
## E2E Verification: {feature-name}

### Happy Path
□ Can complete entire flow from start to end
□ All intermediate states display correctly
□ Final state matches expected outcome
□ Data persists correctly

### Error Paths
□ Each error case shows correct message
□ User can recover from error
□ Form data preserved on error
□ No console errors

### Edge Cases
□ Works with minimum valid input
□ Works with maximum valid input
□ Handles special characters
□ Handles concurrent actions

### Cross-Browser (if required)
□ Chrome
□ Firefox
□ Safari
□ Edge

### Mobile (if required)
□ iOS Safari
□ Android Chrome
□ Responsive layout works
```

### Verification Script

```bash
#!/bin/bash
# qa-e2e-verify.sh

FEATURE=$1

echo "=== E2E Verification: $FEATURE ==="

# Check E2E test exists
echo "E2E Tests:"
ls e2e/${FEATURE}*.spec.ts tests/e2e/${FEATURE}*.ts 2>/dev/null

# Check happy path coverage
echo "Happy path tests:"
grep -rn "should.*success\|should.*complete\|should.*work" e2e/ | grep -i "$FEATURE"

# Check error path coverage
echo "Error path tests:"
grep -rn "should.*error\|should.*fail\|should.*invalid" e2e/ | grep -i "$FEATURE"

# Run E2E tests
echo "Running E2E tests..."
npm run test:e2e -- --grep "$FEATURE"
```

---

## 6. QA Report Template

```markdown
## QA Report: {feature-name}

### Summary
| Metric | Count |
|--------|-------|
| Total Requirements | 12 |
| Implemented | 10 |
| Tested | 9 |
| Verified E2E | 8 |
| Gaps Found | 2 |

### Requirements Traceability
| Status | Count | Details |
|--------|-------|---------|
| ✅ Complete | 10 | Implemented + Tested + Verified |
| ⚠️ Untested | 1 | AC-5: No unit test |
| ❌ Missing | 1 | AC-7: Rate limiting |

### Flow Verification
| Flow | Steps | Verified | Gaps |
|------|-------|----------|------|
| Registration | 8 | 7 | 1 (loading state) |
| Login | 6 | 5 | 1 (rate limit) |

### Gaps Requiring Action

#### Critical (Blocking)
1. **Rate limiting not implemented**
   - Spec: 429 handling required
   - Impact: Users can brute-force login
   - Action: Implement before release

#### High (Should Fix)
2. **Loading state missing**
   - Spec: Show spinner on submit
   - Impact: Poor UX, user might double-click
   - Action: Add isSubmitting state

#### Medium (Nice to Have)
None

### Recommendation
□ Ready for release
☑ Ready with conditions (fix Critical items)
□ Not ready (major gaps)

### Sign-off
- [ ] QA Verified
- [ ] User Accepted
```

---

## Quick Reference

### Before QA Starts
```
1. Read spec completely
2. Extract all acceptance criteria
3. Extract all edge cases
4. Build requirements list
```

### During QA
```
1. Map each requirement to code
2. Map each requirement to test
3. Trace each user flow
4. Verify each step works
5. Check for missing steps
```

### After QA
```
1. Document all gaps
2. Categorize by severity
3. Present findings
4. Get decision on gaps
5. Verify fixes if applied
```
