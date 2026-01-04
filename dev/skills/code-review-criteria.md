---
name: code-review-criteria
description: Post-implementation review criteria - alignment check with improvement suggestions
---

# Code Review Criteria

**Review every implementation before marking complete. Present improvements for user decision.**

## Review Categories

### 1. Fail-Fast Alignment

| Check | Pass | Fail |
|-------|------|------|
| Validation at boundary | First lines of handler validate input | Validation buried in business logic |
| Guard clauses | Early returns for error cases | Nested if/else blocks |
| Error handling first (UI) | Loading/error states before render | Scattered conditionals in JSX |
| Input validation (UI) | Validate on blur, block submit | Only server-side validation |

**Review Commands:**
```bash
# Check for buried validation
grep -n "if.*!.*valid" src/services/ src/handlers/

# Check for nested conditionals (>2 levels)
grep -n "if.*{" src/ | head -20

# Check UI error handling pattern
grep -n "isLoading\|error\|isError" src/components/
```

**Issue Template:**
```markdown
**[FAIL-FAST]** Validation buried in business logic

**Location:** src/services/userService.ts:45

**Current:**
```typescript
const createUser = async (data) => {
  // Validation happens here, deep inside
  if (!data.email) throw new Error('Email required');
};
```

**Suggested:**
```typescript
// Move to handler/controller layer
const parsed = schema.safeParse(req.body);
if (!parsed.success) return res.status(400).json({ error: formatError(parsed.error) });
```

**Impact:** Medium - Improves error traceability
**Apply this improvement?** [Yes/No/Modify]
```

---

### 2. Reusability Alignment

| Check | Pass | Fail |
|-------|------|------|
| No duplicate logic | Uses existing utilities | Inline reimplementation |
| Shared components | Uses UI library | Creates new similar component |
| Shared hooks | Uses existing hooks | Duplicate fetch/state logic |
| Service layer | Business logic in services | Business logic in handlers |

**Review Commands:**
```bash
# Find potential duplicates - date formatting
grep -rn "toISOString\|toLocaleDateString\|format.*Date" src/

# Find potential duplicates - email validation
grep -rn "@.*\\.test\|email.*regex\|validateEmail" src/

# Find inline fetch logic (should be in hooks)
grep -rn "useState.*fetch\|useEffect.*fetch" src/components/

# Find business logic in handlers (should be in services)
grep -rn "await.*create\|await.*update" src/routes/ src/handlers/ src/api/
```

**Issue Template:**
```markdown
**[REUSE]** Duplicate date formatting logic

**Locations:**
- src/components/OrderCard.tsx:23
- src/components/InvoiceList.tsx:45
- src/pages/Dashboard.tsx:89

**Current (in 3 places):**
```typescript
const formatted = new Date(date).toLocaleDateString('en-US', { ... });
```

**Suggested:**
```typescript
// Create: src/utils/date.ts
export const formatDate = (date: string | Date): string => {
  return new Date(date).toLocaleDateString('en-US', { ... });
};

// Use everywhere
import { formatDate } from '@/utils/date';
```

**Impact:** High - 3 files affected, reduces maintenance
**Apply this improvement?** [Yes/No/Modify]
```

---

### 3. Clean Code Alignment

| Check | Pass | Fail |
|-------|------|------|
| Single responsibility | Each function does one thing | Multi-purpose functions |
| Function size | ≤30 lines | >30 lines |
| Nesting depth | ≤3 levels | >3 levels |
| Clear naming | Descriptive names | Abbreviations, unclear |
| No magic numbers | Named constants | Hardcoded values |

**Review Commands:**
```bash
# Find long functions (rough check)
grep -rn "^const.*=.*async\|^function\|^export const" src/ | head -20

# Find magic numbers
grep -rn "[^0-9][0-9][0-9][0-9][^0-9]" src/ | grep -v "test\|spec" | head -10

# Find short variable names (1-2 chars)
grep -rn "const [a-z] =\|const [a-z][a-z] =" src/ | head -10
```

**Issue Template:**
```markdown
**[CLEAN]** Function exceeds 30 lines

**Location:** src/services/orderService.ts:createOrder (45 lines)

**Current:** Single function handling validation, calculation, creation, notification

**Suggested:** Extract into smaller functions:
```typescript
const parseOrderItems = (items: unknown[]) => { ... };      // 8 lines
const calculateTotal = (items: OrderItem[]) => { ... };     // 5 lines
const applyDiscount = (total: number, code: string) => { ... }; // 10 lines
const sendOrderNotification = (order: Order) => { ... };    // 8 lines

const createOrder = async (input: OrderInput) => {
  const items = parseOrderItems(input.items);
  const total = calculateTotal(items);
  const finalTotal = applyDiscount(total, input.discountCode);
  const order = await db.orders.create({ ...input, items, total: finalTotal });
  await sendOrderNotification(order);
  return order;
};
```

**Impact:** Medium - Improves testability and readability
**Apply this improvement?** [Yes/No/Modify]
```

