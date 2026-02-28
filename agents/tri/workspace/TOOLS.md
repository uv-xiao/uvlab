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

---

## ⚡ CRITICAL: Coding Agent Tools (NEW)

**When your context is insufficient or you need tools only available to coding agents, SPAWN A CODING AGENT.**

### When to Use Coding Agents (Especially for Tri)

| Your Limitation | Coding Agent Solution |
|-----------------|----------------------|
| Deep Flash Attention paper analysis | Full PDF extraction with equations |
| Attention mechanism implementation study | Complete codebase analysis |
| Theoretical ML paper reading | In-depth analysis without context limits |
| Algorithm complexity analysis | Access to full paper proofs |
| HPC/CUDA kernel research | Deep dives into implementations |

### Available Skills

**coding-agent-local** - Spawn coding agent on this device:
```bash
/skill:coding-agent-local spawn \
  --task "Clone flash-attention repo and analyze the kernel fusion strategies" \
  --wd ~/attention-research \
  --session flash-attn-analysis
```

**coding-agent-remote** - Spawn coding agent on remote server:
```bash
# List available hosts
/skill:coding-agent-remote hosts

# Spawn on remote
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Search arXiv for 'efficient attention' papers and analyze algorithmic improvements" \
  --wd ~/papers \
  --session attention-survey
```

### Remote Hosts Available

| Host | Purpose | Location |
|------|---------|----------|
| hina | General compute | 115.27.161.184 |
| rikka | General compute | rikka.morz.eu.org |

### Recommended Workflow for Attention Research

```bash
# 1. Find latest attention papers
/skill:arxiv-watcher search "efficient attention mechanism transformer"

# 2. Spawn coding agent for deep analysis
/skill:coding-agent-local spawn \
  --task "Download and analyze the Flash Attention 3 paper - focus on algorithmic innovations" \
  --session fa3-analysis

# 3. Monitor and interact
/skill:coding-agent-local output --session fa3-analysis --lines 100
/skill:coding-agent-local send --session fa3-analysis --input "Explain the memory access patterns"

# 4. Cleanup
/skill:coding-agent-local kill --session fa3-analysis
```

### Important Notes

1. **Command Approval**: Kimi-cli may pause for approval. Use `export KIMI_AUTO_APPROVE=1` for automation

2. **Session Management**: Always kill sessions when done

3. **Tool Access**: Coding agents can use `arxiv-watcher`, `pdf-extract`, `github`, `summarize`
