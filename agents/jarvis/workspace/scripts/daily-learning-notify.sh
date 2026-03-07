#!/bin/bash
# Daily Learning Notification Script
# Called by Jarvis via cron job at 20:00
# Sends notification to Feishu group with today's learning plan

set -e

# Configuration
CONFIG_FILE="/home/uvxiao/.openclaw/agents/jarvis/workspace/LEARNING_CONFIG.json"
SCHEDULE_FILE="/home/uvxiao/.openclaw/agents/jarvis/workspace/LEARNING_SCHEDULE.md"

# Read configuration from JSON file
REPO_URL=$(cat "$CONFIG_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin)['repository']['url'])" 2>/dev/null || echo "https://github.com/uv-xiao/ainfra")
FEISHU_GROUP_ID=$(cat "$CONFIG_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin)['feishu']['groupId'])" 2>/dev/null || echo "")
TIMEZONE=$(cat "$CONFIG_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin)['schedule']['timezone'])" 2>/dev/null || echo "Asia/Shanghai")

# Get today's date
TODAY=$(date +%Y-%m-%d)
DAY_OF_WEEK=$(date +%u)

# Function: Get topic for today from schedule
get_today_topic() {
    local date_str="$1"
    
    # Parse the schedule file to find today's topic
    # Format: | Day | Date | Topic | Focus Area | Assigned Expert |
    awk -v date="$date_str" '
        /^\| [0-9]+ \|/ {
            if ($3 == date) {
                gsub(/^\| \| $/, "", $0)
                print "DAY=" $2
                print "DATE=" $3
                print "TOPIC=" $4
                print "FOCUS=" $5
                print "EXPERT=" $6
                exit
            }
        }
    ' "$SCHEDULE_FILE" 2>/dev/null || echo ""
}

# Function: Get expert info
get_expert_info() {
    local expert_agent="$1"
    
    case "$expert_agent" in
        "lianmin")
            echo "NAME=Lianmin Zheng"
            echo "EMOJI=🚀"
            echo "EXPERTISE=LLM Serving, SGLang, Distributed Training"
            ;;
        "tianqi")
            echo "NAME=Tianqi Chen"
            echo "EMOJI=🔧"
            echo "EXPERTISE=ML Compilers, TVM, XGBoost"
            ;;
        "zihao")
            echo "NAME=Zihao Ye"
            echo "EMOJI=⚡"
            echo "EXPERTISE=GPU Kernels, CUDA, FlashInfer"
            ;;
        "tri")
            echo "NAME=Tri Dao"
            echo "EMOJI=⚡"
            echo "EXPERTISE=Attention, FlashAttention, Algorithms"
            ;;
        *)
            echo "NAME=Unknown"
            echo "EMOJI=🤖"
            echo "EXPERTISE=General"
            ;;
    esac
}

# Function: Build notification message
build_notification() {
    local topic="$1"
    local focus="$2"
    local expert_agent="$3"
    local day_num="$4"
    
    local expert_info=$(get_expert_info "$expert_agent")
    local expert_name=$(echo "$expert_info" | grep "^NAME=" | cut -d= -f2)
    local expert_emoji=$(echo "$expert_info" | grep "^EMOJI=" | cut -d= -f2)
    local expertise=$(echo "$expert_info" | grep "^EXPERTISE=" | cut -d= -f2)
    
    cat <<EOF
🎯 **Daily Learning Reminder** - Day ${day_num} (${TODAY})

📚 **Today's Topic:** ${topic}
🔬 **Focus Area:** ${focus}
👨‍🏫 **Expert Advisor:** ${expert_emoji} ${expert_name}

📋 **What to do today:**
1. 📖 Read related materials in the repository
2. 📝 Create notes: \`notes/$(date +%Y-%m-%d)-${topic,,}.md\`
3. 🏋️ Complete exercises: \`exercises/$(date +%Y-%m-%d)-${topic,,}.md\`
4. ✅ Mark progress as complete

🔗 **Repository:** ${REPO_URL}

⏰ **End-of-day summary** will be sent at 24:00 to track progress.

💬 **Expert consultation** coming up next!

Reply with:
• \`done\` - When you finish today's topic
• \`question: [your question]\` - If you need help
• \`skip\` - To reschedule to another day
EOF
}

# Function: Send Feishu message (placeholder - actual implementation depends on Feishu API)
send_feishu_message() {
    local message="$1"
    
    # This would be replaced with actual Feishu API call
    # For now, we output to stdout which Jarvis can capture
    echo "$message"
}

# Main execution
main() {
    echo "=== Daily Learning Notification ==="
    echo "Date: $TODAY"
    echo ""
    
    # Get today's schedule
    local schedule_info=$(get_today_topic "$TODAY")
    
    if [[ -z "$schedule_info" ]]; then
        echo "⚠️ No topic scheduled for today ($TODAY)"
        echo "Please check LEARNING_SCHEDULE.md"
        exit 1
    fi
    
    # Parse schedule info
    local day_num=$(echo "$schedule_info" | grep "^DAY=" | cut -d= -f2 | tr -d ' ')
    local topic=$(echo "$schedule_info" | grep "^TOPIC=" | cut -d= -f2)
    local focus=$(echo "$schedule_info" | grep "^FOCUS=" | cut -d= -f2)
    local expert=$(echo "$schedule_info" | grep "^EXPERT=" | cut -d= -f2 | tr -d ' ')
    
    # Build and send notification
    local message=$(build_notification "$topic" "$focus" "$expert" "$day_num")
    
    echo "$message"
    
    # Return expert info for next step
    echo ""
    echo "=== EXPERT_INFO ==="
    echo "AGENT_ID=${expert}"
    echo "TOPIC=${topic}"
    echo "FOCUS=${focus}"
}

main "$@"
