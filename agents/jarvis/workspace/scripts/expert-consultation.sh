#!/bin/bash
# Expert Consultation Request Script
# Called by Jarvis to message the appropriate expert

set -e

# Configuration
CONFIG_FILE="/home/uvxiao/.openclaw/agents/jarvis/workspace/LEARNING_CONFIG.json"
SCHEDULE_FILE="/home/uvxiao/.openclaw/agents/jarvis/workspace/LEARNING_SCHEDULE.md"

# Read Feishu config (for potential future use)
FEISHU_GROUP_ID=$(cat "$CONFIG_FILE" | python3 -c "import sys,json; print(json.load(sys.stdin)['feishu']['groupId'])" 2>/dev/null || echo "oc_922c749fb51de36a68f7b2f50eed20af")

# Get today's date
TODAY=$(date +%Y-%m-%d)

# Function: Get expert for today
get_today_expert() {
    local date_str="$1"
    
    awk -v date="$date_str" '
        /^\| [0-9]+ \|/ {
            if ($3 == date) {
                gsub(/^[ \t]+|[ \t]+$/, "", $6)
                print $6
                exit
            }
        }
    ' "$SCHEDULE_FILE" 2>/dev/null
}

# Function: Get today's topic info
get_today_info() {
    local date_str="$1"
    
    awk -v date="$date_str" '
        /^\| [0-9]+ \|/ {
            if ($3 == date) {
                gsub(/^[ \t]+|[ \t]+$/, "", $4)
                gsub(/^[ \t]+|[ \t]+$/, "", $5)
                print "TOPIC=" $4
                print "FOCUS=" $5
                exit
            }
        }
    ' "$SCHEDULE_FILE" 2>/dev/null
}

# Function: Get expert details
get_expert_details() {
    local agent_id="$1"
    
    case "$agent_id" in
        "lianmin")
            echo "NAME=Lianmin Zheng"
            echo "EXPERTISE=LLM Serving, SGLang, vLLM, Distributed Training"
            echo "REPOS=SGLang, FastChat, Alpa"
            echo "PAPERS=SGLang (NeurIPS 24), Alpa (OSDI 22)"
            ;;
        "tianqi")
            echo "NAME=Tianqi Chen"
            echo "EXPERTISE=ML Compilers, TVM, XGBoost, MXNet"
            echo "REPOS=TVM, XGBoost, MLC-LLM"
            echo "PAPERS=TVM (OSDI 18), XGBoost (KDD 16)"
            ;;
        "zihao")
            echo "NAME=Zihao Ye"
            echo "EXPERTISE=GPU Kernels, CUDA, FlashInfer, Triton"
            echo "REPOS=FlashInfer, TVM (contributions)"
            echo "PAPERS=FlashInfer, SparseTIR (ASPLOS 23)"
            ;;
        "tri")
            echo "NAME=Tri Dao"
            echo "EXPERTISE=Attention Mechanisms, FlashAttention, State Space Models"
            echo "REPOS=FlashAttention, Mamba"
            echo "PAPERS=FlashAttention (NeurIPS 22), Mamba (COLM 23)"
            ;;
        *)
            echo "NAME=Unknown"
            echo "EXPERTISE=General AI"
            echo "REPOS=N/A"
            echo "PAPERS=N/A"
            ;;
    esac
}

# Function: Build expert consultation message
build_consultation_message() {
    local expert_agent="$1"
    local topic="$2"
    local focus="$3"
    
    local details=$(get_expert_details "$expert_agent")
    local name=$(echo "$details" | grep "^NAME=" | cut -d= -f2)
    local expertise=$(echo "$details" | grep "^EXPERTISE=" | cut -d= -f2)
    local repos=$(echo "$details" | grep "^REPOS=" | cut -d= -f2)
    local papers=$(echo "$details" | grep "^PAPERS=" | cut -d= -f2)
    
    cat <<EOF
@${expert_agent}

Hi ${name},

Today's learning topic for the user is:

📚 **Topic:** ${topic}
🔬 **Focus Area:** ${focus}

As our resident expert in ${expertise}, could you please provide:

1. 🎯 **Key concepts** to focus on for this topic
2. ⚠️ **Common pitfalls** beginners should avoid
3. 📖 **Recommended resources** (papers, repos, docs)
   - Your relevant work: ${repos}
   - Key papers: ${papers}
4. 🏋️ **One hands-on exercise** suggestion
5. 💡 **Pro tips** from your experience

The user is preparing for AI infrastructure interviews and would greatly benefit from your practical insights!

Please reply with detailed suggestions the user can follow today.

Thanks! 🙏
EOF
}

# Main execution
main() {
    echo "=== Expert Consultation Request ==="
    echo "Date: $TODAY"
    echo ""
    
    # Get today's expert
    local expert=$(get_today_expert "$TODAY")
    local info=$(get_today_info "$TODAY")
    
    if [[ -z "$expert" ]]; then
        echo "⚠️ No expert assigned for today"
        exit 1
    fi
    
    local topic=$(echo "$info" | grep "^TOPIC=" | cut -d= -f2)
    local focus=$(echo "$info" | grep "^FOCUS=" | cut -d= -f2)
    
    echo "Expert: $expert"
    echo "Topic: $topic"
    echo "Focus: $focus"
    echo ""
    
    # Build consultation message
    local message=$(build_consultation_message "$expert" "$topic" "$focus")
    
    echo "=== MESSAGE TO SEND ==="
    echo "$message"
    echo ""
    echo "=== END MESSAGE ==="
    
    # Return expert agent ID for routing
    echo "TARGET_AGENT=${expert}"
}

main "$@"
