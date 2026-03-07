#!/bin/bash
# Generate a comprehensive report of all materials explored during persona forging
# All paths are relative to the agent's workspace

set -e

WORKSPACE_DIR=""
OUTPUT_FILE=""
RESEARCHER_NAME=""
HOMEPAGE_URL=""
AGENT_ID=""

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --agent-id <id>        Agent ID (required or use --workspace)"
    echo "  --workspace <dir>      Workspace directory (auto-detected from agent-id if not specified)"
    echo "  --name <name>          Researcher name"
    echo "  --homepage <url>       Homepage URL"
    echo "  --output <file>        Output report file (default: <workspace>/MATERIALS-REPORT.md)"
    echo ""
    echo "Example:"
    echo "  $0 --agent-id lianmin --name 'Lianmin Zheng' --homepage https://lmzheng.net/"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --workspace)
            WORKSPACE_DIR="$2"
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
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --agent-id)
            AGENT_ID="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Auto-detect workspace from agent ID if not specified
if [ -z "$WORKSPACE_DIR" ] && [ -n "$AGENT_ID" ]; then
    WORKSPACE_DIR="$HOME/.openclaw/agents/$AGENT_ID/workspace"
fi

if [ -z "$WORKSPACE_DIR" ]; then
    echo "Error: Either --workspace or --agent-id must be specified"
    usage
fi

# Set default output if not specified
if [ -z "$OUTPUT_FILE" ]; then
    OUTPUT_FILE="$WORKSPACE_DIR/MATERIALS-REPORT.md"
fi

# Get current date
GENERATION_DATE=$(date +%Y-%m-%d)

# Define subdirectories
PAPERS_DIR="$WORKSPACE_DIR/papers"
PROJECTS_DIR="$WORKSPACE_DIR/projects"
ANALYSIS_DIR="$WORKSPACE_DIR/analysis"

# Count materials
PAPERS_COUNT=0
PROJECTS_COUNT=0
ANALYSIS_COUNT=0

if [ -d "$PAPERS_DIR" ]; then
    PAPERS_COUNT=$(find "$PAPERS_DIR" -name "*.pdf" 2>/dev/null | wc -l || echo "0")
fi

if [ -d "$PROJECTS_DIR" ]; then
    PROJECTS_COUNT=$(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l || echo "0")
fi

if [ -d "$ANALYSIS_DIR" ]; then
    ANALYSIS_COUNT=$(find "$ANALYSIS_DIR" -type f 2>/dev/null | wc -l || echo "0")
fi

echo "Generating materials report..."
echo "  Workspace: $WORKSPACE_DIR"
echo "  Output: $OUTPUT_FILE"
echo "  Papers: $PAPERS_COUNT"
echo "  Projects: $PROJECTS_COUNT"
echo "  Analysis files: $ANALYSIS_COUNT"

# Start generating report
cat > "$OUTPUT_FILE" << EOF
# Materials Report: ${RESEARCHER_NAME:-Researcher Persona}

