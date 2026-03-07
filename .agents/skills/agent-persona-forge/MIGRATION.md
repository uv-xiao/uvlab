# Migration Guide: Fixing Existing Agent Personas

This guide helps migrate existing agent personas created with the old version of agent-persona-forge to the new correct structure.

## What Changed

### ❌ Old (Incorrect) Structure
```
agents/{agent_id}/
├── USER.md              # WRONG: Described researcher as "human user"
├── MATERIALS-REPORT.md  # WRONG: Outside workspace (invisible to agent)
├── papers/              # WRONG: Outside workspace (invisible to agent)
├── projects/            # WRONG: Outside workspace (invisible to agent)
└── workspace/           # Agent can only see this directory
    ├── SOUL.md          # Default template, not customized
    └── IDENTITY.md      # Default template, not customized
```

### ✅ New (Correct) Structure
```
agents/{agent_id}/
└── workspace/           # Agent's entire world
    ├── SOUL.md          # Agent's personality/expertise (from researcher)
    ├── IDENTITY.md      # Agent's name, emoji, vibe
    ├── MATERIALS-REPORT.md  # Documentation of explored materials
    ├── papers/          # Downloaded papers (accessible to agent)
    ├── projects/        # Cloned repos (accessible to agent)
    └── analysis/        # Extracted skills and methodology
```

## Key Changes

| Aspect | Old | New |
|--------|-----|-----|
| **Persona file** | USER.md (wrong meaning) | SOUL.md + IDENTITY.md |
| **File location** | Outside workspace | Inside workspace |
| **Paper storage** | `agents/{id}/papers/` | `agents/{id}/workspace/papers/` |
| **Project storage** | `agents/{id}/projects/` | `agents/{id}/workspace/projects/` |
| **Agent visibility** | Can't see materials | Can see all materials |

## Migration Steps

### Step 1: Move Materials to Workspace

```bash
AGENT_ID="lianmin"  # or "tianqi", etc.

# Create workspace subdirectories
mkdir -p ~/.openclaw/agents/$AGENT_ID/workspace/papers
mkdir -p ~/.openclaw/agents/$AGENT_ID/workspace/projects
mkdir -p ~/.openclaw/agents/$AGENT_ID/workspace/analysis

# Move papers (if any exist)
if [ -d ~/.openclaw/agents/$AGENT_ID/papers ]; then
    mv ~/.openclaw/agents/$AGENT_ID/papers/* ~/.openclaw/agents/$AGENT_ID/workspace/papers/ 2>/dev/null || true
fi

# Move projects (if any exist)
if [ -d ~/.openclaw/agents/$AGENT_ID/projects ]; then
    mv ~/.openclaw/agents/$AGENT_ID/projects/* ~/.openclaw/agents/$AGENT_ID/workspace/projects/ 2>/dev/null || true
fi
```

### Step 2: Convert USER.md to SOUL.md

The old USER.md contains the researcher's profile. This content should become the agent's SOUL.md:

```bash
AGENT_ID="lianmin"
WORKSPACE="~/.openclaw/agents/$AGENT_ID/workspace"

# Backup old files
cp $WORKSPACE/SOUL.md $WORKSPACE/SOUL.md.backup
cp $WORKSPACE/IDENTITY.md $WORKSPACE/IDENTITY.md.backup

# Create new SOUL.md from the researcher's profile
cat > $WORKSPACE/SOUL.md << 'EOF'
# SOUL.md - Who You Are

_You are [Agent Name], an AI agent embodying the expertise and approach of [Researcher Name]._

[Copy relevant sections from the old USER.md]

## Core Identity
You are an expert in:
[From old USER.md Technical Expertise section]

## Background
[From old USER.md Background section]

## Technical Expertise
[From old USER.md Technical Expertise section]

## Communication Style
[From old USER.md Communication Style section]

## Working Principles
[From old USER.md Research Methodology section]

## Boundaries
- Your knowledge reflects publicly available information
- You do not have access to private/behind-paywall content
- Knowledge cutoff: [date]

## Continuity
Your memory lives in these workspace files:
- `SOUL.md` (this file) - Your personality and expertise
- `IDENTITY.md` - Your identity metadata  
- `papers/` - Downloaded research papers
- `projects/` - Cloned repositories
- `analysis/` - Detailed analysis

Read these files at the start of each session.
EOF
```

