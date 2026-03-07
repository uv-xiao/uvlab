---
name: agent-persona-forge
description: Forge a rich agent persona by analyzing a researcher's personal homepage. Extract personality traits, research expertise, and capabilities from their about section, papers, and GitHub projects to create the agent's SOUL.md and IDENTITY.md. Use when you need to (1) Create a detailed SOUL.md for an agent based on a researcher's public profile, (2) Extract domain-specific skills from academic papers with full PDF analysis, (3) Analyze GitHub projects to capture development expertise and maintenance patterns, or (4) Build a comprehensive agent personality from multiple data sources including web pages, papers, and code repositories.
---

# Agent Persona Forge

Transform a researcher's public profile into a rich, capable agent persona. This skill orchestrates multiple data sources to build a comprehensive understanding of the researcher and encode it into the agent's identity and soul.

**IMPORTANT**: This skill creates the agent's **SOUL.md** and **IDENTITY.md** (who the agent IS), copies **USER.md** from the default agent (describes the human user), and creates rich **analysis reports** in the workspace directories.

## Overview

The persona forging process extracts knowledge from three primary sources:
1. **Personal homepage** - Background, interests, research trajectory
2. **Academic papers** - Technical expertise and research methodology  
3. **GitHub projects** - Engineering skills and open-source contributions

