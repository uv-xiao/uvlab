# UV Lab 🧪

> **"Every researcher should be powerful enough to tackle any problem."**

UV Lab is a multi-agent research environment built on [OpenClaw](https://openclaw.ai), where each agent is a **versatile expert** capable of deep, cross-domain research and production implementation.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Sir (uv)                             │
│              Direct message to specific agent                │
│                     OR message Jarvis                        │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │   Jarvis    │  │   Lianmin   │  │   Tianqi    │
    │  (Director) │  │  (Serving)  │  │  (ML Sys)   │
    └─────────────┘  └─────────────┘  └─────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
                    ┌─────────────┐  ┌─────────────┐
                    │   Zihao     │  │    Tri      │
                    │  (Kernels)  │  │  (Attention)│
                    └─────────────┘  └─────────────┘
```

### Agent Roster

| Agent | ID | Expertise | Best For |
|-------|-----|-----------|----------|
| **Jarvis** | `main` | Lab coordination, task dispatch | Task analysis, agent orchestration |
| **Lianmin** | `lianmin` | LLM serving, compilers, distributed | Inference engines, API design, SGLang |
| **Tianqi** | `tianqi` | ML systems, optimization | Training frameworks, TVM, XGBoost |
| **Zihao** | `zihao` | Kernel optimization, deployment | CUDA kernels, FlashInfer, quantization |
| **Tri** | `tri` | Efficient attention, algorithms | Flash Attention, theoretical analysis |

---

## 📁 Repository Structure

```
~
└── .openclaw/
    ├── .git/                     # This repository
    ├── .gitignore                # Excludes system/runtime files
    ├── agents/                   # Research agents (sub-agents)
    │   ├── lianmin/
    │   │   ├── workspace/        # Agent workspace (tracked)
    │   │   └── docs/             # Agent documentation (tracked)
    │   ├── tianqi/
    │   ├── tri/
    │   └── zihao/
    └── workspace/                # Jarvis (main agent) workspace
        ├── AGENTS.md             # Agent configuration
        ├── SOUL.md               # Lab identity
        ├── docs/                 # Lab documentation
        │   ├── MULTI-AGENT-WORKFLOW.md
        │   ├── thunderagent-analysis.md
        │   └── ...
        ├── memory/               # Lab memory
        └── skills/               # Shared skills
```

---

## 🚀 Getting Started

### Prerequisites

- OpenClaw installed and configured
- Feishu bots configured for each agent (optional)

### Clone and Setup

```bash
# Clone the repository to ~/.openclaw
git clone https://github.com/uv-xiao/uvlab.git ~/.openclaw

# Or if already have OpenClaw installed
cd ~/.openclaw
git remote add origin https://github.com/uv-xiao/uvlab.git
git pull origin main
```

### Configure Multi-Agent Workflow

Add to your `openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "workspace": "/home/uvxiao/.openclaw/workspace",
      "model": { "primary": "generic/qwen3.5-plus" }
    },
    "list": [
      {
        "id": "main",
        "default": true,
        "workspace": "/home/uvxiao/.openclaw/workspace"
      },
      {
        "id": "lianmin",
        "workspace": "/home/uvxiao/.openclaw/agents/lianmin/workspace"
      },
      {
        "id": "tianqi",
        "workspace": "/home/uvxiao/.openclaw/agents/tianqi/workspace"
      },
      {
        "id": "zihao",
        "workspace": "/home/uvxiao/.openclaw/agents/zihao/workspace"
      },
      {
        "id": "tri",
        "workspace": "/home/uvxiao/.openclaw/agents/tri/workspace"
      }
    ]
  },
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["main", "lianmin", "tianqi", "zihao", "tri"]
    },
    "sessions": {
      "visibility": "all"
    }
  }
}
```

---

## 🤝 Multi-Agent Collaboration

### Workflow

1. **Task Reception** - Sir sends task to Jarvis or specific agent
2. **Task Analysis** - Jarvis analyzes and routes to appropriate RA(s)
3. **Agent Dispatch** - Spawn agents with `sessions_spawn`
4. **Collaboration** - Agents work independently or coordinate via Jarvis
5. **Result Synthesis** - Jarvis collects and synthesizes outputs
6. **Delivery** - Final result presented to Sir

### Example: Multi-Agent Task

**Sir:** "Build an optimized LLM serving system"

**Jarvis workflow:**
```javascript
// 1. Analyze and spawn Lianmin for architecture
sessions_spawn({
  agentId: "lianmin",
  task: "Design serving system architecture for multi-model deployment",
  label: "lianmin-arch"
})

// 2. Spawn Zihao for kernel optimization
sessions_spawn({
  agentId: "zihao",
  task: "Optimize CUDA kernels for attention and feed-forward layers",
  label: "zihao-kernels"
})

// 3. Synthesize results and deliver
```

---

## 🛠️ Best Practices

### For Lab Director (Jarvis)

- **Always analyze first** - Use keyword matching to route correctly
- **Spawn with full context** - Include agent persona in task prompt
- **Monitor actively** - Check session status periodically
- **Synthesize thoroughly** - Don't just forward raw outputs

### For Research Assistants

- **Embody your persona** - Think like your inspiration
- **Use appropriate skills** - Invoke pkbllm skills when needed
- **Be production-minded** - Code that ships, docs that help
- **Flag collaboration needs** - Tell Jarvis if another agent would help

### Security

- Each agent has independent workspace and permissions
- Use `tools.allow/deny` to limit per-agent capabilities
- Sensitive agents use sandbox mode
- Version control only tracks documentation and configuration

---

## 📚 Documentation

- [Multi-Agent Workflow](workspace/docs/MULTI-AGENT-WORKFLOW.md) - Detailed collaboration patterns
- [Setup Guide](workspace/docs/SETUP.md) - Environment setup instructions
- [ThunderAgent Analysis](workspace/docs/thunderagent-analysis.md) - Technical analysis

---

## 🔗 Related

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw Multi-Agent Tools](https://docs.openclaw.ai/tools/multi-agent-sandbox-tools)
- [PKBLLM Framework](https://github.com/uv-xiao/pkbllm)

---

## 📝 License

Private research repository.

---

*"The best researchers build tools that empower others."*
