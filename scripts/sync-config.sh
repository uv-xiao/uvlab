#!/bin/bash
#
# OpenClaw Configuration Sync Script
# 
# This script manages bidirectional sync between:
# - openclaw.json.template (tracked in git, no sensitive data)
# - openclaw.json.local (not tracked, contains sensitive data)
# - openclaw.json (generated file, used by OpenClaw)
#
# Sensitive fields are defined in sensitive-fields.conf
#
# Usage:
#   ./scripts/sync-config.sh merge    # Generate openclaw.json from template + local
#   ./scripts/sync-config.sh extract  # Extract sensitive values to local config
#   ./scripts/sync-config.sh reverse  # Update template and local from openclaw.json
#   ./scripts/sync-config.sh verify   # Check if openclaw.json matches template + local
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

TEMPLATE_FILE="openclaw.json.template"
LOCAL_FILE="openclaw.json.local"
CONFIG_FILE="openclaw.json"
SENSITIVE_FIELDS_FILE="$SCRIPT_DIR/sensitive-fields.conf"

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

# Load sensitive fields configuration
load_sensitive_fields() {
    if [[ ! -f "$SENSITIVE_FIELDS_FILE" ]]; then
        log_error "Sensitive fields config not found: $SENSITIVE_FIELDS_FILE"
        exit 1
    fi
    
    # Read fields into associative array
    declare -gA SENSITIVE_FIELDS
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        [[ -n "$key" && -n "$value" ]] && SENSITIVE_FIELDS["$key"]="$value"
    done < "$SENSITIVE_FIELDS_FILE"
    
    if [[ ${#SENSITIVE_FIELDS[@]} -eq 0 ]]; then
        log_error "No sensitive fields loaded from $SENSITIVE_FIELDS_FILE"
        exit 1
    fi
    
    log_info "Loaded ${#SENSITIVE_FIELDS[@]} sensitive field definitions"
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
    declare -gA LOCAL_VALUES
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -n "$key" ]] && LOCAL_VALUES["$key"]="$value"
    done < "$LOCAL_FILE"
}

# Convert JSON path to jq path
# Input: models.providers.bailian.apiKey
# Output: .models.providers.bailian.apiKey
json_path_to_jq() {
    local path="$1"
    # Remove leading dot if present, then add one
    path="${path#.}"
    # Ensure path starts with .
    echo ".${path}"
}

# Build jq filter for replacing sensitive values with placeholders
build_jq_filter() {
    local filter=""
    local first=true
    
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        local jq_path=$(json_path_to_jq "$field_path")
        
        if [[ "$first" == "true" ]]; then
            first=false
        else
            filter+=" | "
        fi
        
        # jq_path already starts with . from json_path_to_jq
        filter+="${jq_path} = \"{{${placeholder}}}\""
    done
    
    echo "$filter"
}

# Build jq filter for extracting sensitive values
build_extract_filter() {
    local filter=""
    
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        local jq_path=$(json_path_to_jq "$field_path")
        
        if [[ -z "$filter" ]]; then
            filter="{"
        else
            filter+=", "
        fi
        
        filter+="\"${placeholder}\": ${jq_path}"
    done
    
    filter+="}"
    echo "$filter"
}

merge_config() {
    log_info "Generating $CONFIG_FILE from $TEMPLATE_FILE + $LOCAL_FILE"
    
    check_files
    load_sensitive_fields
    load_local_config
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for merge operation"
        log_info "Please install jq: https://stedolan.github.io/jq/"
        exit 1
    fi
    
    # Read template
    local content
    content=$(cat "$TEMPLATE_FILE")
    
    # Replace placeholders with actual values
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        local value="${LOCAL_VALUES[$placeholder]:-}"
        content="${content//\{\{$placeholder\}\}/$value}"
    done
    
    # Also replace special placeholders
    if [[ -n "${LOCAL_VALUES[HOME]}" ]]; then
        content="${content//\{\{HOME\}\}/${LOCAL_VALUES[HOME]}}"
    fi
    if [[ -n "${LOCAL_VALUES[TIMESTAMP]}" ]]; then
        content="${content//\{\{TIMESTAMP\}\}/${LOCAL_VALUES[TIMESTAMP]}}"
    fi
    
    # Write to config file
    echo "$content" > "$CONFIG_FILE"
    
    log_info "Successfully generated $CONFIG_FILE"
    log_warn "Remember to restart OpenClaw for changes to take effect:"
    log_warn "  openclaw gateway restart"
}

extract_config() {
    log_info "Extracting sensitive values from $CONFIG_FILE to $LOCAL_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    load_sensitive_fields
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for extract operation"
        log_info "Please install jq: https://stedolan.github.io/jq/"
        exit 1
    fi
    
    # Extract values using jq
    local tmp_local="$LOCAL_FILE.tmp.$$"
    
    # Build header
    cat > "$tmp_local" << 'EOF'
# OpenClaw Local Configuration
# DO NOT commit this file to git!

EOF
    
    # Group fields by category for better organization
    echo "# Model API Keys" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == *API_KEY* ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    echo "" >> "$tmp_local"
    echo "# System" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == "HOME" || "$placeholder" == "TIMESTAMP" ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            # For HOME, extract just the home directory part
            if [[ "$placeholder" == "HOME" ]]; then
                value=$(echo "$value" | sed 's|/.openclaw/agents/.*||')
            fi
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    echo "" >> "$tmp_local"
    echo "# Feishu App Credentials" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == *_APP_ID* || "$placeholder" == *_APP_SECRET* ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    echo "" >> "$tmp_local"
    echo "# Gateway Auth Token" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == *TOKEN* ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    # Replace local file
    mv "$tmp_local" "$LOCAL_FILE"
    
    log_info "Successfully extracted values to $LOCAL_FILE"
    log_warn "Please review $LOCAL_FILE and ensure sensitive values are correct"
}

reverse_config() {
    log_info "Updating $TEMPLATE_FILE and $LOCAL_FILE from $CONFIG_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    
    load_sensitive_fields
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required for reverse operation"
        log_info "Please install jq: https://stedolan.github.io/jq/"
        exit 1
    fi
    
    # Create backups
    cp "$TEMPLATE_FILE" "$TEMPLATE_FILE.bak.$(date +%Y%m%d%H%M%S)"
    
    # Step 1: Extract sensitive values to local file
    log_info "Extracting sensitive values..."
    
    local tmp_local="$LOCAL_FILE.tmp.$$"
    cat > "$tmp_local" << 'EOF'
# OpenClaw Local Configuration
# DO NOT commit this file to git!

EOF
    
    # Group fields by category
    echo "# Model API Keys" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == *API_KEY* ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    echo "" >> "$tmp_local"
    echo "# System" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == "HOME" || "$placeholder" == "TIMESTAMP" ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            if [[ "$placeholder" == "HOME" ]]; then
                value=$(echo "$value" | sed 's|/.openclaw/agents/.*||')
            fi
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    echo "" >> "$tmp_local"
    echo "# Feishu App Credentials" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == *_APP_ID* || "$placeholder" == *_APP_SECRET* ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    echo "" >> "$tmp_local"
    echo "# Gateway Auth Token" >> "$tmp_local"
    for field_path in "${!SENSITIVE_FIELDS[@]}"; do
        local placeholder="${SENSITIVE_FIELDS[$field_path]}"
        if [[ "$placeholder" == *TOKEN* ]]; then
            local jq_path=$(json_path_to_jq "$field_path")
            local value=$(jq -r "${jq_path} // \"\"" "$CONFIG_FILE")
            echo "${placeholder}=${value}" >> "$tmp_local"
        fi
    done
    
    mv "$tmp_local" "$LOCAL_FILE"
    log_info "Updated $LOCAL_FILE"
    
    # Step 2: Create template by replacing sensitive values with placeholders
    log_info "Creating template with placeholders..."
    
    local jq_filter=$(build_jq_filter)
    jq "$jq_filter" "$CONFIG_FILE" > "$TEMPLATE_FILE"
    
    log_info "Updated $TEMPLATE_FILE"
    log_info "Backups created:"
    log_info "  $TEMPLATE_FILE.bak.*"
    log_warn "Please review the changes before committing:"
    log_warn "  git diff openclaw.json.template"
}

verify_config() {
    log_info "Verifying $CONFIG_FILE matches $TEMPLATE_FILE + $LOCAL_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Config file not found: $CONFIG_FILE"
        log_info "Run: $0 merge"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warn "jq not found, skipping detailed verification"
        exit 0
    fi
    
    # Simple check: ensure no placeholder remains in openclaw.json
    if grep -q '{{[A-Z_]*}}' "$CONFIG_FILE"; then
        log_error "Found unresolved placeholders in $CONFIG_FILE"
        log_info "Run: $0 merge"
        exit 1
    fi
    
    log_info "Configuration appears to be valid"
}

show_usage() {
    cat << EOF
Usage: $0 <command>

Commands:
  merge    Generate openclaw.json from template + local config
  extract  Extract sensitive values from openclaw.json to update local config
  reverse  Update template and local from openclaw.json (use after editing openclaw.json directly)
  verify   Check if openclaw.json matches template + local config
  help     Show this help message

Examples:
  $0 merge    # Generate config after editing openclaw.json.local
  $0 extract  # Save current openclaw.json values to local config
  $0 reverse  # Reverse sync: update template and local from current openclaw.json
  $0 verify   # Pre-commit hook to ensure consistency

Workflows:
  
  A. Normal workflow (edit local values):
     1. Edit openclaw.json.local
     2. Run: $0 merge
     3. Restart OpenClaw
  
  B. Direct edit workflow (edit openclaw.json in Dashboard):
     1. Edit openclaw.json (e.g., via Dashboard)
     2. Run: $0 reverse
     3. Review changes to template
     4. Commit template changes
     5. Restart OpenClaw

Configuration:
  Sensitive fields are defined in: scripts/sensitive-fields.conf
  Edit this file to add/remove sensitive fields.

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
    reverse)
        reverse_config
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
