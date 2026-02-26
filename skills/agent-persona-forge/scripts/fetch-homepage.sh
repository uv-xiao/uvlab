#!/bin/bash
# Fetch and parse a researcher's homepage

set -e

URL="$1"
OUTPUT_DIR="${2:-./persona-workspace}"

if [ -z "$URL" ]; then
    echo "Usage: $0 <homepage_url> [output_dir]"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Fetching homepage: $URL"

# Use jina.ai reader to get clean markdown
curl -s "https://r.jina.ai/http://$URL" -o "$OUTPUT_DIR/homepage.md" 2>/dev/null || \
curl -s "https://r.jina.ai/$URL" -o "$OUTPUT_DIR/homepage.md" 2>/dev/null || \
{ echo "Error: Failed to fetch homepage"; exit 1; }

echo "Saved to: $OUTPUT_DIR/homepage.md"
echo ""
echo "Content preview:"
head -50 "$OUTPUT_DIR/homepage.md"