---

### 4. Spec Alignment

| Check | Pass | Fail |
|-------|------|------|
| All endpoints implemented | Matches spec table | Missing endpoints |
| Request fields match | Type, required, validation | Missing fields/validation |
| Response fields match | All fields returned | Missing/extra fields |
| Error codes match | All spec error codes | Missing error cases |
| UI states match | All spec states | Missing loading/error/empty |

**Review Commands:**
```bash
# Compare implemented routes to spec
grep -rn "router\.\|app\." src/routes/ | grep -E "get|post|put|delete"

# Check for missing error handlers
grep -rn "catch\|\.catch\|try" src/services/ src/handlers/

# Check UI states
grep -rn "isLoading\|isEmpty\|isError" src/components/
```

**Issue Template:**
```markdown
**[SPEC]** Missing error case from spec

**Spec requirement:**
> 409 CONFLICT "Email already exists" - When duplicate email

**Current implementation:** No duplicate check before create

**Suggested:**
```typescript
const existing = await userRepo.findByEmail(email);
if (existing) {
  throw new ConflictError('Email already exists');
}
```

**Impact:** Critical - Missing required functionality
**Apply this improvement?** [Yes/No/Modify]
```

---

### 5. Performance Considerations

| Check | Pass | Fail |
|-------|------|------|
| No N+1 queries | Uses joins/includes | Loop with queries |
| Proper indexing | Indexes on filtered fields | Missing indexes |
| Pagination | List endpoints paginated | Returns all records |
| Caching considered | Cache for expensive ops | No caching strategy |
| Bundle size (UI) | Dynamic imports for large | All in main bundle |

**Review Commands:**
```bash
# Check for N+1 patterns
grep -rn "for.*await\|forEach.*await\|map.*await" src/

# Check for missing pagination
grep -rn "findMany\|find(\)" src/ | grep -v "limit\|take\|skip"

# Check dynamic imports
grep -rn "lazy\|dynamic\|import(" src/
```

---

## Review Output Format

Present findings in this format:

```markdown
## Code Review Summary

### Implementation: {feature-name}
**Files reviewed:** {count}
**Issues found:** {count by category}

---

### Critical Issues (Must Fix)

#### 1. [SPEC] Missing duplicate email check
**File:** src/services/userService.ts:34
**Current:** Creates user without checking email exists
**Fix:** Add `findByEmail` check before create
**Apply?** [Required]

---

### Improvements (User Decision)

#### 2. [REUSE] Extract date formatting utility
**Files:** 3 files with duplicate logic
**Impact:** Medium
**Effort:** Low (15 min)
**Apply?** [ ] Yes  [ ] No  [ ] Modify

#### 3. [CLEAN] Split createOrder into smaller functions
**File:** src/services/orderService.ts
**Impact:** Medium
**Effort:** Medium (30 min)
**Apply?** [ ] Yes  [ ] No  [ ] Modify

#### 4. [FAIL-FAST] Move validation to handler layer
**File:** src/services/userService.ts
**Impact:** Low
**Effort:** Low (10 min)
**Apply?** [ ] Yes  [ ] No  [ ] Modify

---

### Summary

| Category | Issues | Critical | Optional |
|----------|--------|----------|----------|
| Fail-Fast | 2 | 0 | 2 |
| Reuse | 1 | 0 | 1 |
| Clean Code | 1 | 0 | 1 |
| Spec | 1 | 1 | 0 |
| Performance | 0 | 0 | 0 |

**Next step:** Please select which improvements to apply.
```

---

## Decision Flow

After presenting review:

```yaml
AskUserQuestion:
  questions:
    - question: "Which improvements should be applied?"
      header: "Improvements"
      options:
        - label: "All improvements"
          description: "Apply all suggested changes"
        - label: "Critical only"
          description: "Only apply must-fix issues"
        - label: "Select specific"
          description: "I'll specify which ones"
        - label: "None for now"
          description: "Skip improvements, continue"
      multiSelect: false
```

If user selects "Select specific":
```yaml
AskUserQuestion:
  questions:
    - question: "Select improvements to apply"
      header: "Apply"
      options:
        - label: "#2 Extract date utility"
          description: "3 files, ~15 min"
        - label: "#3 Split createOrder"
          description: "1 file, ~30 min"
        - label: "#4 Move validation"
          description: "1 file, ~10 min"
      multiSelect: true
```

---

## Quick Checklist

Before completing review:

```
□ Checked fail-fast patterns (validation at boundary)
□ Checked for duplicate logic (utilities, components, hooks)
□ Checked function size and nesting
□ Compared implementation to spec
□ Identified critical vs optional issues
□ Presented improvements with Apply? option
□ Got user decision before proceeding
```
