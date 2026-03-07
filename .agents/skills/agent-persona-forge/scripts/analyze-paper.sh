#!/bin/bash
# Download and analyze a paper, creating rich analysis reports

set -e

PAPER_SOURCE="$1"
AGENT_ID="$2"

usage() {
    echo "Usage: $0 <arxiv_id|paper_url> <agent_id>"
    echo ""
    echo "Examples:"
    echo "  $0 2312.07104 lianmin        # SGLang paper"
    echo "  $0 1802.04799 tianqi         # TVM paper"
    exit 1
}

if [ -z "$PAPER_SOURCE" ] || [ -z "$AGENT_ID" ]; then
    echo "Error: Both paper source and agent ID are required"
    usage
fi

# Set up workspace paths
WORKSPACE_DIR="$HOME/.openclaw/agents/$AGENT_ID/workspace"
PAPERS_DIR="$WORKSPACE_DIR/papers"

mkdir -p "$PAPERS_DIR"

ANALYSIS_DATE=$(date +%Y-%m-%d)

echo "=========================================="
echo "Paper Analysis"
echo "=========================================="
echo ""
echo "Source: $PAPER_SOURCE"
echo "Agent: $AGENT_ID"
echo "Date: $ANALYSIS_DATE"
echo ""

# ============================================================================
# Determine paper source and download
# ============================================================================
ARXIV_ID=""
PAPER_TITLE="Unknown Paper"

if [[ "$PAPER_SOURCE" =~ ^[0-9]+\.[0-9]+$ ]]; then
    # It's an arXiv ID
    ARXIV_ID="$PAPER_SOURCE"
    echo "Detected arXiv ID: $ARXIV_ID"
    
    # Try to get paper metadata
    echo "Fetching paper metadata..."
    META_URL="https://export.arxiv.org/api/query?id_list=${ARXIV_ID}"
    METADATA=$(curl -sL "$META_URL" 2>/dev/null || echo "")
    
    if [ -n "$METADATA" ]; then
        PAPER_TITLE=$(echo "$METADATA" | grep -oP '(?<=<title>)[^<]+' | tail -1 | sed 's/^[[:space:]]*//' || echo "Paper $ARXIV_ID")
        PAPER_TITLE=$(echo "$PAPER_TITLE" | sed 's/^[[:space:]]*//')  # Trim leading whitespace
    fi
    
    # Download PDF
    echo "Downloading PDF from arXiv..."
    PDF_URL="https://arxiv.org/pdf/${ARXIV_ID}.pdf"
    PDF_FILE="$PAPERS_DIR/${ARXIV_ID}.pdf"
    
    if command -v curl &> /dev/null; then
        curl -sL "$PDF_URL" -o "$PDF_FILE" || {
            echo "Error: Failed to download PDF from arXiv"
            exit 1
        }
    else
        echo "Error: curl not available for downloading PDF"
        exit 1
    fi
    
    # Save metadata
    if [ -n "$METADATA" ]; then
        echo "$METADATA" > "$PAPERS_DIR/${ARXIV_ID}_metadata.xml"
    fi
    
    PAPER_BASENAME="$ARXIV_ID"
    
elif [[ "$PAPER_SOURCE" == *arxiv.org* ]]; then
    # Extract arXiv ID from URL
    ARXIV_ID=$(echo "$PAPER_SOURCE" | grep -oE '\d+\.\d+' | head -1)
    if [ -n "$ARXIV_ID" ]; then
        echo "Extracted arXiv ID from URL: $ARXIV_ID"
        PDF_URL="https://arxiv.org/pdf/${ARXIV_ID}.pdf"
        PDF_FILE="$PAPERS_DIR/${ARXIV_ID}.pdf"
        curl -sL "$PDF_URL" -o "$PDF_FILE"
        PAPER_BASENAME="$ARXIV_ID"
    else
        echo "Could not extract arXiv ID from URL"
        exit 1
    fi
else
    echo "Unsupported paper source. Please provide an arXiv ID or arxiv.org URL."
    exit 1
fi

echo ""
echo "Paper: $PAPER_TITLE"
echo "PDF saved to: $PDF_FILE"
echo ""

# ============================================================================
# Extract text from PDF
# ============================================================================
echo "Extracting text from PDF..."
TEXT_FILE="$PAPERS_DIR/${PAPER_BASENAME}_text.md"

if command -v pdftotext &> /dev/null; then
    echo "  Using pdftotext..."
    pdftotext "$PDF_FILE" - > "$TEXT_FILE" 2>/dev/null || echo "[PDF text extraction failed]" > "$TEXT_FILE"
