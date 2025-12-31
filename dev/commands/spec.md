---
name: dev:spec
description: "Step 1: Write specification with strict template - GATE 1 validation required"
argument-hint: "<feature-name>"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Task
  - AskUserQuestion
---

# Step 1: Write Specification

## Process

### 1. Gather Requirements

Use AskUserQuestion tool to clarify:
- What is the feature?
- Who is it for? (specific role)
- What problem does it solve?
- What are the success criteria?

### 2. Tech Stack Confirmation

Use AskUserQuestion to confirm:
```
Backend: Language, Framework, ORM, Validation, Auth
Frontend: Framework, State, UI Library, Forms, Styling
```

Use WebSearch/Context7 to verify latest library versions.

### 3. Cross-Feature Awareness

```bash
# Check existing specs for conflicts
ls specs/features/ specs/api/
grep -r "{keyword}" specs/
```

Document: Related Features, Shared Resources, Dependencies.

### 4. Delegate to Spec Writer

Use Task tool with `spec-writer` agent:

```markdown
# Feature: {name}

## User Story
As a {role}, I want to {action}, So that {benefit}.

## Acceptance Criteria (≥3)
- [ ] GIVEN {context} WHEN {action} THEN {result}

## API Contract
| Method | Path | Description |
|--------|------|-------------|

### Request/Response for each endpoint
- Success response
- Error responses (400, 401, 403, 404, 409)

## Data Model
- Tables with constraints
- Relationships (FKs)
- Indexes

## Edge Cases (≥5)
| Scenario | Expected Behavior |

## Related Features
| Feature | Relationship |

## Shared Resources
- Tables, APIs, Components shared with other features

## Out of Scope
- What is NOT included
```

### 5. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 1 for {feature-name}
```

See `gate-1-spec` skill for all 18 criteria.

## GATE 1 Checklist

```
□ Has User Story (As a/I want/So that)
□ Has Acceptance Criteria (≥3, GIVEN/WHEN/THEN)
□ Has API Contract with ALL responses
□ Has Data Model (normalized 3NF)
□ Has Edge Cases (≥5)
□ Has Related Features section
□ Has Out of Scope section
□ Each criterion is testable
□ No conflicts with existing specs
```

## Output

- `specs/{type}/{feature-name}.md`
- Types: `features/`, `api/`, `bug-fixes/`, `enhancements/`
