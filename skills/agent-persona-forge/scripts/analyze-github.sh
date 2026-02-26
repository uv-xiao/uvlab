#!/bin/bash
# Clone and analyze a GitHub repository

set -e

REPO_URL="$1"
AUTHOR_NAME="$2"
OUTPUT_DIR="${3:-./projects}"

if [ -z "$REPO_URL" ]; then
    echo "Usage: $0 <repo_url> [author_name] [output_dir]"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/vllm-project/vllm 'Lianmin Zheng'"
    echo "  $0 vllm-project/vllm 'Lianmin Zheng'"
    exit 1
fi

# Normalize repo URL
if [[ ! "$REPO_URL" == http* ]]; then
    REPO_URL="https://github.com/$REPO_URL"
fi

# Extract owner/repo
REPO_PATH=$(echo "$REPO_URL" | sed 's|https://github.com/||' | sed 's|/$||')
REPO_NAME=$(basename "$REPO_PATH")

PROJECT_DIR="$OUTPUT_DIR/$REPO_NAME"
mkdir -p "$OUTPUT_DIR"

echo "Analyzing repository: $REPO_PATH"

# Clone repository with limited depth for speed
if [ -d "$PROJECT_DIR" ]; then
    echo "Repository already exists at $PROJECT_DIR"
else
    echo "Cloning repository..."
    git clone --depth 100 "$REPO_URL" "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# Extract repository structure
echo ""
echo "=== Repository Structure ===" > "../${REPO_NAME}_analysis.md"
tree -L 2 -d >> "../${REPO_NAME}_analysis.md" 2>/dev/null || ls -la >> "../${REPO_NAME}_analysis.md"

# Get README
echo "" >> "../${REPO_NAME}_analysis.md"
echo "=== README Preview ===" >> "../${REPO_NAME}_analysis.md"
head -100 README.md 2>/dev/null >> "../${REPO_NAME}_analysis.md" || echo "No README found" >> "../${REPO_NAME}_analysis.md"

# If author specified, analyze their contributions
if [ -n "$AUTHOR_NAME" ]; then
    echo ""
    echo "Analyzing contributions by: $AUTHOR_NAME"
    
    # Get commits by author
    echo "" >> "../${REPO_NAME}_analysis.md"
    echo "=== Commit Messages by $AUTHOR_NAME ===" >> "../${REPO_NAME}_analysis.md"
    git log --author="$AUTHOR_NAME" --oneline -20 2>/dev/null >> "../${REPO_NAME}_analysis.md" || echo "No commits found" >> "../${REPO_NAME}_analysis.md"
    
    # Get author's commit count
    COMMIT_COUNT=$(git log --author="$AUTHOR_NAME" --oneline 2>/dev/null | wc -l || echo "0")
    echo "" >> "../${REPO_NAME}_analysis.md"
    echo "Total commits by author: $COMMIT_COUNT" >> "../${REPO_NAME}_analysis.md"
fi

# Identify key source files
echo "" >> "../${REPO_NAME}_analysis.md"
echo "=== Key Source Files ===" >> "../${REPO_NAME}_analysis.md"
find . -name "*.py" -o -name "*.cpp" -o -name "*.cu" -o -name "*.h" 2>/dev/null | head -30 >> "../${REPO_NAME}_analysis.md"

echo ""
echo "Analysis saved to: $OUTPUT_DIR/${REPO_NAME}_analysis.md"
echo "Repository at: $PROJECT_DIR"
echo ""
echo "Next steps:"
echo "  1. Read $OUTPUT_DIR/${REPO_NAME}_analysis.md"
echo "  2. Explore key source files in $PROJECT_DIR"
if [ -n "$AUTHOR_NAME" ]; then
    echo "  3. Use /skill:github to get PR/issue data for $AUTHOR_NAME"
fi
