---
name: spec-planning
description: Plan mode for specifications - discover, design, confirm before writing
---

# Spec Planning (Plan Mode)

**Never write a spec in one pass.** Use this planning process to ensure nothing is missed.

## Why Plan Mode?

| Without Planning | With Planning |
|------------------|---------------|
| Miss edge cases | All cases discovered upfront |
| Vague API design | Field-by-field API contract |
| Missing UI states | Every screen state documented |
| Assumptions by implementer | Explicit decisions by user |
| Rework during implementation | Clean implementation |

---

## The 5-Phase Process

```
Phase 1: DISCOVER → Understand context, find similar features
Phase 2: CLARIFY  → Ask ALL questions upfront
Phase 3: DESIGN   → API + UI in detail, get confirmation
Phase 4: COMPILE  → Write complete spec
Phase 5: VALIDATE → User confirms before implementation
```

---

## Phase 1: DISCOVER (Before Asking User Anything)

### 1.1 Find Similar Features

```bash
# Find existing specs for patterns
ls specs/features/ specs/api/ 2>/dev/null

# Find similar implementations
grep -r "{keyword}" src/services/ src/components/

# Find existing API patterns
grep -r "router\.\|app\." src/routes/ src/api/

# Find existing UI patterns
ls src/components/ src/pages/
```

### 1.2 Document Discoveries

```markdown
## Discovery Notes

### Similar Features Found
- {feature}: {path} - {what to reuse}

### Existing Patterns
- API: {pattern description}
- UI: {pattern description}
- Validation: {library/approach}

### Constraints Discovered
- {technical constraint}
- {business constraint}
```

---

## Phase 2: CLARIFY (Ask Before Designing)

### 2.1 Required Questions

**ALWAYS ask these before any design:**

```markdown
## Clarification Questions

### Core Functionality
1. What problem does this solve?
2. Who is the primary user?
3. What is the success metric?

### Scope
4. What is explicitly OUT of scope?
5. What are the must-have vs nice-to-have features?
6. Are there time/resource constraints?

### Technical
7. Does this integrate with existing features? Which?
8. Are there performance requirements?
9. Are there security considerations?

### UI/UX
10. Is there a design mockup or reference?
11. What devices/browsers must be supported?
12. Are there accessibility requirements?
```

### 2.2 Feature-Specific Questions

Based on feature type, ask additional questions:

**For CRUD Features:**
- What fields are required vs optional?
- What are the validation rules for each field?
- Who can create/read/update/delete?
- Is soft delete or hard delete?

**For Authentication Features:**
- What auth method? (JWT, session, OAuth)
- What are the password requirements?
- Is MFA required?
- What happens on failed login attempts?

**For Payment Features:**
- What payment providers?
- What currencies supported?
- Refund policy?
- Tax handling?

**For Notification Features:**
- What channels? (email, SMS, push, in-app)
- What triggers notifications?
- Can users configure preferences?
- Rate limiting on notifications?

### 2.3 Wait for Answers

**DO NOT proceed to design until ALL questions answered.**

Use AskUserQuestion tool:

```yaml
AskUserQuestion:
  questions:
    - question: "What fields should the user profile have?"
      header: "Profile Fields"
      options:
        - label: "Basic (name, email, avatar)"
          description: "Minimal profile"
        - label: "Extended (+ bio, location, social links)"
          description: "Full profile with social features"
        - label: "Custom"
          description: "I'll specify the fields"
      multiSelect: false
```

---

## Phase 3: DESIGN (Get Confirmation Before Spec)

### 3.1 API Design Summary

Present to user for confirmation:

```markdown
## API Design (Please Confirm)

### Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /api/users | No | Create account |
| GET | /api/users/:id | Yes | Get profile |
| PUT | /api/users/:id | Yes | Update profile |
| DELETE | /api/users/:id | Yes | Delete account |

### Create User Request Fields
| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| email | string | Yes | Valid email, unique | "user@example.com" |
| password | string | Yes | Min 8 chars, 1 number, 1 special | "SecurePass1!" |
| name | string | Yes | 1-100 chars | "John Doe" |
| avatar | string | No | Valid URL or null | "https://..." |

### Create User Response
| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Unique identifier |
| email | string | User's email |
| name | string | User's display name |
| createdAt | iso8601 | Account creation timestamp |

### Error Responses
| Status | Code | Message | When |
|--------|------|---------|------|
| 400 | VALIDATION_ERROR | "Email is required" | Missing email |
| 400 | VALIDATION_ERROR | "Invalid email format" | Bad email |
| 400 | VALIDATION_ERROR | "Password too weak" | Bad password |
| 409 | CONFLICT | "Email already exists" | Duplicate email |

**Does this API design look correct? Any changes needed?**
```

