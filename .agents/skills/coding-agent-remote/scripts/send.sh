#!/bin/bash
#
# Send input to a remote coding agent tmux session
#

set -e

HOST=""
SESSION_NAME=""
INPUT=""

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
        --input|-i)
            INPUT="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 --host <hostname> --session <name> --input 'text'"
            echo ""
            echo "Options:"
            echo "  --host, -h HOST       SSH host (required)"
            echo "  --session, -s NAME    Session name (required)"
            echo "  --input, -i TEXT      Input text to send (required)"
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

if [[ -z "$INPUT" ]]; then
    echo "Error: --input is required"
    exit 1
fi

# Check if session exists on remote
if ! ssh "$HOST" "tmux has-session -t $SESSION_NAME" 2>/dev/null; then
    echo "Error: Session '$SESSION_NAME' not found on $HOST"
    exit 1
fi

# Send the input (escape for remote)
ESCAPED_INPUT=$(printf '%q' "$INPUT")
ssh "$HOST" "tmux send-keys -t $SESSION_NAME $ESCAPED_INPUT Enter"

echo "Input sent to session '$SESSION_NAME' on $HOST"
