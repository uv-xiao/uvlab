#!/bin/bash
#
# OpenClaw Skill Manager Script
# Helper for managing skills in multi-agent environment
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
  install <skill-slug> [agent]    Install skill (to agent workspace or shared)
  list [agent]                    List skills (shared or per-agent)
  verify                          Verify skills configuration
  setup-workspace <agent>         Create skills directory for agent

Examples:
  $0 install git-commit-helper jarvis    # Install to jarvis workspace
  $0 install git-commit-helper           # Install shared (all agents)
  $0 list                                # List shared skills
  $0 list jarvis                         # List jarvis skills
  $0 verify
  $0 setup-workspace jarvis

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

get_agent_workspace() {
    local agent_id="$1"
    jq -r ".agents.list[] | select(.id == \"$agent_id\") | .workspace" "$CONFIG_FILE" 2>/dev/null
}

install_skill() {
    local skill_slug="$1"
    local agent_id="$2"
    
    if [[ -z "$skill_slug" ]]; then
        log_error "Skill slug required"
        echo "Usage: $0 install <skill-slug> [agent]"
        exit 1
    fi
    
    # Check if clawhub is available
    if ! command -v clawhub &> /dev/null; then
        log_warn "clawhub CLI not found, trying openclaw..."
        if ! command -v openclaw &> /dev/null; then
            log_error "Neither clawhub nor openclaw CLI found"
            log_info "Install manually from https://clawhub.com"
            exit 1
        fi
    fi
    
    if [[ -n "$agent_id" ]]; then
        # Install to specific agent workspace
        local workspace=$(get_agent_workspace "$agent_id")
        
        if [[ -z "$workspace" || "$workspace" == "null" ]]; then
            log_error "Agent '$agent_id' not found"
            log_info "Available agents:"
            list_agents
            exit 1
        fi
        
        local skills_dir="$workspace/skills"
        mkdir -p "$skills_dir"
        
        log_step "Installing '$skill_slug' to $agent_id's workspace..."
        
        # Change to workspace and install
        (cd "$workspace" && clawhub install "$skill_slug" 2>/dev/null) || \
            log_warn "clawhub install may have failed, check manually"
        
        log_info "Skill installed to: $skills_dir/"
    else
        # Install shared (all agents)
        local shared_dir="$HOME/.openclaw/skills"
        mkdir -p "$shared_dir"
        
        log_step "Installing '$skill_slug' as shared skill..."
        
        (cd "$shared_dir" && clawhub install "$skill_slug" 2>/dev/null) || \
            log_warn "clawhub install may have failed, check manually"
        
        log_info "Skill installed to: $shared_dir/"
    fi
    
    log_warn "Restart OpenClaw for changes to take effect:"
    log_warn "  openclaw gateway restart"
}

list_skills() {
    local agent_id="$1"
    
    if [[ -n "$agent_id" ]]; then
        # List agent-specific skills
        local workspace=$(get_agent_workspace "$agent_id")
        
        if [[ -z "$workspace" || "$workspace" == "null" ]]; then
            log_error "Agent '$agent_id' not found"
            exit 1
        fi
        
        log_step "Skills for agent '$agent_id':"
        
        local agent_skills_dir="$workspace/skills"
        if [[ -d "$agent_skills_dir" ]]; then
            echo "  Workspace skills ($agent_skills_dir):"
            ls -1 "$agent_skills_dir" 2>/dev/null | sed 's/^/    - /' || echo "    (none)"
        else
            log_info "  No workspace skills directory"
        fi
    else
        # List shared skills
        log_step "Shared Skills (~/.openclaw/skills/):"
        
        if [[ -d "$HOME/.openclaw/skills" ]]; then
            ls -1 "$HOME/.openclaw/skills" 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
        else
            log_info "  No shared skills directory"
        fi
        
        # List project skills
        echo ""
        log_step "Project Skills (.agents/skills/):"
        if [[ -d "$PROJECT_DIR/.agents/skills" ]]; then
            ls -1 "$PROJECT_DIR/.agents/skills" 2>/dev/null | sed 's/^/  - /' || echo "  (none)"
        else
            log_info "  No project skills directory"
        fi
    fi
}

