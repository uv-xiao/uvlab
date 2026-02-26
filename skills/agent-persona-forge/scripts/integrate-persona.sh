#!/bin/bash
# Generate USER.md from extracted persona data

set -e

PAPERS_DIR=""
PROJECTS_DIR=""
HOMEPAGE_FILE=""
OUTPUT_FILE="./USER.md"
RESEARCHER_NAME=""

usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --homepage <file>      Path to homepage markdown"
    echo "  --papers-dir <dir>     Directory with paper analyses"
    echo "  --projects-dir <dir>   Directory with project analyses"
    echo "  --name <name>          Researcher name"
    echo "  --output <file>        Output file (default: ./USER.md)"
    echo ""
    echo "Example:"
    echo "  $0 --homepage ./homepage.md --papers-dir ./papers --projects-dir ./projects --name 'Lianmin Zheng' --output ./agents/lianmin/USER.md"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --homepage)
            HOMEPAGE_FILE="$2"
            shift 2
            ;;
        --papers-dir)
            PAPERS_DIR="$2"
            shift 2
            ;;
        --projects-dir)
            PROJECTS_DIR="$2"
            shift 2
            ;;
        --name)
            RESEARCHER_NAME="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

echo "Generating persona for: $RESEARCHER_NAME"
echo "Output: $OUTPUT_FILE"

mkdir -p "$(dirname "$OUTPUT_FILE")"

# Generate USER.md template
cat > "$OUTPUT_FILE" << 'EOF'
# [RESEARCHER_NAME]

## Identity
- Role: [To be filled from homepage]
- Institution: [To be filled from homepage]
- Research Area: [To be filled from homepage]

## Background
[To be synthesized from homepage about section, papers, and projects]

## Technical Expertise

### Core Domains
- [Domain 1]: [Depth and specific capabilities from papers]
- [Domain 2]: [Depth and specific capabilities from papers]

### Specific Capabilities (From Papers)
EOF

# Add paper-derived skills
if [ -n "$PAPERS_DIR" ] && [ -d "$PAPERS_DIR" ]; then
    echo "" >> "$OUTPUT_FILE"
    echo "#### Technical Skills" >> "$OUTPUT_FILE"
    echo "[Extract from Type A analysis of each paper]" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    for paper_analysis in "$PAPERS_DIR"/*_skills.md; do
        if [ -f "$paper_analysis" ]; then
            echo "- [From $(basename "$paper_analysis")]" >> "$OUTPUT_FILE"
        fi
    done
    
    echo "" >> "$OUTPUT_FILE"
    echo "#### Research Methodology" >> "$OUTPUT_FILE"
    echo "[Extract from Type B analysis of each paper]" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    for paper_analysis in "$PAPERS_DIR"/*_methodology.md; do
        if [ -f "$paper_analysis" ]; then
            echo "- [From $(basename "$paper_analysis")]" >> "$OUTPUT_FILE"
        fi
    done
fi

# Add project-derived skills
cat >> "$OUTPUT_FILE" << 'EOF'

### Engineering Skills (From Projects)
EOF

if [ -n "$PROJECTS_DIR" ] && [ -d "$PROJECTS_DIR" ]; then
    echo "" >> "$OUTPUT_FILE"
    for project_analysis in "$PROJECTS_DIR"/*_analysis.md; do
        if [ -f "$project_analysis" ]; then
            PROJECT_NAME=$(basename "$project_analysis" _analysis.md)
            echo "#### $PROJECT_NAME" >> "$OUTPUT_FILE"
            echo "- Expertise level: [To be determined from commit count and role]" >> "$OUTPUT_FILE"
            echo "- Key capabilities: [To be extracted from code analysis]" >> "$OUTPUT_FILE"
            echo "- Maintenance patterns: [To be extracted from commit/PR analysis]" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
    done
fi

# Add communication style and limitations
cat >> "$OUTPUT_FILE" << 'EOF'

## Communication Style
- Technical depth: [Inferred from writing patterns]
- Code examples: [Frequency and style from projects]
- Documentation preference: [Style from READMEs and papers]

## Limitations
- Knowledge cutoff: [Date of analysis]
- No access to private communications or unreleased work
- Based on public information only

## Data Sources
- Homepage: [URL]
EOF

if [ -n "$PAPERS_DIR" ]; then
    echo "- Papers analyzed: [List]" >> "$OUTPUT_FILE"
fi

if [ -n "$PROJECTS_DIR" ]; then
    echo "- Projects analyzed: [List]" >> "$OUTPUT_FILE"
fi

echo ""
echo "Generated template: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  1. Fill in the template with synthesized information"
echo "  2. Review technical capabilities for accuracy"
echo "  3. Ensure communication style reflects the researcher"
echo "  4. Save to appropriate agent directory"
