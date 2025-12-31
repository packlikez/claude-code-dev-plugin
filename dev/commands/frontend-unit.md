---
name: dev:frontend-unit
description: "Step 6: Frontend unit tests - requires GATE 5 passed"
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

# Step 6: Frontend Unit Tests

## Prerequisites

```
□ GATE 5 PASSED (frontend implementation complete)
□ All components implemented
□ Build passes
```

## Process

### 1. Load Context

```bash
cat specs/{type}/{feature-name}.md         # Spec
cat api-contracts/{feature}.yaml           # API contract
cat src/components/{feature}/*.tsx         # Components
cat src/hooks/use{Feature}.ts              # Hooks
cat skills/test-patterns-unit.md           # Unit test patterns
cat skills/gate-6-frontend-unit.md         # Gate 6 criteria
```

### 2. Create Test Checklist from Spec

```markdown
## Test Checklist

### Component Tests
- [ ] Default render
- [ ] Props variations
- [ ] Loading state
- [ ] Error state
- [ ] Empty state

### Hook Tests
- [ ] Initial state
- [ ] Success state
- [ ] Error state

### Interaction Tests
- [ ] Form submission (exact callback args)
- [ ] Button clicks
- [ ] Validation errors
```

### 3. Delegate to Test Writer

Use Task tool with `test-writer` agent:
```
Write frontend unit tests for {feature-name}:
- Every component state (loading, error, empty, success)
- Every hook state
- User interactions with exact assertions
- Accessibility (keyboard, axe audit)
- Follow test-patterns-unit skill
```

### 4. Key Requirements

From `test-patterns-unit` skill:
- Strong assertions (not just toBeInTheDocument)
- AAA pattern
- Fixtures and helpers
- Mock API responses (MSW)
- ZERO weak assertions

From spec:
- Every acceptance criterion tested
- Every error state tested
- Forms match validation rules

### 5. Accessibility Tests

```typescript
// Required for every component
it('should pass axe audit', async () => {
  const { container } = render(<Component />);
  expect(await axe(container)).toHaveNoViolations();
});

it('should be keyboard navigable', async () => {
  await userEvent.tab();
  expect(screen.getByLabelText('Email')).toHaveFocus();
});
```

### 6. Validate Gate

Use Task tool with `gate-keeper` agent:
```
Validate GATE 6 for {feature-name}
```

See `gate-6-frontend-unit` skill for all 24 criteria.

## Output

- Component tests: `tests/unit/components/{feature}/`
- Hook tests: `tests/unit/hooks/`
- Coverage report
