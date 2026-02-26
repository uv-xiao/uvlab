# UV Lab 🧪

> **"Every researcher should be powerful enough to tackle any problem."**

UV Lab is a multi-agent research environment built on [OpenClaw](https://openclaw.ai), where each agent is a **versatile expert** capable of deep, cross-domain research and production implementation.

---

## 🏗️ Architecture

UV Lab uses **Direct Channel Routing** - each agent has its own Feishu bot, and Sir messages the appropriate agent directly for maximum context preservation.

```
                              Sir (uv)
                                │
            ┌───────────────────┼───────────────────┐
            │                   │                   │
            ▼                   ▼                   ▼
      ┌───────────┐       ┌───────────┐       ┌───────────┐
      │  Jarvis   │       │  Lianmin  │       │  Tianqi   │
      │(Director) │       │ (Serving) │       │ (ML Sys)  │
      └───────────┘       └───────────┘       └───────────┘
                                │                   │
                      ┌─────────┴─────────┐         │
                      │                   │         │
                      ▼                   ▼         ▼
                ┌───────────┐       ┌───────────┐
                │   Zihao   │       │    Tri    │
                │ (Kernels) │       │(Attention)│
                └───────────┘       └───────────┘
```

### Why Direct Routing?

According to [OpenClaw best practices](https://docs.openclaw.ai/tools/subagents), **sub-agents don't inherit full context** (SOUL.md, IDENTITY.md, MEMORY.md are not accessible). By using direct channel routing:

- ✅ Each agent has **full access** to their workspace context
- ✅ No context loss when dispatching tasks
- ✅ Simpler mental model - one bot per expert
- ✅ Agents can still collaborate via `sessions_send` when needed

### Agent Roster

| Agent | ID | Expertise | Best For |
|-------|-----|-----------|----------|
| **Jarvis** | `jarvis` | Lab coordination, cross-domain synthesis | General questions, task decomposition, multi-agent coordination |
| **Lianmin** | `lianmin` | LLM serving, compilers, distributed | Inference engines, API design, SGLang |
| **Tianqi** | `tianqi` | ML systems, optimization | Training frameworks, TVM, XGBoost |
| **Zihao** | `zihao` | Kernel optimization, deployment | CUDA kernels, FlashInfer, quantization |
| **Tri** | `tri` | Efficient attention, algorithms | Flash Attention, theoretical analysis |

---

## 👥 In Honor Of

The agents in UV Lab are named after researchers and innovators who have made groundbreaking contributions to ML systems and AI infrastructure. This is our humble tribute to their work.

### 🎬 Jarvis
Named after **J.A.R.V.I.S.** (Just A Rather Very Intelligent System), Tony Stark's AI assistant from Marvel Comics.

> *The ideal lab director - knowledgeable, helpful, and always ready to assist.*

### 🚀 Lianmin ([@merrymercy](https://github.com/merrymercy))
**Lianmin Zheng** - Creator of [SGLang](https://github.com/sgl-project/sglang), [FastChat](https://github.com/lm-sys/FastChat), [Vicuna](https://lmsys.org/blog/2023-03-30-vicuna/), and [Chatbot Arena](https://chat.lmsys.org/)

> *Pioneer in LLM serving systems and open-source model evaluation. His work on structured generation and efficient inference has shaped how we deploy large models at scale.*

### ⭐ Tianqi ([@tqchen](https://github.com/tqchen))
**Tianqi Chen** - Creator of [XGBoost](https://xgboost.ai/), [TVM](https://tvm.apache.org/), [MLC-LLM](https://llm.mlc.ai/), and co-founder of [DMLC](https://dmlc.github.io/)

> *Visionary in ML compilation and optimization. From gradient boosting to universal ML compilation, his work bridges theory and production systems.*

### ⚡ Zihao ([@yzh119](https://github.com/yzh119))
**Zihao Ye** - Creator of [FlashInfer](https://github.com/flashinfer-ai/flashinfer), core contributor to [MLC-LLM](https://llm.mlc.ai/), and [DGL](https://www.dgl.ai/)

> *Master of kernel optimization and memory-efficient attention. His CUDA expertise enables serving LLMs faster and cheaper.*

### 🔥 Tri ([@tridao](https://github.com/tridao))
**Tri Dao** - Creator of [FlashAttention](https://github.com/Dao-AILab/flash-attention), [Flash-Decoding](https://github.com/Dao-AILab/flash-attention/blob/main/csrc/flash_decoding/README.md), Professor at Princeton

> *Brilliant researcher in efficient attention mechanisms. FlashAttention revolutionized how we think about memory-efficient transformers, making long-context models practical.*

---

**Why these names?**

Each agent embodies the spirit and expertise of their namesake. When you ask Lianmin about serving, you're getting advice inspired by the mind behind SGLang. When Zihao optimizes kernels, he channels the expertise of FlashInfer's creator.

*"If I have seen further, it is by standing on the shoulders of giants."* — Isaac Newton

---

## 📁 Repository Structure

```
~
└── .openclaw/
    ├── .git/                     # This repository
    ├── .gitignore                # Excludes system/runtime files
    ├── openclaw.json             # Configuration
    └── agents/                   # All agents
        ├── jarvis/               # Jarvis (Director)
        │   └── workspace/
        │       ├── AGENTS.md     # Agent identity
        │       ├── SOUL.md       # Lab identity
        │       ├── docs/         # Lab documentation
        │       ├── memory/       # Lab memory
        │       └── skills/       # Shared skills
        ├── lianmin/              # Research assistants
        ├── tianqi/
        ├── tri/
        └── zihao/
```

---

## 🚀 Getting Started

### Prerequisites

- OpenClaw installed and configured
- Feishu bots configured for each agent

### Clone and Setup

```bash
# Clone the repository to ~/.openclaw
git clone https://github.com/uv-xiao/uvlab.git ~/.openclaw

# Or if already have OpenClaw installed
cd ~/.openclaw
git remote add origin https://github.com/uv-xiao/uvlab.git
git pull origin main
```

### Configure Channel Bindings

Add to your `openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "workspace": "/home/uvxiao/.openclaw/agents/jarvis/workspace",
      "model": { "primary": "generic/qwen3.5-plus" }
    },
    "list": [
      {
        "id": "jarvis",
        "default": true,
        "workspace": "/home/uvxiao/.openclaw/agents/jarvis/workspace"
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
  "bindings": [
    { "agentId": "jarvis", "match": { "channel": "feishu", "peer": "jarvis-bot" } },
    { "agentId": "lianmin", "match": { "channel": "feishu", "peer": "lianmin-bot" } },
    { "agentId": "tianqi", "match": { "channel": "feishu", "peer": "tianqi-bot" } },
    { "agentId": "zihao", "match": { "channel": "feishu", "peer": "zihao-bot" } },
    { "agentId": "tri", "match": { "channel": "feishu", "peer": "tri-bot" } }
  ]
}
```

---

## 🤝 Multi-Agent Collaboration

### Workflow

1. **Direct Contact** - Sir messages the appropriate agent directly
2. **Full Context** - Agent works with complete workspace context (SOUL.md, MEMORY.md, etc.)
3. **Self-Directed** - Agent can spawn sub-agents for parallel work if needed
4. **Cross-Agent** - Agents can use `sessions_send` to collaborate when configured

### Example: Task Routing

| Task | Contact |
|------|---------|
| "Design LLM serving system" | → **Lianmin** (serving expert) |
| "Optimize CUDA kernels" | → **Zihao** (kernel expert) |
| "Research attention mechanisms" | → **Tri** (attention expert) |
| "General question / unsure" | → **Jarvis** (coordinator) |
| "Multiple domains needed" | → **Jarvis** (synthesizes across agents) |

### When to Contact Jarvis

- General questions that don't fit a specific domain
- Tasks spanning multiple expertise areas
- Uncertain which specialist to contact
- Cross-cutting concerns (architecture, strategy)

### Agent-to-Agent Communication

When enabled, agents can communicate directly:

```javascript
// Lianmin needs kernel optimization help
sessions_send({
  agentId: "zihao",
  message: "Need optimized attention kernel for multi-GPU serving"
})
```

**Required configuration:**
```json
{
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["jarvis", "lianmin", "tianqi", "zihao", "tri"]
    },
    "sessions": {
      "visibility": "all"
    }
  }
}
```

---

## 🛠️ Best Practices

### For Sir (Human)

- **Contact the right expert** - Use keyword matching to route to appropriate agent
- **Jarvis as fallback** - When unsure, start with Jarvis
- **Be specific** - Clear task descriptions get better results
- **Respect boundaries** - Don't ask kernel questions to Tianqi

### For Agents

- **Embody your persona** - Think like your inspiration
- **Use appropriate skills** - Leverage available skills when needed
- **Be production-minded** - Code that ships, docs that help
- **Escalate when needed** - Use `sessions_send` to collaborate

### Security

- Each agent has independent workspace and permissions
- Use `tools.allow/deny` to limit per-agent capabilities
- Sensitive agents use sandbox mode
- Version control only tracks documentation and configuration

---

## 📚 Documentation

- [Multi-Agent Workflow](agents/jarvis/workspace/docs/MULTI-AGENT-WORKFLOW.md) - Detailed collaboration patterns
- [Setup Guide](agents/jarvis/workspace/docs/SETUP.md) - Environment setup instructions
- [ThunderAgent Analysis](agents/jarvis/workspace/artifacts/reports/thunderagent-analysis.md) - Technical analysis

---

## 🔗 Related

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw Multi-Agent Tools](https://docs.openclaw.ai/tools/multi-agent-sandbox-tools)
- [UV Lab Repository](https://github.com/uv-xiao/uvlab)

---

## 📝 License

Private research repository.

---

*"The best researchers build tools that empower others."*
