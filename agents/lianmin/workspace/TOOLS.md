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

### When to Use Coding Agents (Especially for Lianmin)

| Your Limitation | Coding Agent Solution |
|-----------------|----------------------|
| Analyzing large serving system papers | Coding agents can read full PDFs with `pdf-extract` |
| Deep vLLM/SGLang codebase analysis | Spawn agent to explore and profile the code |
| Benchmarking tasks | Long-running benchmarks in persistent sessions |
| Researching new papers | Use `arxiv-watcher` to find and analyze papers |
| Compiler/codegen research | Full repository analysis without context limits |

### Available Skills

**coding-agent-local** - Spawn coding agent on this device:
```bash
/skill:coding-agent-local spawn \
  --task "Clone vLLM repo and analyze the scheduler implementation" \
  --wd ~/serving-research \
  --session vllm-scheduler
```

**coding-agent-remote** - Spawn coding agent on remote server:
```bash
# First, list available hosts
/skill:coding-agent-remote hosts

# Spawn on remote for compute-intensive tasks
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Download latest arXiv papers on LLM serving and summarize" \
  --wd ~/papers \
  --session serving-papers
```

### Remote Hosts Available

| Host | Purpose | Location |
|------|---------|----------|
| hina | General compute | 115.27.161.184 |
| rikka | General compute | rikka.morz.eu.org |

### Recommended Workflow for Paper Analysis

```bash
# 1. Find relevant papers
/skill:arxiv-watcher search "LLM serving continuous batching"

# 2. Spawn coding agent for deep analysis
/skill:coding-agent-local spawn \
  --task "Download arxiv:2309.XXXXX and extract the scheduling algorithm details" \
  --session paper-deep-dive

# 3. Monitor and retrieve results
/skill:coding-agent-local output --session paper-deep-dive --lines 100

# 4. Cleanup
/skill:coding-agent-local kill --session paper-deep-dive
```

### Important Notes

1. **Command Approval**: Kimi-cli may pause for approval. For automation, use `export KIMI_AUTO_APPROVE=1`

2. **Session Management**: Always kill sessions when done

3. **Tool Chaining**: Coding agents have access to `arxiv-watcher`, `pdf-extract`, `github` skills
