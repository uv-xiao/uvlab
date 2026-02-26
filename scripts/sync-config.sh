#!/bin/bash
#
# OpenClaw Configuration Sync Script
# 
# This script manages bidirectional sync between:
# - openclaw.json.template (tracked in git, no sensitive data)
# - openclaw.json.local (not tracked, contains sensitive data)
# - openclaw.json (generated file, used by OpenClaw)
#
# Usage:
#   ./scripts/sync-config.sh merge    # Generate openclaw.json from template + local
#   ./scripts/sync-config.sh extract  # Update template from current openclaw.json
#   ./scripts/sync-config.sh verify   # Check if openclaw.json matches template + local
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

TEMPLATE_FILE="openclaw.json.template"
LOCAL_FILE="openclaw.json.local"
CONFIG_FILE="openclaw.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_files() {
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        log_error "Template file not found: $TEMPLATE_FILE"
        exit 1
    fi
    
    if [[ ! -f "$LOCAL_FILE" ]]; then
        log_error "Local config file not found: $LOCAL_FILE"
        log_info "Please create $LOCAL_FILE from $LOCAL_FILE.example"
        exit 1
    fi
}

# Load local config into variables
load_local_config() {
    declare -g BAILIAN_API_KEY
    declare -g GENERIC_API_KEY
    declare -g HOME_DIR
    declare -g TIMESTAMP
    declare -g JARVIS_APP_ID
    declare -g JARVIS_APP_SECRET
    declare -g LIANMIN_APP_ID
    declare -g LIANMIN_APP_SECRET
    declare -g TIANQI_APP_ID
    declare -g TIANQI_APP_SECRET
    declare -g ZIHAO_APP_ID
    declare -g ZIHAO_APP_SECRET
    declare -g TRI_APP_ID
    declare -g TRI_APP_SECRET
    declare -g GATEWAY_AUTH_TOKEN
    
    # Source the local file (it should be in KEY=value format)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        
        # Remove leading/trailing whitespace
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        case "$key" in
            BAILIAN_API_KEY) BAILIAN_API_KEY="$value" ;;
            GENERIC_API_KEY) GENERIC_API_KEY="$value" ;;
            HOME) HOME_DIR="$value" ;;
            TIMESTAMP) TIMESTAMP="$value" ;;
            JARVIS_APP_ID) JARVIS_APP_ID="$value" ;;
            JARVIS_APP_SECRET) JARVIS_APP_SECRET="$value" ;;
            LIANMIN_APP_ID) LIANMIN_APP_ID="$value" ;;
            LIANMIN_APP_SECRET) LIANMIN_APP_SECRET="$value" ;;
            TIANQI_APP_ID) TIANQI_APP_ID="$value" ;;
            TIANQI_APP_SECRET) TIANQI_APP_SECRET="$value" ;;
            ZIHAO_APP_ID) ZIHAO_APP_ID="$value" ;;
            ZIHAO_APP_SECRET) ZIHAO_APP_SECRET="$value" ;;
            TRI_APP_ID) TRI_APP_ID="$value" ;;
            TRI_APP_SECRET) TRI_APP_SECRET="$value" ;;
            GATEWAY_AUTH_TOKEN) GATEWAY_AUTH_TOKEN="$value" ;;
        esac
    done < "$LOCAL_FILE"
    
    # Set defaults if not provided
    TIMESTAMP="${TIMESTAMP:-$(date -u +%Y-%m-%dT%H:%M:%S.000Z)}"
}

merge_config() {
    log_info "Generating $CONFIG_FILE from $TEMPLATE_FILE + $LOCAL_FILE"
    
    check_files
    load_local_config
    
    # Read template and replace placeholders
    local content
    content=$(cat "$TEMPLATE_FILE")
    
    # Replace placeholders
    content="${content//\{\{BAILIAN_API_KEY\}\}/$BAILIAN_API_KEY}"
    content="${content//\{\{GENERIC_API_KEY\}\}/$GENERIC_API_KEY}"
    content="${content//\{\{HOME\}\}/$HOME_DIR}"
    content="${content//\{\{TIMESTAMP\}\}/$TIMESTAMP}"
    content="${content//\{\{JARVIS_APP_ID\}\}/$JARVIS_APP_ID}"
    content="${content//\{\{JARVIS_APP_SECRET\}\}/$JARVIS_APP_SECRET}"
    content="${content//\{\{LIANMIN_APP_ID\}\}/$LIANMIN_APP_ID}"
    content="${content//\{\{LIANMIN_APP_SECRET\}\}/$LIANMIN_APP_SECRET}"
    content="${content//\{\{TIANQI_APP_ID\}\}/$TIANQI_APP_ID}"
    content="${content//\{\{TIANQI_APP_SECRET\}\}/$TIANQI_APP_SECRET}"
    content="${content//\{\{ZIHAO_APP_ID\}\}/$ZIHAO_APP_ID}"
    content="${content//\{\{ZIHAO_APP_SECRET\}\}/$ZIHAO_APP_SECRET}"
    content="${content//\{\{TRI_APP_ID\}\}/$TRI_APP_ID}"
    content="${content//\{\{TRI_APP_SECRET\}\}/$TRI_APP_SECRET}"
    content="${content//\{\{GATEWAY_AUTH_TOKEN\}\}/$GATEWAY_AUTH_TOKEN}"
    
    # Write to config file
    echo "$content" > "$CONFIG_FILE"
    
    log_info "Successfully generated $CONFIG_FILE"
    log_warn "Remember to restart OpenClaw for changes to take effect:"
    log_warn "  openclaw gateway restart"
}

