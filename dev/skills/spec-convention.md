---
name: spec-convention
description: Complete specification template - every section required, every detail explicit
---

# Specification Convention

Every specification MUST follow this template. **No section can be skipped. No detail left vague.**

## Required Template

```markdown
# Feature: {feature-name}

## Meta

| Field | Value |
|-------|-------|
| Type | feature / bug-fix / enhancement / api |
| Priority | critical / high / medium / low |
| Layers | backend / frontend / full-stack |
| Status | draft / review / approved |
| Author | {name} |
| Created | {date} |
| Updated | {date} |

---

## User Story

**As a** {specific role},
**I want to** {specific action},
**So that** {specific benefit}.

---

## Acceptance Criteria

Minimum 3 criteria. Each MUST be in GIVEN/WHEN/THEN format.

1. **GIVEN** {context/precondition}
   **WHEN** {action taken}
   **THEN** {expected result}

2. **GIVEN** {context/precondition}
   **WHEN** {action taken}
   **THEN** {expected result}

3. **GIVEN** {context/precondition}
   **WHEN** {action taken}
   **THEN** {expected result}

---

## API Contract

### Endpoints Overview

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /api/... | Yes/No | {description} |
| GET | /api/... | Yes/No | {description} |
| PUT | /api/... | Yes/No | {description} |
| DELETE | /api/... | Yes/No | {description} |

### Endpoint Details

#### {METHOD} {PATH}

**Description:** {what this endpoint does}

**Authentication:** {None / Bearer Token / API Key}

**Authorization:** {Any user / Roles: admin, user / Owner only}

**Rate Limit:** {X requests per minute}

**Request Headers:**
| Header | Required | Value |
|--------|----------|-------|
| Content-Type | Yes | application/json |
| Authorization | Yes/No | Bearer {token} |

**Request Body:**
| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| field1 | string | Yes | {rules} | "example" |
| field2 | number | No | {rules} | 123 |

**Validation Error Messages:**
| Field | Rule | Message |
|-------|------|---------|
| field1 | required | "Field1 is required" |
| field1 | format | "Invalid field1 format" |
| field2 | min | "Field2 must be at least X" |

**Success Response ({status}):**
```json
{
  "field": "value"
}
```

**Error Responses:**
| Status | Code | Message | When |
|--------|------|---------|------|
| 400 | VALIDATION_ERROR | "{specific message}" | {condition} |
| 401 | UNAUTHORIZED | "Authentication required" | No/invalid token |
| 403 | FORBIDDEN | "Permission denied" | Wrong role |
| 404 | NOT_FOUND | "{Resource} not found" | ID doesn't exist |
| 409 | CONFLICT | "{Resource} already exists" | Duplicate |
| 429 | RATE_LIMIT | "Too many requests" | Rate exceeded |
| 500 | INTERNAL_ERROR | "Something went wrong" | Server error |

---

## Data Model

### Entity: {EntityName}

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, auto-generated | Unique identifier |
| field1 | VARCHAR(255) | NOT NULL, UNIQUE | {description} |
| field2 | INTEGER | DEFAULT 0 | {description} |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation time |
| updated_at | TIMESTAMP | NOT NULL | Last update time |

### Indexes

| Name | Fields | Type | Purpose |
|------|--------|------|---------|
| idx_entity_field1 | field1 | UNIQUE | Fast lookup by field1 |
| idx_entity_created | created_at | BTREE | Sort by creation date |

### Relationships

| From | To | Type | On Delete |
|------|-----|------|-----------|
| Entity.user_id | User.id | Many-to-One | CASCADE |
| Entity.id | Child.entity_id | One-to-Many | CASCADE |

---

## UI Screens

### Screen: {ScreenName}

**Route:** /{path}

**Title:** "{Page Title} | App Name"

**Auth Required:** Yes/No

**Layout:**
```
┌─────────────────────────────────────────────────┐
│ [Header]                                         │
├─────────────────────────────────────────────────┤
│                                                 │
│   Page Title                    [Action Button] │
│                                                 │
│   ┌─────────────────────────────────────────┐  │
│   │ Content Area                            │  │
│   │                                         │  │
│   └─────────────────────────────────────────┘  │
│                                                 │
│   [Footer Actions]                              │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Components:**
| Component | Source | Props/Notes |
|-----------|--------|-------------|
| Header | existing: src/components/Header | - |
| Button | existing: src/components/ui/Button | variant, onClick |
| NewComponent | NEW | {description of what to create} |

