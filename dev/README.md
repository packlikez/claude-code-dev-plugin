# Dev Plugin v0.2.0

Quality Gate Development: 8-step workflow with strict validation.

**Workflow:** SPEC -> BACKEND -> UNIT -> API -> FRONTEND -> UNIT -> E2E -> E2E INTEGRATION (Gates 1-8)

Each step MUST pass its gate before proceeding.

## Installation

```bash
claude plugin add github:packlikez/claude-code-dev-plugin
```

## Commands

### Workflow Commands

| Step | Command | Purpose |
|------|---------|---------|
| 0 | `/dev:init` | Initialize + gap analysis |
| 1 | `/dev:spec <name>` | Write specification (Gate 1) |
| 2 | `/dev:backend <name>` | Implement backend (Gate 2) |
| 3 | `/dev:backend-unit <name>` | Backend unit tests (Gate 3) |
| 4 | `/dev:api-test <name>` | API integration tests (Gate 4) |
| 5 | `/dev:frontend <name>` | Implement frontend (Gate 5) |
| 6 | `/dev:frontend-unit <name>` | Frontend unit tests (Gate 6) |
| 7 | `/dev:e2e <name>` | E2E tests - mocked API (Gate 7) |
| 8 | `/dev:e2e-integration <name>` | E2E Integration - real API (Gate 8) |

### Utility Commands

| Command | Purpose |
|---------|---------|
| `/dev:status` | Smart status with next step recommendation |
| `/dev:preflight <name>` | Pre-check before implementation |
| `/dev:ensure <target>` | Verify feature/module is complete |
| `/dev:health` | Project health dashboard |
| `/dev:learn <category>` | Capture learnings from mistakes |

## Agents

| Agent | Purpose |
|-------|---------|
| spec-writer | Write complete specs |
| implementer | Implement code with reuse-first approach |
| test-writer | Write tests with strong assertions |
| gate-keeper | Validate gate exit criteria |

## Quick Start

```bash
/dev:init                           # Initialize
/dev:preflight user-registration    # Pre-check
/dev:spec user-registration         # Step 1
/dev:backend user-registration      # Step 2
/dev:backend-unit user-registration # Step 3
/dev:api-test user-registration     # Step 4
/dev:frontend user-registration     # Step 5
/dev:frontend-unit user-registration # Step 6
/dev:e2e user-registration          # Step 7
/dev:e2e-integration user-registration # Step 8
/dev:ensure user-registration       # Verify complete
```

## Key Concepts

- **Weak test detection**: Gates reject visibility-only assertions automatically
- **Strong assertions required**: Tests must verify actual values, not just existence
- **Screen verification**: Spec must list ALL UI screens, Gate 5 verifies
- **Dependency mapping**: Pages/routes checked before implementation
- **Learning system**: Capture mistakes to improve over time

## Weak Test Detection

Passing tests ≠ Working feature. Gates detect and reject weak assertions.

**Blocked patterns:**
```
toBeDefined(), toExist(), toBeTruthy(), toBeVisible() alone
toHaveBeenCalled() without args, length > 0 without content check
```

**Required patterns:**
```
toBe(specificValue), toEqual({expected}), toHaveText('value')
toHaveBeenCalledWith({args}), list[0].field === expected
```

See `weak-test-detection` skill for detection commands.

## File Structure

- `.claude/project.md` - Project patterns
- `.claude/progress.md` - Workflow progress
- `.claude/gaps.md` - Gap analysis report
- `.claude/deps/` - Dependency maps
- `.claude/learnings/` - Captured improvements

## License

MIT
