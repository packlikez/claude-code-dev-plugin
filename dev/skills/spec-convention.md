---
name: spec-convention
description: Strict specification template that MUST be followed exactly
---

# Specification Convention

Every specification MUST follow this template exactly. No sections can be skipped.

## Required Template

```markdown
# Feature: {feature-name}

## Meta
- **Type**: feature | bug-fix | enhancement | api
- **Priority**: critical | high | medium | low
- **Layers**: backend | frontend | full-stack
- **Status**: draft | review | approved

## User Story
As a {role},
I want to {action},
So that {benefit}.

## Acceptance Criteria
- [ ] GIVEN {context} WHEN {action} THEN {result}
- [ ] GIVEN {context} WHEN {action} THEN {result}
- [ ] GIVEN {context} WHEN {action} THEN {result}

(Minimum 3 criteria required. Each MUST be in GIVEN/WHEN/THEN format.)

## API Contract

### Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | /api/... | ... |
| GET | /api/... | ... |

### Request/Response Details

#### {METHOD} {PATH}

**Request:**
```json
{
  "field": "type (constraints)"
}
```

**Success Response ({status}):**
```json
{
  "field": "type"
}
```

**Error Responses:**

| Status | Error Code | Message | When |
|--------|------------|---------|------|
| 400 | VALIDATION_ERROR | {message} | Invalid input |
| 401 | UNAUTHORIZED | Not authenticated | No/invalid token |
| 403 | FORBIDDEN | Not authorized | Wrong role/permission |
| 404 | NOT_FOUND | {resource} not found | ID doesn't exist |
| 409 | CONFLICT | {resource} already exists | Duplicate unique field |
| 500 | INTERNAL_ERROR | Something went wrong | Server error |

## Data Model

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, auto-generated | Unique identifier |
| ... | ... | ... | ... |

### Indexes
- {index definition}

### Relationships
- {relationship definition}

## Edge Cases

| Scenario | Input | Expected Behavior |
|----------|-------|-------------------|
| Empty input | `""` or `[]` | Return 400: "Field required" |
| Null value | `null` | Return 400: "Field required" |
| Invalid format | `"invalid"` | Return 400: "Invalid format" |
| Boundary - min | `0` or min value | {expected behavior} |
| Boundary - max | max value | {expected behavior} |
| Duplicate | existing value | Return 409: "Already exists" |
| Not found | non-existent ID | Return 404: "Not found" |
| Unauthorized | no token | Return 401: "Unauthorized" |
| Forbidden | wrong role | Return 403: "Forbidden" |

(Minimum 5 edge cases required)

## UI Screens (Required for frontend/full-stack)

### Pages/Routes
| Route | Page Component | Purpose |
|-------|----------------|---------|
| /projects | ProjectsPage | List all projects |
| /projects/:id/board | KanbanBoardPage | Kanban view for project |

### User Flow
```
1. User lands on /projects
2. User sees list of projects (ProjectsPage)
3. User clicks a project
4. User redirected to /projects/:id/board
5. User sees Kanban board (KanbanBoardPage)
```

### Screen Details

#### {ScreenName}
- **Route**: /path
- **Components needed**: List, Card, Button
- **Data displayed**: name, status, count
- **Actions**: create, edit, delete
- **States**: loading, empty, error

(List ALL screens in the user flow. Missing screens = incomplete spec.)

## Security Requirements

### Authentication & Authorization
| Requirement | Details |
|-------------|---------|
| Auth required | Yes/No |
| Auth method | JWT/Session/API Key |
| Roles allowed | admin, user, guest |
| Resource ownership | User can only access own resources |

### Input Validation
| Field | Validation | Sanitization |
|-------|------------|--------------|
| email | Email format | Lowercase, trim |
| name | 1-255 chars | Trim, escape HTML |
| content | Max 10000 chars | Sanitize HTML |

### Security Considerations
- [ ] SQL injection: Use parameterized queries
- [ ] XSS: Sanitize user input before rendering
- [ ] CSRF: Include CSRF token for mutations
- [ ] Rate limiting: {X} requests per {time window}
- [ ] Sensitive data: {fields to encrypt/hash}

## Performance Requirements

### Response Time Targets
| Operation | Target | Max |
|-----------|--------|-----|
| List (paginated) | < 100ms | 500ms |
| Get single | < 50ms | 200ms |
| Create | < 200ms | 1000ms |
| Update | < 200ms | 1000ms |
| Delete | < 100ms | 500ms |

### Scalability
- Expected load: {X} requests/second
- Data volume: {X} records expected
- Pagination: Required for lists > 20 items
- Caching: {strategy - none/redis/in-memory}

### Database Considerations
- Indexes needed: {list required indexes}
- Query complexity: {simple/join/aggregate}
- Batch operations: {if applicable}

## Observability

### Logging Requirements
| Event | Level | Data to Log |
|-------|-------|-------------|
| Request received | INFO | method, path, userId |
| Validation failed | WARN | field, error, input |
| Resource not found | WARN | resourceId, userId |
| Server error | ERROR | error, stack, context |
| Success | INFO | action, resourceId, duration |

### Metrics to Track
- [ ] Request count by endpoint
- [ ] Response time percentiles (p50, p95, p99)
- [ ] Error rate by type
- [ ] Active users

### Alerts
- Error rate > 1%: Warning
- Error rate > 5%: Critical
- Response time p95 > 500ms: Warning

## Migration & Rollback

### Database Migration
```sql
-- UP: Changes to apply
ALTER TABLE users ADD COLUMN new_field VARCHAR(255);

