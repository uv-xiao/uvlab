# Coding Agent Remote - Quick Usage Guide

## List Available SSH Hosts

```bash
/skill:coding-agent-remote hosts
```

## Spawn a Remote Coding Agent

```bash
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Clone and analyze a repository" \
  --wd ~/work \
  --session remote-task
```

## Common Operations

| Command | Description |
|---------|-------------|
| `hosts` | List configured SSH hosts |
| `list --host NAME` | Show sessions on remote host |
| `output --host NAME --session SNAME` | Get remote session output |
| `send --host NAME --session SNAME --input "TEXT"` | Send input to remote session |
| `kill --host NAME --session SNAME` | Terminate remote session |

## Example Workflow

```bash
# 1. Check available hosts
/skill:coding-agent-remote hosts

# 2. Spawn agent on remote server
/skill:coding-agent-remote spawn \
  --host rikka \
  --task "Download https://arxiv.org/abs/1706.03762 and summarize" \
  --wd ~/research \
  --session paper-summary

# 3. Check progress on remote
/skill:coding-agent-remote list --host rikka

# 4. Get output
/skill:coding-agent-remote output --host rikka --session paper-summary

# 5. Send additional instruction
/skill:coding-agent-remote send \
  --host rikka \
  --session paper-summary \
  --input "Focus on the attention mechanism explanation"

# 6. Clean up
/skill:coding-agent-remote kill --host rikka --session paper-summary
```

## SSH Setup Requirements

Ensure in `~/.ssh/config`:
- Host is defined
- Key authentication is set up
- Remote has `tmux` and `kimi` installed

Test SSH:
```bash
ssh hina "echo OK && which tmux && which kimi"
```
