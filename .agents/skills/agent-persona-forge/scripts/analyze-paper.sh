#!/bin/bash
# Download and analyze a research paper

set -e

PAPER_REF="$1"
OUTPUT_DIR="${2:-./papers}"

if [ -z "$PAPER_REF" ]; then
    echo "Usage: $0 <arxiv_id|paper_url|paper_title> [output_dir]"
    echo ""
    echo "Examples:"
    echo "  $0 2309.06180"
    echo "  $0 https://arxiv.org/abs/2309.06180"
    echo "  $0 'vLLM: Efficient Memory Management for LLM Serving'"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# Extract arXiv ID if full URL provided
ARXIV_ID=$(echo "$PAPER_REF" | grep -oE '[0-9]{4}\.[0-9]{4,5}' || echo "")

if [ -n "$ARXIV_ID" ]; then
    echo "Detected arXiv ID: $ARXIV_ID"
    
    # Download PDF
    PDF_URL="https://arxiv.org/pdf/${ARXIV_ID}.pdf"
    PDF_PATH="$OUTPUT_DIR/${ARXIV_ID}.pdf"
    
    echo "Downloading PDF from $PDF_URL"
    curl -s -L "$PDF_URL" -o "$PDF_PATH"
    
    # Get metadata
    echo "Fetching metadata..."
    curl -s "https://export.arxiv.org/api/query?id_list=$ARXIV_ID" -o "$OUTPUT_DIR/${ARXIV_ID}_metadata.xml"
    
    echo ""
    echo "Downloaded:"
    echo "  PDF: $PDF_PATH"
    echo "  Metadata: $OUTPUT_DIR/${ARXIV_ID}_metadata.xml"
    echo ""
    echo "Next steps:"
    echo "  1. Use /skill:pdf-extract to analyze the PDF"
    echo "  2. Extract both technical skills and methodology"
    
else
    echo "Non-arXiv reference: $PAPER_REF"
    echo ""
    echo "Please manually:"
    echo "  1. Download the PDF to $OUTPUT_DIR/"
    echo "  2. Rename it to a descriptive filename"
    echo "  3. Then use /skill:pdf-extract to analyze"
fi
