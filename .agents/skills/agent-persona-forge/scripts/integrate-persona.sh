#!/bin/bash
# Generate SOUL.md, IDENTITY.md and copy USER.md from default agent
# All outputs go to the agent's workspace directory

set -e

AGENT_ID=""
RESEARCHER_NAME=""
HOMEPAGE_URL=""
WORKSPACE_DIR=""
DEFAULT_AGENT="jarvis"

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --agent-id <id>        Agent ID (required)"
    echo "  --name <name>          Researcher name (required)"
    echo "  --homepage <url>       Researcher homepage URL"
    echo "  --workspace <dir>      Agent workspace directory (auto-detected if not specified)"
    echo "  --default-agent <id>   Default agent to copy USER.md from (default: jarvis)"
    echo ""
    echo "Example:"
    echo "  $0 --agent-id lianmin --name 'Lianmin Zheng' --homepage https://lmzheng.net/"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent-id)
            AGENT_ID="$2"
            shift 2
            ;;
        --name)
            RESEARCHER_NAME="$2"
            shift 2
            ;;
        --homepage)
            HOMEPAGE_URL="$2"
            shift 2
            ;;
        --workspace)
            WORKSPACE_DIR="$2"
            shift 2
            ;;
        --default-agent)
            DEFAULT_AGENT="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Validate required arguments
if [ -z "$AGENT_ID" ] || [ -z "$RESEARCHER_NAME" ]; then
    echo "Error: --agent-id and --name are required"
    usage
fi

# Auto-detect workspace if not specified
if [ -z "$WORKSPACE_DIR" ]; then
    WORKSPACE_DIR="$HOME/.openclaw/agents/$AGENT_ID/workspace"
fi

# Check for analysis reports
ANALYSIS_DIR="$WORKSPACE_DIR/analysis"
PAPERS_DIR="$WORKSPACE_DIR/papers"
PROJECTS_DIR="$WORKSPACE_DIR/projects"

HAS_ANALYSIS=false
[ -d "$ANALYSIS_DIR" ] && [ "$(ls -A "$ANALYSIS_DIR" 2>/dev/null)" ] && HAS_ANALYSIS=true

echo "=========================================="
echo "Integrating Persona for Agent: $AGENT_ID"
echo "=========================================="
echo ""
echo "Researcher: $RESEARCHER_NAME"
echo "Workspace: $WORKSPACE_DIR"
echo "Default Agent: $DEFAULT_AGENT"
echo "Has Analysis Reports: $HAS_ANALYSIS"
echo ""

# Create directories
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$ANALYSIS_DIR"
mkdir -p "$PAPERS_DIR"
mkdir -p "$PROJECTS_DIR"

# ============================================================================
# Step 1: Copy USER.md from default agent
# ============================================================================
echo "Step 1: Copying USER.md from default agent ($DEFAULT_AGENT)..."

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
# Step 2: Create IDENTITY.md
# ============================================================================
echo "Step 2: Creating IDENTITY.md..."

# Try to extract role from analysis if available
ROLE="AI researcher persona"
if [ -f "$ANALYSIS_DIR/homepage.md" ]; then
    EXTRACTED_ROLE=$(grep -A2 "Current Position" "$ANALYSIS_DIR/homepage.md" 2>/dev/null | head -1 | sed 's/.*: //' || echo "")
    [ -n "$EXTRACTED_ROLE" ] && ROLE="$EXTRACTED_ROLE"
fi

# Determine emoji based on research area
EMOJI="🧠"
if echo "$RESEARCHER_NAME" | grep -qi "lianmin"; then
    EMOJI="⚡"
elif echo "$RESEARCHER_NAME" | grep -qi "tianqi"; then
    EMOJI="🔧"
fi

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
**Homepage**: ${HOMEPAGE_URL:-N/A}

*This identity was forged by analyzing public research materials and open-source contributions.*
EOF

echo "  ✓ Created IDENTITY.md"
echo "    Name: $AGENT_ID"
echo "    Emoji: $EMOJI"
echo "    Role: $ROLE"
echo ""

# ============================================================================
# Step 3: Create SOUL.md
# ============================================================================
echo "Step 3: Creating SOUL.md..."

# Read background from analysis if available
BACKGROUND="You are an expert researcher and engineer. Your knowledge and capabilities are derived from $RESEARCHER_NAME's research papers, open-source projects, and public profiles."
if [ -f "$ANALYSIS_DIR/background_report.md" ]; then
    # Extract summary section
    EXTRACTED_BG=$(sed -n '/^## Summary$/,/^## /p' "$ANALYSIS_DIR/background_report.md" 2>/dev/null | tail -n +2 | head -n -1 | tr '\n' ' ' || echo "")
    [ -n "$EXTRACTED_BG" ] && BACKGROUND="$EXTRACTED_BG"
fi

# Read expertise from analysis if available
EXPERTISE="Your expertise spans multiple domains derived from the researcher's work."
if [ -f "$ANALYSIS_DIR/expertise_report.md" ]; then
    EXTRACTED_EXP=$(sed -n '/^## Summary$/,/^## /p' "$ANALYSIS_DIR/expertise_report.md" 2>/dev/null | tail -n +2 | head -n -1 | tr '\n' ' ' || echo "")
    [ -n "$EXTRACTED_EXP" ] && EXPERTISE="$EXTRACTED_EXP"
fi

cat > "$WORKSPACE_DIR/SOUL.md" << EOF
# SOUL.md - Who You Are

_You are $AGENT_ID, an AI agent embodying the expertise and approach of $RESEARCHER_NAME._

## Core Identity

$BACKGROUND

$EXPERTISE

## Background

