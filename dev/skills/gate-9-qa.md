---
name: gate-9-qa
description: Gate 9 exit criteria - QA validation against requirements
---

# Gate 9: QA Validation

**Final gate before release. Every requirement verified. Every flow traced. Every gap reported.**

## Exit Criteria

### 1. Requirements Traceability Complete

```
□ All acceptance criteria (AC) extracted from spec
□ Each AC mapped to implementation file:line
□ Each AC mapped to test file:line
□ No AC without implementation
□ No AC without test
```

**Verification:**
```bash
# Count acceptance criteria
grep -c "GIVEN\|AC-" specs/{type}/{feature}.md

# Verify each has implementation
# (Manual check required for each AC)

# Verify each has test
grep -rn "{AC keyword}" tests/ src/**/*.test.ts
```

**FAIL if:**
- Any AC has no implementation
- Any AC has no test

---

### 2. Edge Cases Covered

```
□ All edge cases (EC) extracted from spec
□ Each EC has implementation
□ Each EC has test
□ Error messages match spec exactly
```

**Verification:**
```bash
# Extract edge cases
grep -n "Edge Case\|EC-\|Empty\|Invalid\|Error" specs/{type}/{feature}.md

# Verify error messages match
grep -rn "message.*:" specs/{type}/{feature}.md
# Compare with:
grep -rn "error.*:\|message.*:" src/
```

**FAIL if:**
- Any EC not implemented
- Error message wording differs from spec

---

### 3. User Flow Complete

```
□ Entry point exists (route, page)
□ Each step has implementation
□ Each step has handler
□ Success flow reaches expected end state
□ Error flows handled at each step
□ No missing steps in flow
```

**Verification:**
```bash
# Trace flow step by step
# 1. Entry point
grep -rn "path.*{route}" src/routes/ src/App.tsx
ls src/pages/{Feature}*.tsx

# 2. Form/Input handling
grep -rn "handle\|onChange\|onBlur" src/pages/{Feature}*.tsx

# 3. Submit handling
grep -rn "handleSubmit\|onSubmit" src/pages/{Feature}*.tsx

# 4. API call
grep -rn "{feature}Service\|{feature}Api\|fetch\|axios" src/

# 5. Success handling
grep -rn "success\|redirect\|navigate" src/pages/{Feature}*.tsx

# 6. Error handling
grep -rn "catch\|error\|onError" src/pages/{Feature}*.tsx
```

**FAIL if:**
- Any step in flow has no implementation
- Flow cannot reach expected end state

---

### 4. State Handling Complete

```
□ Loading state implemented
□ Error state implemented
□ Empty state implemented (for lists)
□ Success state implemented
□ Each state matches spec UI description
```

**Verification:**
```bash
# Loading state
grep -rn "isLoading\|loading\|isSubmitting" src/pages/{Feature}*.tsx src/components/{Feature}*.tsx

# Error state
grep -rn "isError\|error\|ErrorState" src/pages/{Feature}*.tsx src/components/{Feature}*.tsx

# Empty state
grep -rn "isEmpty\|length === 0\|EmptyState" src/pages/{Feature}*.tsx src/components/{Feature}*.tsx

# Success state
grep -rn "isSuccess\|success\|data\[" src/pages/{Feature}*.tsx src/components/{Feature}*.tsx
```

**FAIL if:**
- Missing loading state (users see blank during load)
- Missing error state (errors fail silently)
- Missing empty state (confusing UX for lists)

---

### 5. Validation Complete

```
□ All required fields validated
□ All validation rules from spec implemented
□ Error messages match spec exactly
□ Validation triggers on blur (UI)
□ Validation blocks submit (UI)
□ Validation at boundary (API)
```

**Verification:**
```bash
# UI validation
grep -rn "onBlur.*validate\|validate.*onBlur" src/
grep -rn "disabled.*isValid\|!isValid" src/

# API validation
grep -rn "schema\|validate\|safeParse" src/routes/ src/handlers/ src/api/

# Error messages
grep -rn "error.*message\|setError\|setFieldError" src/
```

**FAIL if:**
- Required field has no validation
- Validation rule missing from spec
- Error message differs from spec

---

### 6. Tests Pass

```
□ All unit tests pass
□ All integration tests pass
□ All E2E tests pass
□ No skipped tests
□ No flaky tests
```

**Verification:**
```bash
# Run all tests
npm test

# Check for skipped
grep -rn "\.skip\|xit\|xdescribe" tests/ src/**/*.test.ts

# Check E2E
npm run test:e2e
```

**FAIL if:**
- Any test fails
- Tests are skipped

---

### 7. Build Succeeds

```
□ No TypeScript errors
□ No lint errors
□ No build warnings (or justified)
□ Bundle size acceptable
```

**Verification:**
```bash
npm run build
npm run lint
npm run typecheck
```

**FAIL if:**
- Build fails
- TypeScript errors
- Lint errors

---

## Gap Reporting

When gaps found, report:

```markdown
## QA Gaps: {feature-name}

### Critical (Must Fix Before Release)
| # | Gap | Requirement | Impact |
|---|-----|-------------|--------|
| 1 | Missing rate limit handling | Spec: 429 response | Security |
| 2 | Duplicate email not checked | AC-3 | Data integrity |

### High (Should Fix)
| # | Gap | Requirement | Impact |
|---|-----|-------------|--------|
| 3 | No loading state on submit | UI spec | UX |

### Medium (Can Defer)
| # | Gap | Requirement | Impact |
|---|-----|-------------|--------|
| 4 | Network error E2E test missing | Test coverage | Risk |

### Decision Required
Please decide how to handle gaps:
1. Fix all before release
2. Fix critical only
3. Document and release
```

---

## Pass Criteria

| Criterion | Required |
|-----------|----------|
| All AC implemented | ✅ Yes |
| All AC tested | ✅ Yes |
| All EC implemented | ✅ Yes |
| Flow complete | ✅ Yes |
| States complete | ✅ Yes |
| Validation complete | ✅ Yes |
| Tests pass | ✅ Yes |
| Build succeeds | ✅ Yes |
| No critical gaps | ✅ Yes |
| High gaps addressed or approved | ⚠️ Conditional |

**PASS:** All ✅ criteria met, no critical gaps
**PASS_WITH_CONDITIONS:** All ✅ met, high gaps approved to defer
**FAIL:** Any ✅ criterion not met, or critical gap exists
