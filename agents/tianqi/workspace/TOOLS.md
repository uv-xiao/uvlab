# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Feishu Messaging

**Critical lesson (2026-02-26):**

| Tool | Use Case | Example |
|------|----------|---------|
| `sessions_send` | Send messages **between agent sessions** (inter-agent coordination) | `sessions_send(sessionKey="agent:lianmin:...", message="...")` |
| `message` | Send messages **to users via Feishu** | `message(action="send", channel="feishu", accountId="tianqi", target="ou_xxx", message="...")` |

**Common mistake:** Don't use `sessions_send` to message users — it times out because sessions represent incoming message contexts, not outbound channels.

**Correct pattern for Feishu DM:**
```
message(
  action: "send",
  channel: "feishu",
  accountId: "tianqi",  // YOUR account
  target: "ou_6c412e7bd985f6fa4150e47b409e3b50",  // user ID
  message: "..."
)
```

---

## ⚡ CRITICAL: Coding Agent Tools (NEW)

**When your context is insufficient or you need tools only available to coding agents, SPAWN A CODING AGENT.**

### When to Use Coding Agents (Especially for Tianqi)

| Your Limitation | Coding Agent Solution |
|-----------------|----------------------|
| Analyzing ML system papers deeply | Full PDF extraction with `pdf-extract` |
| XGBoost/TVM/Relax codebase analysis | Complete repository exploration |
| Optimization algorithm research | Access to full papers and implementations |
| Long-running training experiments | Persistent tmux sessions on remote hosts |
| Distributed systems research | Deep dives into system architectures |

### Available Skills

**coding-agent-local** - Spawn coding agent on this device:
```bash
/skill:coding-agent-local spawn \
  --task "Analyze the TVM Relax compiler passes and explain the optimization pipeline" \
  --wd ~/ml-systems \
  --session tvm-analysis
```

**coding-agent-remote** - Spawn coding agent on remote server:
```bash
# List available hosts
/skill:coding-agent-remote hosts

# Spawn on remote for intensive tasks
/skill:coding-agent-remote spawn \
  --host rikka \
  --task "Search arXiv for 'ML compiler optimization' papers from 2024 and summarize key techniques" \
  --wd ~/research \
  --session compiler-papers
```

### Remote Hosts Available

| Host | Purpose | Location |
|------|---------|----------|
| hina | General compute | 115.27.161.184 |
| rikka | General compute | rikka.morz.eu.org |

### Recommended Workflow for ML Systems Research

```bash
# 1. Search for relevant papers
/skill:arxiv-watcher search "machine learning systems optimization"

# 2. Spawn coding agent for comprehensive analysis
/skill:coding-agent-local spawn \
  --task "Download the top 3 papers and analyze their system design trade-offs" \
  --session ml-systems-review

# 3. Monitor progress
/skill:coding-agent-local list
/skill:coding-agent-local output --session ml-systems-review --lines 50

# 4. Cleanup when done
/skill:coding-agent-local kill --session ml-systems-review
```

### Important Notes

1. **Command Approval**: Kimi-cli may pause for approval. Use `export KIMI_AUTO_APPROVE=1` for automation

2. **Session Management**: Always kill sessions to free resources

3. **Tool Access**: Coding agents have `arxiv-watcher`, `pdf-extract`, `github`, `summarize` skills
