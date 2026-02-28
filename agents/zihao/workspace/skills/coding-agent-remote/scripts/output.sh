#!/bin/bash
#
# Get output from a remote coding agent tmux session
#

set -e

HOST=""
SESSION_NAME=""
LINES=50

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host|-h)
            HOST="$2"
            shift 2
            ;;
        --session|-s)
            SESSION_NAME="$2"
            shift 2
            ;;
        --lines|-n)
            LINES="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 --host <hostname> --session <name> [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --host, -h HOST       SSH host (required)"
            echo "  --session, -s NAME    Session name (required)"
            echo "  --lines, -n N         Number of lines to show (default: 50)"
            echo "  --help                Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$HOST" ]]; then
    echo "Error: --host is required"
    exit 1
fi

if [[ -z "$SESSION_NAME" ]]; then
    echo "Error: --session is required"
    exit 1
fi

# Check if session exists on remote
if ! ssh "$HOST" "tmux has-session -t $SESSION_NAME" 2>/dev/null; then
    echo "Error: Session '$SESSION_NAME' not found on $HOST"
    echo ""
    echo "Active sessions on $HOST:"
    ssh "$HOST" "tmux list-sessions 2>/dev/null | grep '^coding-'" || echo "  (none)"
    exit 1
fi

# Get output from remote session
echo "Output from session '$SESSION_NAME' on $HOST (last $LINES lines):"
echo "============================================================"
ssh "$HOST" "tmux capture-pane -t $SESSION_NAME -p -S '-$LINES' 2>/dev/null || tmux capture-pane -t $SESSION_NAME -p"
