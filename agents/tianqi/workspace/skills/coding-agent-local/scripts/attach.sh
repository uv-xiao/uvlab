#!/bin/bash
#
# Attach to a coding agent tmux session interactively
#

set -e

# Default values
SESSION_NAME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --session|-s)
            SESSION_NAME="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --session, -s NAME    Session name (required)"
            echo "  --help, -h            Show this help"
            echo ""
            echo "Note: This will take over your terminal."
            echo "      Use Ctrl+B then D to detach from tmux."
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

echo "Attaching to session '$SESSION_NAME'..."
echo "Use Ctrl+B then D to detach"
echo ""

# Attach to the session
exec tmux attach-session -t "$SESSION_NAME"
