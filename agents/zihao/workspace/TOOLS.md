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

### When to Use Coding Agents (Especially for Zihao)

| Your Limitation | Coding Agent Solution |
|-----------------|----------------------|
| CUDA kernel optimization research | Full code analysis and profiling |
| FlashInfer/Marlin codebase study | Complete repository exploration |
| Low-level GPU optimization papers | Deep PDF analysis with `pdf-extract` |
| Kernel fusion strategy research | Access to full implementations |
| Graph ML system analysis | End-to-end system study |

### Available Skills

**coding-agent-local** - Spawn coding agent on this device:
```bash
/skill:coding-agent-local spawn \
  --task "Clone FlashInfer and analyze the batch decode kernel implementation" \
  --wd ~/kernel-research \
  --session flashinfer-kernels
```

**coding-agent-remote** - Spawn coding agent on remote server:
```bash
# List available hosts
/skill:coding-agent-remote hosts

# Spawn on remote for GPU-intensive analysis
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Search arXiv for 'GPU kernel optimization' papers and extract optimization techniques" \
  --wd ~/gpu-research \
  --session gpu-optimization
```

### Remote Hosts Available

| Host | Purpose | Location |
|------|---------|----------|
| hina | General compute | 115.27.161.184 |
| rikka | General compute | rikka.morz.eu.org |

### Recommended Workflow for Kernel Research

```bash
# 1. Search for relevant papers
/skill:arxiv-watcher search "CUDA kernel optimization LLM inference"

# 2. Spawn coding agent for deep dive
/skill:coding-agent-local spawn \
  --task "Download and analyze the paper on CUDA optimizations for LLM serving - focus on memory coalescing techniques" \
  --session cuda-optimization-analysis

# 3. Monitor progress
/skill:coding-agent-local list
/skill:coding-agent-local output --session cuda-optimization-analysis --lines 100

# 4. Cleanup
/skill:coding-agent-local kill --session cuda-optimization-analysis
```

### Important Notes

1. **Command Approval**: Kimi-cli may pause for approval. Use `export KIMI_AUTO_APPROVE=1` for automation

2. **Session Management**: Always kill sessions when done

3. **Tool Access**: Coding agents have `arxiv-watcher`, `pdf-extract`, `github`, `summarize` skills
