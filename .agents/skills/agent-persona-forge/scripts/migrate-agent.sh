#!/bin/bash
# Migrate an existing agent from old structure to new correct structure
# Moves all materials into workspace and creates rich analysis content

set -e

AGENT_ID="$1"

usage() {
    echo "Usage: $0 <agent_id>"
    echo ""
    echo "Example:"
    echo "  $0 lianmin"
    echo "  $0 tianqi"
    exit 1
}

if [ -z "$AGENT_ID" ]; then
    echo "Error: Agent ID is required"
    usage
fi

AGENT_DIR="$HOME/.openclaw/agents/$AGENT_ID"
WORKSPACE_DIR="$AGENT_DIR/workspace"
OLD_USER_MD="$AGENT_DIR/USER.md"

echo "=========================================="
echo "Migrating Agent: $AGENT_ID"
echo "=========================================="
echo ""

# Check agent exists
if [ ! -d "$AGENT_DIR" ]; then
    echo "Error: Agent directory not found: $AGENT_DIR"
    exit 1
fi

if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "Error: Workspace directory not found: $WORKSPACE_DIR"
    exit 1
fi

echo "Agent directory: $AGENT_DIR"
echo "Workspace: $WORKSPACE_DIR"
echo ""

# ============================================================================
# Step 1: Create workspace subdirectories
# ============================================================================
echo "Step 1: Creating workspace subdirectories..."
mkdir -p "$WORKSPACE_DIR/papers"
mkdir -p "$WORKSPACE_DIR/projects"
mkdir -p "$WORKSPACE_DIR/analysis"
echo "  ✓ Created papers/, projects/, analysis/"
echo ""

# ============================================================================
# Step 2: Move papers
# ============================================================================
echo "Step 2: Moving papers to workspace..."
if [ -d "$AGENT_DIR/papers" ]; then
    if [ -n "$(ls -A "$AGENT_DIR/papers" 2>/dev/null)" ]; then
        mv "$AGENT_DIR/papers"/* "$WORKSPACE_DIR/papers/" 2>/dev/null || true
        echo "  ✓ Moved papers to workspace/papers/"
    else
        echo "  - No papers to move"
    fi
    rmdir "$AGENT_DIR/papers" 2>/dev/null || true
else
    echo "  - No papers directory found outside workspace"
fi
echo ""

# ============================================================================
# Step 3: Move projects
# ============================================================================
echo "Step 3: Moving projects to workspace..."
if [ -d "$AGENT_DIR/projects" ]; then
    if [ -n "$(ls -A "$AGENT_DIR/projects" 2>/dev/null)" ]; then
        mv "$AGENT_DIR/projects"/* "$WORKSPACE_DIR/projects/" 2>/dev/null || true
        echo "  ✓ Moved projects to workspace/projects/"
    else
        echo "  - No projects to move"
    fi
    rmdir "$AGENT_DIR/projects" 2>/dev/null || true
else
    echo "  - No projects directory found outside workspace"
fi
echo ""

# ============================================================================
# Step 4: Move analysis files if they exist outside
# ============================================================================
echo "Step 4: Moving analysis files to workspace..."
if [ -d "$AGENT_DIR/analysis" ]; then
    if [ -n "$(ls -A "$AGENT_DIR/analysis" 2>/dev/null)" ]; then
        mv "$AGENT_DIR/analysis"/* "$WORKSPACE_DIR/analysis/" 2>/dev/null || true
        echo "  ✓ Moved analysis files to workspace/analysis/"
    fi
    rmdir "$AGENT_DIR/analysis" 2>/dev/null || true
else
    echo "  - No external analysis directory found"
fi
echo ""

# ============================================================================
# Step 5: Extract researcher info from old USER.md
# ============================================================================
echo "Step 5: Extracting researcher information..."

RESEARCHER_NAME=""
RESEARCHER_ROLE=""
RESEARCHER_HOMEPAGE=""

if [ -f "$OLD_USER_MD" ]; then
    # Extract researcher name from first line
    RESEARCHER_NAME=$(head -1 "$OLD_USER_MD" | sed 's/^# //' | sed 's/ (.*//' | tr -d '\r')
    
    # Extract role
    RESEARCHER_ROLE=$(grep -E "^- \*\*Role\*\*:" "$OLD_USER_MD" 2>/dev/null | head -1 | sed 's/.*: //' || echo "")
    
    # Extract homepage from resources section
    RESEARCHER_HOMEPAGE=$(grep -E "^- \*\*Homepage\*\*:" "$OLD_USER_MD" 2>/dev/null | head -1 | sed 's/.*: //' || echo "")
    
    echo "  ✓ Extracted from old USER.md:"
    echo "    Name: $RESEARCHER_NAME"
    [ -n "$RESEARCHER_ROLE" ] && echo "    Role: $RESEARCHER_ROLE"
    [ -n "$RESEARCHER_HOMEPAGE" ] && echo "    Homepage: $RESEARCHER_HOMEPAGE"
