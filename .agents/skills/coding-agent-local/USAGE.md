# Coding Agent Local - Quick Usage Guide

## Spawn a Coding Agent

```bash
/skill:coding-agent-local spawn \
  --task "Analyze the repository structure" \
  --wd ~/projects/myrepo \
  --session my-analysis
```

## Common Operations

| Command | Description |
|---------|-------------|
| `list` | Show all active sessions |
| `output --session NAME` | Get session output |
| `send --session NAME --input "TEXT"` | Send input to session |
| `kill --session NAME` | Terminate a session |

## Example Workflow

```bash
# 1. Spawn agent for a complex task
/skill:coding-agent-local spawn \
  --task "Read ~/papers/attention.pdf and summarize key findings" \
  --session pdf-analysis

# 2. Check progress
/skill:coding-agent-local list

# 3. Get output
/skill:coding-agent-local output --session pdf-analysis --lines 100

# 4. Send follow-up instruction
/skill:coding-agent-local send \
  --session pdf-analysis \
  --input "Focus on the methodology section"

# 5. Clean up when done
/skill:coding-agent-local kill --session pdf-analysis
```

## Important: Command Approval

Kimi-cli requires approval for shell commands. For automation:

1. **Set environment variable** (recommended):
   ```bash
   export KIMI_AUTO_APPROVE=1
   ```

2. **Or use `yes` command** in tasks:
   ```bash
   --task "yes | kimi analyze this file"
   ```
