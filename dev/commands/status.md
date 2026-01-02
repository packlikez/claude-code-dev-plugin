---
name: dev:status
description: Smart project status - identifies next step with minimal token usage
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# Development Status (Token-Optimized)

## Purpose

Quickly assess project state and determine the optimal next action with **minimal context loading**.

---

## Process

### 1. Quick Scan (Low Token Cost)

Run lightweight checks first - DON'T load full files:

```bash
# Check for progress file
ls .claude/progress.md 2>/dev/null

# Count specs
ls specs/**/*.md 2>/dev/null | wc -l

# Count implementations
ls src/services/*.ts src/routes/*.ts 2>/dev/null | wc -l

# Count test files by type
ls tests/unit/**/*.test.ts 2>/dev/null | wc -l
ls tests/integration/**/*.test.ts 2>/dev/null | wc -l
ls tests/ui/**/*.spec.ts 2>/dev/null | wc -l
ls tests/e2e/**/*.spec.ts 2>/dev/null | wc -l

# Check for checkpoints
ls .claude/checkpoint.md 2>/dev/null

# Check for learnings
ls .claude/learnings/*.md 2>/dev/null | wc -l
```

### 2. Determine Project State

Based on quick scan, classify:

| State | Indicators | Next Action |
|-------|------------|-------------|
| **New Project** | No specs, no .claude/ | Run `/dev:init` |
| **Has Checkpoint** | .claude/checkpoint.md exists | Resume from checkpoint |
| **Spec Only** | Specs exist, no impl | Start Step 2: Backend |
| **Impl No Tests** | Impl exists, no tests | Start Step 3: Unit Tests |
| **Partial Tests** | Some test types missing | Continue testing steps |
| **All Complete** | All test types exist | Validate gates |

### 3. Smart Next Step Detection

```markdown
## Decision Tree (Token-Efficient)

1. Checkpoint exists?
   → YES: Load checkpoint, resume
   → NO: Continue

2. Progress file exists?
   → YES: Read ONLY the status section (first 50 lines)
   → NO: Scan file structure

3. Identify gaps:
   - Missing specs → /dev:spec
   - Missing backend → /dev:backend
   - Missing unit tests → /dev:backend-unit
   - Missing API tests → /dev:api-test
   - Missing frontend → /dev:frontend
   - Missing frontend tests → /dev:frontend-unit
   - Missing UI tests → /dev:ui-test
   - Missing E2E → /dev:e2e
```

### 4. Load Only What's Needed

```markdown
## Minimal Context Loading

DON'T: Load all specs, all implementations, all tests
DO: Load only the blocking item

Example: If Step 3 is next
- Load: spec for current feature (source of truth)
- Load: implementation file (what to test)
- DON'T load: gate criteria (test-writer knows them)
```

---

## Output Format

### Quick Status Report

```
PROJECT STATUS SUMMARY

Features: 3 total (2 complete, 1 in progress)
Current: user-registration (Step 4/8)
Last Gate: GATE 3 (Backend Unit Tests)
Blockers: None

RECOMMENDED NEXT ACTION:
/dev:api-test user-registration

Est. tokens: ~15,000
Est. context needed: spec + routes only
```

### Feature Progress Grid

| Feature | G1 | G2 | G3 | G4 | G5 | G6 | G7 | G8 | Status |
|---------|----|----|----|----|----|----|----|----|--------|
| user-registration | OK | OK | OK | WIP | - | - | - | - | Step 4 |
| password-reset | OK | OK | OK | OK | OK | OK | OK | OK | COMPLETE |
| user-profile | OK | WIP | - | - | - | - | - | - | Step 2 |

Legend: OK=Passed, WIP=In Progress, -=Pending, X=Failed

---

## Token Optimization Rules

### Load Order (Minimal First)

```markdown
1. File counts only (0 tokens)
2. Progress.md status section (100-200 tokens)
3. Checkpoint if exists (200-500 tokens)
4. STOP - Provide recommendation

Only load more if user requests details
```

### What NOT to Load

```markdown
❌ Full spec files (unless actively working)
❌ All implementation files
❌ All test files
❌ Gate criteria (agents know them)
❌ Pattern skills (agents know them)
```

### Smart Recommendations

```markdown
## Token-Aware Recommendations

If context is fresh (<10K tokens):
→ "Ready to work on Step X. Proceed? (loads ~15K tokens)"

If context is heavy (>50K tokens):
→ "Context heavy. Recommend:
   1. Complete current task
   2. Create checkpoint
   3. New session for next step"

If checkpoint exists:
→ "Resume from checkpoint? (loads only checkpoint context)"
```

---

## Resume from Checkpoint

If `.claude/checkpoint.md` exists:

```markdown
## Checkpoint Detected

Feature: {name}
Last Step: {N}
Status: {description}

To resume:
1. Load minimal context from checkpoint
2. Continue from documented next step
3. Skip already-completed work

Estimated resume tokens: ~{X}
vs Fresh start tokens: ~{Y}
Savings: {Y-X} tokens
```

---

## Integration with Learning

Check `.claude/learnings/` for relevant issues:

```markdown
## Recent Learnings for Current Step

If working on Step 3 (Backend Unit Tests):
- Check learnings/test-improvements.md
- Apply any recent patterns
- Avoid documented anti-patterns

This prevents repeating mistakes = saves tokens
```

---

## Commands

```bash
/dev:status                  # Quick overview, minimal tokens
/dev:status {feature}        # Single feature status
/dev:status --details        # Full status (higher token cost)
/dev:status --checkpoint     # Show checkpoint only
/dev:status --learnings      # Show relevant learnings
```

---

## Example Flow

```markdown
User: /dev:status