**States:**
| State | Condition | Display |
|-------|-----------|---------|
| Loading | isLoading=true | Skeleton matching layout |
| Empty | data.length=0 | EmptyState with CTA |
| Error | error!=null | ErrorState with retry |
| Success | data.length>0 | Actual content |

**Interactions:**
| Element | Event | Behavior |
|---------|-------|----------|
| Action Button | click | {what happens} |
| Row | click | Navigate to /{path}/{id} |
| Delete | click | Show confirm dialog |

**Responsive:**
| Breakpoint | Changes |
|------------|---------|
| Mobile (<640px) | {layout changes} |
| Tablet (640-1024px) | {layout changes} |
| Desktop (>1024px) | Full layout as shown |

**Accessibility:**
- [ ] Keyboard navigation works
- [ ] Screen reader announces dynamic content
- [ ] Focus management on modal open/close
- [ ] Color contrast meets WCAG AA

---

## Edge Cases

| # | Scenario | Input | Expected Behavior |
|---|----------|-------|-------------------|
| 1 | Empty input | "" or [] | Return 400: "Field is required" |
| 2 | Null value | null | Return 400: "Field is required" |
| 3 | Invalid format | "invalid" | Return 400: "Invalid format" |
| 4 | Boundary - min | 0 or min value | {accept/reject with message} |
| 5 | Boundary - max | max value | {accept/reject with message} |
| 6 | Over max | max + 1 | Return 400: "Exceeds maximum" |
| 7 | Duplicate | existing value | Return 409: "Already exists" |
| 8 | Not found | non-existent ID | Return 404: "Not found" |
| 9 | Unauthorized | no token | Return 401: "Unauthorized" |
| 10 | Forbidden | wrong role | Return 403: "Forbidden" |
| 11 | Network failure | connection lost | Show error, retry button |
| 12 | Concurrent edit | stale data | Return 409 or merge strategy |

(Minimum 5 edge cases required)

---

## Security Requirements

### Authentication & Authorization

| Requirement | Details |
|-------------|---------|
| Auth required | Yes/No |
| Auth method | JWT / Session / API Key |
| Token location | Authorization header / Cookie |
| Token expiry | {duration} |
| Refresh strategy | {how tokens are refreshed} |
| Roles allowed | admin, user, guest |
| Resource ownership | User can only access own resources |

### Input Validation

| Field | Validation | Sanitization |
|-------|------------|--------------|
| email | Email format | Lowercase, trim |
| name | 1-100 chars, letters/spaces | Trim, escape HTML |
| content | Max 10000 chars | Sanitize HTML |
| file | Max 5MB, types: jpg/png | Virus scan |

### Security Considerations

- [ ] SQL injection: Use parameterized queries
- [ ] XSS: Sanitize user input before rendering
- [ ] CSRF: Include CSRF token for mutations
- [ ] Rate limiting: {X} requests per {time window}
- [ ] Sensitive data: {fields to encrypt/hash}
- [ ] Audit logging: Log {actions} with {data}

---

## Performance Requirements

### Response Time Targets

| Operation | Target | Max |
|-----------|--------|-----|
| List (paginated) | <100ms | 500ms |
| Get single | <50ms | 200ms |
| Create | <200ms | 1000ms |
| Update | <200ms | 1000ms |
| Delete | <100ms | 500ms |

### Scalability

| Metric | Expectation |
|--------|-------------|
| Concurrent users | {number} |
| Requests/second | {number} |
| Data volume | {number} records |
| Growth rate | {X}% per month |

### Caching Strategy

| Resource | Cache | TTL | Invalidation |
|----------|-------|-----|--------------|
| List | Redis | 5 min | On create/update/delete |
| Single | Redis | 10 min | On update/delete |
| Static | CDN | 1 day | On deploy |

### Pagination

- Default page size: 20
- Max page size: 100
- Strategy: Offset / Cursor

---

## Observability

### Logging

| Event | Level | Data to Log |
|-------|-------|-------------|
| Request received | INFO | method, path, userId |
| Validation failed | WARN | field, error, sanitized input |
| Resource not found | WARN | resourceId, userId |
| Permission denied | WARN | userId, resource, action |
| Server error | ERROR | error, stack, context |
| Success | INFO | action, resourceId, duration |

