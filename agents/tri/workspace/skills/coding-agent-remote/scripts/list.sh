#!/bin/bash
#
# List active coding agent tmux sessions on a remote host
#

set -e

HOST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host|-h)
            HOST="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 --host <hostname>"
            echo ""
            echo "Options:"
            echo "  --host, -h HOST    SSH host to connect to (required)"
            echo "  --help             Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ -z "$HOST" ]]; then
    echo "Error: --host is required"
    exit 1
fi

# Get sessions from remote host
SESSIONS=$(ssh "$HOST" "tmux list-sessions -F '#{session_name}|#{session_created}' 2>/dev/null | grep '^coding-'" || true)

if [[ -z "$SESSIONS" ]]; then
    echo "No active coding agent sessions found on $HOST."
    exit 0
fi

echo "Active Coding Agent Sessions on $HOST:"
echo "======================================="
printf "%-30s %-20s\n" "Session Name" "Created"
printf "%-30s %-20s\n" "------------" "-------"

while IFS='|' read -r name created; do
    created_fmt=$(date -d "@$created" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -r "$created" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
    printf "%-30s %-20s\n" "$name" "$created_fmt"
done <<< "$SESSIONS"

echo ""
echo "Total: $(echo "$SESSIONS" | wc -l) session(s)"
