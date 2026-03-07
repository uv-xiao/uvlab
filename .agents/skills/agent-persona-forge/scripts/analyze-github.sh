#!/bin/bash
# Clone and analyze a GitHub repository, creating rich analysis reports

set -e

REPO_URL="$1"
AUTHOR_NAME="$2"
AGENT_ID="$3"
FULL_CLONE="${FULL_CLONE:-false}"

usage() {
    echo "Usage: $0 <repo_url> [author_name] [agent_id]"
    echo ""
    echo "Environment variables:"
    echo "  FULL_CLONE=true    Perform full clone instead of shallow (default: false)"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/vllm-project/vllm 'Lianmin Zheng' lianmin"
    echo "  $0 vllm-project/vllm '' lianmin"
    echo "  FULL_CLONE=true $0 apache/tvm 'Tianqi Chen' tianqi"
    exit 1
}

if [ -z "$REPO_URL" ]; then
    echo "Error: Repository URL is required"
    usage
fi

if [ -z "$AGENT_ID" ]; then
    echo "Error: Agent ID is required"
    usage
fi

# Set up workspace paths
WORKSPACE_DIR="$HOME/.openclaw/agents/$AGENT_ID/workspace"
PROJECTS_DIR="$WORKSPACE_DIR/projects"

mkdir -p "$PROJECTS_DIR"

ANALYSIS_DATE=$(date +%Y-%m-%d)

# Normalize repo URL
if [[ ! "$REPO_URL" == http* ]]; then
    REPO_URL="https://github.com/$REPO_URL"
fi

# Extract owner/repo
REPO_PATH=$(echo "$REPO_URL" | sed 's|https://github.com/||' | sed 's|/$||')
REPO_NAME=$(basename "$REPO_PATH")
OWNER=$(dirname "$REPO_PATH" | sed 's|/[^/]*$||')

PROJECT_DIR="$PROJECTS_DIR/$REPO_NAME"
ANALYSIS_FILE="$PROJECTS_DIR/${REPO_NAME}_analysis.md"

echo "=========================================="
echo "GitHub Project Analysis"
echo "=========================================="
echo ""
echo "Repository: $REPO_PATH"
echo "Agent: $AGENT_ID"
echo "Date: $ANALYSIS_DATE"
echo "Full clone: $FULL_CLONE"
echo ""

# ============================================================================
# Clone repository
# ============================================================================
echo "Cloning repository..."
if [ -d "$PROJECT_DIR" ]; then
    echo "  Repository already exists at $PROJECT_DIR"
    echo "  Updating to latest..."
    cd "$PROJECT_DIR"
    git pull 2>/dev/null || echo "  Could not update (may be a shallow clone)"
else
    if [ "$FULL_CLONE" = "true" ]; then
        echo "  Performing full clone (this may take longer)..."
        git clone "$REPO_URL" "$PROJECT_DIR"
    else
        echo "  Performing shallow clone (--depth 100)..."
        git clone --depth 100 "$REPO_URL" "$PROJECT_DIR"
        echo ""
        echo "  Tip: Use FULL_CLONE=true for complete commit history"
    fi
fi

cd "$PROJECT_DIR"
echo "  ✓ Repository ready at: $PROJECT_DIR"
echo ""

# ============================================================================
# Gather repository information
# ============================================================================
echo "Gathering repository information..."

# Get basic info
DEFAULT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
TOTAL_COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")

# Get author info if specified
AUTHOR_COMMITS=""
AUTHOR_COMMIT_COUNT=0
if [ -n "$AUTHOR_NAME" ]; then
    AUTHOR_COMMITS=$(git log --author="$AUTHOR_NAME" --oneline 2>/dev/null || echo "")
    AUTHOR_COMMIT_COUNT=$(echo "$AUTHOR_COMMITS" | grep -c . || echo 0)
fi

# Try to get README
README_CONTENT=""
for readme in README.md README.rst README; do
    if [ -f "$readme" ]; then
        README_CONTENT=$(head -200 "$readme" 2>/dev/null || echo "")
        break
    fi
done

# Get directory structure
DIR_STRUCTURE=$(tree -L 2 -d 2>/dev/null || find . -maxdepth 2 -type d | head -30)

# Get key source files
SOURCE_FILES=$(find . -type f \( -name "*.py" -o -name "*.cpp" -o -name "*.cu" -o -name "*.h" -o -name "*.hpp" -o -name "*.rs" -o -name "*.go" -o -name "*.java" \) 2>/dev/null | head -50)

echo "  ✓ Gathered repository data"
echo ""

# ============================================================================
# Create rich project analysis report
# ============================================================================
echo "Creating rich analysis report..."

cat > "$ANALYSIS_FILE" << EOF
# Project Analysis: $REPO_NAME

## Repository Overview

