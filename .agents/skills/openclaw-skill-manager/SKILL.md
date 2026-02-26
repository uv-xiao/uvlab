---
name: openclaw-skill-manager
description: Manage OpenClaw agent skills via ClawdHub. Use when the user wants to (1) install skills to specific agents or all agents, (2) configure skill sources (hub/project/user), (3) manage skill assignments in openclaw.json, or (4) troubleshoot skill loading issues. Handles both global skills (shared by all agents) and per-agent skills (agent-specific).
---

# OpenClaw Skill Manager

Manage skills for UV Lab's multi-agent OpenClaw environment via ClawdHub.

## Quick Commands

```bash
# Install a skill from ClawdHub (interactive)
openclaw skills install

# Install a specific skill by name
openclaw skills install <skill-name>

# List installed skills
openclaw skills list

# Remove a skill
openclaw skills remove <skill-name>

# Update all skills
openclaw skills update
```

## Configuration Architecture

### Global Skills (All Agents Share)

Defined in `tools.skills` in `openclaw.json`:

```json
{
  "tools": {
    "skills": {
      "enabled": true,
      "sources": {
        "hub": { "enabled": true },      // ClawdHub skills
        "project": { "enabled": true },  // .agents/skills/
        "user": { "enabled": true }      // ~/.config/agents/skills/
      }
    }
  }
}
```

### Per-Agent Skills (Agent-Specific)

Defined in `agents.list[].skills` in `openclaw.json`:

```json
{
  "agents": {
    "list": [
      {
        "id": "jarvis",
        "skills": ["skill-name-1", "skill-name-2"]
      }
    ]
  }
}
```

## Workflows

### Install Skill to All Agents (Global)

1. Install from ClawdHub:
   ```bash
   openclaw skills install <skill-name>
   ```

2. Verify in `openclaw.json`:
   ```json
   {
     "tools": {
       "skills": {
         "enabled": true,
         "sources": { "hub": { "enabled": true } }
       }
     }
   }
   ```

3. Restart OpenClaw:
   ```bash
   openclaw gateway restart
   ```

### Install Skill to Specific Agent

1. Edit `openclaw.json` manually or use the sync script approach
2. Add skill to agent's `skills` array:
   ```json
   {
     "id": "lianmin",
     "skills": ["cuda-optimizer", "sglang-deploy"]
   }
   ```

3. Use `./scripts/sync-config.sh reverse` to sync changes back to template

### Install Local/Project Skills

Place skills in directory structure:

```
~/.config/agents/skills/       # User-level (all projects)
.agents/skills/                # Project-level (UV Lab only)
```

Each skill folder:
```
skill-name/
├── SKILL.md                   # Required
├── scripts/                   # Optional
├── references/               # Optional
└── assets/                   # Optional
```

## Skill Sources Priority

Skills load in this priority (first wins):
1. **Project**: `.agents/skills/`
2. **User**: `~/.config/agents/skills/`
3. **Hub**: ClawdHub (via `openclaw skills install`)
4. **Built-in**: OpenClaw defaults

## Troubleshooting

### Skills Not Loading

1. Check `tools.skills.enabled` is `true`
2. Verify skill sources are enabled
3. Check skill is installed: `openclaw skills list`
4. Review logs: `openclaw logs --follow`

### Agent-Specific Skills Not Working

1. Verify agent ID matches exactly
2. Check skill name spelling
3. Ensure skill is available in sources

### ClawdHub Connection Issues

```bash
# Test ClawdHub connectivity
openclaw skills list

# Force refresh skill cache
openclaw skills update
```

## References

- [OpenClaw Skills Docs](https://docs.openclaw.ai/tools/skills)
- [ClawdHub Docs](https://docs.openclaw.ai/tools/clawhub)
- [Skills Config](https://docs.openclaw.ai/tools/skills-config)
