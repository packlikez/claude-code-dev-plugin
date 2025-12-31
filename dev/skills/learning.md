---
name: learning
description: Instructions for Claude Code to learn from mistakes and improve the system
---

# Learning System

## When to Trigger This Skill

Claude Code MUST apply this skill when ANY of these occur:

1. **Gate validation fails** - A gate-keeper check fails
2. **Test fails** - Unit, API, UI, or E2E test fails
3. **Implementation rework** - Had to redo work due to missing requirement
4. **User correction** - User points out a mistake
5. **Pattern violation** - Used wrong project pattern

---

## Step 1: Capture the Issue

When an issue occurs, immediately create or append to the learning file:

```bash
# Create learnings directory if not exists
mkdir -p .claude/learnings

# Determine category file
# Options: spec-gaps.md, pattern-violations.md, test-improvements.md, gate-feedback.md, token-optimizations.md
```

Write to the appropriate file using this exact format:

```markdown
## {YYYY-MM-DD} - {short-title}

**Issue:** {what went wrong - be specific}
**Discovery:** {Step N / Gate N / User feedback / Test failure}
**Root cause:** {why it happened}
**Fix applied:** {immediate fix}
**Tokens wasted:** {estimate: debugging + rework + re-testing}

### System Improvement

**Target:** {commands|agents|skills}/{filename}.md
**Change:** {Add rule | Add example | Add check}
**Content to add:**
```
{exact text to add to the target file}
```

---
```

---

## Step 2: Apply the Improvement

After documenting, Claude Code MUST update the target file:

### If Target is a Skill

Read the skill file, then add the learning:

```bash
# Example: Adding to test-patterns-unit.md
cat skills/test-patterns-unit.md
```

Then use Edit tool to add under appropriate section:

```markdown
## Learned Edge Cases (from .claude/learnings/)
- [ ] {new edge case} (added: {date})
```

### If Target is a Gate Criteria

Read the gate file, then add new criterion:

```bash
# Example: Adding to gate-3-backend-unit.md
cat skills/gate-3-backend-unit.md
```

Then use Edit tool to add:

```markdown
## Additional Criteria (from learnings)
- [ ] {new check} (added: {date}, source: {issue-title})
```

### If Target is an Agent

Read the agent file, then add to anti-patterns or rules:

```bash
# Example: Adding to agents/implementer.md
cat agents/implementer.md
```

Then use Edit tool to add:

```markdown
## Learned Anti-Patterns
❌ {what not to do} (learned: {date})
```

### If Target is a Command

Read the command file, then add to process or requirements:

```bash
# Example: Adding to commands/backend.md
cat commands/backend.md
```

---

## Step 3: Verify Improvement Applied

After editing, confirm the change:

```bash
# Grep to verify the addition
grep -n "{key phrase from addition}" {target-file}
```

---

## Learning Categories Reference

| Category | File | When to Use |
|----------|------|-------------|
| Spec gaps | `.claude/learnings/spec-gaps.md` | Missing requirement discovered during implementation or testing |
| Pattern violations | `.claude/learnings/pattern-violations.md` | Used wrong project convention |
| Test improvements | `.claude/learnings/test-improvements.md` | Test didn't catch a bug, weak assertion |
| Gate feedback | `.claude/learnings/gate-feedback.md` | Gate passed but issue found later |
| Token optimizations | `.claude/learnings/token-optimizations.md` | Wasted tokens on unnecessary reads/actions |

---

## Example: Full Learning Flow

**Scenario:** Unit test passed but API test revealed null pointer bug

### Step 1: Capture

Write to `.claude/learnings/test-improvements.md`:

```markdown
## 2024-01-15 - Null check missing for optional avatar field

**Issue:** User API returns 500 when user has no avatar
**Discovery:** Step 4 (API Test) - GET /users/{id} test failed
**Root cause:** Unit test mocked avatar as always present
**Fix applied:** Added null check: user.avatar?.url || defaultAvatar
**Tokens wasted:** ~8,000 (debugging 3K, fix 2K, re-test 3K)

### System Improvement

**Target:** skills/test-patterns-unit.md
**Change:** Add edge case requirement
**Content to add:**
```
### Optional Field Edge Cases (REQUIRED)
For every optional field in the data model:
- [ ] Test with field present
- [ ] Test with field null
- [ ] Test with field undefined
```

---
```

### Step 2: Apply

```bash
# Read the target file
cat skills/test-patterns-unit.md
```

Then use Edit tool to add the content at appropriate location.

### Step 3: Verify

```bash
grep -n "Optional Field Edge Cases" skills/test-patterns-unit.md
```

---

## Automatic Learning Triggers

Claude Code should check for learning opportunities at these points:

| Event | Action |
|-------|--------|
| Gate fails | Capture why, update gate criteria if missing check |
| Test fails | Capture why, update test patterns if gap |
| User says "that's wrong" | Capture correction, update relevant skill |
| Rework needed | Capture root cause, update spec-convention if missing requirement |
| Same issue twice | HIGH PRIORITY - systematic fix needed |

---

## Token Cost Tracking

Maintain running total in `.claude/learnings/metrics.md`:

```markdown
# Learning Metrics

## This Session
| Date | Issue | Tokens Wasted | Improvement Made |
|------|-------|---------------|------------------|
| {date} | {title} | {tokens} | {target file updated} |

## Total Savings Estimate
- Issues prevented by improvements: {count}
- Est. tokens saved: {count × avg waste}
```

---

## Integration with Other Commands

### After `/dev:init`

Check for existing learnings:

```bash
ls .claude/learnings/*.md 2>/dev/null
```

If learnings exist, apply any that haven't been applied to skills/agents.

### After Any Gate Validation

If gate fails, immediately trigger learning capture.

### Before `/dev:status`

Check for unaddressed learnings:

```bash
grep -l "System Improvement" .claude/learnings/*.md | head -5
```

Report count of pending improvements.

---

## Quick Reference for Claude Code

```markdown
## On Issue Discovery

1. STOP current work
2. Create/append to .claude/learnings/{category}.md
3. Use exact format from Step 1
4. Edit target file with improvement
5. Verify with grep
6. Resume work

## Files to Know

.claude/learnings/
├── spec-gaps.md           # Missing requirements
├── pattern-violations.md  # Wrong conventions used
├── test-improvements.md   # Test gaps
├── gate-feedback.md       # Gate criteria gaps
├── token-optimizations.md # Efficiency learnings
└── metrics.md             # Running totals
```
