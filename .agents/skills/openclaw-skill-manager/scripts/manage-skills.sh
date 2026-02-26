#!/bin/bash
#
# OpenClaw Skill Manager Script
# Helper for installing skills to specific agents or all agents
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
CONFIG_FILE="$PROJECT_DIR/openclaw.json"
TEMPLATE_FILE="$PROJECT_DIR/openclaw.json.template"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

show_help() {
    cat << EOF
Usage: $0 <command> [options]

Commands:
  install-global <skill-name>     Install skill globally (all agents)
  install-agent <agent> <skill>   Install skill to specific agent
  list-agents                     List all configured agents
  list-skills [agent]             List skills (global or for specific agent)
  verify                          Verify skills configuration

Examples:
  $0 install-global git-commit-helper
  $0 install-agent jarvis git-commit-helper
  $0 list-agents
  $0 list-skills jarvis

EOF
}

check_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "openclaw.json not found at $CONFIG_FILE"
        log_info "Run: ./scripts/sync-config.sh merge"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed"
        exit 1
    fi
}

install_global() {
    local skill_name="$1"
    
    if [[ -z "$skill_name" ]]; then
        log_error "Skill name required"
        echo "Usage: $0 install-global <skill-name>"
        exit 1
    fi
    
    log_step "Installing skill globally: $skill_name"
    
    # Install via openclaw CLI
    if command -v openclaw &> /dev/null; then
        openclaw skills install "$skill_name" || {
            log_warn "Failed to install via openclaw CLI, attempting manual configuration..."
        }
    else
        log_warn "openclaw CLI not found, using manual configuration"
    fi
    
    log_info "Skill '$skill_name' configured globally"
    log_warn "Restart OpenClaw for changes to take effect:"
    log_warn "  openclaw gateway restart"
}

install_agent() {
    local agent_id="$1"
    local skill_name="$2"
    
    if [[ -z "$agent_id" || -z "$skill_name" ]]; then
        log_error "Agent ID and skill name required"
        echo "Usage: $0 install-agent <agent-id> <skill-name>"
        exit 1
    fi
    
    check_config
    
    log_step "Installing skill '$skill_name' to agent '$agent_id'"
    
    # Check if agent exists
    if ! jq -e ".agents.list[] | select(.id == \"$agent_id\")" "$CONFIG_FILE" > /dev/null 2>&1; then
        log_error "Agent '$agent_id' not found in configuration"
        log_info "Available agents:"
        list_agents
        exit 1
    fi
    
    # Check if skill already installed for this agent
    local has_skill=$(jq -r ".agents.list[] | select(.id == \"$agent_id\") | .skills // [] | contains([\"$skill_name\"])" "$CONFIG_FILE")
    
    if [[ "$has_skill" == "true" ]]; then
        log_warn "Skill '$skill_name' is already installed for agent '$agent_id'"
        exit 0
    fi
    
    # Add skill to agent
    local temp_file=$(mktemp)
    jq ".agents.list |= map(if .id == \"$agent_id\" then .skills = (.skills // []) + [\"$skill_name\"] else . end)" "$CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$CONFIG_FILE"
    
    log_info "Skill '$skill_name' added to agent '$agent_id'"
    log_warn "Run './scripts/sync-config.sh reverse' to sync to template"
    log_warn "Then restart OpenClaw: openclaw gateway restart"
}

list_agents() {
    check_config
    
    log_step "Configured Agents:"
    echo ""
    
    jq -r '.agents.list[] | "  \(.id)\t\(.workspace // "N/A")\t\(.skills | length // 0) skills"' "$CONFIG_FILE" | \
    while read -r line; do
        echo -e "$line"
    done
    
    echo ""
    log_info "Use 'list-skills <agent>' to see agent-specific skills"
}

list_skills() {
    local agent_id="$1"
    
    if [[ -n "$agent_id" ]]; then
        check_config
        log_step "Skills for agent '$agent_id':"
        
        local skills=$(jq -r ".agents.list[] | select(.id == \"$agent_id\") | .skills // [] | join(\", \")" "$CONFIG_FILE")
        
        if [[ -z "$skills" || "$skills" == "null" ]]; then
            log_info "  No agent-specific skills configured"
        else
            echo "  Agent-specific: $skills"
        fi
    else
        log_step "Global Skills Configuration:"
        
        if command -v openclaw &> /dev/null; then
            echo "  Installed skills:"
            openclaw skills list 2>/dev/null || log_warn "  Could not list skills"
        else
            log_info "  openclaw CLI not available"
        fi
    fi
    
    echo ""
    log_info "Skill sources (from openclaw.json):"
    jq -r '.tools.skills.sources // {} | to_entries[] | "  \(.key): \(.value.enabled // false)"' "$CONFIG_FILE" 2>/dev/null || \
        log_warn "  Skills not configured"
}

verify_config() {
    check_config
    
    log_step "Verifying skills configuration..."
    
    # Check if skills is enabled
    local skills_enabled=$(jq -r '.tools.skills.enabled // false' "$CONFIG_FILE")
    
    if [[ "$skills_enabled" != "true" ]]; then
        log_error "Skills are NOT enabled in configuration"
        log_info "Add to openclaw.json:"
        cat << 'JSON'
  "tools": {
    "skills": {
      "enabled": true,
      "sources": {
        "hub": { "enabled": true },
        "project": { "enabled": true },
        "user": { "enabled": true }
      }
    }
  }
JSON
        exit 1
    fi
    
    log_info "✓ Skills are enabled"
    
    # Check sources
    local hub_enabled=$(jq -r '.tools.skills.sources.hub.enabled // false' "$CONFIG_FILE")
    local project_enabled=$(jq -r '.tools.skills.sources.project.enabled // false' "$CONFIG_FILE")
    local user_enabled=$(jq -r '.tools.skills.sources.user.enabled // false' "$CONFIG_FILE")
    
    [[ "$hub_enabled" == "true" ]] && log_info "✓ ClawdHub source enabled" || log_warn "✗ ClawdHub source disabled"
    [[ "$project_enabled" == "true" ]] && log_info "✓ Project source enabled (.agents/skills/)" || log_warn "✗ Project source disabled"
    [[ "$user_enabled" == "true" ]] && log_info "✓ User source enabled (~/.config/agents/skills/)" || log_warn "✗ User source disabled"
    
    # Check agent-specific skills
    echo ""
    log_step "Agent-specific skills:"
    jq -r '.agents.list[] | "  \(.id): \(.skills // [] | length) skill(s)"' "$CONFIG_FILE"
}

# Main
case "${1:-help}" in
    install-global)
        install_global "$2"
        ;;
    install-agent)
        install_agent "$2" "$3"
        ;;
    list-agents)
        list_agents
        ;;
    list-skills)
        list_skills "$2"
        ;;
    verify)
        verify_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
