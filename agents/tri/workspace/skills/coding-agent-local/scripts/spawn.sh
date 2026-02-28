#!/bin/bash
#
# Spawn a coding agent (kimi-cli) in a new tmux session
#

set -e

# Default values
WORK_DIR="$HOME/workspace"
SESSION_NAME=""
TASK=""
MODEL="kimi-k2.5"
KIMI_BIN="${KIMI_CLI_PATH:-$(which kimi 2>/dev/null || echo '/home/uvxiao/.local/bin/kimi')}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
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
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        --kimi-path)
            KIMI_BIN="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --task, -t TASK       Task description for the coding agent (required)"
            echo "  --wd, -w DIR          Working directory (default: ~/workspace)"
            echo "  --session, -s NAME    Session name (default: auto-generated)"
            echo "  --model, -m MODEL     Kimi model to use (default: kimi-k2.5)"
            echo "  --kimi-path PATH      Path to kimi binary"
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
if [[ -z "$TASK" ]]; then
    echo "Error: --task is required"
    exit 1
fi

# Validate kimi binary exists
if [[ ! -x "$KIMI_BIN" ]]; then
    echo "Error: kimi not found at $KIMI_BIN"
    echo "Set KIMI_CLI_PATH environment variable or use --kimi-path"
    exit 1
fi

# Generate session name if not provided
if [[ -z "$SESSION_NAME" ]]; then
    SESSION_NAME="coding-$(date +%Y%m%d-%H%M%S)"
fi

# Create working directory if it doesn't exist
mkdir -p "$WORK_DIR"

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed"
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Error: Session '$SESSION_NAME' already exists"
    echo "Use a different name or kill the existing session first"
    exit 1
fi

echo "Spawning coding agent..."
echo "  Session: $SESSION_NAME"
echo "  Working directory: $WORK_DIR"
echo "  Model: $MODEL"
echo ""

# Create tmux session with initial command
tmux new-session -d -s "$SESSION_NAME" -c "$WORK_DIR"

# Set environment variables in the session
tmux set-environment -t "$SESSION_NAME" KIMI_MODEL "$MODEL"

# Send the task to kimi
tmux send-keys -t "$SESSION_NAME" "$KIMI_BIN" Enter
tmux send-keys -t "$SESSION_NAME" "$TASK" Enter

echo "Coding agent spawned successfully!"
echo ""
echo "To check output:"
echo "  ./scripts/output.sh --session $SESSION_NAME"
echo ""
echo "To list all sessions:"
echo "  ./scripts/list.sh"
echo ""
echo "To kill this session:"
echo "  ./scripts/kill.sh --session $SESSION_NAME"

# Output session name for scripting
exit 0
