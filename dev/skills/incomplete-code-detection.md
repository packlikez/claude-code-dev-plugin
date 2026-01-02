---
name: incomplete-code-detection
description: Detect incomplete, placeholder, or mock code that should be real implementation
---

# Incomplete Code Detection

Catches code that looks complete but isn't actually functional.

## Detection Patterns

### 1. Empty Functions

```bash
# Empty function body
grep -rEn "(\{[\s]*\}|=> \{\}|=> \{ \})" src/

# Function with only return
grep -rEn "function.*\{[\s]*return;?[\s]*\}" src/

# Arrow function returning nothing useful
grep -rEn "=>[\s]*(undefined|null|void 0|\{\}|\[\])" src/
```

### 2. Placeholder Implementations

```bash
# TODO/FIXME/HACK comments
grep -rEn "(TODO|FIXME|HACK|XXX|PLACEHOLDER)" src/

# "not implemented" patterns
grep -rEin "(not implemented|to be implemented|implement later|stub)" src/

# Throw not implemented
grep -rEn "throw.*['\"]not implemented" src/
```

### 3. Mock/Fake Data Left in Production Code

```bash
# Hardcoded test data
grep -rEn "(test@|example\.com|fake|mock|dummy|sample)" src/ | grep -v "\.test\.\|\.spec\.\|__test__"

# Lorem ipsum
grep -rEin "lorem ipsum" src/

# Hardcoded IDs
grep -rEn "['\"]123['\"]|['\"]abc['\"]|['\"]test-id['\"]" src/
```

### 4. Console Statements (Debug Code)

```bash
# Console logging
grep -rEn "console\.(log|debug|info|warn|error)" src/

# Debugger statements
grep -rn "debugger" src/
```

### 5. Commented Out Code

```bash
# Large comment blocks (potential dead code)
grep -rEn "^[\s]*//" src/ | head -50

# Commented function calls
grep -rEn "//.*\(" src/
```

### 6. Empty Event Handlers

```bash
# onClick={() => {}}
grep -rEn "on[A-Z][a-zA-Z]*=\{[\s]*\(\)[\s]*=>[\s]*\{\}[\s]*\}" src/

# onClick={() => console.log}
grep -rEn "on[A-Z][a-zA-Z]*=\{.*console\." src/

# Empty handler functions
grep -rEn "handle[A-Z][a-zA-Z]*.*\{[\s]*\}" src/
```

### 7. Hardcoded Values That Should Be Dynamic

```bash
# Hardcoded URLs
grep -rEn "http://localhost|https://localhost|127\.0\.0\.1" src/

# Hardcoded credentials
grep -rEin "(password|secret|api.?key|token).*[=:].*['\"]" src/

# Hardcoded config
grep -rEn "['\"]prod['\"]|['\"]production['\"]|['\"]dev['\"]" src/
```

### 8. Incomplete Error Handling

```bash
# Empty catch blocks
grep -rEn "catch.*\{[\s]*\}" src/

# Catch with only console
grep -rEn "catch.*\{[\s]*console\." src/

# Swallowed errors
grep -rEn "catch[\s]*\([\s]*\)" src/
```

### 9. Unfinished Conditionals

```bash
# Empty if/else blocks
grep -rEn "if.*\{[\s]*\}|else[\s]*\{[\s]*\}" src/

# TODO in conditions
grep -rEn "if.*TODO|else.*TODO" src/
```

### 10. Return Placeholders

```bash
# Return empty/null without logic
grep -rEn "return[\s]+(null|undefined|\{\}|\[\]|''|\"\")" src/

# Return hardcoded values
grep -rEn "return ['\"][^'\"]+['\"]" src/ | grep -v "error\|message\|type"
```

## Full Scan Command

Run all detection patterns:

```bash
#!/bin/bash
echo "=== INCOMPLETE CODE SCAN ==="

echo -e "\n1. Empty functions:"
grep -rEn "(\{[\s]*\}|=> \{\})" src/ --include="*.ts" --include="*.tsx" | head -20

echo -e "\n2. TODO/FIXME/HACK:"
grep -rEn "(TODO|FIXME|HACK|XXX)" src/ | head -20

echo -e "\n3. Mock data in src:"
grep -rEn "(test@|example\.com|fake|mock|dummy)" src/ --include="*.ts" --include="*.tsx" | grep -v "\.test\.\|\.spec\." | head -20

echo -e "\n4. Console statements:"
grep -rEn "console\.(log|debug)" src/ --include="*.ts" --include="*.tsx" | head -20

echo -e "\n5. Empty handlers:"
grep -rEn "on[A-Z].*=>[\s]*\{\}" src/ --include="*.tsx" | head -20

echo -e "\n6. Empty catch blocks:"
grep -rEn "catch.*\{[\s]*\}" src/ | head -20

echo -e "\n7. Hardcoded localhost:"
grep -rEn "localhost|127\.0\.0\.1" src/ | head -20

echo -e "\n8. Debugger statements:"
grep -rn "debugger" src/ | head -20

echo "=== SCAN COMPLETE ==="
```

## Per-File Deep Check

For critical files, do line-by-line verification:

```bash
# List all functions in file
grep -n "function\|const.*=.*=>\|=.*function" {file}

# For each function, check it has real implementation:
# - More than 1 line
# - No TODO inside
# - No console.log only
# - Has actual logic (if/for/return with value)
```

## Integration with Ensure

During `/dev:ensure`, run this scan:

1. Run full scan command
2. If ANY pattern matches → flag as INCOMPLETE
3. For each match, require:
   - Explanation why it's intentional, OR
   - Fix before passing

## Checklist

```
[ ] No empty functions in src/
[ ] No TODO/FIXME/HACK in src/
[ ] No mock/test data in src/ (except test files)
[ ] No console.log/debug in src/
[ ] No empty event handlers
[ ] No empty catch blocks
[ ] No hardcoded localhost/credentials
[ ] No debugger statements
[ ] No commented-out code blocks
[ ] All functions have real implementation
```
