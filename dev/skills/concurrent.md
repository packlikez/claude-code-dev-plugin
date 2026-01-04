---
name: concurrent
description: Context management for large tasks - checkpointing, chunking, resuming
---

# Context Management (ALL AGENTS)

This skill is REQUIRED for all agents to handle large features.

## When to Apply

ALWAYS check before:
1. Starting any multi-step task
2. Reading more than 5 files
3. Creating more than 3 files
4. After completing a major chunk of work

---

## Decision Tree: Direct vs Delegate

Before any task, Claude Code should decide:

- Task requires reading 5+ files? YES -> Delegate to agent. NO -> Continue
- Task will create 3+ new files? YES -> Delegate to agent. NO -> Continue
- Task has distinct phases (research, implement, test)? YES -> Consider delegating phases. NO -> Continue
- Already read 10+ files in this session? YES -> Create checkpoint, consider new session. NO -> Execute directly

---

## Task Sizing Guide

Before starting, estimate the task:

| Task Type | Est. Context | Action |
|-----------|--------------|--------|
| Single file edit | 1-5K tokens | Execute directly |
| 2-3 file change | 5-10K tokens | Execute directly |
| New component + tests | 10-20K tokens | Consider delegating tests |
| New feature (backend) | 20-40K tokens | Delegate to implementer |
| Full feature (8 steps) | 100K+ tokens | Checkpoint after each step |

---

## Executing Concurrent Operations

### Parallel Tool Calls

When operations are independent, Claude Code SHOULD call multiple tools in one response:

```
✅ DO: Read 3 related files in parallel
- Read file1.ts
- Read file2.ts
- Read file3.ts
(All in same response)

❌ DON'T: Read files one at a time
- Read file1.ts
- (wait for response)
- Read file2.ts
- (wait for response)
```

### Parallel Agent Delegation

When using Task tool, launch independent agents together:

```
✅ DO: Launch multiple background agents
Task 1: Explore agent → find auth files
Task 2: Explore agent → find test patterns
(Both in same response with run_in_background: true)

❌ DON'T: Wait for one agent before starting another
```

---

## Background Task Execution

### When to Use Background Tasks

| Scenario | Use Background? | Why |
|----------|-----------------|-----|
| Long build (>30s) | YES | Continue working while building |
| Multiple code scans | YES | Run all scans in parallel |
| Dev server | YES | Keep server running, continue work |
| Quick file read | NO | Faster to wait |
| Single grep | NO | Instant result |

### Running Bash in Background

```yaml
# Start long-running command in background
Bash:
  command: "npm run build"
  run_in_background: true
  description: "Build project in background"

# Returns immediately with task_id
# Continue working on other tasks...

# Later, retrieve the result
TaskOutput:
  task_id: "{task_id_from_bash}"
  block: true  # Wait for completion
```

### Running Agents in Background

```yaml
# Launch agent in background
Task:
  subagent_type: "test-writer"
  prompt: "Write unit tests for userService"
  run_in_background: true

# Returns immediately with agent_id
# Continue working...

# Later, retrieve the result
TaskOutput:
  task_id: "{agent_id}"
  block: true
```

### Parallel Agent Pattern (RECOMMENDED)

Launch multiple agents in ONE message for true parallelism:

```yaml
# All three run SIMULTANEOUSLY
Task #1:
  subagent_type: "Explore"
  prompt: "Find all authentication files"
  run_in_background: true

Task #2:
  subagent_type: "Explore"
  prompt: "Find all test patterns"
  run_in_background: true

Task #3:
  subagent_type: "Explore"
  prompt: "Find all API routes"
  run_in_background: true

# Then retrieve all results
TaskOutput: { task_id: "{agent_1_id}" }
TaskOutput: { task_id: "{agent_2_id}" }
TaskOutput: { task_id: "{agent_3_id}" }
```

### Background Task Patterns

#### Pattern 1: Build While Working

```
1. Start build in background
2. Continue editing files
3. Check build result before commit
```

#### Pattern 2: Parallel Code Review

```
1. Launch code-reviewer agent (background)
2. Launch security-scanner agent (background)
3. Launch test-runner agent (background)
4. Collect all results
5. Summarize findings
```

#### Pattern 3: Dev Server + Implementation

```
1. Start dev server in background
2. Implement feature
3. Server auto-reloads
4. Check server output for errors
```

### TaskOutput Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `task_id` | required | ID from background task |
| `block` | true | Wait for completion |
| `timeout` | 30000 | Max wait time (ms), max 600000 |

### Monitoring Background Tasks

```bash
# List all running background tasks
/tasks
```

### Best Practices

1. **Use background for long operations** (>5 seconds)
2. **Launch parallel agents in ONE message** for true parallelism
3. **Always retrieve results** before depending on them
4. **Set appropriate timeouts** for long tasks
5. **Check task status** with `block: false` if unsure

---

