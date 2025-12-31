---
name: dev:backend
description: "Step 2: Backend implementation - requires GATE 1 passed"
argument-hint: "<feature-name>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
---

# Step 2: Backend Implementation

## Prerequisites

```
□ GATE 1 PASSED (spec complete)
□ Spec exists: specs/{type}/{feature-name}.md
```

## Process

### 1. Load Context

```bash
cat specs/{type}/{feature-name}.md     # Spec (source of truth)
cat .claude/project.md                 # Project patterns
```

### 2. Dependency Mapping (BEFORE any code)

Load dependency-map skill and map ALL needed items:

```bash
cat skills/dependency-map.md
```

**Extract from spec:**

| Service | Purpose | Exists? | Action |
|---------|---------|---------|--------|
| {service} | {purpose} | ? | CREATE/REUSE |

| Utility | Purpose | Exists? | Action |
|---------|---------|---------|--------|
| {utility} | {purpose} | ? | CREATE/REUSE |

**Quick existence check:**
```bash
ls src/services/ 2>/dev/null
ls src/utils/ src/lib/ 2>/dev/null
grep -r "{function-name}" src/utils/ 2>/dev/null
```

**Create stubs for ALL missing items FIRST:**
```typescript
// Create stub files with throw new Error('Not implemented')
// This ensures no "module not found" during implementation
```

### 3. Implementation Order

Based on dependency map:
1. Create stubs for all missing
2. Implement services (no dependencies first)
3. Implement services (with dependencies)
4. Implement routes (uses services)

### 4. Delegate to Implementer

Use Task tool with `implementer` agent:
```
Implement backend for {feature-name}:
- Dependency map: .claude/deps/{feature-name}.md
- All endpoints from spec
- All validation rules from spec
- All error responses from spec
- Follow project patterns
```

### 5. Key Requirements

From spec:
- Every endpoint implemented
- Every validation rule
- Every error response (400, 401, 403, 404, 409, 500)

Quality:
- No TODO/FIXME
- Small functions (≤30 lines)
- Fail fast (validations at top)
- Max 3 levels nesting

### 6. Spec Gap Protocol

If you discover gaps during implementation:
```
Use AskUserQuestion:
"Found gap in spec: {issue}
Options:
1. Update spec to {A}
2. Update spec to {B}"
```

Update spec first, then implement.

### 7. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 2 for {feature-name}
```

See `gate-2-backend` skill for all 17 criteria.

## Output

- Implementation in `src/`
- Migrations in `migrations/` (if needed)