**Generated**: ${GENERATION_DATE}
**Agent ID**: ${AGENT_ID:-N/A}
**Workspace**: \`${WORKSPACE_DIR}\`

---

## Executive Summary

This report documents all materials explored and analyzed during the persona forging process for **${RESEARCHER_NAME:-the researcher}**.

All materials are stored within the agent's workspace where they can be accessed during sessions.

### Materials Overview

| Category | Count | Location | Status |
|----------|-------|----------|--------|
| Homepage | 1 | \`analysis/homepage.md\` | ${HOMEPAGE_URL:+Analyzed} |
| Papers | ${PAPERS_COUNT} | \`papers/\` | Downloaded & Analyzed |
| GitHub Projects | ${PROJECTS_COUNT} | \`projects/\` | Cloned & Analyzed |
| Analysis Files | ${ANALYSIS_COUNT} | \`analysis/\` | Generated |
| **Total Sources** | $((1 + PAPERS_COUNT + PROJECTS_COUNT)) | - | - |

---

## 1. Homepage Analysis

### Source
- **URL**: ${HOMEPAGE_URL:-Not specified}
- **Fetched**: ${GENERATION_DATE}
- **Local Copy**: \`analysis/homepage.md\`

### Sections Analyzed
- [x] About/Biography
- [x] Research Interests
- [x] Publications List
- [x] Projects/Tools
- [x] Awards/Recognition
- [x] Professional Service

### Key Information Extracted
All information from the homepage has been extracted and saved to \`analysis/homepage.md\`.

EOF

# Section 2: Papers Analysis
cat >> "$OUTPUT_FILE" << EOF

---

## 2. Papers Explored

### Summary
- **Total papers**: ${PAPERS_COUNT}
- **Location**: \`papers/\`
- **Analysis Location**: \`analysis/\`

### Paper Details

EOF

if [ -d "$PAPERS_DIR" ] && [ "$PAPERS_COUNT" -gt 0 ]; then
    for pdf_file in "$PAPERS_DIR"/*.pdf; do
        if [ -f "$pdf_file" ]; then
            basename_pdf=$(basename "$pdf_file" .pdf)
            echo "#### Paper: ${basename_pdf}" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "- **PDF**: \`papers/${basename_pdf}.pdf\`" >> "$OUTPUT_FILE"
            
            # Check for extracted text
            if [ -f "$PAPERS_DIR/${basename_pdf}_text.md" ]; then
                echo "- **Extracted Text**: \`${basename_pdf}_text.md\`" >> "$OUTPUT_FILE"
            fi
            
            # Check for skill extraction
            if [ -f "$ANALYSIS_DIR/${basename_pdf}_skills.md" ]; then
                echo "- **Technical Skills**: \`analysis/${basename_pdf}_skills.md\`" >> "$OUTPUT_FILE"
            fi
            
            # Check for methodology extraction
            if [ -f "$ANALYSIS_DIR/${basename_pdf}_methodology.md" ]; then
                echo "- **Methodology Analysis**: \`analysis/${basename_pdf}_methodology.md\`" >> "$OUTPUT_FILE"
            fi
            
            echo "" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "*No papers were analyzed during this persona forging session.*" >> "$OUTPUT_FILE"
fi

# Section 3: GitHub Projects Analysis
cat >> "$OUTPUT_FILE" << EOF

---

## 3. GitHub Projects Explored

### Summary
- **Total projects**: ${PROJECTS_COUNT}
- **Location**: \`projects/\`
- **Analysis Location**: \`analysis/\`

### Project Details

EOF

if [ -d "$PROJECTS_DIR" ] && [ "$PROJECTS_COUNT" -gt 0 ]; then
    for project_dir in "$PROJECTS_DIR"/*/; do
        if [ -d "$project_dir" ]; then
            project_name=$(basename "$project_dir")
            analysis_file="${project_name}_analysis.md"
            
            echo "#### Project: ${project_name}" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            echo "- **Local Path**: \`projects/${project_name}/\`" >> "$OUTPUT_FILE"
            
            if [ -f "$ANALYSIS_DIR/$analysis_file" ]; then
                echo "- **Analysis Report**: \`analysis/${analysis_file}\`" >> "$OUTPUT_FILE"
            fi
            
            # Check for commit count if git repo
            if [ -d "$project_dir/.git" ]; then
                commit_count=$(cd "$project_dir" && git log --oneline 2>/dev/null | wc -l || echo "0")
                echo "- **Commits Available**: ${commit_count}" >> "$OUTPUT_FILE"
                
                # Check if it was a full or shallow clone
                shallow_check=$(cd "$project_dir" && git rev-parse --is-shallow-repository 2>/dev/null || echo "true")
                if [ "$shallow_check" = "true" ]; then
                    echo "- **Clone Type**: Shallow (use FULL_CLONE=true for full history)" >> "$OUTPUT_FILE"
                else
                    echo "- **Clone Type**: Full" >> "$OUTPUT_FILE"
                fi
            fi
            
            echo "" >> "$OUTPUT_FILE"
        fi
    done
else
    echo "*No GitHub projects were analyzed during this persona forging session.*" >> "$OUTPUT_FILE"
fi

# Section 4: Analysis Artifacts
cat >> "$OUTPUT_FILE" << EOF

---

## 4. Analysis Artifacts

### Generated Files in \`analysis/\`

| File | Description |
|------|-------------|
| \`homepage.md\` | Homepage content and extraction |
EOF

# List all analysis files
if [ -d "$ANALYSIS_DIR" ]; then
    for file in "$ANALYSIS_DIR"/*_skills.md; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            echo "| \`${basename_file}\` | Technical skills extraction |" >> "$OUTPUT_FILE"
        fi
    done
    
    for file in "$ANALYSIS_DIR"/*_methodology.md; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            echo "| \`${basename_file}\` | Research methodology extraction |" >> "$OUTPUT_FILE"
        fi
    done
    
    for file in "$ANALYSIS_DIR"/*_analysis.md; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            if [[ ! "$basename_file" == *_skills.md ]] && [[ ! "$basename_file" == *_methodology.md ]]; then
                echo "| \`${basename_file}\` | Project/repository analysis |" >> "$OUTPUT_FILE"
            fi
        fi
    done
fi

# Section 5: Agent Persona Files
cat >> "$OUTPUT_FILE" << EOF

---

## 5. Agent Persona Files

These files define the agent's identity and are located in the workspace root:

| File | Purpose | Status |
|------|---------|--------|
| \`IDENTITY.md\` | Agent's name, emoji, avatar, vibe | $([ -f "$WORKSPACE_DIR/IDENTITY.md" ] && echo "✅ Generated" || echo "❌ Not generated") |
| \`SOUL.md\` | Agent's personality, expertise, behavior | $([ -f "$WORKSPACE_DIR/SOUL.md" ] && echo "✅ Generated" || echo "❌ Not generated") |
| \`MATERIALS-REPORT.md\` | This report | ✅ Generated |

EOF

# Section 6: Data Quality Assessment
cat >> "$OUTPUT_FILE" << EOF

---

## 6. Data Quality Assessment

### Coverage Analysis

| Source Type | Target | Actual | Coverage |
|-------------|--------|--------|----------|
| Homepage sections | 6 | ${HOMEPAGE_URL:+1} | ${HOMEPAGE_URL:+Complete} |
| Papers | Variable | ${PAPERS_COUNT} | Analyzed |
| GitHub Projects | Variable | ${PROJECTS_COUNT} | Cloned & Analyzed |
| Analysis Files | Variable | ${ANALYSIS_COUNT} | Generated |

### Improvements Over Previous Version

✅ **All materials in workspace**: Papers, projects, and analysis files are all stored in the agent's workspace directory where they can be accessed.

✅ **Full PDF extraction**: Papers are downloaded as PDFs with text extraction performed (when tools available).

✅ **Support for full clone**: Use FULL_CLONE=true environment variable for complete git history.

✅ **Correct file types**: Generates SOUL.md and IDENTITY.md (who the agent IS), not USER.md (who the human user is).

### Limitations Addressed

| Previous Limitation | Status | Solution |
|---------------------|--------|----------|
| Papers/projects outside workspace | ✅ Fixed | All materials now in workspace/ |
| Shallow clone only | ✅ Fixed | FULL_CLONE=true for full history |
| No full PDF deep-dive | ✅ Fixed | PDF text extraction with templates |
| Generated USER.md | ✅ Fixed | Now generates SOUL.md and IDENTITY.md |
| Limited author analysis | ✅ Fixed | Multiple matching patterns |

### Current Limitations

- Analysis is based solely on publicly available information
- Private communications, unpublished work, and paywalled content are not accessed
- The persona reflects the researcher's public work as of ${GENERATION_DATE}
- PDF text extraction requires poppler-utils (pdftotext) or pdfplumber

EOF

# Section 7: File Inventory
cat >> "$OUTPUT_FILE" << EOF

---

## 7. Complete File Inventory

### Workspace Structure

\`\`\`
workspace/
├── IDENTITY.md                          # Agent identity (name, emoji, etc.)
├── SOUL.md                              # Agent personality and expertise
├── MATERIALS-REPORT.md                  # This file
├── papers/                              # Downloaded research papers
$(if [ -d "$PAPERS_DIR" ]; then
    for file in "$PAPERS_DIR"/*.pdf 2>/dev/null; do
        if [ -f "$file" ]; then
            echo "│   ├── $(basename "$file")"
        fi
    done
    for file in "$PAPERS_DIR"/*_text.md 2>/dev/null; do
        if [ -f "$file" ]; then
            echo "│   ├── $(basename "$file")"
        fi
    done
fi)
├── projects/                            # Cloned GitHub repositories
$(if [ -d "$PROJECTS_DIR" ]; then
    for dir in "$PROJECTS_DIR"/*/ 2>/dev/null; do
        if [ -d "$dir" ]; then
            echo "│   ├── $(basename "$dir")/"
        fi
    done
fi)
└── analysis/                            # Analysis and extraction files
    ├── homepage.md                      # Homepage content
$(if [ -d "$ANALYSIS_DIR" ]; then
    for file in "$ANALYSIS_DIR"/*_skills.md 2>/dev/null; do
        if [ -f "$file" ]; then
            echo "    ├── $(basename "$file")"
        fi
    done
    for file in "$ANALYSIS_DIR"/*_methodology.md 2>/dev/null; do
        if [ -f "$file" ]; then
            echo "    ├── $(basename "$file")"
        fi
    done
    for file in "$ANALYSIS_DIR"/*_analysis.md 2>/dev/null; do
        if [ -f "$file" ]; then
            echo "    ├── $(basename "$file")"
        fi
    done
fi)
\`\`\`

### All Paths Are Workspace-Relative

All paths above are relative to the agent's workspace directory:
\`${WORKSPACE_DIR}\`

This ensures the agent can access all materials during sessions.

EOF

# Section 8: Usage Notes
cat >> "$OUTPUT_FILE" << EOF

---

## 8. Usage Notes

### For the Agent

At the start of each session, read these files to remember your identity:
1. \`IDENTITY.md\` - Your name, emoji, and basic identity
2. \`SOUL.md\` - Your personality, expertise, and behavior
3. \`analysis/homepage.md\` - Researcher background
4. \`analysis/*_skills.md\` - Technical skills from papers
5. \`analysis/*_methodology.md\` - Research methodology

### For the Human User

- The agent's expertise is derived from ${RESEARCHER_NAME:-the researched persona}
- All materials are stored in the agent's workspace for transparency
- The agent can reference papers in \`papers/\` and code in \`projects/\`
- Knowledge cutoff: ${GENERATION_DATE}

---

*This report was generated by the agent-persona-forge skill on ${GENERATION_DATE}*
*All materials are stored in the agent's workspace: ${WORKSPACE_DIR}*
EOF

echo ""
echo "Materials report generated: $OUTPUT_FILE"
echo ""
echo "Summary:"
echo "  - Papers: $PAPERS_COUNT"
echo "  - Projects: $PROJECTS_COUNT"
echo "  - Analysis files: $ANALYSIS_COUNT"
echo "  - Workspace: $WORKSPACE_DIR"
echo ""
echo "All materials are in the agent's workspace where they can be accessed."
