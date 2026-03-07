#!/bin/bash
# Fetch and analyze a researcher's homepage, creating rich analysis reports

set -e

HOMEPAGE_URL="$1"
AGENT_ID="$2"

usage() {
    echo "Usage: $0 <homepage_url> <agent_id>"
    echo ""
    echo "Examples:"
    echo "  $0 https://lmzheng.net/ lianmin"
    echo "  $0 https://tqchen.com/ tianqi"
    exit 1
}

if [ -z "$HOMEPAGE_URL" ] || [ -z "$AGENT_ID" ]; then
    echo "Error: Both homepage URL and agent ID are required"
    usage
fi

# Set up workspace paths
WORKSPACE_DIR="$HOME/.openclaw/agents/$AGENT_ID/workspace"
ANALYSIS_DIR="$WORKSPACE_DIR/analysis"

mkdir -p "$ANALYSIS_DIR"

FETCH_DATE=$(date +%Y-%m-%d)

echo "=========================================="
echo "Fetching Homepage Analysis"
echo "=========================================="
echo ""
echo "URL: $HOMEPAGE_URL"
echo "Agent: $AGENT_ID"
echo "Date: $FETCH_DATE"
echo ""

# ============================================================================
# Fetch homepage content
# ============================================================================
echo "Fetching homepage content via jina.ai..."
JINA_URL="https://r.jina.ai/http:${HOMEPAGE_URL#http:}"
JINA_URL="${JINA_URL#http://https://}"
JINA_URL="${JINA_URL#https://https://}"

HOMEPAGE_CONTENT=""
if command -v curl &> /dev/null; then
    HOMEPAGE_CONTENT=$(curl -sL "$JINA_URL" 2>/dev/null || echo "")
fi

if [ -z "$HOMEPAGE_CONTENT" ]; then
    echo "Warning: Could not fetch homepage content automatically."
    HOMEPAGE_CONTENT="[Content could not be fetched automatically. Please manually paste homepage content here.]"
fi

# Extract researcher name from content or URL
RESEARCHER_NAME=$(echo "$HOMEPAGE_CONTENT" | head -5 | grep -oE '^[A-Z][a-z]+ [A-Z][a-z]+' | head -1 || echo "")
if [ -z "$RESEARCHER_NAME" ]; then
    # Try to extract from URL
    RESEARCHER_NAME=$(echo "$HOMEPAGE_URL" | sed 's|https://||' | sed 's|www.||' | sed 's|/.*||' | sed 's|\..*||')
    RESEARCHER_NAME=$(echo "$RESEARCHER_NAME" | sed 's/^./\u&/' | sed 's/ ./\u&/g')  # Capitalize
fi

echo "Detected researcher: $RESEARCHER_NAME"
echo ""

# ============================================================================
# Create 1. homepage.md - Full extraction
# ============================================================================
echo "Creating analysis/homepage.md..."

cat > "$ANALYSIS_DIR/homepage.md" << EOF
# Homepage Analysis: $RESEARCHER_NAME

## Source Information
- **URL**: $HOMEPAGE_URL
- **Fetched**: $FETCH_DATE
- **Analyzed by**: agent-persona-forge skill
- **Researcher**: $RESEARCHER_NAME

## Raw Content

$HOMEPAGE_CONTENT

---

## Extracted Information (To Be Filled)

### Personal Information
- **Full Name**: $RESEARCHER_NAME
- **Current Position**: [Title, Organization]
- **Location**: [If available]
- **Email**: [If public]

### Education Background
- **Ph.D.**: [University, Advisor(s), Year]
- **M.S./B.S.**: [University, Year]
- **Other**: [Notable programs, honors]

### Career Trajectory
- **Current**: [Role, Organization, Start Date]
- **Previous**: [Previous roles with dates]
- **Notable Affiliations**: [Organizations, labs]

### Research Interests
[Detailed extraction of research areas]

1. **[Area 1]**
   - Specific focus: [Details]
   - Key problems: [What they work on]
   - Approach: [How they tackle it]

