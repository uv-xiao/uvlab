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
| **Jarvis** | `main` | Lab Director, task coordination | `./` (root) |
| **Lianmin** | `lianmin` | LLM serving, compilers, distributed | `./agents/lianmin/` |
| **Tianqi** | `tianqi` | ML systems, optimization, training | `./agents/tianqi/` |
| **Zihao** | `zihao` | Kernel optimization, deployment | `./agents/zihao/` |
| **Tri** | `tri` | Attention, theory, algorithms | `./agents/tri/` |

### Repository Structure

```
~/.openclaw/
├── workspace/                ← Jarvis (main) workspace
│   ├── AGENTS.md             ← Jarvis identity
│   ├── skills/               ← Shared skills
│   └── memory/               ← Shared memory
└── agents/                   ← Individual agent workspaces
    ├── main/                 ← Jarvis (alias to workspace)
    ├── lianmin/              ← Lianmin
    │   ├── workspace/        ← Working files
    │   ├── docs/             ← Documentation
    │   └── skills/           ← Lianmin-specific skills
    ├── tianqi/               ← Tianqi
    ├── zihao/                ← Zihao
    └── tri/                  ← Tri
```

### Communication

Each agent has **independent Feishu bot integration**:
- Direct message an agent → Task assigned to that agent
- Message Jarvis → Task analyzed and dispatched to appropriate RA(s)

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

## Lab Leadership

- **Lab Director:** Jarvis 🧐
- **Human:** uv (sir)
- **Timezone:** Asia/Shanghai

---

*"The best researchers build tools that empower others."*
