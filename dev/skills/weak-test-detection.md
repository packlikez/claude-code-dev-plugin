---
name: weak-test-detection
description: Detect and reject weak assertions that prove nothing about functionality
---

# Weak Test Detection

## Problem

Passing tests ≠ Working feature

Weak assertions create false confidence. Feature can be completely broken while all tests pass.

## Blocked Assertion Patterns

### Existence Checks (prove element exists, not that it works)

```
toBeDefined()
toExist()
not.toBeNull()
not.toBeUndefined()
toBeInTheDocument()
toBeVisible()          # for data elements
toHaveLength(*)        # without checking content
toBeTruthy()
toBeFalsy()
```

### Vague Comparisons

```
toBeGreaterThan(0)     # items exist but content unknown
toBeLessThan(*)        # range check without value check
toMatch(/.*/)          # matches anything
toContain('')          # contains empty string
```

### Mock Verification Without Args

```
toHaveBeenCalled()           # called, but with what?
toHaveBeenCalledTimes(*)     # called N times, but with what?
```

## Detection Commands

Run these to find weak assertions in test files:

```bash
# Existence-only assertions
grep -rn "toBeDefined()" tests/
grep -rn "toExist()" tests/
grep -rn "\.not\.toBeNull()" tests/
grep -rn "toBeInTheDocument()" tests/
grep -rn "toBeTruthy()" tests/
grep -rn "toBeFalsy()" tests/

# Visibility without content check (look for missing toContainText/toHaveText)
grep -rn "toBeVisible()" tests/ | grep -v "toContainText\|toHaveText\|toHaveValue"

# Mock called without argument verification
grep -rn "toHaveBeenCalled()" tests/ | grep -v "toHaveBeenCalledWith"

# Length check without content
grep -rn "toHaveLength(" tests/ | grep -v "toEqual\|toBe\|toContain"

# Greater than zero (items exist but unknown)
grep -rn "toBeGreaterThan(0)" tests/

# Combined detection script
grep -rEn "(toBeDefined|toExist|toBeTruthy|toBeFalsy)\(\)" tests/
```

## Required Assertion Patterns

### Instead of existence, assert value:

| Weak | Strong |
|------|--------|
| `expect(user).toBeDefined()` | `expect(user.email).toBe('test@example.com')` |
| `expect(result).toBeTruthy()` | `expect(result.status).toBe('success')` |
| `expect(list.length).toBeGreaterThan(0)` | `expect(list[0].name).toBe('Expected')` |
| `expect(element).toBeVisible()` | `expect(element).toHaveText('John Doe')` |
| `expect(fn).toHaveBeenCalled()` | `expect(fn).toHaveBeenCalledWith({email: 'x'})` |

### Data flow verification:

```
# Input value must appear in output
input = 'john@example.com'
# ... action ...
expect(result.email).toBe(input)        # Not just toBeDefined()
expect(element).toContainText(input)    # Not just toBeVisible()
expect(dbRecord.email).toBe(input)      # Not just not.toBeNull()
```

## Gate Validation

Each gate must run detection before passing:

```bash
# Count weak assertions
WEAK=$(grep -rEc "(toBeDefined|toExist|toBeTruthy|toBeFalsy)\(\)" tests/ || echo 0)
if [ "$WEAK" -gt 0 ]; then
  echo "FAIL: $WEAK weak assertions found"
  exit 1
fi
```

## Exceptions

Visibility checks OK for:
- Layout/structure tests (not data)
- Loading spinners, modals
- Element presence before interaction

Must still combine with content assertion for data elements:
```
await expect(element).toBeVisible()
await expect(element).toHaveText('Specific Value')  # Required for data
```

## Checklist

```
[ ] No toBeDefined() for data
[ ] No toBeTruthy()/toBeFalsy() for results
[ ] No toBeVisible() alone for data elements
[ ] No toHaveBeenCalled() without toHaveBeenCalledWith()
[ ] No length checks without content checks
[ ] Input values appear in output assertions
[ ] DB state verified with specific values
[ ] API response fields checked individually
```