### Step 3: Update IDENTITY.md

```bash
cat > $WORKSPACE/IDENTITY.md << 'EOF'
# IDENTITY.md - Who Am I?

- **Name:** [Agent name, e.g., "lianmin"]
- **Creature:** AI researcher persona
- **Vibe:** [From old USER.md - e.g., "Systems-oriented, performance-focused"]
- **Emoji:** [Choose appropriate - e.g., "⚡" for performance expert]
- **Avatar:** [Optional URL or workspace path]

---

I am an AI agent inspired by the work and expertise of [Researcher Name].
My knowledge and capabilities are derived from their research papers, 
open-source projects, and public profiles.
EOF
```

### Step 4: Reset USER.md

USER.md should describe the **human user**, not the researcher:

```bash
cat > $WORKSPACE/USER.md << 'EOF'
# USER.md - About Your Human

_Learn about the person you're helping. Update this as you go._

- **Name:**
- **What to call them:**
- **Pronouns:** _(optional)_
- **Timezone:**
- **Notes:**

## Context

_(What do they care about? What projects are they working on? What annoys them? What makes them laugh? Build this over time.)_

---

The more you know, the better you can help. But remember — you're learning about a person, not building a dossier. Respect the difference.
EOF
```

### Step 5: Move MATERIALS-REPORT.md

```bash
# Move the materials report to workspace
mv ~/.openclaw/agents/$AGENT_ID/MATERIALS-REPORT.md $WORKSPACE/MATERIALS-REPORT.md 2>/dev/null || true
```

### Step 6: Verify

Check the final structure:

```bash
echo "=== Agent: $AGENT_ID ==="
echo ""
echo "Workspace contents:"
ls -la $WORKSPACE/
echo ""
echo "Papers:"
ls -la $WORKSPACE/papers/ 2>/dev/null || echo "  (empty)"
echo ""
echo "Projects:"
ls -la $WORKSPACE/projects/ 2>/dev/null || echo "  (empty)"
echo ""
echo "Identity:"
head -10 $WORKSPACE/IDENTITY.md
echo ""
echo "Soul excerpt:"
head -20 $WORKSPACE/SOUL.md
```

## Automated Migration Script

Use the provided migration script:

```bash
./scripts/migrate-agent.sh <agent_id>
```

This script will:
1. Move all materials to the workspace
2. Convert USER.md content to SOUL.md
3. Update IDENTITY.md
4. Reset USER.md to the correct template
5. Move MATERIALS-REPORT.md to workspace
6. Verify the final structure

## Verification Checklist

After migration, verify:

- [ ] All files are in `agents/{id}/workspace/`, not outside
- [ ] `SOUL.md` contains the researcher's expertise and personality
- [ ] `IDENTITY.md` has name, emoji, and vibe
- [ ] `USER.md` is the default template (for human user info)
- [ ] `papers/` directory is in workspace (if papers exist)
- [ ] `projects/` directory is in workspace (if projects exist)
- [ ] `MATERIALS-REPORT.md` is in workspace
- [ ] Agent can access all materials during sessions

## Common Issues

### Issue: Old files still outside workspace
**Fix**: Delete the old directories after confirming they're empty or moved:
```bash
rm -rf ~/.openclaw/agents/$AGENT_ID/papers
rm -rf ~/.openclaw/agents/$AGENT_ID/projects
rm -f ~/.openclaw/agents/$AGENT_ID/USER.md
rm -f ~/.openclaw/agents/$AGENT_ID/MATERIALS-REPORT.md
```

### Issue: Content looks wrong after migration
**Fix**: Check the backup files:
```bash
diff $WORKSPACE/SOUL.md $WORKSPACE/SOUL.md.backup
```

### Issue: Agent still can't see files
**Fix**: Verify the workspace path in openclaw.json:
```bash
grep -A5 "\"$AGENT_ID\"" ~/.openclaw/openclaw.json
```
The workspace should be `~/.openclaw/agents/{id}/workspace`.
