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
| sglang | merrymercy (Lianmin Zheng) | LLM serving, compilers, distributed systems |
| xgboost | tqchen (Tianqi Chen) | ML systems, optimization, scalable training |
| flashinfer | yzh119 (Zihao Ye) | Kernel optimization, LLM deployment, graph ML |
| flashattn | tridao (Tri Dao) | Efficient attention, ML theory, HPC |

### pkbllm Skills Framework

- **Repo:** https://github.com/uv-xiao/pkbllm
- **Purpose:** Reusable instruction sets for LLM-human interaction
- **Categories:** common/, productivity/, knowledge/, human/, bootstrap/
- **Usage:** `npx skills add . --list` to discover, `pkb_agents_md.py assemble` to inject

### Models

- **Primary:** generic/qwen3.5-plus
- **Provider:** Alibaba Cloud DashScope
- **Base URL:** https://coding.dashscope.aliyuncs.com/v1
