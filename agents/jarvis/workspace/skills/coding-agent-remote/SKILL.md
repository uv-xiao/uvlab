---
name: coding-agent-remote
description: Use coding agents (kimi-cli) on remote servers via SSH and tmux. Connect to remote hosts defined in ~/.ssh/config, spawn coding agents in tmux sessions there, and manage them remotely.
---

# Coding Agent (Remote)

Connect to remote servers via SSH and spawn coding agents (kimi-cli) in tmux sessions on those hosts. This allows OpenClaw agents to delegate tasks to coding agents running on more powerful remote machines.

## Prerequisites

- `ssh` must be installed and configured
- Remote host must be defined in `~/.ssh/config`
- Remote host must have `tmux` installed
- Remote host should have `kimi` (kimi-cli) installed
- SSH key authentication should be set up for passwordless login

## Quick Commands

```bash
# List configured SSH hosts
/skill:coding-agent-remote hosts

# Spawn a coding agent on a remote server
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Analyze the performance of this Python script" \
  --wd ~/projects

# List active sessions on a remote host
/skill:coding-agent-remote list --host hina

# Check output from a remote session
/skill:coding-agent-remote output --host hina --session coding-001

# Send input to a remote session
/skill:coding-agent-remote send --host hina --session coding-001 --input "Optimize memory"

# Kill a remote session
/skill:coding-agent-remote kill --host hina --session coding-001
```

## Scripts

### List SSH Hosts

```bash
./scripts/hosts.sh
```

Shows all hosts configured in `~/.ssh/config`.

### Spawn Remote Coding Agent

```bash
./scripts/spawn.sh \
  --host <hostname> \
  --task "Your task description" \
  [--wd /path/to/workdir] \
  [--session custom-name]
```

**Options:**
- `--host, -h`: SSH host to connect to (required, must be in ~/.ssh/config)
- `--task, -t`: The task to give to the coding agent (required)
- `--wd, -w`: Working directory on remote host (default: ~/workspace)
- `--session, -s`: Custom session name (default: auto-generated)
- `--kimi-path`: Path to kimi binary on remote host (default: kimi)

**Example:**
```bash
./scripts/spawn.sh \
  --host hina \
  --task "Clone https://github.com/user/repo and analyze it" \
  --wd ~/work \
  --session repo-analysis
```

### List Remote Sessions

```bash
./scripts/list.sh --host <hostname>
```

Shows all coding agent tmux sessions on the remote host.

### Get Remote Session Output

```bash
./scripts/output.sh --host <hostname> --session <name> [--lines 50]
```

**Options:**
- `--host, -h`: SSH host (required)
- `--session, -s`: Session name (required)
- `--lines, -n`: Number of lines to show (default: 50)

### Send Input to Remote Session

```bash
./scripts/send.sh --host <hostname> --session <name> --input "Your input"
```

### Kill Remote Session

```bash
./scripts/kill.sh --host <hostname> --session <name> [--force]
```

## SSH Configuration

Your `~/.ssh/config` should define the hosts you want to use. Example:

```
Host hina
  HostName 115.27.161.184
  User uvxiao
  IdentityFile ~/.ssh/id_ed25519
  ForwardAgent yes

Host rikka
  HostName rikka.morz.eu.org
  User uvxiao
  IdentityFile ~/.ssh/id_ed25519
```

## Workflow

### 1. Check Available Hosts

```bash
/skill:coding-agent-remote hosts
```

### 2. Spawn a Remote Coding Agent

```bash
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Download and analyze the latest PyTorch release" \
  --wd ~/ml-projects \
  --session pytorch-analysis
```

### 3. Monitor Progress

```bash
# Check if session is running
/skill:coding-agent-remote list --host hina

# Get output
/skill:coding-agent-remote output --host hina --session pytorch-analysis
```

### 4. Provide Additional Input

```bash
/skill:coding-agent-remote send \
  --host hina \
  --session pytorch-analysis \
  --input "Focus on the autograd improvements"
```

### 5. Cleanup

```bash
/skill:coding-agent-remote kill --host hina --session pytorch-analysis
```

## Important Notes

### Command Approval

Kimi-cli requires user approval for shell commands. For automated operation:

1. **Set environment variable** (if kimi supports it):
   ```bash
   export KIMI_AUTO_APPROVE=1
   ```

2. **Or use the `yes` command** in your task:
   ```bash
   ./scripts/spawn.sh --host hina --task "yes | kimi your-task"
   ```

### Remote Prerequisites

Before using a remote host, ensure:

1. **SSH access works** without password:
   ```bash
   ssh hina "echo 'SSH works'"
   ```

2. **tmux is installed** on remote:
   ```bash
   ssh hina "which tmux"
   ```

3. **kimi is installed** on remote (or available via some other method):
   ```bash
   ssh hina "which kimi"
   ```

### Installing Kimi on Remote Host

If kimi is not installed on the remote host, you can install it:

```bash
ssh hina '
  # Install uv if not present
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # Install kimi-cli
  uv tool install kimi-cli
'
```

## Use Cases

### Offload Token-Intensive Tasks

When your OpenClaw agent lacks sufficient tokens:
```bash
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Read this 500-page PDF and extract key findings" \
  --wd ~/research
```

### Access Better Hardware

Use remote GPUs or more powerful machines:
```bash
/skill:coding-agent-remote spawn \
  --host rikka \
  --task "Profile this CUDA kernel and suggest optimizations"
```

### Run Long Tasks

Tasks that would timeout in your environment:
```bash
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Train this model for 10 epochs and report metrics"
```

## Troubleshooting

### SSH Connection Fails

1. Verify host is in `~/.ssh/config`:
   ```bash
   cat ~/.ssh/config | grep "^Host"
   ```

2. Test SSH connection:
   ```bash
   ssh <hostname> "echo OK"
   ```

3. Check SSH key permissions:
   ```bash
   chmod 600 ~/.ssh/id_ed25519
   ```

### Remote Tmux Not Found

Install tmux on remote host:
```bash
ssh <hostname> "sudo apt-get install -y tmux"
```

### Remote Kimi Not Found

Install kimi on remote host:
```bash
ssh <hostname> "uv tool install kimi-cli"
```

### Session Commands Hang

If SSH commands hang, check:
1. Network connectivity to remote host
2. SSH agent forwarding (if using agent)
3. Remote host load (may be overloaded)

## Security Notes

- Coding agents run with your user permissions on the remote host
- They can access any files your user can access on that host
- Review tasks before spawning to avoid unintended operations
- Use SSH key authentication with passphrase protection
- Consider using `ForwardAgent no` for untrusted hosts