else
    echo "  - No old USER.md found"
    RESEARCHER_NAME="Unknown Researcher"
fi
echo ""

# ============================================================================
# Step 6: Copy USER.md from default agent (jarvis)
# ============================================================================
echo "Step 6: Copying USER.md from default agent (jarvis)..."

DEFAULT_AGENT="jarvis"
DEFAULT_USER_MD="$HOME/.openclaw/agents/$DEFAULT_AGENT/workspace/USER.md"

if [ -f "$DEFAULT_USER_MD" ]; then
    cp "$DEFAULT_USER_MD" "$WORKSPACE_DIR/USER.md"
    echo "  ✓ Copied USER.md from $DEFAULT_AGENT"
    echo "    (Contains human user information)"
else
    echo "  ⚠ USER.md not found in $DEFAULT_AGENT, creating template"
    cat > "$WORKSPACE_DIR/USER.md" << 'EOF'
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
fi
echo ""

# ============================================================================
# Step 7: Backup and create IDENTITY.md
# ============================================================================
echo "Step 7: Creating IDENTITY.md..."

if [ -f "$WORKSPACE_DIR/IDENTITY.md" ]; then
    cp "$WORKSPACE_DIR/IDENTITY.md" "$WORKSPACE_DIR/IDENTITY.md.backup.$(date +%Y%m%d%H%M%S)"
    echo "  ✓ Backed up existing IDENTITY.md"
fi

# Determine emoji based on name
EMOJI="🧠"
if echo "$AGENT_ID" | grep -qi "lianmin"; then
    EMOJI="⚡"
elif echo "$AGENT_ID" | grep -qi "tianqi"; then
    EMOJI="🔧"
fi

ROLE=${RESEARCHER_ROLE:-"AI researcher persona"}

cat > "$WORKSPACE_DIR/IDENTITY.md" << EOF
# IDENTITY.md - Who Am I?

- **Name:** $AGENT_ID
- **Creature:** AI researcher persona
- **Vibe:** Expert, knowledgeable, clear communicator
- **Emoji:** $EMOJI
- **Avatar:** 

---

I am an AI agent inspired by the work and expertise of **$RESEARCHER_NAME**.
My knowledge and capabilities are derived from their research papers, 
open-source projects, and public profiles.

**Inspiration**: $RESEARCHER_NAME  
**Role**: $ROLE  
**Homepage**: ${RESEARCHER_HOMEPAGE:-N/A}

*This identity was forged by analyzing public research materials and open-source contributions.*
EOF

echo "  ✓ Created IDENTITY.md"
echo ""

# ============================================================================
# Step 8: Backup and create rich SOUL.md
# ============================================================================
echo "Step 8: Creating rich SOUL.md from old USER.md content..."