### 3.2 UI Design Summary

Present to user for confirmation:

```markdown
## UI Design (Please Confirm)

### Screen: Registration Page
**Route:** /register

**Layout:**
```
┌─────────────────────────────────────┐
│           Logo                       │
├─────────────────────────────────────┤
│         Create Account               │
│                                      │
│  ┌─────────────────────────────┐    │
│  │ Email                        │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ Password          [👁]       │    │
│  └─────────────────────────────┘    │
│  Password strength: [████░░░░]      │
│                                      │
│  ┌─────────────────────────────┐    │
│  │ Full Name                    │    │
│  └─────────────────────────────┘    │
│                                      │
│  [        Create Account        ]    │
│                                      │
│  Already have an account? Log in     │
└─────────────────────────────────────┘
```

**Components:**
- Logo (existing: src/components/Logo)
- FormField (existing: src/components/ui/FormField)
- PasswordInput (NEW - with show/hide toggle)
- PasswordStrength (NEW - strength indicator)
- Button (existing: src/components/ui/Button)
- Link (existing)

**States:**
| State | Behavior |
|-------|----------|
| Initial | Empty form, submit disabled |
| Typing | Validate on blur, enable submit when valid |
| Submitting | Button shows spinner, fields disabled |
| Error | Show field errors, focus first error |
| Success | Redirect to /dashboard |

**Interactions:**
- Email: Validate email format on blur
- Password: Show/hide toggle, strength indicator updates on type
- Submit: Validate all, show loading, handle errors

**Responsive:**
- Mobile: Full width, stacked
- Desktop: Centered card (max-width 400px)

**Does this UI design look correct? Any changes needed?**
```

### 3.3 Confirm Before Proceeding

```markdown
## Design Confirmation

### API Design
- [ ] Endpoints confirmed
- [ ] Request fields confirmed
- [ ] Response fields confirmed
- [ ] Error cases confirmed

### UI Design
- [ ] Screens confirmed
- [ ] Components confirmed
- [ ] States confirmed
- [ ] Interactions confirmed

**Ready to write the full specification?**
```

---

## Phase 4: COMPILE (Write Complete Spec)

Only after Phase 3 confirmation, write the full spec using `spec-convention` skill.

Include EVERYTHING discussed:
- All API fields with exact validation rules
- All UI screens with exact states
- All error messages verbatim
- All edge cases discovered

---

## Phase 5: VALIDATE (Final Check)

### 5.1 Completeness Checklist

```markdown
## Spec Validation

### API Completeness
- [ ] All endpoints have request/response defined
- [ ] All fields have type, required, validation
- [ ] All error codes have specific message
- [ ] Auth requirements specified per endpoint
- [ ] Rate limiting defined

### UI Completeness
- [ ] All screens have layout mockup
- [ ] All components listed (existing vs new)
- [ ] All states defined (loading, error, empty, success)
- [ ] All interactions described
- [ ] Responsive behavior specified
- [ ] Accessibility requirements noted

### Edge Cases
- [ ] Empty input handling
- [ ] Invalid input handling
- [ ] Network failure handling
- [ ] Concurrent access handling
- [ ] Permission edge cases

### Integration
- [ ] Dependencies on other features listed
- [ ] Impact on existing features noted
```

### 5.2 Present for Final Approval

```markdown
## Specification Complete

**Feature:** {name}
**Spec File:** specs/features/{name}.md

### Summary
- {n} API endpoints
- {n} UI screens
- {n} new components
- {n} edge cases covered

### Key Decisions Made
1. {decision 1}
2. {decision 2}
3. {decision 3}

**Please review the spec. Ready to proceed to implementation?**
```

---

## Quick Reference

### Before Writing Anything
1. Search for similar features
2. Ask ALL clarifying questions
3. Wait for answers

### Before Compiling Spec
4. Present API design for confirmation
5. Present UI design for confirmation
6. Get explicit approval

### Before Implementation
7. Present complete spec
8. Get final approval

**The goal: Zero assumptions by implementer. Every detail explicit.**
