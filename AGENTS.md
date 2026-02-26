# UV Lab - Elite Research Laboratory

> **"Every researcher should be powerful enough to tackle any problem."**

Welcome to UV Lab - a research environment where each agent is a **versatile expert** capable of deep, cross-domain research.

## Lab Structure (Multi-Agent)

This lab uses **OpenClaw Multi-Agent Architecture** with independent agents:

```
Sir (uv) → Jarvis (Main) → Research Assistants (RA)
```

### Agent Roster

| Agent | ID | Expertise | Workspace |
|-------|-----|-----------|-----------|
| **Jarvis** | `main` | Lab Director, task coordination | `~/.openclaw/workspace/` |
| **Lianmin** | `lianmin` | LLM serving, compilers, distributed | `~/.openclaw/agents/lianmin/workspace/` |
| **Tianqi** | `tianqi` | ML systems, optimization, training | `~/.openclaw/agents/tianqi/workspace/` |
| **Zihao** | `zihao` | Kernel optimization, deployment | `~/.openclaw/agents/zihao/workspace/` |
| **Tri** | `tri` | Attention, theory, algorithms | `~/.openclaw/agents/tri/workspace/` |

### Communication

Each agent has **independent Feishu bot integration**:
- Direct message an agent → Task assigned to that agent
- Message Jarvis → Task analyzed and dispatched to appropriate RA(s)

### Collaboration Flow

1. **Sir** sends task to appropriate agent (or Jarvis)
2. **Agent** executes independently with full context
3. **Cross-agent collaboration** via `sessions_spawn` when needed
4. **Results** delivered directly or synthesized by Jarvis

## Shared Resources

```
research-lab/
├── agents/           # Agent personas (reference)
├── reports/          # Shared research outputs
└── MULTI-AGENT-WORKFLOW.md  # Collaboration patterns
```

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

## Lab Leadership

- **Lab Director:** Jarvis 🧐
- **Human:** uv (sir)
- **Timezone:** Asia/Shanghai

---

*"The best researchers build tools that empower others."*