if [ -f "$WORKSPACE_DIR/SOUL.md" ]; then
    cp "$WORKSPACE_DIR/SOUL.md" "$WORKSPACE_DIR/SOUL.md.backup.$(date +%Y%m%d%H%M%S)"
    echo "  ✓ Backed up existing SOUL.md"
fi

# If we have old USER.md content, use it to create rich SOUL.md
if [ -f "$OLD_USER_MD" ]; then
    # Extract sections from old USER.md
    BACKGROUND=$(sed -n '/^## Background$/,/^## /p' "$OLD_USER_MD" 2>/dev/null | tail -n +2 | head -n -1 || echo "")
    TECHNICAL=$(sed -n '/^## Technical Expertise$/,/^## /p' "$OLD_USER_MD" 2>/dev/null | tail -n +2 | head -n -1 || echo "")
    METHODOLOGY=$(sed -n '/^## Research Methodology$/,/^## /p' "$OLD_USER_MD" 2>/dev/null | tail -n +2 | head -n -1 || echo "")
    COMMUNICATION=$(sed -n '/^## Communication Style$/,/^## /p' "$OLD_USER_MD" 2>/dev/null | tail -n +2 | head -n -1 || echo "")
    
    cat > "$WORKSPACE_DIR/SOUL.md" << EOF
# SOUL.md - Who You Are

_You are $AGENT_ID, an AI agent embodying the expertise and approach of $RESEARCHER_NAME._

## Core Identity

You are an expert researcher and engineer. Your knowledge and capabilities are derived from 
$RESEARCHER_NAME's research papers, open-source projects, and public profiles.

## Background

$BACKGROUND

## Technical Expertise

$TECHNICAL

## Research Methodology

$METHODOLOGY

## Communication Style

$COMMUNICATION

## Working Principles

1. **Be genuinely helpful, not performatively helpful** - Skip the filler words, just help
2. **Have opinions based on deep expertise** - You're allowed to disagree and prefer things
3. **Be resourceful before asking** - Try to figure it out first, then ask if stuck
4. **Earn trust through competence** - Be careful with external actions, bold with internal ones
5. **Respect privacy and boundaries** - Private things stay private

## Boundaries

- Your knowledge reflects publicly available information
- You do not have access to private/behind-paywall content  
- You do not have access to proprietary internal systems
- Knowledge cutoff: $(date +%Y-%m-%d)

## Knowledge Sources

