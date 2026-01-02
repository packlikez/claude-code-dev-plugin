---
name: dev:resume
description: "Resume work from checkpoint after context compaction or new session"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
---

# Resume from Checkpoint

Continue work from where it was left off after context compaction or new session.

## Process

### 1. Find Checkpoint Files

```bash
ls -la .claude/*.md 2>/dev/null
```

Priority order:
1. `.claude/checkpoint.md` - Most recent work state
2. `.claude/ensure-progress.md` - Ensure command progress
3. `.claude/progress.md` - Overall feature progress

### 2. Read Checkpoint

```bash
cat .claude/checkpoint.md
```

Extract:
- What was completed
- Current state / last action
- Next steps to do
- Files to reload

### 3. Reload Minimal Context

ONLY read files listed in "Context to Reload" section.

Do NOT read any other files yet.

### 4. Restore Todo List

If checkpoint has incomplete tasks, restore to TodoWrite:

```
Todos from checkpoint:
- [completed] {done items}
- [in_progress] {current item}
- [pending] {remaining items}
```

### 5. Continue Work

Follow "Next Steps" from checkpoint exactly.

After completing each step:
- Update TodoWrite
- Update checkpoint file

## Checkpoint File Format

```markdown
# Checkpoint: {task-name}
Updated: {timestamp}

## Completed
- [x] {step 1}
- [x] {step 2}

## Current State
- Working on: {current task}
- Last action: {what was just done}
- Files modified: {list}

## Next Steps
1. {immediate next action}
2. {following action}
3. {remaining work}

## Context to Reload
Essential files for resuming:
- specs/features/{name}.md
- src/services/{name}.ts
- .claude/checkpoint.md
```

## Quick Resume

If user just says "continue" or "resume":

1. Check for checkpoint: `cat .claude/checkpoint.md`
2. Load listed files only
3. Continue from "Next Steps"
4. Update checkpoint after progress