### Basic Information
- **Repository**: $REPO_PATH
- **URL**: $REPO_URL
- **Owner**: $OWNER
- **Local Path**: \`projects/$REPO_NAME/\`
- **Default Branch**: $DEFAULT_BRANCH
- **Clone Date**: $ANALYSIS_DATE
- **Clone Type**: $([ "$FULL_CLONE" = "true" ] && echo "Full" || echo "Shallow (--depth 100)")

### Project Description

#### From README
$(if [ -n "$README_CONTENT" ]; then
    echo "\`\`\`"
    echo "$README_CONTENT" | head -100
    echo "\`\`\`"
else
    echo "[No README found]"
fi)

#### Mission & Goals
[What the project aims to achieve - extract from README and documentation]

#### Target Users
[Who uses this system and for what purposes]

### Key Statistics
- **Total Commits**: $TOTAL_COMMITS
$(if [ -n "$AUTHOR_NAME" ]; then
    echo "- **Commits by $AUTHOR_NAME**: $AUTHOR_COMMIT_COUNT"
fi)

---

## Technical Architecture

### System Design
[High-level architecture description based on code structure]

### Directory Structure
\`\`\`
$DIR_STRUCTURE
\`\`\`

### Core Components

#### 1. [Component Name - e.g., Core Runtime]
- **Purpose**: [What this component does]
- **Location**: [Directory/file paths]
- **Key Files**:
$(if [ -n "$SOURCE_FILES" ]; then
    echo "$SOURCE_FILES" | head -10 | while read f; do
        echo "  - \`$f\`"
    done
else
    echo "  - [To be identified]"
fi)
- **Design Patterns**: [Architecture patterns used]
- **Dependencies**: [What it relies on]

#### 2. [Component Name]
[Same structure]

### Data Flow
[How data moves through the system - to be analyzed from code]

### Key Algorithms & Techniques

#### [Algorithm/Technique Name]
- **Purpose**: [What problem it solves]
- **Implementation**: [Where to find it in the code]
- **Key Files**: [Specific source files]
- **Complexity**: [Time/space complexity if applicable]
- **Innovations**: [Novel aspects]

---

## Code Quality Analysis

### Code Organization
[How the codebase is structured and organized]

#### Module Structure
- [Module 1]: [Responsibility]
- [Module 2]: [Responsibility]

### Coding Standards

#### Style Observations
- **Formatting**: [Code formatting patterns]
- **Naming**: [Naming conventions]
- **Documentation**: [Docstring and comment patterns]

#### Type Safety
- **Type Hints**: [Usage of typing]
- **Static Analysis**: [Tools used if any]

#### Testing Practices
- **Test Framework**: [What testing framework is used]
- **Coverage**: [Observed testing patterns]
- **Test Types**: [Unit/integration/etc.]

### Notable Implementation Details
[Interesting coding techniques observed]

---

$(if [ -n "$AUTHOR_NAME" ]; then
cat << 'AUTHOR_SECTION'
## Author Contribution Analysis

### Commit History for AUTHOR_NAME

#### Overview
- **Total Commits**: AUTHOR_COMMIT_COUNT
- **First Commit**: [To be determined]
- **Most Recent**: [To be determined]

#### Recent Commits
\`\`\`
AUTHOR_COMMITS
\`\`\`

#### Contribution Patterns

##### Code Contributions
- **Core Features Built**:
  - [Feature 1]: [Description and evidence]
  - [Feature 2]: [Description and evidence]

- **Bug Fixes**:
  - [Fix type 1]: [Pattern observed]
  - [Fix type 2]: [Pattern observed]

- **Refactoring**:
  - [Refactoring type]: [Code quality improvements]

##### Commit Message Style
[Pattern analysis of commit messages]
- Format: [Structure observed]
- Keywords: [Common tags like [FIX], [DOC], etc.]

##### Review Activity
[If review data is available]

#### Author's Role Evolution
[How their role in the project changed over time]

AUTHOR_SECTION
fi)

---

## Project Impact

### Adoption Metrics
- **GitHub Stars**: [To be fetched]
- **Forks**: [To be fetched]
- **Contributors**: [To be fetched]
- **Downloads**: [If available]

### Production Usage
[Where this system is used in production]

#### Companies/Organizations
- [Org 1]: [How they use it]
- [Org 2]: [How they use it]

#### Integration Ecosystem
[Tools/frameworks that integrate with this project]

### Community Health

#### Activity Metrics
- **Issue Response Time**: [If observable]
- **PR Merge Rate**: [If observable]
- **Release Frequency**: [How often releases happen]

#### Governance
- **Maintainers**: [Who maintains the project]
- **Decision Making**: [How decisions are made]

---

## Skills Demonstrated

### Technical Skills

#### Core Expertise
1. **[Skill 1 - e.g., CUDA Kernel Optimization]**
   - **Evidence**: [Where in the codebase]
   - **Proficiency**: [Expert/Advanced/Intermediate]
   - **Applications**: [What it enables]

2. **[Skill 2]**
   [Same structure]

#### System Design Skills
- **[Skill]**: [Evidence and application]

### Engineering Practices

#### Development Workflow
- **Version Control**: [Git workflow patterns]
- **CI/CD**: [Automation practices]
- **Code Review**: [Review patterns observed]

#### Quality Assurance
- **Testing Strategy**: [Approach to testing]
- **Documentation**: [Documentation practices]
- **Performance**: [Performance optimization practices]

### Domain Expertise

#### [Domain 1 - e.g., Distributed Systems]
- **Knowledge Areas**: [Specific expertise]
- **Application**: [How it's applied in this project]

#### [Domain 2]
[Same structure]

---

## Documentation Quality

### README Analysis

#### Completeness
- [x] Installation instructions
- [ ] Usage examples
- [ ] API documentation
- [ ] Contributing guidelines
- [ ] License information

#### Clarity
- **Quick Start**: [How easy to get started]
- **Concepts**: [How well concepts are explained]
- **Examples**: [Quality and quantity of examples]

### API Documentation
[Coverage and quality of API docs]

#### Strengths
- [Strength 1]
- [Strength 2]

#### Gaps
- [Gap 1]
- [Gap 2]

### Tutorials & Guides
[Learning resources available]

---

## Maintenance Patterns

### Issue Handling
[How issues are managed]

#### Issue Categories
- [Category 1]: [Pattern]
- [Category 2]: [Pattern]

#### Response Patterns
- **Response Time**: [Typical time to response]
- **Resolution Rate**: [How often issues are resolved]

### Release Cycle
[How releases are done]

#### Versioning
- **Scheme**: [SemVer, etc.]
- **Frequency**: [How often releases happen]
- **Breaking Changes**: [How they're handled]

### Community Interaction
[How maintainers interact with community]

---

## Strengths & Weaknesses

### Project Strengths
1. **[Strength 1]**
   - **Evidence**: [Specific examples]
   - **Impact**: [Why it matters]

2. **[Strength 2]**
   [Same structure]

### Areas for Improvement
1. **[Area 1]**
   - **Current State**: [What's lacking]
   - **Suggestion**: [How to improve]
   - **Priority**: [High/Medium/Low]

2. **[Area 2]**
   [Same structure]

### Technical Debt
[Observable technical debt]

---

## Relevance to Agent Persona

### How This Project Shapes Your Expertise
[How this codebase contributes to the agent's capabilities]

### Specific Knowledge Gained

#### Technical Knowledge
- [Knowledge 1]: [Application]
- [Knowledge 2]: [Application]

#### Practical Skills
- [Skill 1]: [Application]
- [Skill 2]: [Application]

### Questions You Can Now Answer
- **[Question type 1]**: [Example question]
- **[Question type 2]**: [Example question]

### Code Patterns to Reference
[Specific patterns from this codebase that are useful]

---

## Key Files Reference

### Essential Reading
1. \`[file path]\`: [Why important - brief description]
2. \`[file path]\`: [Why important]
3. \`[file path]\`: [Why important]

### Implementation Examples
1. \`[file path]\`: [What it demonstrates]
2. \`[file path]\`: [What it demonstrates]

### Configuration
1. \`[file path]\`: [Configuration purpose]
2. \`[file path]\`: [Configuration purpose]

### Tests
1. \`[file path]\`: [What functionality is tested]
2. \`[file path]\`: [What functionality is tested]

---

## Notes for Agent Usage

### When to Reference This Project
[Scenarios where this codebase is relevant]

### Key Insights to Remember
- [Insight 1]: [Summary]
- [Insight 2]: [Summary]

### Common Pitfalls to Avoid
- [Pitfall 1]: [Explanation]
- [Pitfall 2]: [Explanation]

### Related Resources
- Documentation: [Links]
- Examples: [Links]
- Community: [Links]

---

*Analysis generated on $ANALYSIS_DATE*
*Repository: $REPO_URL*
EOF

echo "  ✓ Created ${REPO_NAME}_analysis.md"
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "=========================================="
echo "Repository Analysis Complete!"
echo "=========================================="
echo ""
echo "Repository location: $PROJECT_DIR"
echo "Analysis report: $ANALYSIS_FILE"
echo ""
echo "Statistics:"
echo "  Total commits: $TOTAL_COMMITS"
[ -n "$AUTHOR_NAME" ] && echo "  Commits by $AUTHOR_NAME: $AUTHOR_COMMIT_COUNT"
echo ""
echo "Next steps:"
echo "  1. Read the analysis report"
echo "  2. Explore key source files in $PROJECT_DIR"
echo "  3. Fill in the analysis with detailed observations"
echo "  4. Identify key patterns and skills"
echo "  5. Use insights to enhance SOUL.md"
if [ "$FULL_CLONE" != "true" ]; then
    echo ""
    echo "For full commit history: FULL_CLONE=true $0 $REPO_URL '$AUTHOR_NAME' $AGENT_ID"
fi
echo ""
