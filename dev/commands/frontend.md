---
name: dev:frontend
description: "Step 5: Frontend implementation - requires GATE 4 passed"
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

# Step 5: Frontend Implementation

## Prerequisites

```
□ GATE 4 PASSED (API tests complete)
□ API contract: api-contracts/{feature}.yaml
```

## Process

### 1. Load Context

```bash
cat specs/{type}/{feature-name}.md     # Spec
cat api-contracts/{feature}.yaml       # API contract
cat skills/ux-patterns.md              # UX patterns
```

### 2. Dependency Mapping (BEFORE any code)

Load dependency-map skill and map ALL needed UI elements:

```bash
cat skills/dependency-map.md
```

**Extract from spec - UI Components:**

| Component | Purpose | Exists? | Action |
|-----------|---------|---------|--------|
| {Form} | {purpose} | ? | CREATE/REUSE |
| {Dialog} | {purpose} | ? | CREATE/REUSE |
| {Button} | {purpose} | ? | REUSE (ui lib) |

**Extract from spec - Hooks/Services:**

| Hook/Service | Purpose | Exists? | Action |
|--------------|---------|---------|--------|
| useAuth | Auth state | ? | CREATE/REUSE |
| apiClient | API calls | ? | CREATE/REUSE |

**Quick existence check:**
```bash
ls src/components/ui/ 2>/dev/null
ls src/components/ 2>/dev/null
ls src/hooks/ 2>/dev/null
grep -r "Dialog\|Modal" src/components/ 2>/dev/null
```

**Create stubs for ALL missing components FIRST:**
```typescript
// Stub component
export const FeatureDialog = () => {
  throw new Error('Not implemented - TODO');
};
```

### 3. Implementation Order

Based on dependency map:
1. Create stubs for all missing components
2. Implement shared hooks (useAuth, useApi, etc.)
3. Implement child components (buttons, inputs)
4. Implement parent components (forms, dialogs)
5. Implement page/container components

### 4. Delegate to Implementer

Use Task tool with `implementer` agent:
```
Implement frontend for {feature-name}:
- Dependency map: .claude/deps/{feature-name}.md
- Generate types from API contract
- Follow ux-patterns skill
- Handle all UI states
- No native browser components
```

### 5. Key Requirements

From `ux-patterns` skill:
- Optimistic updates
- Skeleton loaders (not spinners)
- Confirmation dialogs (not alert/confirm)
- Focus management
- Form protection (auto-save, unsaved warning)
- No native components (select, date, file)

From spec:
- All screens implemented
- All error states handled
- Forms match backend validation

### 6. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 5 for {feature-name}
```

See `gate-5-frontend` skill for all 26 criteria.

## Output

- Components: `src/components/{feature}/`
- Hooks: `src/hooks/`
- Types: `src/types/`