-- DOWN: How to rollback
ALTER TABLE users DROP COLUMN new_field;
```

### Feature Flags
- Flag name: `feature_{feature-name}`
- Default: disabled
- Rollout plan: 1% → 10% → 50% → 100%

### Rollback Plan
1. Disable feature flag
2. Run DOWN migration
3. Deploy previous version
4. Notify stakeholders

## Out of Scope
- {feature or functionality NOT included}
- {future consideration}

## Dependencies
- [ ] {required dependency}
- [ ] {external service}
```

## Validation Rules

### User Story
- MUST have all three parts: As a / I want / So that
- Role must be specific (not "user")
- Action must be concrete
- Benefit must be clear

### Acceptance Criteria
- MUST have minimum 3 criteria
- Each MUST be in GIVEN/WHEN/THEN format
- Each MUST be testable (yes/no answer possible)
- NO ambiguous words: should, might, could, maybe

### API Contract
- MUST list ALL endpoints
- MUST include request body/params
- MUST include ALL response codes (success + errors)
- MUST have specific error messages

### Edge Cases
- MUST have minimum 5 cases
- MUST include: empty, null, boundary, duplicate, not found

### Security Requirements
- MUST specify auth required (yes/no)
- MUST list allowed roles
- MUST identify sensitive fields
- MUST specify rate limiting

### Performance Requirements
- MUST set response time targets
- MUST identify caching strategy
- MUST specify pagination for lists

### Observability
- MUST define what to log
- MUST specify log levels
- MUST identify key metrics

### UI Screens (for frontend/full-stack)
- MUST list ALL pages/routes in user flow
- MUST show user navigation flow
- MUST specify each screen's components
- MUST identify ALL states (loading, empty, error)
- Missing screen in spec = incomplete feature

## Anti-Patterns

```markdown
❌ BAD: "User should be able to register"
✓ GOOD: "GIVEN a new visitor WHEN they submit valid registration form THEN account is created"

❌ BAD: "Handle errors appropriately"
✓ GOOD: "GIVEN invalid email WHEN submitted THEN return 400 with 'Invalid email format'"

❌ BAD: Response: { success: true }
✓ GOOD: Response: { id: "uuid", email: "string", createdAt: "iso8601" }

❌ BAD: Edge cases: "Handle edge cases"
✓ GOOD: Edge cases table with specific scenarios
```

## File Location

Save specs to: `specs/{type}/{feature-name}.md`

Types:
- `features/` - New functionality
- `api/` - API-only changes
- `bug-fixes/` - Bug fix specifications
- `enhancements/` - Improvements
