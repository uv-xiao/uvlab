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

### Agents

| ID | Name | Role |
|----|------|------|
| main | Jarvis | Lab Director |
| ra-core | Core RA | General research |
| ra-code | Code RA | Code/implementation |
| ra-data | Data RA | Data analysis |
| ra-review | Review RA | Literature review |

### Models

- **Primary:** generic/qwen3.5-plus
- **Provider:** Alibaba Cloud DashScope
- **Base URL:** https://coding.dashscope.aliyuncs.com/v1