2. **[Area 2]**
   - Specific focus: [Details]
   - Key problems: [What they work on]
   - Approach: [How they tackle it]

### Awards & Recognition
- [Award 1]: [Details, year]
- [Award 2]: [Details, year]

### Professional Service
- [Role 1]: [Organization, years]
- [Role 2]: [Organization, years]

### Links & Resources
- **Homepage**: $HOMEPAGE_URL
- **Google Scholar**: [URL if available]
- **GitHub**: [URL if available]
- **Twitter/X**: [URL if available]

## Next Steps

1. Review and extract key information above
2. Identify papers to analyze
3. Identify GitHub projects to clone
4. Fill in background_report.md with synthesis
EOF

echo "  ✓ Created $ANALYSIS_DIR/homepage.md"

# ============================================================================
# Create 2. background_report.md - Detailed background synthesis
# ============================================================================
echo "Creating analysis/background_report.md..."

cat > "$ANALYSIS_DIR/background_report.md" << EOF
# Background Report: $RESEARCHER_NAME

## Biography Synthesis

### Overview
$RESEARCHER_NAME is a researcher whose background is being analyzed from their homepage at $HOMEPAGE_URL.

### Early Education & Foundations
[Analysis of educational background and how it shaped their work]
- **Institutions**: [Universities attended]
- **Key Mentors**: [Advisors and their influence]
- **Honors**: [Notable academic achievements]

### Career Progression

#### Current Position
- **Role**: [Title]
- **Organization**: [Institution/Company]
- **Responsibilities**: [Key duties]
- **Start Date**: [When they started]

#### Previous Positions
1. **[Previous Role 1]**
   - Organization: [Name]
   - Duration: [Dates]
   - Key achievements: [What they accomplished]

2. **[Previous Role 2]**
   - Organization: [Name]
   - Duration: [Dates]
   - Key achievements: [What they accomplished]

### Research Evolution
[How their research interests have evolved over time]

#### Early Work
[What they focused on initially]

#### Transition Points
[Key moments of shift in focus]

#### Current Focus
[What they work on now]

### Key Collaborations
- **[Collaborator/Group 1]**: [Nature of collaboration, outcomes]
- **[Collaborator/Group 2]**: [Nature of collaboration, outcomes]

### Major Contributions

#### Research Contributions
- [Contribution 1]: [Description and impact]
- [Contribution 2]: [Description and impact]

#### Open Source Contributions
- [Project 1]: [Description and adoption]
- [Project 2]: [Description and adoption]

#### Community Building
- [Initiative 1]: [Description and impact]
- [Initiative 2]: [Description and impact]

### Impact & Recognition

#### Academic Impact
- **Citation Metrics**: [If available]
- **Key Papers**: [Most influential works]
- **Venues**: [Top-tier publications]

#### Industry Impact
- **Systems in Production**: [Where their work is used]
- **Adoption**: [Companies/projects using their work]

#### Awards & Honors
- [Award 1]: [Year, significance]
- [Award 2]: [Year, significance]

### Personal Style & Philosophy
[Inferred from homepage content, quotes, writing style]

#### Research Philosophy
- [Principle 1]: [Evidence from homepage]
- [Principle 2]: [Evidence from homepage]

#### Working Style
- [Characteristic 1]: [Evidence]
- [Characteristic 2]: [Evidence]

## Summary

$RESEARCHER_NAME is [2-3 paragraph synthesis of who they are as a researcher, their key contributions, their impact, and their approach to research].

## Sources
- Homepage: $HOMEPAGE_URL (fetched $FETCH_DATE)
- [Additional sources to be added]

## Next Steps
1. Extract specific publications from homepage
2. Identify key GitHub repositories
3. Analyze papers for technical expertise
4. Analyze projects for engineering skills
EOF

echo "  ✓ Created $ANALYSIS_DIR/background_report.md"

# ============================================================================
# Create 3. expertise_report.md - Technical expertise synthesis
# ============================================================================
echo "Creating analysis/expertise_report.md..."

