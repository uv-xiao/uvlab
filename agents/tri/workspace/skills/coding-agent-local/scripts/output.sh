#!/bin/bash
#
# Get output from a coding agent tmux session
#

set -e

# Default values
SESSION_NAME=""
LINES=50
FOLLOW=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --session|-s)
            SESSION_NAME="$2"
            shift 2
            ;;
        --lines|-n)
            LINES="$2"
            shift 2
            ;;
        --follow|-f)
            FOLLOW=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --session, -s NAME    Session name (required)"
            echo "  --lines, -n N         Number of lines to show (default: 50)"
            echo "  --follow, -f          Follow output in real-time"
            echo "  --help, -h            Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$SESSION_NAME" ]]; then
    echo "Error: --session is required"
    exit 1
fi

# Check if session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Error: Session '$SESSION_NAME' not found"
    echo ""
    echo "Active sessions:"
    tmux list-sessions 2>/dev/null | grep "^coding-" || echo "  (none)"
    exit 1
fi

if [[ "$FOLLOW" == true ]]; then
    # Follow mode - stream output
    echo "Following output from session '$SESSION_NAME' (Ctrl+C to stop)..."
    echo "============================================================"
    
    # Get current history size
    HISTORY_SIZE=$(tmux display-message -t "$SESSION_NAME" -p "#{history_size}" 2>/dev/null || echo "0")
    
    # Show last N lines first
    tmux capture-pane -t "$SESSION_NAME" -p -S "-$LINES" 2>/dev/null || tmux capture-pane -t "$SESSION_NAME" -p
    
    # Then follow
    while true; do
        sleep 1
        NEW_SIZE=$(tmux display-message -t "$SESSION_NAME" -p "#{history_size}" 2>/dev/null || echo "0")
        if [[ "$NEW_SIZE" -gt "$HISTORY_SIZE" ]]; then
            tmux capture-pane -t "$SESSION_NAME" -p -S "$HISTORY_SIZE" -E "$NEW_SIZE" 2>/dev/null
            HISTORY_SIZE="$NEW_SIZE"
        fi
    done
else
    # One-time capture
    echo "Output from session '$SESSION_NAME' (last $LINES lines):"
    echo "============================================================"
    tmux capture-pane -t "$SESSION_NAME" -p -S "-$LINES" 2>/dev/null || tmux capture-pane -t "$SESSION_NAME" -p
fi