elif command -v pdftoppm &> /dev/null && command -v tesseract &> /dev/null; then
    echo "  OCR available but slow (skipping)..."
    echo "[OCR extraction not performed - install pdftotext for better results]" > "$TEXT_FILE"
else
    echo "  Note: Install pdftotext (poppler-utils) for text extraction"
    echo "[PDF text extraction requires pdftotext or similar tool]" > "$TEXT_FILE"
fi

if [ -f "$TEXT_FILE" ] && [ -s "$TEXT_FILE" ]; then
    echo "  ✓ Text extracted to: $(basename "$TEXT_FILE")"
else
    echo "  ! Text extraction limited (install pdftotext for full extraction)"
fi

# ============================================================================
# Create rich technical skills analysis
# ============================================================================
echo "Creating technical skills analysis..."

cat > "$PAPERS_DIR/${PAPER_BASENAME}_skills.md" << EOF
# Technical Skills Analysis: $PAPER_TITLE

## Paper Information
- **Title**: $PAPER_TITLE
- **arXiv ID**: ${ARXIV_ID:-"N/A"}
- **Venue**: [To be filled from metadata]
- **Year**: [To be filled from metadata]
- **Authors**: [To be filled from metadata]
- **PDF**: \`${PAPER_BASENAME}.pdf\`
- **Extracted Text**: \`${PAPER_BASENAME}_text.md\`
- **Analysis Date**: $ANALYSIS_DATE

## Problem Statement

### What Problem Does This Paper Solve?
[Detailed description of the problem from abstract and introduction]

**Key Questions**:
- What is the core problem?
- Why is it important?
- Who is affected by this problem?

### Why Is This Problem Important?
[Context and significance from the paper]

### What Were the Limitations of Prior Work?
[Gap analysis from related work section]

## Technical Contributions

### Core Innovation
[The key technical insight - what makes this paper novel]

**Novelty Claims**:
- [Claim 1]: [Evidence from paper]
- [Claim 2]: [Evidence from paper]

### Key Techniques & Methods

#### 1. [Technique Name]
- **Description**: [What it does]
- **How It Works**: [Technical details]
- **Mathematical Foundation**: [Key equations if applicable]
- **Implementation Details**: [Important specifics]
- **Code Reference**: [Where in the codebase]

#### 2. [Technique Name]
[Same structure]

### System Architecture (if applicable)

#### Overview
[High-level system description]

#### Components
1. **[Component 1]**: [Description and responsibility]
2. **[Component 2]**: [Description and responsibility]

#### Data Flow
[How data moves through the system]

### Algorithms & Data Structures

#### [Algorithm Name]
**Purpose**: [What it does]

**Pseudocode**:
\`\`\`
[Algorithm pseudocode]
\`\`\`

**Complexity**:
- Time: [O(?)]
- Space: [O(?)]

**Key Optimizations**:
- [Optimization 1]: [Description]
- [Optimization 2]: [Description]

## Experimental Results

### Evaluation Setup

#### Benchmarks/Datasets
- [Benchmark 1]: [Description and why chosen]
- [Benchmark 2]: [Description and why chosen]

#### Baselines
- [Baseline 1]: [What it is and why compared]
- [Baseline 2]: [What it is and why compared]

#### Metrics
- [Metric 1]: [Definition and importance]
- [Metric 2]: [Definition and importance]

#### Hardware/Environment
- GPU: [Type and count]
- CPU: [Type]
- Memory: [Amount]
- Software: [Framework versions]

### Key Results

#### Quantitative Results
| Metric | This Work | Baseline 1 | Baseline 2 | Improvement |
|--------|-----------|------------|------------|-------------|
| [Metric 1] | [Value] | [Value] | [Value] | [X%] |
| [Metric 2] | [Value] | [Value] | [Value] | [X%] |

#### Qualitative Results
[Observations beyond numbers]

### Analysis of Results

#### Why Did It Work?
[Explanation of success factors]

#### When Does It Work Best?
[Conditions for optimal performance]

#### Limitations Observed
[Where the approach falls short]

## Skills Extracted

### Technical Skills Gained

#### Core Techniques
1. **[Skill 1]**: [Description and application]
   - Evidence: [Where in paper]
   - Mastery level: [Expert/Proficient/Familiar]

2. **[Skill 2]**: [Description and application]
   - Evidence: [Where in paper]
   - Mastery level: [Expert/Proficient/Familiar]

#### Domain Knowledge
- **[Domain 1]**: [What was learned]
  - Key concepts: [List]
  - Applications: [Use cases]

- **[Domain 2]**: [What was learned]
  - Key concepts: [List]
  - Applications: [Use cases]

### Implementation Insights

#### What Works in Practice
- [Insight 1]: [Practical lesson with evidence]
- [Insight 2]: [Practical lesson with evidence]

#### Common Pitfalls to Avoid
- [Pitfall 1]: [Description and prevention]
- [Pitfall 2]: [Description and prevention]

#### Best Practices
- [Practice 1]: [Recommendation]
- [Practice 2]: [Recommendation]

## Relevance to Agent Persona

### How This Shapes Your Expertise
[How this paper contributes to the agent's capabilities]

### Questions You Can Now Answer
- [Question type 1]: [Example]
- [Question type 2]: [Example]

### Projects You Can Contribute To
- [Project type 1]: [How the agent can help]
- [Project type 2]: [How the agent can help]

## Connections to Other Work

### Builds Upon
- [Paper/System 1]: [Relationship]
- [Paper/System 2]: [Relationship]

### Influenced
- [Paper/System 1]: [How this work influenced it]
- [Paper/System 2]: [How this work influenced it]

### Related Techniques
- [Technique 1]: [Comparison]
- [Technique 2]: [Comparison]

## Critical Analysis

### Strengths
1. [Strength 1]: [Evidence]
2. [Strength 2]: [Evidence]

### Weaknesses
1. [Weakness 1]: [Evidence]
2. [Weakness 2]: [Evidence]

### Open Questions
- [Question 1]: [Why it matters]
- [Question 2]: [Why it matters]

## Notes for Future Reference

### Key Citations to Follow
- [Citation 1]: [Why important]
- [Citation 2]: [Why important]

### Implementation Resources
- Code: [URL if available]
- Documentation: [URL if available]
- Datasets: [URL if available]

### Follow-up Work
- [Follow-up 1]: [What it addresses]
- [Follow-up 2]: [What it addresses]
EOF

echo "  ✓ Created ${PAPER_BASENAME}_skills.md"

# ============================================================================
# Create rich methodology analysis
# ============================================================================
echo "Creating research methodology analysis..."

cat > "$PAPERS_DIR/${PAPER_BASENAME}_methodology.md" << EOF
# Research Methodology Analysis: $PAPER_TITLE

## Research Process

### Problem Identification

#### How Did the Authors Identify This Problem?
[Analysis of their problem identification approach from introduction]

**Signals They Looked For**:
- [Signal 1]: [Evidence from paper]
- [Signal 2]: [Evidence from paper]

**Initial Hypothesis**:
[What they initially thought]

#### Why Is This the Right Problem?
[Analysis of problem significance]

**Stakeholders**:
- [Stakeholder 1]: [How they're affected]
- [Stakeholder 2]: [How they're affected]

**Impact Potential**:
[Why solving this matters]

### Solution Development

#### Ideation Process
[How they came up with the solution]

**Inspiration Sources**:
- [Source 1]: [How it influenced the solution]
- [Source 2]: [How it influenced the solution]

**Brainstorming Approach**:
[How they generated ideas]

#### Design Decisions

**Key Decision 1: [Decision Topic]**
- **Options Considered**: [What alternatives were evaluated]
- **Selection**: [What was chosen]
- **Rationale**: [Why this choice was made]
- **Trade-offs**: 
  - Gained: [Benefits]
  - Sacrificed: [Costs]

**Key Decision 2: [Decision Topic]**
[Same structure]

#### Validation During Development
[How they validated ideas before full implementation]

**Prototyping**:
- Approach: [How they prototyped]
- Key learnings: [What they discovered]

**Early Experiments**:
- What was tested: [Description]
- Results: [What they learned]

### Evaluation Methodology

#### Experimental Design

**Hypothesis**:
[What was being tested]

**Variables**:
- Independent: [What was manipulated]
- Dependent: [What was measured]
- Controlled: [What was held constant]

**Experimental Conditions**:
- [Condition 1]: [Description]
- [Condition 2]: [Description]

#### Dataset/Benchmark Selection

**Why These Benchmarks?**
- [Benchmark 1]: [Selection rationale]
- [Benchmark 2]: [Selection rationale]

**Dataset Characteristics**:
- Size: [Scale]
- Diversity: [Coverage]
- Realism: [How representative]

#### Comparison Methodology

**Baseline Selection**:
- [Baseline 1]: [Why chosen]
- [Baseline 2]: [Why chosen]

**Fairness Considerations**:
[How they ensured fair comparison]

**Implementation Details**:
- Baseline implementations: [How they were obtained/implementated]
- Hyperparameters: [How they were tuned]

#### Statistical Rigor

**Statistical Tests Used**:
- [Test 1]: [When and why used]
- [Test 2]: [When and why used]

**Variance Handling**:
[How they dealt with randomness]

**Reproducibility Measures**:
[What they did to ensure reproducibility]

### Research Insights

#### Key Findings

**Finding 1: [Name]**
- Observation: [What they found]
- Evidence: [Data supporting it]
- Implication: [What it means]

**Finding 2: [Name]**
[Same structure]

#### Surprising Results

**Unexpected Finding 1**:
- What was expected: [Prior expectation]
- What was observed: [Actual result]
- Explanation: [Why this happened]

**Unexpected Finding 2**:
[Same structure]

#### Limitations Acknowledged

**By the Authors**:
- [Limitation 1]: [How they described it]
- [Limitation 2]: [How they described it]

**Additional Limitations**:
- [Limitation 3]: [Critical analysis]

#### Future Directions Suggested

**By the Authors**:
- [Direction 1]: [What they proposed]
- [Direction 2]: [What they proposed]

**Additional Opportunities**:
- [Direction 3]: [Critical suggestion]

## Methodology Lessons

### What Worked Well

**Approach 1: [Name]**
- What they did: [Description]
- Why it worked: [Analysis]
- When to apply: [Guidance]

**Approach 2: [Name]**
[Same structure]

### What Could Be Improved

**Area 1: [Name]**
- Current approach: [What they did]
- Limitations: [What's suboptimal]
- Suggestions: [How to improve]

**Area 2: [Name]**
[Same structure]

### Generalizable Principles

**Principle 1: [Name]**
- Description: [What the principle is]
- Evidence: [Support from this paper]
- Application: [Where else it applies]

**Principle 2: [Name]**
[Same structure]

## Application to New Problems

### How This Methodology Could Be Applied Elsewhere

**Domain 1: [Name]**
- Applicability: [How it transfers]
- Adaptations needed: [What would change]
- Expected outcomes: [Anticipated results]

**Domain 2: [Name]**
[Same structure]

### Methodology Template

Based on this paper, a template for similar research:

1. **Problem Identification**:
   - Look for: [Signals]
   - Validate: [How to confirm importance]

2. **Solution Development**:
   - Ideate: [Approach]
   - Decide: [Framework]
   - Validate: [Methods]

3. **Evaluation**:
   - Benchmark: [Selection criteria]
   - Compare: [Fairness principles]
   - Analyze: [Statistical approach]

## Critical Assessment

### Methodology Strengths
1. [Strength 1]: [Evidence and impact]
2. [Strength 2]: [Evidence and impact]

### Methodology Weaknesses
1. [Weakness 1]: [Evidence and impact]
2. [Weakness 2]: [Evidence and impact]

### Would This Approach Work For...?

**[Problem Type 1]**:
- Applicability: [High/Medium/Low]
- Reasoning: [Why/why not]

**[Problem Type 2]**:
- Applicability: [High/Medium/Low]
- Reasoning: [Why/why not]

## Notes

### Key Takeaways
- [Takeaway 1]: [Summary]
- [Takeaway 2]: [Summary]

### Questions for Further Investigation
- [Question 1]: [Why it matters]
- [Question 2]: [Why it matters]

### Related Readings
- [Paper 1]: [Connection to this work]
- [Paper 2]: [Connection to this work]
EOF

echo "  ✓ Created ${PAPER_BASENAME}_methodology.md"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "=========================================="
echo "Paper Analysis Complete!"
echo "=========================================="
echo ""
echo "Files created in $PAPERS_DIR:"
echo "  ✓ ${PAPER_BASENAME}.pdf (downloaded paper)"
[ -f "$TEXT_FILE" ] && echo "  ✓ ${PAPER_BASENAME}_text.md (extracted text)"
echo "  ✓ ${PAPER_BASENAME}_skills.md (technical skills analysis)"
echo "  ✓ ${PAPER_BASENAME}_methodology.md (research methodology)"
[ -f "$PAPERS_DIR/${PAPER_BASENAME}_metadata.xml" ] && echo "  ✓ ${PAPER_BASENAME}_metadata.xml (arXiv metadata)"
echo ""
echo "Next steps:"
echo "  1. Read the PDF and extracted text"
echo "  2. Fill in the technical skills analysis with detailed content"
echo "  3. Fill in the methodology analysis with detailed content"
echo "  4. Update analysis/publications_index.md status"
echo "  5. Use insights to enhance SOUL.md"
echo ""
