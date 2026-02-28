#!/bin/bash
#
# Send input to a coding agent tmux session
#

set -e

# Default values
SESSION_NAME=""
INPUT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --session|-s)
            SESSION_NAME="$2"
            shift 2
            ;;
        --input|-i)
            INPUT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --session, -s NAME    Session name (required)"
            echo "  --input, -i TEXT      Input text to send (required)"
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

if [[ -z "$INPUT" ]]; then
    echo "Error: --input is required"
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

# Send the input
tmux send-keys -t "$SESSION_NAME" "$INPUT" Enter

echo "Input sent to session '$SESSION_NAME'"
