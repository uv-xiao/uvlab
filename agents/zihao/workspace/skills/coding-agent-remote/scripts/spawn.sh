#!/bin/bash
#
# Spawn a coding agent on a remote host via SSH
#

set -e

# Default values
HOST=""
WORK_DIR="~/workspace"
SESSION_NAME=""
TASK=""
KIMI_BIN="kimi"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host|-h)
            HOST="$2"
            shift 2
            ;;
        --task|-t)
            TASK="$2"
            shift 2
            ;;
        --wd|-w)
            WORK_DIR="$2"
            shift 2
            ;;
        --session|-s)
            SESSION_NAME="$2"
            shift 2
            ;;
        --kimi-path)
            KIMI_BIN="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --host, -h HOST       SSH host to connect to (required, from ~/.ssh/config)"
            echo "  --task, -t TASK       Task description for the coding agent (required)"
            echo "  --wd, -w DIR          Working directory on remote (default: ~/workspace)"
            echo "  --session, -s NAME    Session name (default: auto-generated)"
            echo "  --kimi-path PATH      Path to kimi binary on remote"
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

if [[ -z "$TASK" ]]; then
    echo "Error: --task is required"
    exit 1
fi

# Generate session name if not provided
if [[ -z "$SESSION_NAME" ]]; then
    SESSION_NAME="coding-$(date +%Y%m%d-%H%M%S)"
fi

# Test SSH connection
echo "Testing SSH connection to $HOST..."
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$HOST" "echo 'SSH OK'" > /dev/null 2>&1; then
    echo "Error: Cannot connect to $HOST via SSH"
    echo ""
    echo "Check:"
    echo "  1. Host is defined in ~/.ssh/config"
    echo "  2. SSH key authentication is set up"
    echo "  3. Host is reachable"
    echo ""
    echo "Test with: ssh $HOST 'echo OK'"
    exit 1
fi

# Check if tmux is available on remote
echo "Checking tmux on remote host..."
if ! ssh "$HOST" "which tmux" > /dev/null 2>&1; then
    echo "Error: tmux is not installed on $HOST"
    echo "Install with: ssh $HOST 'sudo apt-get install -y tmux'"
    exit 1
fi

# Check if kimi is available on remote (warn but don't fail)
echo "Checking kimi on remote host..."
if ! ssh "$HOST" "which $KIMI_BIN" > /dev/null 2>&1; then
    echo "Warning: kimi not found on $HOST at $KIMI_BIN"
    echo "You may need to install it: ssh $HOST 'uv tool install kimi-cli'"
    echo ""
fi

# Create working directory on remote
ssh "$HOST" "mkdir -p $WORK_DIR"

# Check if session already exists
if ssh "$HOST" "tmux has-session -t $SESSION_NAME" 2>/dev/null; then
    echo "Error: Session '$SESSION_NAME' already exists on $HOST"
    exit 1
fi

echo ""
echo "Spawning remote coding agent..."
echo "  Host: $HOST"
echo "  Session: $SESSION_NAME"
echo "  Working directory: $WORK_DIR"
echo ""

# Create tmux session on remote host
ssh "$HOST" "tmux new-session -d -s $SESSION_NAME -c $WORK_DIR"

# Send the task to kimi on remote
ssh "$HOST" "tmux send-keys -t $SESSION_NAME $KIMI_BIN Enter"
# Escape the task string for remote execution
ESCAPED_TASK=$(printf '%q' "$TASK")
ssh "$HOST" "tmux send-keys -t $SESSION_NAME $ESCAPED_TASK Enter"

echo "Remote coding agent spawned successfully!"
echo ""
echo "To check output:"
echo "  ./scripts/output.sh --host $HOST --session $SESSION_NAME"
echo ""
echo "To list remote sessions:"
echo "  ./scripts/list.sh --host $HOST"
echo ""
echo "To kill this session:"
echo "  ./scripts/kill.sh --host $HOST --session $SESSION_NAME"