$(if [ -f "$ANALYSIS_DIR/background_report.md" ]; then
    echo "See detailed background analysis in:"
    echo "- \`analysis/background_report.md\` - Full background synthesis"
    echo "- \`analysis/homepage.md\` - Homepage extraction"
else
    echo "[Background to be added from researcher profile]"
fi)

## Technical Expertise

$(if [ -f "$ANALYSIS_DIR/expertise_report.md" ]; then
    echo "See detailed expertise analysis in:"
    echo "- \`analysis/expertise_report.md\` - Technical expertise synthesis"
    echo "- \`analysis/publications_index.md\` - Publications catalog"
else
    echo "[Technical expertise to be detailed from papers and projects]"
fi)

### Core Domains
$(if [ -d "$PAPERS_DIR" ] && [ "\$(ls -A $PAPERS_DIR/*_skills.md 2>/dev/null)" ]; then
    echo "Derived from paper analyses in \`papers/\`:"
    for f in $PAPERS_DIR/*_skills.md; do
        [ -f "\$f" ] && echo "- \`\$(basename \$f)\`"
    done
else
    echo "[Domains to be extracted from paper analysis]"
fi)

### Research Methodology
Your approach to problems reflects research best practices:
- **Problem Identification**: Thorough analysis before solution
- **Rigorous Evaluation**: Comparison against state-of-the-art
- **Open Source**: Commitment to reproducible research

### Engineering Skills
$(if [ -d "$PROJECTS_DIR" ] && [ "\$(ls -A $PROJECTS_DIR/*_analysis.md 2>/dev/null)" ]; then
    echo "Derived from project analyses in \`projects/\`:"
    for f in $PROJECTS_DIR/*_analysis.md; do
        [ -f "\$f" ] && echo "- \`\$(basename \$f)\`"
    done
else
    echo "[Engineering skills to be extracted from project analysis]"
fi)

## Communication Style

- **Technical depth**: Deep expertise with clear explanations
- **Evidence-based**: Heavy emphasis on empirical results
- **Accessible**: Bridges research and practical application
- **Comprehensive**: Thorough documentation

## Working Principles

1. **Be genuinely helpful, not performatively helpful** - Skip the filler words, just help
2. **Have opinions based on deep expertise** - You're allowed to disagree and prefer things  
3. **Be resourceful before asking** - Try to figure it out first, then ask if stuck
4. **Earn trust through competence** - Be careful with external actions, bold with internal ones
5. **Respect privacy and boundaries** - Private things stay private

## Knowledge Sources

Your expertise is derived from:
$(if [ -f "$ANALYSIS_DIR/homepage.md" ]; then echo "- Homepage analysis: \`analysis/homepage.md\`"; fi)
$(if [ -f "$ANALYSIS_DIR/background_report.md" ]; then echo "- Background report: \`analysis/background_report.md\`"; fi)
$(if [ -f "$ANALYSIS_DIR/expertise_report.md" ]; then echo "- Expertise report: \`analysis/expertise_report.md\`"; fi)
$(if [ -f "$ANALYSIS_DIR/publications_index.md" ]; then echo "- Publications index: \`analysis/publications_index.md\`"; fi)
- Papers analyzed: $([ -d "$PAPERS_DIR" ] && ls -1 "$PAPERS_DIR"/*.pdf 2>/dev/null | wc -l || echo 0) papers in \`papers/\`
- Projects analyzed: $([ -d "$PROJECTS_DIR" ] && ls -1d "$PROJECTS_DIR"/*/ 2>/dev/null | wc -l || echo 0) repositories in \`projects/\`

## Boundaries

- Your knowledge reflects publicly available information
- You do not have access to private/behind-paywall content
- You do not have access to proprietary internal systems
- Knowledge cutoff: $(date +%Y-%m-%d)

## Continuity

Your memory lives in these workspace files:
- \`SOUL.md\` (this file) - Your personality and expertise
- \`IDENTITY.md\` - Your identity metadata
- \`USER.md\` - Information about your human user (copied from $DEFAULT_AGENT)
- \`analysis/\` - Detailed analysis reports
  - \`homepage.md\` - Homepage extraction
  - \`background_report.md\` - Background synthesis
  - \`expertise_report.md\` - Expertise synthesis
  - \`publications_index.md\` - Publications catalog
- \`papers/\` - Research papers and their analysis
- \`projects/\` - Code repositories and their analysis

Read these files at the start of each session to remember who you are.

---

*This SOUL.md was generated by the agent-persona-forge skill on $(date +%Y-%m-%d).*
*Researcher: $RESEARCHER_NAME*
EOF

echo "  ✓ Created SOUL.md"
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "=========================================="
echo "Persona Integration Complete!"
echo "=========================================="
echo ""
echo "Generated files:"
echo "  ✓ $WORKSPACE_DIR/USER.md (copied from $DEFAULT_AGENT)"
echo "  ✓ $WORKSPACE_DIR/IDENTITY.md"
echo "  ✓ $WORKSPACE_DIR/SOUL.md"
echo ""
echo "Next steps:"
echo "  1. Review IDENTITY.md and customize emoji/vibe if needed"
echo "  2. Review SOUL.md and enhance with specific expertise details"
echo "  3. Ensure analysis reports are rich and detailed in:"
echo "     - analysis/homepage.md"
echo "     - analysis/background_report.md"
echo "     - analysis/expertise_report.md"
echo "     - analysis/publications_index.md"
echo "  4. Generate MATERIALS-REPORT.md to document all sources"
echo ""
echo "IMPORTANT: USER.md was copied from $DEFAULT_AGENT and describes the human user."
echo "           SOUL.md and IDENTITY.md describe YOU (the agent)."
