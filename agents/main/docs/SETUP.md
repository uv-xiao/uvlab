# UV Lab Setup Guide

This document describes the complete setup process for the UV Lab research environment.

## Prerequisites

- Node.js 18+ (LTS recommended)
- OpenClaw Gateway running
- GitHub account access

## Setup Steps

### 1. Clone Working Repository

The uvlab repository is the main working directory (Obsidian vault):

```bash
cd /home/admin/openclaw/workspace
git remote add origin https://github.com/uv-xiao/uvlab.git
git pull origin main
```

### 2. Install OpenClaw Studio

Studio provides the web dashboard for visibility:

```bash
cd /home/admin
git clone https://github.com/grp06/openclaw-studio.git
cd openclaw-studio
npm install
```

### 3. Configure Studio

Studio settings are stored at `~/.openclaw/openclaw-studio/settings.json`:

```json
{
  "gatewayUrl": "ws://localhost:18789",
  "gatewayToken": "<your-gateway-token>"
}
```

### 4. Run Studio

```bash
cd /home/admin/openclaw-studio
npm run dev
```

Open http://localhost:3000 in your browser.

### 5. Configure Agents

Agent configurations are in `research-lab/agents/`:

- **ra-core.md** - Core Research Assistant
- **ra-code.md** - Code Research Assistant  
- **ra-data.md** - Data Research Assistant
- **ra-review.md** - Literature Review Assistant

### 6. Gateway Configuration

The gateway runs on `ws://localhost:18789` with token auth.

Config location: `~/.openclaw/openclaw.json`

## Verification

1. ✅ Gateway running: `openclaw gateway status`
2. ✅ Studio accessible: http://localhost:3000
3. ✅ Workspace synced: `git status` in workspace
4. ✅ Agents configured: Check `research-lab/agents/`

## Troubleshooting

### Studio can't connect to Gateway

- Verify gateway is running: `openclaw gateway status`
- Check token matches in settings.json
- Ensure gateway is bound to loopback (not just localhost)

### Agent spawn fails

- Check agent allowlist in gateway config
- Verify workspace permissions
- Review agent configuration files

## Next Steps

1. Start a research project in `research-lab/projects/`
2. Spawn agents for specific tasks
3. Document findings in `research-lab/notes/`
4. Sync with GitHub regularly