extract_config() {
    log_info "Extracting sensitive values from $CONFIG_FILE to update template"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Create backup of template
    cp "$TEMPLATE_FILE" "$TEMPLATE_FILE.bak"
    
    # Extract values and create new local file
    local tmp_local="$LOCAL_FILE.tmp"
    
    cat > "$tmp_local" << 'EOF'
# OpenClaw Local Configuration
# Copy this file to openclaw.json.local and fill in your sensitive values
# DO NOT commit openclaw.json.local to git!

# Model API Keys
EOF
    
    # Extract API keys using jq if available, otherwise grep
    if command -v jq &> /dev/null; then
        local bailian_key generic_key home_dir timestamp
        local jarvis_id jarvis_secret lianmin_id lianmin_secret
        local tianqi_id tianqi_secret zihao_id zihao_secret
        local tri_id tri_secret gateway_token
        
        bailian_key=$(jq -r '.models.providers.bailian.apiKey // ""' "$CONFIG_FILE")
        generic_key=$(jq -r '.models.providers.generic.apiKey // ""' "$CONFIG_FILE")
        home_dir=$(jq -r '.agents.defaults.workspace' "$CONFIG_FILE" | sed 's|/.openclaw/agents/jarvis/workspace||')
        timestamp=$(jq -r '.meta.lastTouchedAt // ""' "$CONFIG_FILE")
        
        jarvis_id=$(jq -r '.channels.feishu.accounts.jarvis.appId // ""' "$CONFIG_FILE")
        jarvis_secret=$(jq -r '.channels.feishu.accounts.jarvis.appSecret // ""' "$CONFIG_FILE")
        lianmin_id=$(jq -r '.channels.feishu.accounts.lianmin.appId // ""' "$CONFIG_FILE")
        lianmin_secret=$(jq -r '.channels.feishu.accounts.lianmin.appSecret // ""' "$CONFIG_FILE")
        tianqi_id=$(jq -r '.channels.feishu.accounts.tianqi.appId // ""' "$CONFIG_FILE")
        tianqi_secret=$(jq -r '.channels.feishu.accounts.tianqi.appSecret // ""' "$CONFIG_FILE")
        zihao_id=$(jq -r '.channels.feishu.accounts.zihao.appId // ""' "$CONFIG_FILE")
        zihao_secret=$(jq -r '.channels.feishu.accounts.zihao.appSecret // ""' "$CONFIG_FILE")
        tri_id=$(jq -r '.channels.feishu.accounts.tri.appId // ""' "$CONFIG_FILE")
        tri_secret=$(jq -r '.channels.feishu.accounts.tri.appSecret // ""' "$CONFIG_FILE")
        
        gateway_token=$(jq -r '.gateway.auth.token // ""' "$CONFIG_FILE")
        
        cat >> "$tmp_local" << EOF
BAILIAN_API_KEY=${bailian_key}
GENERIC_API_KEY=${generic_key}

# System
HOME=${home_dir}
TIMESTAMP=${timestamp}

# Feishu App Credentials
JARVIS_APP_ID=${jarvis_id}
JARVIS_APP_SECRET=${jarvis_secret}

LIANMIN_APP_ID=${lianmin_id}
LIANMIN_APP_SECRET=${lianmin_secret}

TIANQI_APP_ID=${tianqi_id}
TIANQI_APP_SECRET=${tianqi_secret}

ZIHAO_APP_ID=${zihao_id}
ZIHAO_APP_SECRET=${zihao_secret}

TRI_APP_ID=${tri_id}
TRI_APP_SECRET=${tri_secret}

# Gateway Auth Token
GATEWAY_AUTH_TOKEN=${gateway_token}
EOF
    else
        log_warn "jq not found, using fallback method"
        log_error "Please install jq for better extraction: https://stedolan.github.io/jq/"
        exit 1
    fi
    
    # Replace local file
    mv "$tmp_local" "$LOCAL_FILE"
    
    log_info "Successfully extracted values to $LOCAL_FILE"
    log_warn "Please review $LOCAL_FILE and ensure sensitive values are correct"
}

verify_config() {
    log_info "Verifying $CONFIG_FILE matches $TEMPLATE_FILE + $LOCAL_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        log_info "Run: $0 merge"
        exit 1
    fi
    
    # Generate temp config and compare
    local tmp_config="$CONFIG_FILE.tmp.$$"
    
    # Run merge to temp file
    LOCAL_FILE="$LOCAL_FILE" TEMPLATE_FILE="$TEMPLATE_FILE" \
        bash -c 'source scripts/sync-config.sh merge' > /dev/null 2>&1 || true
    
    # Compare (ignoring whitespace and timestamps)
    if diff -q <(jq -S . "$CONFIG_FILE" 2>/dev/null) <(jq -S . "$CONFIG_FILE" 2>/dev/null) > /dev/null 2>&1; then
        log_info "Configuration is up to date"
        rm -f "$tmp_config"
        exit 0
    else
        log_warn "Configuration mismatch detected"
        log_info "Run: $0 merge"
        rm -f "$tmp_config"
        exit 1
    fi
}

show_usage() {
    cat << EOF
Usage: $0 <command>

Commands:
  merge    Generate openclaw.json from template + local config
  extract  Extract sensitive values from openclaw.json to update local config
  verify   Check if openclaw.json matches template + local config
  help     Show this help message

Examples:
  $0 merge    # Generate config after editing openclaw.json.local
  $0 extract  # Save current openclaw.json values to local config
  $0 verify   # Pre-commit hook to ensure consistency

Files:
  openclaw.json.template     - Template with placeholders (tracked in git)
  openclaw.json.local        - Your sensitive values (NOT tracked)
  openclaw.json              - Generated config used by OpenClaw
EOF
}

case "${1:-help}" in
    merge)
        merge_config
        ;;
    extract)
        extract_config
        ;;
    verify)
        verify_config
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
