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

## UV Lab Configuration

### Gateway

- **URL:** ws://localhost:18789
- **Mode:** local, loopback
- **Auth:** token mode
- **Token:** 20e110256c06ea9aff13f90b6143874c2c7fb90bc5fc5207

### OpenClaw Studio

- **Location:** /home/admin/openclaw-studio
- **URL:** http://localhost:3000
- **Settings:** ~/.openclaw/openclaw-studio/settings.json

### Research Lab

- **Workspace:** /home/admin/openclaw/workspace
- **Repo:** https://github.com/uv-xiao/uvlab
- **Lab Dir:** research-lab/
- **Agents:** research-lab/agents/

### Research Agents (Elite Experts)

Each agent is a versatile research expert, not narrowly specialized.

| Agent | Inspired By | Expertise |
|-------|-------------|-----------|
| main / Jarvis | Lab Director | Coordination, oversight |
| lianmin | merrymercy (Lianmin Zheng) | LLM serving, compilers, distributed systems |
| tianqi | tqchen (Tianqi Chen) | ML systems, optimization, scalable training |
| zihao | yzh119 (Zihao Ye) | Kernel optimization, LLM deployment, graph ML |
| tri | tridao (Tri Dao) | Efficient attention, ML theory, HPC |

### pkbllm Skills Framework

- **Repo:** https://github.com/uv-xiao/pkbllm
- **Purpose:** Reusable instruction sets for LLM-human interaction
- **Categories:** common/, productivity/, knowledge/, human/, bootstrap/
- **Usage:** `npx skills add . --list` to discover, `pkb_agents_md.py assemble` to inject

### Models

- **Primary:** generic/qwen3.5-plus
- **Provider:** Alibaba Cloud DashScope
- **Base URL:** https://coding.dashscope.aliyuncs.com/v1

---

## ⚡ CRITICAL: Coding Agent Tools (NEW)

**When your context is insufficient or you need tools only available to coding agents, SPAWN A CODING AGENT.**

### When to Use Coding Agents

| Your Limitation | Coding Agent Solution |
|-----------------|----------------------|
| Insufficient tokens for large files | Coding agents have larger context windows |
| Need to process PDFs | Use `pdf-extract` skill via coding agent |
| Need deep paper analysis | Use `arxiv-watcher` + `pdf-extract` chain |
| Long-running tasks | Coding agents run in persistent tmux sessions |
| Full filesystem access | Coding agents have broader access |

### Available Skills

**coding-agent-local** - Spawn coding agent on this device:
```bash
/skill:coding-agent-local spawn \
  --task "Analyze the repository structure and identify bottlenecks" \
  --wd ~/projects/myrepo \
  --session analysis-task
```

**coding-agent-remote** - Spawn coding agent on remote server:
```bash
# First, list available hosts
/skill:coding-agent-remote hosts

# Spawn on remote
/skill:coding-agent-remote spawn \
  --host hina \
  --task "Download and analyze PyTorch source code" \
  --wd ~/ml-research \
  --session pytorch-analysis
```

### Remote Hosts Available

| Host | Purpose | Location |
|------|---------|----------|
| hina | General compute | 115.27.161.184 |
| rikka | General compute | rikka.morz.eu.org |

### Common Workflow

```bash
# 1. Spawn a coding agent for token-heavy task
/skill:coding-agent-local spawn \
  --task "Read ~/papers/attention-is-all-you-need.pdf and extract key contributions" \
  --session paper-analysis

# 2. Monitor progress
/skill:coding-agent-local list
/skill:coding-agent-local output --session paper-analysis --lines 100

# 3. Send follow-up if needed
/skill:coding-agent-local send \
  --session paper-analysis \
  --input "Focus on the multi-head attention mechanism"

# 4. Get final results and cleanup
/skill:coding-agent-local output --session paper-analysis --lines 500
/skill:coding-agent-local kill --session paper-analysis
```

### Important Notes

1. **Command Approval**: Kimi-cli may pause for approval. For automation, use:
   - Environment variable: `export KIMI_AUTO_APPROVE=1`
   - Or preface task with `yes |`

2. **Session Management**: Always kill sessions when done to free resources

3. **Error Handling**: If a coding agent fails, check output and retry with clearer instructions

4. **Tool Chaining**: You can ask coding agents to use their skills like `pdf-extract`, `arxiv-watcher`, etc.
