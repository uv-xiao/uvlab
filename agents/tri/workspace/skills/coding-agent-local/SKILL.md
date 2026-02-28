---
name: coding-agent-local
description: Use local coding agents (kimi-cli) via tmux sessions. Spawn a coding agent in a detached tmux session to handle complex tasks that require more tokens or tools than the OpenClaw agent has available.
---

# Coding Agent (Local)

Spawn and manage local coding agents (kimi-cli) in tmux sessions. This allows OpenClaw agents to delegate token-intensive tasks to a coding agent running on the same device.

## Prerequisites

- `tmux` must be installed
- `kimi` (kimi-cli) must be installed and in PATH

## Important Notes

**Command Approval:** Kimi-cli requires user approval for shell commands. When you spawn a coding agent with a task, kimi may pause waiting for approval. You have two options:

1. **Use the `yes` command** to auto-approve (recommended for automation):
   ```bash
   ./scripts/spawn.sh --task "yes | kimi --approve-all your-task"
   ```

2. **Attach and approve manually** if you need to review commands:
   ```bash
   ./scripts/attach.sh --session <name>
   # Then approve commands interactively
   ```

For fully automated operation, consider setting `KIMI_AUTO_APPROVE=1` in the environment.

## Quick Commands

```bash
# Spawn a coding agent in a new tmux session
/skill:coding-agent-local spawn --task "Analyze the performance of this Python script" --wd ~/projects

# List active coding agent sessions
/skill:coding-agent-local list

# Check output from a session
/skill:coding-agent-local output --session coding-001

# Send additional input to a running session
/skill:coding-agent-local send --session coding-001 --input "Optimize the memory usage"

# Attach to a session interactively (for debugging)
/skill:coding-agent-local attach --session coding-001

# Kill a session
/skill:coding-agent-local kill --session coding-001
```

## Scripts

### Spawn a Coding Agent

```bash
./scripts/spawn.sh --task "Your task description here" [--wd /path/to/workdir] [--session custom-name]
```

**Options:**
- `--task, -t`: The task to give to the coding agent (required)
- `--wd, -w`: Working directory for the session (default: ~/workspace)
- `--session, -s`: Custom session name (default: auto-generated)
- `--model, -m`: Kimi model to use (default: k2.5)

**Example:**
```bash
./scripts/spawn.sh \
  --task "Refactor this codebase to use async/await" \
  --wd ~/my-project \
  --session refactor-task
```

### List Active Sessions

```bash
./scripts/list.sh
```

Shows all coding agent tmux sessions with their status and runtime.

### Get Session Output

```bash
./scripts/output.sh --session <session-name> [--lines 100] [--follow]
```

**Options:**
- `--session, -s`: Session name (required)
- `--lines, -n`: Number of lines to show (default: 50)
- `--follow, -f`: Follow output in real-time (like tail -f)

### Send Input to Session

```bash
./scripts/send.sh --session <session-name> --input "Your input here"
```

### Attach to Session

```bash
./scripts/attach.sh --session <session-name>
```

**Note:** This will take over your terminal. Use Ctrl+B then D to detach.

### Kill Session

```bash
./scripts/kill.sh --session <session-name>
```

## Workflow

### 1. Delegate a Complex Task

When you encounter a task that requires:
- More tokens than available
- Complex file operations
- Long-running analysis
- Skills only available to coding agents

Spawn a coding agent:
```bash
/skill:coding-agent-local spawn \
  --task "Analyze the uvlab repository structure and create a diagram" \
  --wd ~/.openclaw \
  --session uvlab-analysis
```

### 2. Monitor Progress

Check if the session is still running:
```bash
/skill:coding-agent-local list
```

Get the latest output:
```bash
/skill:coding-agent-local output --session uvlab-analysis --lines 100
```

### 3. Provide Additional Context

If the coding agent needs more information:
```bash
/skill:coding-agent-local send \
  --session uvlab-analysis \
  --input "Focus on the skills/ directory structure"
```

### 4. Retrieve Results

Once the session completes, get the full output:
```bash
/skill:coding-agent-local output --session uvlab-analysis --lines 500
```

### 5. Cleanup

Remove the session when done:
```bash
/skill:coding-agent-local kill --session uvlab-analysis
```

## Session Naming

Auto-generated session names follow the pattern: `coding-{timestamp}`

Examples:
- `coding-20260228-135422`
- `coding-20260228-135856`

## Integration with OpenClaw

Use this skill when you need to:

1. **Process large files** that exceed your context window
2. **Use coding-agent-only skills** like pdf-extract, arxiv-watcher
3. **Run long tasks** that would timeout in your environment
4. **Access the full filesystem** without sandbox restrictions

## Example: Full Workflow

```
User: "Can you analyze the PDF at ~/papers/attention.pdf and summarize it?"

You: "This task requires PDF extraction which needs more tokens. Let me spawn a coding agent."

/skill:coding-agent-local spawn \
  --task "Extract and summarize the key contributions from ~/papers/attention.pdf" \
  --session pdf-analysis

"Spawned coding agent in session pdf-analysis. Checking progress..."

/skill:coding-agent-local output --session pdf-analysis --follow

"The coding agent has completed the analysis. Here's the summary:"
[Results from output]

/skill:coding-agent-local kill --session pdf-analysis
```

## Troubleshooting

### Session Not Found

If you get "session not found":
1. Check active sessions: `./scripts/list.sh`
2. The session may have exited already
3. Check if tmux is running: `tmux ls`

### No Output

If output is empty:
1. The session may still be initializing
2. Check with list command to see if it's running
3. Wait a moment and try again

### Kimi Not Found

If kimi-cli is not in PATH, you can:
1. Use full path: `--kimi-path /home/user/.local/bin/kimi`
2. Or set environment variable: `export KIMI_CLI_PATH=/path/to/kimi`

## Security Notes

- Coding agents run with the same permissions as the OpenClaw process
- They can access the full filesystem
- Review tasks before spawning to avoid unintended operations