cat > "$ANALYSIS_DIR/expertise_report.md" << EOF
# Technical Expertise Report: $RESEARCHER_NAME

## Core Competency Areas

### 1. [Primary Domain - e.g., Machine Learning Systems]
**Depth**: World-leading / Expert / Knowledgeable
**Evidence**: [Key papers, systems, metrics from homepage]

**Specific Capabilities**:
- **[Capability 1]**: [Detailed description with examples]
  - Evidence: [Where this is demonstrated]
  - Applications: [What it enables]
  
- **[Capability 2]**: [Detailed description with examples]
  - Evidence: [Where this is demonstrated]
  - Applications: [What it enables]

**Key Innovations**:
- **[Innovation 1]**: [Description and impact]
  - Problem solved: [What was the issue]
  - Solution: [How they solved it]
  - Impact: [Results achieved]

**Systems Built**:
- **[System 1]**: [Description, scale, adoption]
  - Purpose: [What it does]
  - Scale: [How big/important]
  - Adoption: [Who uses it]

### 2. [Secondary Domain]
[Same structure as above]

### 3. [Tertiary Domain]
[Same structure as above]

## Research Methodology

### Problem Identification Approach
[How they identify important problems to work on]

#### Signals They Look For
- [Signal 1]: [Description]
- [Signal 2]: [Description]

#### Process
1. [Step 1]: [Description]
2. [Step 2]: [Description]

### Solution Development Process

#### Ideation
[How they come up with solutions]

#### Validation
[How they validate ideas before building]

#### Implementation
[Their approach to building systems]

### Evaluation Philosophy
[How they validate their work]

#### Benchmarking Approach
- **Metrics**: [What they measure]
- **Baselines**: [What they compare against]
- **Scale**: [Evaluation scale]

#### Rigor
[Statistical and experimental rigor]

### Open Source Approach
[Their philosophy on open sourcing work]

#### Release Criteria
[When and how they release code]

#### Community Engagement
[How they interact with users/contributors]

## Technical Stack & Tools

### Primary Programming Languages
- **[Language 1]**: [Usage context, proficiency level]
- **[Language 2]**: [Usage context, proficiency level]

### Frameworks & Platforms
- **[Framework 1]**: [Usage context, expertise level]
- **[Framework 2]**: [Usage context, expertise level]

### Hardware Expertise
- **[Hardware 1]**: [Specific expertise]
- **[Hardware 2]**: [Specific expertise]

### Development Tools
- **Version Control**: [Git workflow]
- **CI/CD**: [Testing/deployment practices]
- **Documentation**: [Documentation tools/practices]

## Communication & Collaboration Style

### Writing Style
- **Technical Depth**: [Level and characteristics]
- **Clarity**: [How they explain complex concepts]
- **Accessibility**: [How they make work understandable]

### Code Style
- **Architecture**: [Design patterns observed]
- **Documentation**: [Docstring and comment conventions]
- **Testing**: [Testing philosophy and coverage]

### Community Engagement
- **Mentorship**: [How they help others]
- **Code Review**: [What they focus on in reviews]
- **Issue Handling**: [How they handle bugs/requests]

## Collaboration Patterns

### Working with Students/Junior Researchers
[Their approach to mentorship]

### Industry Collaboration
[How they work with industry partners]

### Open Source Maintenance
[How they maintain projects]

## Summary

$RESEARCHER_NAME's technical identity is characterized by [key characteristics]. Their expertise in [primary domain] is demonstrated through [key evidence]. They approach problems with [methodology characteristics] and communicate their work through [communication characteristics].

