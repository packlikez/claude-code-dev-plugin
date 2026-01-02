# Dev Plugin v0.2.0

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

## What's New in v0.2.0

- **Simplified Test Strategy**: E2E with mocked API (fast) + E2E Integration with real API (final)
- **Screen Verification**: Spec must list ALL UI screens, gate-5 verifies all exist
- **Utility Commands**: preflight, ensure, health, learn for better project management
- **Dependency Mapping**: Pages/Routes checked first before implementation
- **Learning System**: Capture mistakes and improve system over time

## The Problem This Solves

Common AI development mistakes:
- Weak assertions that don't verify actual values
- Missing edge case tests
- Missing screens/pages discovered mid-implementation
- Duplicate code instead of reusing existing
- Incomplete specs leading to rework
- Repeating the same mistakes across sessions

**Cost of bad early steps**: One incomplete spec = rework across all 8 steps.

## Commands

### Workflow Commands (14 total)

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
| `/dev:preflight <name>` | Pre-check before implementation (spec, env, deps) |
| `/dev:ensure <target>` | Verify feature/module is complete (runs all gates) |
| `/dev:health` | Project health dashboard (tests, coverage, quality) |
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

All agents include:
- **`concurrent` skill** - Context management and token optimization
- **`learning` skill** - Capture issues and improve system

## Skills (18 total)

### Core Skills

| Skill | Purpose |
|-------|---------|
| `spec-convention` | Spec template + security, performance, UI screens |
| `project-patterns` | Follow existing patterns |
| `api-contract` | API contract with pagination, caching |
| `ux-patterns` | Accessibility, responsive, forms |
| `dependency-map` | Map ALL dependencies (pages first!) |

### Test Pattern Skills

| Skill | Purpose |
|-------|---------|
| `test-patterns-unit` | Backend + frontend unit test patterns |
| `test-patterns-api` | API integration tests (real DB) |
| `test-patterns-ui` | E2E browser test patterns |

### System Skills

| Skill | Purpose |
|-------|---------|
| `concurrent` | Manage context limits, checkpoints |
| `learning` | Capture mistakes, improve system |

### Gate Criteria Skills

| Skill | Criteria |
|-------|----------|
| `gate-1-spec` | 25 criteria |
| `gate-2-backend` | 17 criteria |
| `gate-3-backend-unit` | 20 criteria |
| `gate-4-api-test` | 26 criteria |
| `gate-5-frontend` | 26 criteria (+ screen verification) |
| `gate-6-frontend-unit` | 24 criteria |
| `gate-7-e2e` | 16 criteria |
| `gate-8-e2e-integration` | 18 criteria |

## Key Features

### Screen Verification (Prevents Missing Pages)

Spec must list ALL screens:
```markdown
## UI Screens
| Route | Page Component | Purpose |
|-------|----------------|---------|
| /projects | ProjectsPage | List projects |
| /projects/:id/board | KanbanBoardPage | Kanban view |
```

Gate 5 verifies ALL screens exist before passing.

### Dependency Mapping

Before implementation, map ALL dependencies (pages first!):
```markdown
### Pages/Routes Needed (CRITICAL)
| Route | Component | Exists? | Action |
|-------|-----------|---------|--------|
| /projects | ProjectsPage | NO | CREATE |
```

### Learning System

Capture mistakes to improve over time:
```bash
/dev:learn spec-gaps      # Spec was incomplete
/dev:learn test-issues    # Tests missed edge cases
```

## Quick Start

```bash
# 1. Initialize + analyze gaps
/dev:init

# 2. Pre-check before starting
/dev:preflight user-registration

# 3. Follow the 8-step workflow
/dev:spec user-registration
/dev:backend user-registration
/dev:backend-unit user-registration
/dev:api-test user-registration
/dev:frontend user-registration
/dev:frontend-unit user-registration
/dev:e2e user-registration
/dev:e2e-integration user-registration

# 4. Verify complete
/dev:ensure user-registration

# 5. Check project health
/dev:health
```

## Philosophy

```
TESTS PASSING ≠ WORKING

Real validation requires:
✓ Strong assertions on specific values
✓ All edge cases covered
✓ ALL screens listed in spec
✓ Dependencies mapped before coding
✓ Project patterns followed
✓ All 8 gates passed
✓ E2E with mocked API (fast, stable)
✓ E2E Integration with real API (final validation)
✓ Continuous learning from mistakes
```

## File Structure

```
.claude/
├── project.md       # Project patterns & structure
├── progress.md      # Workflow progress
├── gaps.md          # Gap analysis report
├── deps/            # Dependency maps
└── learnings/       # Captured improvements
    ├── spec-gaps.md
    ├── test-issues.md
    └── pattern-violations.md
```

## License

MIT

## Contributing

Issues and PRs welcome at [github.com/packlikez/claude-code-dev-plugin](https://github.com/packlikez/claude-code-dev-plugin)