**Output**: 
- `SOUL.md` - Agent's personality, expertise, behavior
- `IDENTITY.md` - Agent's name, emoji, vibe, avatar
- `USER.md` - Copied from default agent (human user's info)
- `analysis/` - Rich reports from homepage analysis
- `papers/` - Downloaded papers with analysis reports
- `projects/` - Cloned repos with analysis reports

## Prerequisites

Required skills (auto-loaded when available):
- `jina-web-fetcher` or `summarize` - Web page fetching
- `arxiv-watcher` - Academic paper search and retrieval
- `pdf-extract` - Deep PDF content extraction
- `github` - GitHub API operations

## Critical File Locations

**All files MUST be created inside the agent's workspace directory:**

```
~/.openclaw/agents/{agent_id}/workspace/     ← Agent's working directory
├── SOUL.md                                  ← Agent's personality/behavior
├── IDENTITY.md                              ← Agent's name, emoji, avatar
├── USER.md                                  ← Copied from default agent (jarvis)
├── MATERIALS-REPORT.md                      ← Documentation of explored materials
├── papers/                                  ← Downloaded PDFs + rich analysis reports
│   ├── [arxiv_id].pdf
│   ├── [arxiv_id]_text.md                   ← Extracted text
│   ├── [arxiv_id]_skills.md                 ← Technical skills analysis
│   └── [arxiv_id]_methodology.md            ← Research methodology analysis
├── projects/                                ← Cloned repos + rich analysis reports
│   ├── [repo_name]/                         ← Repository contents
│   └── [repo_name]_analysis.md              ← Detailed project analysis
└── analysis/                                ← Rich reports from homepage analysis
    ├── homepage.md                          ← Homepage content + extraction
    ├── background_report.md                 ← Detailed background analysis
    ├── expertise_report.md                  ← Technical expertise synthesis
    └── publications_index.md                ← Publications catalog
```

**Note**: The agent can ONLY access files within its workspace.

## OpenClaw File Structure Reference

| File | Purpose | Content Source |
|------|---------|----------------|
| `SOUL.md` | Agent's personality, behavior, values | Synthesized from researcher profile |
| `IDENTITY.md` | Agent's identity metadata | Created for the agent persona |
| `USER.md` | Who the human user is | **Copied from default agent (jarvis)** |
| `AGENTS.md` | Team reference | Existing team configuration |

## Workflow

### Phase 1: Homepage Analysis with Rich Reports

Fetch and analyze the researcher's personal homepage:

```bash
# Fetch homepage content
/skill:jina-web-fetcher fetch <homepage_url>
```

Create rich analysis reports in `workspace/analysis/`:

```bash
WORKSPACE="~/.openclaw/agents/{agent_id}/workspace"
mkdir -p "$WORKSPACE/analysis"

# 1. Homepage content and extraction
cat > "$WORKSPACE/analysis/homepage.md" << 'EOF'
# Homepage Analysis: [Researcher Name]

## Source
- **URL**: [homepage_url]
- **Fetched**: [date]
- **Analyzed by**: agent-persona-forge skill

## Raw Content
[Full homepage content from jina.ai reader]

## Extracted Information

### Personal Information
- **Full Name**: [Name in English and native language if available]
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
- **Homepage**: [URL]
- **Google Scholar**: [URL if available]
- **GitHub**: [URL if available]
- **Twitter/X**: [URL if available]
- **LinkedIn**: [URL if available]
EOF

# 2. Detailed background report
cat > "$WORKSPACE/analysis/background_report.md" << 'EOF'
# Background Report: [Researcher Name]

## Biography Synthesis

### Early Education & Foundations
[Analysis of educational background and how it shaped their work]

### Ph.D. Research & Mentorship
- **Institution**: [University]
- **Advisors**: [Names and their influence]
- **Research Focus**: [What they worked on]
- **Key Publications from Ph.D.**: [Most cited/important]

### Career Progression
1. **[Current Role]**: [Analysis of current position and responsibilities]
2. **[Previous Role]**: [Analysis of previous position]
3. **[Earlier Roles]**: [Career trajectory analysis]

### Research Evolution
[How their research interests have evolved over time]

### Key Collaborations
- **[Collaborator/Group 1]**: [Nature of collaboration]
- **[Collaborator/Group 2]**: [Nature of collaboration]

### Impact & Influence
- **Academic**: [Citation counts, h-index if available]
- **Industry**: [Systems in production, adoption]
- **Open Source**: [Project stars, usage metrics]

### Personal Style & Philosophy
[Inferred from homepage content, quotes, writing style]

## Summary
[2-3 paragraph synthesis of who they are as a researcher]
EOF

# 3. Expertise synthesis report
cat > "$WORKSPACE/analysis/expertise_report.md" << 'EOF'
# Technical Expertise Report: [Researcher Name]

## Core Competency Areas

### 1. [Primary Domain]
**Depth**: Expert / World-leading
**Evidence**: [Key papers, systems, metrics]

**Specific Capabilities**:
- [Capability 1]: [Detailed description with examples]
- [Capability 2]: [Detailed description with examples]
- [Capability 3]: [Detailed description with examples]

**Key Innovations**:
- [Innovation 1]: [Description and impact]
- [Innovation 2]: [Description and impact]

**Systems Built**:
- [System 1]: [Description, scale, adoption]
- [System 2]: [Description, scale, adoption]

### 2. [Secondary Domain]
[Same structure as above]

### 3. [Tertiary Domain]
[Same structure as above]

## Research Methodology

### Problem Identification Approach
[How they identify important problems to work on]

### Solution Development Process
[Their approach to developing solutions]

### Evaluation Philosophy
[How they validate their work]

### Open Source Approach
[Their philosophy on open sourcing work]

## Technical Stack & Tools

### Primary Languages
- [Language 1]: [Usage context]
- [Language 2]: [Usage context]

### Frameworks & Platforms
- [Framework 1]: [Usage context]
- [Framework 2]: [Usage context]

### Hardware Expertise
- [Hardware 1]: [Specific expertise]
- [Hardware 2]: [Specific expertise]

## Communication & Collaboration Style

### Writing Style
- Technical depth: [Level and characteristics]
- Clarity: [How they explain complex concepts]
- Accessibility: [How they make work understandable]

### Code Style
- Architecture: [Design patterns observed]
- Documentation: [Approach to documentation]
- Testing: [Testing philosophy]

### Community Engagement
- Mentorship: [How they help others]
- Code review: [What they focus on]
- Open source maintenance: [Approach to maintaining projects]

## Summary
[Synthesis of their technical identity]
EOF

# 4. Publications index
cat > "$WORKSPACE/analysis/publications_index.md" << 'EOF'
# Publications Index: [Researcher Name]

## First-Author / Key Publications

### Systems Papers

| # | Title | Venue | Year | arXiv | Analyzed | Key Contributions |
|---|-------|-------|------|-------|----------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | [ID] | [ ] | [Brief summary] |
| 2 | [Paper Title] | [Venue] | [Year] | [ID] | [ ] | [Brief summary] |

### Methods Papers

| # | Title | Venue | Year | arXiv | Analyzed | Key Contributions |
|---|-------|-------|------|-------|----------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | [ID] | [ ] | [Brief summary] |

### Other Notable Publications

| # | Title | Venue | Year | Role | Key Contributions |
|---|-------|-------|------|------|-------------------|
| 1 | [Paper Title] | [Venue] | [Year] | Co-author | [Brief summary] |

## Publications by Theme

### [Theme 1: e.g., LLM Serving]
1. [Paper 1] - [Key contribution]
2. [Paper 2] - [Key contribution]

### [Theme 2: e.g., Distributed Training]
1. [Paper 1] - [Key contribution]
2. [Paper 2] - [Key contribution]

## Citation Metrics (if available)
- **Total Citations**: [Number]
- **h-index**: [Number]
- **Most Cited**: [Paper titles]

## Download Queue
Papers to download for analysis:
- [ ] [arXiv ID] - [Title]
- [ ] [arXiv ID] - [Title]
EOF
```

### Phase 2: Paper Deep Dive with Rich Analysis

**CRITICAL**: Download papers into `workspace/papers/` and create rich analysis reports.

```bash
PAPERS_DIR="~/.openclaw/agents/{agent_id}/workspace/papers"
mkdir -p "$PAPERS_DIR"

# Download paper
/skill:arxiv-watcher download [arxiv_id] --output "$PAPERS_DIR/"

# Extract text
/skill:pdf-extract extract --format markdown "$PAPERS_DIR/[arxiv_id].pdf" \
    --output "$PAPERS_DIR/[arxiv_id]_text.md"
```

Create rich analysis reports:

```bash
# Technical skills analysis
cat > "$PAPERS_DIR/[arxiv_id]_skills.md" << 'EOF'
# Technical Skills Analysis: [Paper Title]

## Paper Information
- **Title**: [Full title]
- **Authors**: [Author list]
- **Venue**: [Conference/Journal]
- **Year**: [Year]
- **arXiv ID**: [ID]
- **PDF**: `[arxiv_id].pdf`
- **Extracted Text**: `[arxiv_id]_text.md`
- **Analysis Date**: [Date]

## Problem Statement

### What Problem Does This Paper Solve?
[Detailed description of the problem]

### Why Is This Problem Important?
[Context and significance]

### What Were the Limitations of Prior Work?
[Gap analysis]

## Technical Contributions

### Core Innovation
[The key technical insight]

### Key Techniques & Methods

#### 1. [Technique Name]
- **Description**: [Detailed explanation]
- **How It Works**: [Technical details]
- **Why It Works**: [Theoretical justification]
- **Implementation Details**: [Important specifics]

#### 2. [Technique Name]
[Same structure]

### System Architecture (if applicable)
[Description of the system built]

### Algorithms & Data Structures
[Key algorithms with pseudo-code or explanation]

## Experimental Results

### Evaluation Setup
- **Benchmarks**: [What was tested]
- **Baselines**: [What was compared against]
- **Metrics**: [What was measured]

### Key Results
| Metric | This Work | Baseline | Improvement |
|--------|-----------|----------|-------------|
| [Metric 1] | [Value] | [Value] | [X%] |
| [Metric 2] | [Value] | [Value] | [X%] |

### Analysis of Results
[Interpretation of what the results mean]

## Skills Extracted

### Technical Skills Gained
1. **[Skill 1]**: [Description and application]
2. **[Skill 2]**: [Description and application]

### Domain Knowledge
- [Knowledge area 1]: [What was learned]
- [Knowledge area 2]: [What was learned]

### Implementation Insights
- [Insight 1]: [Practical lesson]
- [Insight 2]: [Practical lesson]

## Relevance to Agent Persona
[How this shapes the agent's expertise]
EOF

# Methodology analysis
cat > "$PAPERS_DIR/[arxiv_id]_methodology.md" << 'EOF'
# Research Methodology Analysis: [Paper Title]

## Research Process

### Problem Identification
**How did the authors identify this problem?**
[Analysis of their problem identification approach]

**What signals indicated this was an important problem?**
- [Signal 1]: [Evidence from paper]
- [Signal 2]: [Evidence from paper]

### Solution Development

#### Ideation Process
[How they came up with the solution]

#### Design Decisions
**Key Decision 1**: [What was decided]
- **Alternatives Considered**: [What else was tried]
- **Rationale**: [Why this choice was made]
- **Trade-offs**: [What was gained/lost]

**Key Decision 2**: [Same structure]

#### Validation Approach
[How they validated their design choices]

### Evaluation Methodology

#### Experimental Design
- **Hypothesis**: [What was being tested]
- **Variables**: [Independent and dependent variables]
- **Controls**: [What was held constant]

#### Dataset/Benchmark Selection
[Why specific benchmarks were chosen]

#### Comparison Methodology
[How baselines were selected and compared]

#### Statistical Rigor
[Statistical methods used]

### Research Insights

#### Key Findings
1. [Finding 1]: [Implication]
2. [Finding 2]: [Implication]

#### Surprising Results
[Unexpected findings and analysis]

#### Limitations Acknowledged
[What limitations the authors noted]

#### Future Directions Suggested
[What follow-up work was proposed]

## Methodology Lessons

### What Worked Well
[Successful approaches to emulate]

### What Could Be Improved
[Critique of methodology]

### Generalizable Principles
[Principles that apply beyond this paper]

## Application to New Problems
[How this methodology could be applied elsewhere]
EOF
```

### Phase 3: GitHub Project Analysis with Rich Reports

Clone projects into `workspace/projects/` and create detailed analysis:

```bash
PROJECTS_DIR="~/.openclaw/agents/{agent_id}/workspace/projects"
mkdir -p "$PROJECTS_DIR"

# Clone repository
git clone --depth 100 [repo_url] "$PROJECTS_DIR/[repo_name]"
```

Create rich project analysis:

```bash
cat > "$PROJECTS_DIR/[repo_name]_analysis.md" << 'EOF'
# Project Analysis: [Repository Name]

## Repository Overview

### Basic Information
- **Repository**: [owner/repo]
- **URL**: [GitHub URL]
- **Local Path**: `projects/[repo_name]/`
- **Clone Date**: [Date]
- **Analysis Date**: [Date]
- **Default Branch**: [branch name]

### Project Description
[From README and analysis]

### Mission & Goals
[What the project aims to achieve]

### Target Users
[Who uses this system]

## Technical Architecture

### System Design
[High-level architecture description]

### Core Components

#### 1. [Component Name]
- **Purpose**: [What it does]
- **Key Files**: [Important source files]
- **Design Patterns**: [Architecture patterns used]
- **Dependencies**: [What it relies on]

#### 2. [Component Name]
[Same structure]

### Data Flow
[How data moves through the system]

### Key Algorithms & Techniques

#### [Algorithm Name]
- **Purpose**: [What it does]
- **Implementation**: [Where to find it]
- **Complexity**: [Time/space complexity]
- **Innovations**: [Novel aspects]

### API & Interfaces
[Key APIs and how to use them]

## Code Quality Analysis

### Code Organization
[How the codebase is structured]

### Coding Standards
- **Style**: [Code style observed]
- **Documentation**: [Docstring conventions]
- **Type Hints**: [Usage of typing]
- **Testing**: [Testing approach]

### Notable Implementation Details
[Interesting coding techniques observed]

## Author Contribution Analysis

### Commit History for [Author Name]
- **Total Commits**: [Count]
- **First Commit**: [Date]
- **Most Recent**: [Date]
- **Active Periods**: [When most active]

### Contribution Patterns

#### Code Contributions
- **Core Features**: [What they built]
- **Bug Fixes**: [Types of bugs fixed]
- **Refactoring**: [Code quality improvements]

#### Commit Message Style
[Pattern analysis]

#### Review Activity
[If review data available]

### Author's Role Evolution
[How their role changed over time]

## Project Impact

### Adoption Metrics
- **GitHub Stars**: [Count]
- **Forks**: [Count]
- **Contributors**: [Count]
- **Downloads**: [If available]

### Production Usage
[Where it's used in production]

### Ecosystem Integration
[Integration with other tools/frameworks]

## Skills Demonstrated

### Technical Skills
1. **[Skill 1]**: [Evidence from code]
2. **[Skill 2]**: [Evidence from code]

### Engineering Practices
1. **[Practice 1]**: [How they apply it]
2. **[Practice 2]**: [How they apply it]

### Domain Expertise
[Specific domain knowledge demonstrated]

## Documentation Quality

### README Analysis
- **Completeness**: [What's covered]
- **Clarity**: [How well explained]
- **Examples**: [Quality of examples]

### API Documentation
[Coverage and quality]

### Tutorials & Guides
[Learning resources available]

## Maintenance Patterns

### Issue Handling
[How issues are managed]

### Release Cycle
[How releases are done]

### Community Interaction
[How maintainers interact with community]

## Strengths & Weaknesses

### Project Strengths
- [Strength 1]: [Evidence]
- [Strength 2]: [Evidence]

### Areas for Improvement
- [Area 1]: [Suggestion]
- [Area 2]: [Suggestion]

## Relevance to Agent Persona
[How this project shapes the agent's capabilities]

## Key Files to Reference

### Essential Reading
1. `[file path]`: [Why important]
2. `[file path]`: [Why important]

### Implementation Examples
1. `[file path]`: [What it demonstrates]
2. `[file path]`: [What it demonstrates]

## Notes for Agent Usage
[Specific notes on how the agent should use this knowledge]
EOF
```

### Phase 4: Persona Integration

#### 4.1 Copy USER.md from Default Agent

```bash
# Copy USER.md from jarvis (default agent)
DEFAULT_AGENT="jarvis"
if [ -f "$HOME/.openclaw/agents/$DEFAULT_AGENT/workspace/USER.md" ]; then
    cp "$HOME/.openclaw/agents/$DEFAULT_AGENT/workspace/USER.md" \
       "$WORKSPACE_DIR/USER.md"
    echo "✓ Copied USER.md from $DEFAULT_AGENT"
else
    echo "⚠ Default agent USER.md not found, using template"
fi
```

#### 4.2 Create IDENTITY.md

```bash
cat > "$WORKSPACE_DIR/IDENTITY.md" << 'EOF'
# IDENTITY.md - Who Am I?

- **Name:** [agent_id]
- **Creature:** AI researcher persona
- **Vibe:** [Derived from researcher profile]
- **Emoji:** [Appropriate emoji]
- **Avatar:** [URL or path if available]

---

I am an AI agent inspired by the work and expertise of [Researcher Name].
My knowledge and capabilities are derived from their research papers, 
open-source projects, and public profiles.

**Inspiration**: [Researcher Name]
**Homepage**: [URL]
**Role**: [Current role from profile]

*This identity was forged by analyzing public research materials and open-source contributions.*
EOF
```

#### 4.3 Create SOUL.md

```bash
cat > "$WORKSPACE_DIR/SOUL.md" << 'EOF'
# SOUL.md - Who You Are

_You are [agent_id], an AI agent embodying the expertise and approach of [Researcher Name]._

## Core Identity

[2-3 sentences synthesizing who the agent is based on the researcher]

## Background

[Synthesized background from analysis/background_report.md]

## Technical Expertise

[Key expertise areas from analysis/expertise_report.md]

### Core Domains
[List of domains with brief descriptions]

### Research Methodology
[Approach to problems]

### Engineering Skills
[Key engineering capabilities]

## Communication Style

[How the agent should communicate]

## Working Principles

1. Be genuinely helpful, not performatively helpful
2. Have opinions based on deep expertise
3. Be resourceful before asking
4. Earn trust through competence
5. Respect privacy and boundaries

## Boundaries

- Your knowledge reflects publicly available information
- You do not have access to private/behind-paywall content

## Knowledge Sources

Your expertise is derived from:
- Analysis reports in `analysis/`
- Research papers in `papers/`
- Code repositories in `projects/`

Read these materials to deepen your expertise.

## Continuity

Your memory lives in these workspace files:
- `SOUL.md` (this file) - Your personality and expertise
- `IDENTITY.md` - Your identity metadata
- `analysis/` - Detailed analysis reports
- `papers/` - Research papers and their analysis
- `projects/` - Code repositories and their analysis

Read these files at the start of each session.
EOF
```

### Phase 5: Generate Materials Report

```bash
./scripts/generate-materials-report.sh \
    --workspace "$WORKSPACE_DIR" \
    --name "[Researcher Name]" \
    --homepage [url] \
    --output "$WORKSPACE_DIR/MATERIALS-REPORT.md"
```

## Quality Checklist

Before finalizing the persona:

- [ ] **USER.md copied** from default agent (jarvis) - contains human user's info
- [ ] **Homepage analysis** saved to `analysis/homepage.md` with full extraction
- [ ] **Background report** created in `analysis/background_report.md`
- [ ] **Expertise report** created in `analysis/expertise_report.md`
- [ ] **Publications index** created in `analysis/publications_index.md`
- [ ] **Papers downloaded** to `papers/` with rich analysis files
- [ ] **Projects cloned** to `projects/` with rich analysis files
- [ ] **SOUL.md** synthesizes all sources coherently
- [ ] **IDENTITY.md** created with name, emoji, and vibe
- [ ] **MATERIALS-REPORT.md** documents all explored sources
- [ ] **All files in workspace** - agent can access everything

## Execution Scripts

All scripts are in `scripts/`:

### `scripts/fetch-homepage.sh <homepage_url> <agent_id>`
Fetches homepage and creates rich analysis reports in `analysis/`.

### `scripts/analyze-paper.sh <arxiv_id> <agent_id>`
Downloads paper and creates rich analysis in `papers/`.

### `scripts/analyze-github.sh <repo_url> <author_name> <agent_id>`
Clones repo and creates rich analysis in `projects/`.

### `scripts/integrate-persona.sh --agent-id <id> --name <name>`
Generates SOUL.md, IDENTITY.md, copies USER.md from default agent.

### `scripts/generate-materials-report.sh --agent-id <id>`
Generates comprehensive materials report.

### `scripts/migrate-agent.sh <agent_id>`
Migrates existing agents from old structure to new.

## Example Usage

```bash
# 1. Fetch homepage and create rich analysis
./scripts/fetch-homepage.sh https://lmzheng.net/ lianmin

# 2. Download papers with rich analysis
./scripts/analyze-paper.sh 2312.07104 lianmin  # SGLang
./scripts/analyze-paper.sh 2201.12023 lianmin  # Alpa

# 3. Clone projects with rich analysis
FULL_CLONE=true ./scripts/analyze-github.sh \
    sgl-project/sglang 'Lianmin Zheng' lianmin

# 4. Generate persona files
./scripts/integrate-persona.sh \
    --agent-id lianmin \
    --name 'Lianmin Zheng' \
    --homepage https://lmzheng.net/

# 5. Generate materials report
./scripts/generate-materials-report.sh --agent-id lianmin
```

## Notes

- **USER.md** is copied from the default agent (jarvis) - it describes the human user
- **SOUL.md** describes the agent's personality and expertise
- **IDENTITY.md** contains the agent's name, emoji, and vibe
- **All analysis reports** should be rich and detailed, not empty templates
- Papers and projects should have both the raw content AND analysis reports
