---
name: dev:learn
description: "Capture learnings from mistakes, issues, or discoveries"
argument-hint: "<category> (spec-gaps, test-issues, pattern-violations, gate-feedback)"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Capture Learning

Document mistakes, issues, and discoveries to improve the system over time.

## Categories

| Category | When to Use |
|----------|-------------|
| `spec-gaps` | Spec was incomplete, missing requirements |
| `test-issues` | Tests missed edge cases, weak assertions |
| `pattern-violations` | Didn't follow project patterns |
| `gate-feedback` | Gate criteria improvements needed |
| `dependency-issues` | Missing dependencies discovered mid-work |
| `performance` | Performance problems found |

## Usage

```bash
/dev:learn spec-gaps           # Document spec issue
/dev:learn test-issues         # Document test problem
/dev:learn pattern-violations  # Document pattern violation
```

## Process

### 1. Describe the Issue

Use AskUserQuestion to gather:
- What happened?
- When was it discovered?
- What was the impact?

### 2. Identify Root Cause

- Why did this happen?
- What check should have caught it?
- Which skill/agent/gate should be updated?

### 3. Document Learning

Write to `.claude/learnings/{category}.md`:

```markdown
## {YYYY-MM-DD} - {short-title}

**Issue:** {what went wrong - be specific}

**Discovery:** {when/where discovered}
- Step: {step number}
- Gate: {gate number if applicable}
- Time wasted: {estimate}

**Root Cause:** {why it happened}

**Fix Applied:** {what was done to fix}

**Prevention:** {how to prevent in future}
- [ ] Update skill: {skill-name}
- [ ] Update gate: {gate-name}
- [ ] Add to checklist: {which}

**Status:** Open / Resolved
```

### 4. Update System

Based on learning, update relevant files:

| Issue Type | Update |
|------------|--------|
| Spec gap | `spec-convention.md` |
| Test issue | `test-patterns-*.md` |
| Pattern violation | `project-patterns.md` |
| Gate feedback | `gate-{n}-*.md` |
| Dependency issue | `dependency-map.md` |

## Example Learnings

### Spec Gap Example

```markdown
## 2025-01-02 - Missing ProjectsPage in spec

**Issue:** Spec mentioned user flow "list → select → board" but
didn't explicitly list ProjectsPage component.

**Discovery:** Step 5 (Frontend) - discovered mid-implementation
- Time wasted: ~30 minutes

**Root Cause:** Spec lacked explicit "UI Screens" section

**Fix Applied:** Created ProjectsPage component

**Prevention:**
- [x] Update skill: spec-convention.md - add UI Screens section
- [x] Update gate: gate-1-spec.md - require screens list
- [x] Update skill: dependency-map.md - check pages first

**Status:** Resolved
```

### Test Issue Example

```markdown
## 2025-01-02 - Weak assertion in user test

**Issue:** Test used `expect(user).toBeDefined()` instead of
checking actual values.

**Discovery:** Gate 3 review - gate-keeper caught it

**Root Cause:** Copy-pasted test pattern without updating

**Prevention:**
- [x] Update skill: test-patterns-unit.md - add blocked assertions
- [x] Update gate: gate-3-backend-unit.md - grep for toBeDefined

**Status:** Resolved
```

## View Learnings

```bash
# List all learnings
ls .claude/learnings/

# View specific category
cat .claude/learnings/spec-gaps.md

# Count by category
wc -l .claude/learnings/*.md

# Find unresolved
grep -l "Status: Open" .claude/learnings/*.md
```

## Learning Stats

Track improvement over time:

```
┌────────────────────────────────────────────────┐
│ LEARNINGS SUMMARY                              │
├────────────────────────────────────────────────┤
│ Total captured: 15                             │
│ Resolved: 12                                   │
│ Open: 3                                        │
│                                                │
│ By Category:                                   │
│ ├── spec-gaps: 4                               │
│ ├── test-issues: 5                             │
│ ├── pattern-violations: 3                      │
│ └── gate-feedback: 3                           │
│                                                │
│ System Updates Made: 8                         │
│ Skills updated: 5                              │
│ Gates updated: 3                               │
└────────────────────────────────────────────────┘
```
