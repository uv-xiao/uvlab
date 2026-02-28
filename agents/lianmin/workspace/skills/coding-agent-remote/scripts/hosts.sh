#!/bin/bash
#
# List SSH hosts from ~/.ssh/config
#

SSH_CONFIG="${HOME}/.ssh/config"

if [[ ! -f "$SSH_CONFIG" ]]; then
    echo "Error: ~/.ssh/config not found"
    exit 1
fi

echo "Configured SSH Hosts:"
echo "===================="

# Extract Host entries (excluding wildcard patterns)
grep "^Host " "$SSH_CONFIG" | grep -v "*" | while read -r line; do
    host=$(echo "$line" | sed 's/^Host //')
    # Skip if it's a pattern with wildcards
    if [[ "$host" != *"*"* ]]; then
        echo "  - $host"
    fi
done

echo ""
echo "To use a host: ./scripts/spawn.sh --host <hostname> --task '...'"