## Context Management

### Before Reading Files

Ask: "Do I actually need this file's content?"

```
Need to check if file exists?
→ Use: ls {file} 2>/dev/null
→ DON'T: Read the entire file

Need to find a specific pattern?
→ Use: grep -n "pattern" {file}
→ DON'T: Read the entire file

Need specific lines?
→ Use: Read with offset/limit
→ DON'T: Read the entire file
```

### After Major Changes

Create a checkpoint after:
- Completing a workflow step (1-8)
- Implementing a major component
- Before context gets too heavy

Checkpoint command:

```bash
# Create checkpoint file
mkdir -p .claude
```

Write to `.claude/checkpoint.md`:

```markdown
# Checkpoint: {feature-name}

## Completed
- [x] {completed step}
- [x] {completed step}

## Current State
- Working on: {current file/task}
- Last action: {what was just done}

## Next Steps
1. {next action}
2. {following action}

## Context to Reload
```bash
cat {essential-file-1}
cat {essential-file-2}
```
```

---

## Delegation Rules

### When to Use Task Tool with Agents

| Agent | Use When | Context Needed |
|-------|----------|----------------|
| `Explore` | Need to find files/patterns | Minimal - agent searches |
| `test-writer` | Writing tests | Spec + implementation |
| `gate-keeper` | Validating a step | Feature files only |
| `implementer` | Building feature | Spec + patterns |

### Delegation Format

When delegating, provide:
1. Clear task description
2. Feature name
3. Specific files to reference
4. Expected output

Example:

```
Use Task tool with test-writer agent:
"Write backend unit tests for user-registration feature.
Reference: specs/features/user-registration.md
Implementation: src/services/userService.ts
Output: tests/unit/services/userService.test.ts"
```

---

## Token Optimization Actions

### Instead of Reading Entire Files

```bash
# Check file exists (0 tokens)
ls src/services/userService.ts 2>/dev/null

# Find specific function (few tokens)
grep -n "createUser" src/services/userService.ts

# Read specific section (minimal tokens)
Read file with offset=50, limit=30
```

### Instead of Loading All Skills

Only load the skill needed for current step:

```
Step 1 (Spec): Load spec-convention only
Step 2 (Backend): Load project-patterns only
Step 3 (Tests): Load test-patterns-unit only
```

### Summarize Before Continuing

After completing a sub-task, summarize what was done before moving on:

```markdown
## Completed: Backend Implementation

Files created:
- src/services/userService.ts (create, read, update, delete)
- src/routes/users.ts (5 endpoints)

Ready for: Step 3 (Backend Unit Tests)
```

---

## Checkpoint Recovery

When resuming from checkpoint (context compacted or new session):

### Step 1: Check for Checkpoint

```bash
ls .claude/checkpoint.md .claude/ensure-progress.md .claude/progress.md 2>/dev/null
```

### Step 2: Read Checkpoint

```bash
cat .claude/checkpoint.md
```

### Step 3: Load ONLY Listed Files

Only read files in "Context to Reload" section. Don't read anything else.

### Step 4: Continue from "Next Steps"

Follow exactly what checkpoint says to do next.

### Step 5: Update Checkpoint After Progress

After completing more work, update checkpoint immediately.

## Resume Patterns

| Command | Checkpoint File |
|---------|-----------------|
| `/dev:ensure` | `.claude/ensure-progress.md` |
| Any workflow step | `.claude/checkpoint.md` |
| Full feature | `.claude/progress.md` |

### Resume Example

```bash
# User says: "continue" or "resume"

# 1. Check what was in progress
cat .claude/checkpoint.md

# 2. Load minimal context from checkpoint
# (only files listed in "Context to Reload")

# 3. Continue from "Next Steps" section
```

---

## Warning Signs: Context Too Heavy

Claude Code should recognize these signs:

| Sign | Action |
|------|--------|
| Read 10+ files | Consider checkpointing |
| Multiple large file edits | Summarize progress |
| Starting to forget earlier context | Create checkpoint immediately |
| Task taking many rounds | Break into smaller tasks |

When any sign appears:

1. Complete current atomic action
2. Create checkpoint
3. Summarize what's done
4. List remaining work
5. Either continue or suggest new session

---

## Quick Reference

### Before Any Task

```
1. Estimate size (how many files?)
2. Decide: direct or delegate?
3. If delegate: which agent?
4. If direct: batch reads together
```

### During Task

```
1. Use parallel tool calls when possible
2. Use grep before read
3. Use offset/limit for large files
4. Summarize after each component
```

### After Task

```
1. Create checkpoint if task was large
2. Clear mental slate
3. Report what's done
4. Suggest next action
```

---

## File Reference

- `.claude/checkpoint.md` - Current work state
- `.claude/progress.md` - Overall feature progress
- `.claude/project.md` - Project patterns
- `.claude/learnings/` - Improvement feedback
