# Dev Plugin v0.1.0

**Quality Gate Development**: 8-step workflow with strict validation, token optimization, and continuous learning.

```
SPEC → BACKEND → UNIT → API → FRONTEND → UNIT → E2E → E2E INTEGRATION
[G1]    [G2]     [G3]   [G4]    [G5]      [G6]   [G7]      [G8]
                                          (mocked)    (real API)
```

Each step MUST pass its gate before proceeding. No exceptions.

## Installation

```bash
claude plugin add github:packlikez/claude-code-dev-plugin
```

## The Problem This Solves

Common AI development mistakes:
- Weak assertions that don't verify actual values
- Missing edge case tests
- Duplicate code instead of reusing existing
- Incomplete specs leading to rework
- Discovering missing components mid-implementation (token waste)
- Repeating the same mistakes across sessions

**Cost of bad early steps**: One incomplete spec = rework across all 8 steps.

## Commands

### Workflow Commands

| Step | Command | Purpose | API |
|------|---------|---------|-----|
| 0 | `/dev:init` | Initialize + gap analysis | - |
| 1 | `/dev:spec <name>` | Write specification (Gate 1) | - |
| 2 | `/dev:backend <name>` | Implement backend (Gate 2) | - |
| 3 | `/dev:backend-unit <name>` | Backend unit tests (Gate 3) | Mocked |
| 4 | `/dev:api-test <name>` | API integration tests (Gate 4) | Real |
| 5 | `/dev:frontend <name>` | Implement frontend (Gate 5) | - |
| 6 | `/dev:frontend-unit <name>` | Frontend unit tests (Gate 6) | Mocked |
| 7 | `/dev:e2e <name>` | E2E tests (Gate 7) | Mocked |
| 8 | `/dev:e2e-integration <name>` | E2E Integration (Gate 8) | Real |

### Utility Commands

| Command | Purpose |
|---------|---------|
| `/dev:status` | Smart status with next step recommendation |
| `/dev:preflight <name>` | Pre-check before implementation |
| `/dev:ensure <target>` | Verify feature/module is complete |
| `/dev:health` | Project health dashboard |
| `/dev:learn <category>` | Capture learnings from mistakes |

## Test Strategy

| Step | Scope | API | Speed | Purpose |
|------|-------|-----|-------|---------|
| 3 | Backend Unit | Mocked | Fast | Isolated logic |
| 4 | API Test | Real DB | Medium | Backend integration |
| 6 | Frontend Unit | Mocked | Fast | Component logic |
| 7 | E2E | Mocked | Fast | UI flows, stable |
| 8 | E2E Integration | Real | Slow | Full system validation |

## Agents

| Agent | Purpose |
|-------|---------|
| `spec-writer` | Write complete specs with strict template |
| `implementer` | Implement code with reuse-first approach |
| `test-writer` | Write tests with strong assertions |
| `gate-keeper` | Validate gate exit criteria + code quality |

## Skills

### Core Skills

| Skill | Purpose |
|-------|---------|
| `spec-convention` | Spec template + security, performance |
| `project-patterns` | Follow existing patterns |
| `api-contract` | API contract with pagination, caching |
| `ux-patterns` | Accessibility, responsive, forms |
| `dependency-map` | Map ALL dependencies before implementation |

### Test Pattern Skills

| Skill | Purpose |
|-------|---------|
| `test-patterns-unit` | Backend + frontend unit test patterns |
| `test-patterns-api` | API integration tests (real DB) |
| `test-patterns-ui` | E2E browser test patterns |

### Gate Criteria Skills

| Skill | Criteria |
|-------|----------|
| `gate-1-spec` | 25 criteria |
| `gate-2-backend` | 17 criteria |
| `gate-3-backend-unit` | 20 criteria |
| `gate-4-api-test` | 26 criteria |
| `gate-5-frontend` | 26 criteria |
| `gate-6-frontend-unit` | 24 criteria |
| `gate-7-e2e` | 16 criteria |
| `gate-8-e2e-integration` | 18 criteria |

## Quick Start

```bash
# 1. Initialize + analyze gaps
/dev:init

# 2. Check status
/dev:status

# 3. Follow the 8-step workflow
/dev:spec user-registration
/dev:backend user-registration
/dev:backend-unit user-registration
/dev:api-test user-registration
/dev:frontend user-registration
/dev:frontend-unit user-registration
/dev:e2e user-registration
/dev:e2e-integration user-registration
```

## Philosophy

```
TESTS PASSING ≠ WORKING

Real validation requires:
✓ Strong assertions on specific values
✓ All edge cases covered
✓ Dependencies mapped before coding
✓ Project patterns followed
✓ All 8 gates passed
✓ E2E with mocked API (fast, stable)
✓ E2E Integration with real API (final validation)
```

## License

MIT