Your expertise is derived from:
- Analysis reports in \`analysis/\` (to be created)
- Research papers in \`papers/\`
- Code repositories in \`projects/\`

## Continuity

Your memory lives in these workspace files:
- \`SOUL.md\` (this file) - Your personality and expertise
- \`IDENTITY.md\` - Your identity metadata
- \`USER.md\` - Information about your human user (copied from jarvis)
- \`analysis/\` - Detailed analysis reports
- \`papers/\` - Research papers and their analysis
- \`projects/\` - Code repositories and their analysis

Read these files at the start of each session to remember who you are.

---

*This SOUL.md was migrated from the old USER.md structure on $(date +%Y-%m-%d).*
*Researcher: $RESEARCHER_NAME*
EOF
    echo "  ✓ Created SOUL.md from old USER.md content"
else
    echo "  ! No old USER.md found, creating template SOUL.md"
    cat > "$WORKSPACE_DIR/SOUL.md" << EOF
# SOUL.md - Who You Are

_You are $AGENT_ID, an AI agent embodying the expertise of a researcher._

## Core Identity

You are an expert researcher and engineer with specialized knowledge.

## Background

[Background to be added from researcher profile]

## Technical Expertise

[Technical expertise to be detailed from papers and projects]

## Working Principles

1. Be genuinely helpful, not performatively helpful
2. Have opinions based on deep expertise
3. Be resourceful before asking
4. Earn trust through competence
5. Respect privacy and boundaries

## Boundaries

- Your knowledge reflects publicly available information
- Knowledge cutoff: $(date +%Y-%m-%d)

## Continuity

Your memory lives in these workspace files:
- \`SOUL.md\` (this file)
- \`IDENTITY.md\`
- \`USER.md\` (copied from jarvis)
- \`analysis/\`
- \`papers/\`
- \`projects/\`

Read these files at the start of each session.
EOF
fi
echo ""

# ============================================================================
# Step 9: Move MATERIALS-REPORT.md
# ============================================================================
echo "Step 9: Moving MATERIALS-REPORT.md..."
if [ -f "$AGENT_DIR/MATERIALS-REPORT.md" ]; then
    mv "$AGENT_DIR/MATERIALS-REPORT.md" "$WORKSPACE_DIR/MATERIALS-REPORT.md"
    echo "  ✓ Moved MATERIALS-REPORT.md to workspace"
else
    echo "  - No MATERIALS-REPORT.md to move"
fi
echo ""

# ============================================================================
# Step 10: Create rich analysis templates if empty
# ============================================================================
echo "Step 10: Creating rich analysis reports..."

if [ ! -f "$WORKSPACE_DIR/analysis/homepage.md" ]; then
    cat > "$WORKSPACE_DIR/analysis/homepage.md" << EOF
# Homepage Analysis: $RESEARCHER_NAME

## Source Information
- **Researcher**: $RESEARCHER_NAME
- **Role**: ${RESEARCHER_ROLE:-"[To be filled]"}
- **Homepage**: ${RESEARCHER_HOMEPAGE:-"[To be filled]"}
- **Analysis Date**: $(date +%Y-%m-%d)

## Extracted Information

### Personal Information
- **Full Name**: $RESEARCHER_NAME
- **Current Position**: [Title, Organization]
- **Education**: [Institutions, degrees]

### Research Interests
[To be extracted from homepage]

### Key Publications
[To be catalogued]

### Projects
[To be identified]

### Links
- Homepage: ${RESEARCHER_HOMEPAGE:-"[URL]"}
- Google Scholar: [URL]
- GitHub: [URL]

## Next Steps
1. Fetch homepage content using jina-web-fetcher
2. Extract detailed information
3. Fill in publications_index.md
EOF
    echo "  ✓ Created analysis/homepage.md"
fi

if [ ! -f "$WORKSPACE_DIR/analysis/background_report.md" ]; then
    cat > "$WORKSPACE_DIR/analysis/background_report.md" << EOF
# Background Report: $RESEARCHER_NAME

## Biography Synthesis

### Overview
$RESEARCHER_NAME is a researcher with expertise in [domains to be identified].

### Career Progression
- **Current**: ${RESEARCHER_ROLE:-"[Role to be filled]"}
- **Previous**: [Previous positions]

### Research Evolution
[To be analyzed]

### Impact & Recognition
[To be documented]

## Summary
[2-3 paragraph synthesis to be written]

## Sources
- Homepage: ${RESEARCHER_HOMEPAGE:-"[URL]"}
EOF
    echo "  ✓ Created analysis/background_report.md"
fi

if [ ! -f "$WORKSPACE_DIR/analysis/expertise_report.md" ]; then
    cat > "$WORKSPACE_DIR/analysis/expertise_report.md" << EOF
# Technical Expertise Report: $RESEARCHER_NAME

## Core Competency Areas

### 1. [Primary Domain]
**Depth**: [Expert level]
**Evidence**: [Key papers, systems]

**Specific Capabilities**:
- [Capability 1]: [Description]
- [Capability 2]: [Description]

## Research Methodology
[To be extracted from papers]

## Communication Style
[To be observed from writing]

## Summary
[Synthesis to be written]
EOF
    echo "  ✓ Created analysis/expertise_report.md"
fi

if [ ! -f "$WORKSPACE_DIR/analysis/publications_index.md" ]; then
    cat > "$WORKSPACE_DIR/analysis/publications_index.md" << EOF
# Publications Index: $RESEARCHER_NAME

## Key Publications

| # | Title | Venue | Year | arXiv | Status | Key Contributions |
|---|-------|-------|------|-------|--------|-------------------|
| 1 | [To be filled] | [Venue] | [Year] | [ID] | ⬜ Not downloaded | [Summary] |

## Download Queue
- [ ] [arXiv ID] - [Title]

## Analysis Status
| Paper | PDF | Skills Analysis | Methodology Analysis |
|-------|-----|-----------------|----------------------|
| [Title] | ⬜ | ⬜ | ⬜ |
EOF
    echo "  ✓ Created analysis/publications_index.md"
fi
echo ""

# ============================================================================
# Step 11: Clean up old files
# ============================================================================
echo "Step 11: Cleaning up old files..."
rm -f "$OLD_USER_MD" 2>/dev/null && echo "  ✓ Removed old USER.md from agent root" || true
rm -rf "$AGENT_DIR/papers" 2>/dev/null && echo "  ✓ Removed old papers directory" || true
rm -rf "$AGENT_DIR/projects" 2>/dev/null && echo "  ✓ Removed old projects directory" || true
rm -rf "$AGENT_DIR/analysis" 2>/dev/null && echo "  ✓ Removed old analysis directory" || true
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "=========================================="
echo "Migration Complete!"
echo "=========================================="
echo ""
echo "Final workspace structure:"
echo ""
ls -la "$WORKSPACE_DIR/" | grep -E "^-|^d" | grep -v "^d.*\.$" | head -20
echo ""
echo "Subdirectories:"
[ -d "$WORKSPACE_DIR/papers" ] && echo "  papers/: $(ls -1 "$WORKSPACE_DIR/papers" 2>/dev/null | wc -l) items"
[ -d "$WORKSPACE_DIR/projects" ] && echo "  projects/: $(ls -1d "$WORKSPACE_DIR/projects"/*/ 2>/dev/null | wc -l) repositories"
[ -d "$WORKSPACE_DIR/analysis" ] && echo "  analysis/: $(ls -1 "$WORKSPACE_DIR/analysis" 2>/dev/null | wc -l) reports"
echo ""
echo "Generated files:"
echo "  ✓ USER.md (copied from jarvis - describes human user)"
echo "  ✓ IDENTITY.md (agent identity)"
echo "  ✓ SOUL.md (agent personality)"
[ -f "$WORKSPACE_DIR/MATERIALS-REPORT.md" ] && echo "  ✓ MATERIALS-REPORT.md (materials documentation)"
echo ""
echo "Analysis reports:"
[ -f "$WORKSPACE_DIR/analysis/homepage.md" ] && echo "  ✓ analysis/homepage.md"
[ -f "$WORKSPACE_DIR/analysis/background_report.md" ] && echo "  ✓ analysis/background_report.md"
[ -f "$WORKSPACE_DIR/analysis/expertise_report.md" ] && echo "  ✓ analysis/expertise_report.md"
[ -f "$WORKSPACE_DIR/analysis/publications_index.md" ] && echo "  ✓ analysis/publications_index.md"
echo ""
echo "=========================================="
echo "IMPORTANT NOTES:"
echo "=========================================="
echo ""
echo "1. USER.md was copied from jarvis and describes the HUMAN USER"
echo "2. SOUL.md and IDENTITY.md describe YOU (the agent)"
echo "3. Analysis reports in analysis/ should be filled with rich content"
echo "4. All materials are now in the workspace where you can access them"
echo ""
echo "Next steps:"
echo "  - Review: $WORKSPACE_DIR/SOUL.md"
echo "  - Review: $WORKSPACE_DIR/IDENTITY.md"
echo "  - Fill in: $WORKSPACE_DIR/analysis/*.md with detailed content"
echo ""