list_agents() {
    check_config
    
    log_step "Configured Agents:"
    echo ""
    
    jq -r '.agents.list[] | "  \(.id)"' "$CONFIG_FILE" | while read -r agent_id; do
        local workspace=$(get_agent_workspace "$agent_id")
        local skills_dir="$workspace/skills"
        local skill_count=0
        
        if [[ -d "$skills_dir" ]]; then
            skill_count=$(ls -1 "$skills_dir" 2>/dev/null | wc -l)
        fi
        
        echo "  $agent_id ($skill_count workspace skills)"
    done
}

setup_workspace() {
    local agent_id="$1"
    
    if [[ -z "$agent_id" ]]; then
        log_error "Agent ID required"
        echo "Usage: $0 setup-workspace <agent-id>"
        exit 1
    fi
    
    check_config
    
    local workspace=$(get_agent_workspace "$agent_id")
    
    if [[ -z "$workspace" || "$workspace" == "null" ]]; then
        log_error "Agent '$agent_id' not found in configuration"
        exit 1
    fi
    
    local skills_dir="$workspace/skills"
    
    if [[ -d "$skills_dir" ]]; then
        log_info "Skills directory already exists: $skills_dir"
    else
        mkdir -p "$skills_dir"
        log_info "Created skills directory: $skills_dir"
    fi
}

verify_config() {
    check_config
    
    log_step "Verifying skills configuration..."
    
    # Check if skills section exists
    if ! jq -e '.skills' "$CONFIG_FILE" > /dev/null 2>&1; then
        log_error "'skills' section not found in openclaw.json"
        log_info "Add to openclaw.json:"
        cat << 'JSON'
  "skills": {
    "load": {
      "extraDirs": [],
      "watch": true
    },
    "entries": {}
  }
JSON
        exit 1
    fi
    
    log_info "✓ Skills section exists"
    
    # Check load configuration
    local watch_enabled=$(jq -r '.skills.load.watch // false' "$CONFIG_FILE")
    if [[ "$watch_enabled" == "true" ]]; then
        log_info "✓ Skill file watching enabled"
    else
        log_warn "✗ Skill file watching disabled"
    fi
    
    # Check entries
    local entry_count=$(jq -r '(.skills.entries // {}) | keys | length' "$CONFIG_FILE")
    log_info "✓ $entry_count skill(s) configured in entries"
    
    # Check directories
    echo ""
    log_step "Skill directories:"
    
    if [[ -d "$HOME/.openclaw/skills" ]]; then
        local shared_count=$(ls -1 "$HOME/.openclaw/skills" 2>/dev/null | wc -l)
        log_info "  ~/.openclaw/skills/: $shared_count skill(s)"
    else
        log_info "  ~/.openclaw/skills/: (not created)"
    fi
    
    # Check agent workspaces
    echo ""
    log_step "Agent workspace skills:"
    jq -r '.agents.list[].id' "$CONFIG_FILE" | while read -r agent_id; do
        local workspace=$(get_agent_workspace "$agent_id")
        local skills_dir="$workspace/skills"
        
        if [[ -d "$skills_dir" ]]; then
            local count=$(ls -1 "$skills_dir" 2>/dev/null | wc -l)
            log_info "  $agent_id: $count skill(s)"
        else
            log_warn "  $agent_id: no skills directory"
        fi
    done
}

# Main
case "${1:-help}" in
    install)
        install_skill "$2" "$3"
        ;;
    list)
        list_skills "$2"
        ;;
    list-agents)
        list_agents
        ;;
    setup-workspace)
        setup_workspace "$2"
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
