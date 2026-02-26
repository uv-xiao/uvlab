---
name: openclaw-skill-manager
description: Manage OpenClaw agent skills via ClawdHub. Use when the user wants to (1) install skills from ClawdHub, (2) configure skill loading paths, (3) manage per-skill settings in openclaw.json, or (4) set up workspace-specific vs shared skills.
---

# OpenClaw Skill Manager

Manage skills for UV Lab's multi-agent OpenClaw environment.

## Quick Commands

```bash
# Install a skill from ClawdHub
clawhub install <skill-slug>

# Update all installed skills
clawhub update --all

# Sync skills
clawhub sync --all
```

## Skill Locations (Precedence)

Skills load from three locations (highest precedence first):

1. **Workspace skills**: `<workspace>/skills/` - Per-agent skills
2. **Managed skills**: `~/.openclaw/skills/` - Shared across all agents
3. **Bundled skills**: Shipped with OpenClaw install

### UV Lab Skill Structure

```
~/.openclaw/
├── .agents/skills/              # Project-level skills (can be moved to workspace)
├── agents/
│   ├── jarvis/workspace/skills/   # Jarvis-only skills
│   ├── lianmin/workspace/skills/  # Lianmin-only skills
│   └── ...
└── skills/                      # Shared skills (all agents)
```

## Configuration

Skills configuration lives under root `skills` key in `openclaw.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": [],
      "watch": true,
      "watchDebounceMs": 250
    },
    "install": {
      "preferBrew": true,
      "nodeManager": "npm"
    },
    "entries": {
      "skill-name": {
        "enabled": true,
        "env": { "KEY": "value" },
        "apiKey": "..."
      }
    }
  }
}
```

### Key Fields

- `skills.load.extraDirs`: Additional skill directories (lowest precedence)
- `skills.load.watch`: Auto-refresh skills on file changes
- `skills.entries.<skillName>`: Per-skill overrides
  - `enabled`: Enable/disable skill
  - `env`: Environment variables for skill
  - `apiKey`: API key (convenience for primary env var)

## Workflows

### Install Skill to Specific Agent

```bash
# Navigate to agent's workspace
cd agents/jarvis/workspace

# Install skill (goes to ./skills/)
clawhub install <skill-slug>
```

### Install Shared Skill (All Agents)

```bash
# Install to ~/.openclaw/skills/
clawhub install <skill-slug>
```

Or manually move project skills:
```bash
mv .agents/skills/my-skill ~/.openclaw/skills/
```

### Configure Skill in openclaw.json

```json
{
  "skills": {
    "entries": {
      "gemini": {
        "enabled": true,
        "apiKey": "{{GEMINI_API_KEY}}"
      }
    }
  }
}
```

### Add Extra Skill Directories

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/path/to/shared/skills"]
    }
  }
}
```

## Skill Format

Each skill is a directory with `SKILL.md`:

```
skill-name/
├── SKILL.md          # Required - YAML frontmatter + instructions
├── scripts/          # Optional - executable scripts
├── references/       # Optional - reference docs
└── assets/           # Optional - templates, images
```

### SKILL.md Example

```yaml
---
name: my-skill
description: Do something useful
metadata:
  {
    "openclaw": {
      "requires": { "bins": ["node"], "env": ["API_KEY"] }
    }
  }
---

# Instructions here...
```

## Multi-Agent Setup

For UV Lab's 5 agents:

| Agent | Workspace Skills Path | Use For |
|-------|----------------------|---------|
| jarvis | `agents/jarvis/workspace/skills/` | Director-specific tools |
| lianmin | `agents/lianmin/workspace/skills/` | Serving/LLM tools |
| tianqi | `agents/tianqi/workspace/skills/` | ML systems tools |
| zihao | `agents/zihao/workspace/skills/` | CUDA/kernel tools |
| tri | `agents/tri/workspace/skills/` | Attention/algo tools |

Shared skills go to `~/.openclaw/skills/` (visible to all).

## Troubleshooting

### Skills Not Loading

1. Check skill is in correct location:
   ```bash
   ls agents/<agent>/workspace/skills/
   ls ~/.openclaw/skills/
   ```

2. Verify SKILL.md has valid YAML frontmatter

3. Check skill requirements in metadata:
   ```yaml
   metadata:
     { "openclaw": { "requires": { "bins": ["required-binary"] } } }
   ```

4. Review logs: `openclaw logs --follow`

### Skill Conflicts

If same skill name exists in multiple locations, precedence is:
1. `<workspace>/skills/` (highest)
2. `~/.openclaw/skills/`
3. Bundled skills (lowest)

### Disable a Skill

```json
{
  "skills": {
    "entries": {
      "skill-name": { "enabled": false }
    }
  }
}
```

## References

- [OpenClaw Skills Docs](https://docs.openclaw.ai/tools/skills)
- [Skills Config](https://docs.openclaw.ai/tools/skills-config)
- [ClawdHub](https://docs.openclaw.ai/tools/clawhub)
