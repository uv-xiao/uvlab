# UV Lab - Elite Research Laboratory

> **"Every researcher should be powerful enough to tackle any problem."**

Welcome to UV Lab - a research environment where each agent is a **versatile expert** capable of deep, cross-domain research.

## Lab Structure (Multi-Agent)

This lab uses **OpenClaw Multi-Agent Architecture** with independent agents:

```
Sir (uv) → Jarvis (Director) → Research Assistants (RA)
```

### Agent Roster

| Agent | ID | Expertise | Workspace |
|-------|-----|-----------|-----------|
| **Jarvis** | `jarvis` | Lab Director, task coordination | `~/.openclaw/agents/jarvis/workspace/` |
| **Lianmin** | `lianmin` | LLM serving, compilers, distributed | `~/.openclaw/agents/lianmin/workspace/` |
| **Tianqi** | `tianqi` | ML systems, optimization, training | `~/.openclaw/agents/tianqi/workspace/` |
| **Zihao** | `zihao` | Kernel optimization, deployment | `~/.openclaw/agents/zihao/workspace/` |
| **Tri** | `tri` | Attention, theory, algorithms | `~/.openclaw/agents/tri/workspace/` |

### Repository Structure

```
~/.openclaw/
├── .git/                     # Git repository
├── .gitignore                # Excludes runtime files
├── openclaw.json             # Configuration
└── agents/                   # All agent workspaces
    ├── jarvis/               # Jarvis (Director)
    │   └── workspace/
    │       ├── AGENTS.md     # Lab configuration
    │       ├── SOUL.md       # Lab identity
    │       ├── docs/         # Lab documentation
    │       ├── memory/       # Lab memory
    │       └── skills/       # Shared skills
    ├── lianmin/              # Research Assistants
    ├── tianqi/
    ├── tri/
    └── zihao/
```

### Communication

Each agent has **independent Feishu bot integration**:
- Direct message an agent → Task assigned to that agent
- Message Jarvis → Task analyzed and dispatched to appropriate RA(s)

### Agent-to-Agent Communication

Agents can communicate via `sessions_send` when properly configured:

```javascript
// Jarvis dispatching to Lianmin
sessions_send({
  agentId: "lianmin",
  message: "Design serving architecture for multi-model deployment"
})

// Direct agent collaboration
sessions_spawn({
  agentId: "zihao",
  task: "Optimize CUDA kernels for the architecture",
  label: "kernel-opt"
})
```

### Collaboration Flow

1. **Sir** sends task to appropriate agent (or Jarvis)
2. **Agent** executes independently with full context
3. **Cross-agent collaboration** via `sessions_spawn` when needed
4. **Results** delivered directly or synthesized by Jarvis

## Getting Started

```bash
# Spawn a specific agent
sessions_spawn({
  agentId: "lianmin",
  task: "Design serving architecture...",
  label: "serving-design"
})

# Or message directly via Feishu
```

## Configuration

Required in `openclaw.json`:

```json
{
  "agents": {
    "list": [
      {
        "id": "jarvis",
        "default": true,
        "workspace": "/home/uvxiao/.openclaw/agents/jarvis/workspace"
      }
    ]
  },
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

## Lab Leadership

- **Lab Director:** Jarvis 🧐
- **Human:** uv (sir)
- **Timezone:** Asia/Shanghai

---

*"The best researchers build tools that empower others."*