## Related Analysis
- Background: \`background_report.md\`
- Publications: \`publications_index.md\`
- Paper analyses: \`../papers/\`
- Project analyses: \`../projects/\`

## Next Steps
1. Analyze papers for technical depth
2. Analyze projects for engineering practices
3. Extract specific skills for agent capabilities
4. Synthesize into SOUL.md
EOF

echo "  ✓ Created $ANALYSIS_DIR/expertise_report.md"

# ============================================================================
# Create 4. publications_index.md - Publications catalog
# ============================================================================
echo "Creating analysis/publications_index.md..."

cat > "$ANALYSIS_DIR/publications_index.md" << EOF
# Publications Index: $RESEARCHER_NAME

## First-Author / Key Publications

### Systems Papers

| # | Title | Venue | Year | arXiv | Status | Key Contributions |
|---|-------|-------|------|-------|--------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | [ID] | ⬜ Not downloaded | [Brief summary] |
| 2 | [Paper Title] | [Venue] | [Year] | [ID] | ⬜ Not downloaded | [Brief summary] |

### Methods Papers

| # | Title | Venue | Year | arXiv | Status | Key Contributions |
|---|-------|-------|------|-------|--------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | [ID] | ⬜ Not downloaded | [Brief summary] |

### Survey/Tutorial Papers

| # | Title | Venue | Year | Status | Key Contributions |
|---|-------|-------|------|--------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | ⬜ Not downloaded | [Brief summary] |

## Publications by Theme

### [Theme 1: e.g., LLM Serving Systems]
1. **[Paper Title]** ([Venue Year]) - [Key contribution]
   - arXiv: [ID]
   - Status: ⬜ Not downloaded
   - Why important: [Reason]

2. **[Paper Title]** ([Venue Year]) - [Key contribution]
   - arXiv: [ID]
   - Status: ⬜ Not downloaded
   - Why important: [Reason]

### [Theme 2: e.g., Distributed Training]
1. **[Paper Title]** ([Venue Year]) - [Key contribution]
   - arXiv: [ID]
   - Status: ⬜ Not downloaded
   - Why important: [Reason]

## Co-authored Publications

| # | Title | Venue | Year | Role | Key Contributions |
|---|-------|-------|------|------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | Co-author | [Brief summary] |

## Citation Metrics
- **Total Citations**: [Number from Google Scholar]
- **h-index**: [Number]
- **i10-index**: [Number]
- **Most Cited Papers**:
  1. [Title] ([Count] citations)
  2. [Title] ([Count] citations)

## Download Queue

### High Priority (Core Papers)
- [ ] [arXiv ID] - [Title] - [Why important]
- [ ] [arXiv ID] - [Title] - [Why important]

### Medium Priority (Supporting Papers)
- [ ] [arXiv ID] - [Title] - [Why important]
- [ ] [arXiv ID] - [Title] - [Why important]

### Low Priority (Related Work)
- [ ] [arXiv ID] - [Title] - [Why important]

## Analysis Status

| Paper | PDF | Text Extracted | Skills Analysis | Methodology Analysis |
|-------|-----|----------------|-----------------|----------------------|
| [Title] | ⬜ | ⬜ | ⬜ | ⬜ |

## Next Steps
1. Extract all publications from homepage
2. Identify arXiv IDs for each paper
3. Prioritize papers for download
4. Download and analyze each paper
EOF

echo "  ✓ Created $ANALYSIS_DIR/publications_index.md"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "=========================================="
echo "Homepage Analysis Complete!"
echo "=========================================="
echo ""
echo "Created rich analysis reports:"
echo "  ✓ $ANALYSIS_DIR/homepage.md (homepage content + extraction template)"
echo "  ✓ $ANALYSIS_DIR/background_report.md (detailed background synthesis)"
echo "  ✓ $ANALYSIS_DIR/expertise_report.md (technical expertise analysis)"
echo "  ✓ $ANALYSIS_DIR/publications_index.md (publications catalog)"
echo ""
echo "Next steps:"
echo "  1. Fill in extracted information in homepage.md"
echo "  2. Complete background_report.md with synthesis"
echo "  3. Complete expertise_report.md with technical analysis"
echo "  4. Fill in publications_index.md with paper list"
echo "  5. Download papers using: ./scripts/analyze-paper.sh <arxiv_id> $AGENT_ID"
echo "  6. Clone projects using: ./scripts/analyze-github.sh <repo_url> '$RESEARCHER_NAME' $AGENT_ID"
echo ""
