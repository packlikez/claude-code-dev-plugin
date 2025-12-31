---
name: dependency-map
description: Map ALL dependencies before implementation to avoid mid-work discoveries
---

# Dependency Mapping

## Purpose

Before writing ANY code, identify ALL components/endpoints/services needed.
This prevents discovering "button opens dialog but dialog doesn't exist" mid-implementation.

---

## When to Apply

Claude Code MUST run dependency mapping:
- Before Step 2 (Backend implementation)
- Before Step 5 (Frontend implementation)
- When spec mentions multiple connected components

---

## Process

### Step 1: Extract from Spec (NO code reading yet)

Read ONLY the spec and list:

```markdown
## Dependency Map: {feature-name}

### Pages/Routes Needed (CRITICAL - check first!)
| Route | Page Component | Purpose | Exists? | Action |
|-------|----------------|---------|---------|--------|
| /projects | ProjectsPage | List projects | ? | ? |
| /projects/:id/board | KanbanBoardPage | Kanban view | ? | ? |

### User Flow Verification
1. User lands on /projects → ProjectsPage
2. User clicks project → /projects/:id/board → KanbanBoardPage
3. All pages in flow must exist!

### UI Components Needed
| Component | Purpose | Exists? | Action |
|-----------|---------|---------|--------|
| LoginForm | User login form | ? | ? |
| Dialog | Confirm action | ? | ? |
| Toast | Show success/error | ? | ? |

### API Endpoints Needed
| Method | Path | Purpose | Exists? | Action |
|--------|------|---------|---------|--------|
| POST | /auth/login | Authenticate | ? | ? |
| GET | /users/me | Get current user | ? | ? |

### Services Needed
| Service | Purpose | Exists? | Action |
|---------|---------|---------|--------|
| AuthService | Handle auth logic | ? | ? |
| TokenService | Manage JWT | ? | ? |

### Shared Utilities Needed
| Utility | Purpose | Exists? | Action |
|---------|---------|---------|--------|
| validateEmail | Email format check | ? | ? |
| formatDate | Date display | ? | ? |
```

### Step 2: Check Existence (Quick scans only)

```bash
# Check Pages/Routes FIRST (most critical)
grep -rn "path.*projects" src/routes/ src/App.tsx 2>/dev/null
ls src/pages/Projects* src/pages/Kanban* 2>/dev/null

# Check UI components
ls src/components/ui/Dialog* 2>/dev/null
ls src/components/ui/Toast* 2>/dev/null
ls src/components/LoginForm* 2>/dev/null

# Check API endpoints
grep -r "POST.*login\|/auth/login" src/routes/ 2>/dev/null
grep -r "GET.*users/me" src/routes/ 2>/dev/null

# Check services
ls src/services/auth* src/services/Auth* 2>/dev/null
ls src/services/token* src/services/Token* 2>/dev/null

# Check utilities
grep -r "validateEmail\|formatDate" src/utils/ src/lib/ 2>/dev/null
```

### Step 3: Fill the Map

Update table with findings:

```markdown
### UI Components Needed
| Component | Purpose | Exists? | Action |
|-----------|---------|---------|--------|
| LoginForm | User login form | NO | CREATE |
| Dialog | Confirm action | YES | REUSE |
| Toast | Show success/error | YES | REUSE |
```

### Step 4: Determine Implementation Order

```markdown
## Implementation Order

### Must Create First (blockers)
1. AuthService - LoginForm depends on it
2. validateEmail utility - Form needs it

### Can Create in Parallel
- LoginForm (after AuthService)
- API endpoint (after AuthService)

### Already Exist (just import)
- Dialog
- Toast
```

### Step 5: Create Stubs for Missing Items

Before implementing main feature, create minimal stubs:

```typescript
// src/services/authService.ts (STUB)
export const authService = {
  login: async (email: string, password: string): Promise<User> => {
    throw new Error('Not implemented - TODO');
  },
  logout: async (): Promise<void> => {
    throw new Error('Not implemented - TODO');
  },
};
```

```typescript
// src/utils/validation.ts (STUB)
export const validateEmail = (email: string): boolean => {
  throw new Error('Not implemented - TODO');
};
```

This ensures:
- All imports work immediately
- TypeScript types are available
- No "module not found" errors during development

---

## Quick Dependency Extraction

### From Spec: UI Indicators

Look for these words in spec:
- "button" → needs Button component
- "form" → needs form handling, validation
- "dialog/modal" → needs Dialog component
- "list/table" → needs data display component
- "loading" → needs loading state/skeleton
- "error message" → needs error display
- "notification/toast" → needs Toast component
- "dropdown/select" → needs Select component

### From Spec: API Indicators

Look for these patterns:
- "create/add" → POST endpoint
- "update/edit" → PUT/PATCH endpoint
- "delete/remove" → DELETE endpoint
- "view/show/get" → GET endpoint
- "list/search" → GET with pagination
- "validate" → might need endpoint or client-side

### From Spec: Service Indicators

Look for:
- "authenticate" → AuthService
- "validate" → ValidationService or utility
- "send email" → EmailService
- "upload file" → FileService
- "payment" → PaymentService

---

## Output

Save dependency map to: `.claude/deps/{feature-name}.md`

```markdown
# Dependencies: {feature-name}

## Summary
- Components: 5 needed (3 exist, 2 to create)
- Endpoints: 3 needed (1 exists, 2 to create)
- Services: 2 needed (0 exist, 2 to create)
- Utilities: 4 needed (3 exist, 1 to create)

## Create First (Blockers)
1. AuthService
2. validateEmail

## Implementation Order
1. Create stubs for all missing
2. Implement AuthService
3. Implement LoginForm
4. Connect and test

## Time Estimate
- Stubs: 5 min
- AuthService: 30 min
- LoginForm: 45 min
- Integration: 15 min
```

---

## Integration with Workflow

### In Backend Command (Step 2)

Before implementing:
```bash
cat skills/dependency-map.md
```

Then run dependency mapping for API + Services.

### In Frontend Command (Step 5)

Before implementing:
```bash
cat skills/dependency-map.md
```

Then run dependency mapping for UI + API calls.

---

## Token Savings

| Without Mapping | With Mapping |
|-----------------|--------------|
| Discover missing dialog mid-way | Know upfront, stub first |
| Stop, create dialog, return | Linear implementation |
| Context lost, re-read files | Single focused session |
| ~15,000 tokens wasted | ~500 tokens for mapping |
