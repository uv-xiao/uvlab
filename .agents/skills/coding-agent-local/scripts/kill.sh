#!/bin/bash
#
# Kill a coding agent tmux session
#

set -e

# Default values
SESSION_NAME=""
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --session|-s)
            SESSION_NAME="$2"
            shift 2
            ;;
        --force|-f)
            FORCE=true
            shift
            ;;
        --all)
            KILL_ALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --session, -s NAME    Session name to kill (required unless --all)"
            echo "  --force, -f           Kill without confirmation"
            echo "  --all                 Kill all coding agent sessions"
            echo "  --help, -h            Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Handle --all
if [[ "$KILL_ALL" == true ]]; then
    SESSIONS=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | grep "^coding-" || true)
    
    if [[ -z "$SESSIONS" ]]; then
        echo "No coding agent sessions to kill."
        exit 0
    fi
    
    COUNT=$(echo "$SESSIONS" | wc -l)
    
    if [[ "$FORCE" != true ]]; then
        echo "The following sessions will be killed:"
        echo "$SESSIONS"
        echo ""
        read -p "Kill all $COUNT session(s)? (y/N) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi
    fi
    
    echo "$SESSIONS" | while read -r session; do
        tmux kill-session -t "$session" 2>/dev/null && echo "Killed: $session" || echo "Failed: $session"
    done
    
    exit 0
fi

# Validate required arguments
if [[ -z "$SESSION_NAME" ]]; then
    echo "Error: --session is required (or use --all)"
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

# Confirm unless --force
if [[ "$FORCE" != true ]]; then
    read -p "Kill session '$SESSION_NAME'? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Kill the session
tmux kill-session -t "$SESSION_NAME"
echo "Session '$SESSION_NAME' killed."