### Metrics

- [ ] Request count by endpoint
- [ ] Response time percentiles (p50, p95, p99)
- [ ] Error rate by type
- [ ] Active users / sessions

### Alerts

| Condition | Severity | Action |
|-----------|----------|--------|
| Error rate > 1% | Warning | Notify on-call |
| Error rate > 5% | Critical | Page on-call |
| P95 latency > 500ms | Warning | Notify team |
| P95 latency > 2s | Critical | Page on-call |

---

## Migration & Rollback

### Database Migration

```sql
-- UP
{SQL to apply changes}

-- DOWN
{SQL to rollback changes}
```

### Feature Flag

| Setting | Value |
|---------|-------|
| Flag name | feature_{feature-name} |
| Default | disabled |
| Rollout | 1% → 10% → 50% → 100% |

### Rollback Plan

1. Disable feature flag
2. Run DOWN migration
3. Deploy previous version
4. Notify stakeholders
5. Post-mortem if needed

---

## Out of Scope

- {feature or functionality NOT included}
- {future consideration - explicitly deferred}
- {related feature that is separate}

---

## Dependencies

### Existing Features

- [ ] {feature that must exist}
- [ ] {API that will be used}

### External Services

- [ ] {third-party service}
- [ ] {external API}

### New Infrastructure

- [ ] {new service/database needed}
- [ ] {configuration required}

---

## Testing Requirements

### Unit Tests

- [ ] All service methods tested
- [ ] All validation rules tested
- [ ] All error cases tested

### Integration Tests

- [ ] All API endpoints tested
- [ ] All response codes verified
- [ ] Database state verified

### E2E Tests

- [ ] Happy path tested
- [ ] Error recovery tested
- [ ] Cross-browser tested (Chrome, Firefox, Safari)
- [ ] Mobile responsive tested

---

## Implementation Notes

{Any additional context for implementers}

---

## Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | {author} | Initial specification |
```

---

## Validation Checklist

Before marking spec as complete:

```markdown
## Spec Completeness

### Meta
- [ ] All meta fields filled
- [ ] Status is appropriate

### User Story
- [ ] Role is specific (not generic "user")
- [ ] Action is concrete
- [ ] Benefit is clear

### Acceptance Criteria
- [ ] At least 3 criteria
- [ ] All in GIVEN/WHEN/THEN format
- [ ] Each is testable (yes/no answer)
- [ ] No ambiguous words (should, might, could)

### API Contract
- [ ] All endpoints listed
- [ ] All request fields have type, required, validation
- [ ] All validation rules have error messages
- [ ] All response codes documented
- [ ] Rate limiting specified

### Data Model
- [ ] All fields with types and constraints
- [ ] Indexes defined
- [ ] Relationships documented

### UI Screens
- [ ] ASCII mockup for each screen
- [ ] Components listed (existing vs new)
- [ ] All states defined (loading, empty, error, success)
- [ ] Interactions documented
- [ ] Responsive behavior specified
- [ ] Accessibility requirements noted

### Edge Cases
- [ ] At least 5 edge cases
- [ ] Includes: empty, null, boundary, duplicate, not found

### Security
- [ ] Auth requirements clear
- [ ] Input validation per field
- [ ] Security considerations listed

### Performance
- [ ] Response time targets set
- [ ] Caching strategy defined
- [ ] Pagination specified

### Observability
- [ ] Logging events defined
- [ ] Metrics identified
- [ ] Alerts configured
```

---

## Anti-Patterns

```markdown
❌ "User should be able to register"
✅ "GIVEN a visitor WHEN submitting valid form THEN account created"

❌ "Handle errors appropriately"
✅ Table with every error: status, code, message, when

❌ "Show user list"
✅ ASCII mockup + states + interactions + responsive

❌ Response: { success: true }
✅ Response: { id, email, name, createdAt } with types

❌ "Validate input"
✅ Field-by-field validation rules with error messages
```

---

## File Location

Save specs to: `specs/{type}/{feature-name}.md`

| Type | Folder | Use When |
|------|--------|----------|
| feature | specs/features/ | New functionality |
| api | specs/api/ | API-only changes |
| bug-fix | specs/bug-fixes/ | Bug fix specifications |
| enhancement | specs/enhancements/ | Improvements to existing |
