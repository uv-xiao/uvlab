#!/bin/bash
#
# List active coding agent tmux sessions
#

set -e

# Filter for coding- prefixed sessions
SESSIONS=$(tmux list-sessions -F "#{session_name}|#{session_created}|#{session_attached}" 2>/dev/null | grep "^coding-" || true)

if [[ -z "$SESSIONS" ]]; then
    echo "No active coding agent sessions found."
    exit 0
fi

echo "Active Coding Agent Sessions:"
echo "=============================="
printf "%-30s %-20s %s\n" "Session Name" "Created" "Attached"
printf "%-30s %-20s %s\n" "------------" "-------" "--------"

while IFS='|' read -r name created attached; do
    # Convert timestamp to readable format
    created_fmt=$(date -d "@$created" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date -r "$created" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown")
    
    if [[ "$attached" == "1" ]]; then
        attached_str="Yes"
    else
        attached_str="No"
    fi
    
    printf "%-30s %-20s %s\n" "$name" "$created_fmt" "$attached_str"
done <<< "$SESSIONS"

echo ""
echo "Total: $(echo "$SESSIONS" | wc -l) session(s)"
