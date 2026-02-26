# UV Lab - Elite Research Laboratory

> **"Every researcher should be powerful enough to tackle any problem."**

Welcome to UV Lab - a research environment where each agent is a **versatile expert** capable of deep, cross-domain research.

## Philosophy

Traditional AI assistants are narrowly specialized. Our agents are **elite researchers** - each capable of:

- 🧠 **Deep research** - Reading papers, understanding theory, pushing boundaries
- 💻 **Production implementation** - Writing code that ships and performs
- 🔧 **Systems expertise** - Building scalable, robust infrastructure
- 📝 **Clear communication** - Documentation, papers, presentations

## Multi-Agent Architecture

This lab uses **OpenClaw Multi-Agent Architecture** with independent agents:

```
Sir (uv) → Jarvis (Main) → Research Assistants (RA)
```

### Agent Roster

| Agent | ID | Inspired By | Key Projects | Expertise |
|-------|-----|-------------|--------------|-----------|
| **Jarvis** | `main` | - | - | Lab Director, coordination |
| **Lianmin** | `lianmin` | merrymercy | SGLang, FastChat, Vicuna | LLM serving, compilers, distributed |
| **Tianqi** | `tianqi` | tqchen | XGBoost, TVM, MLC | ML systems, optimization, training |
| **Zihao** | `zihao` | yzh119 | FlashInfer, MLC-LLM, DGL | Kernel optimization, deployment |
| **Tri** | `tri` | tridao | Flash Attention | Attention, theory, algorithms |

### Agent Workspaces

Each agent has an independent workspace:

```
~/.openclaw/
├── workspace/                 # Jarvis (main)
├── agents/lianmin/workspace/  # Lianmin
├── agents/tianqi/workspace/   # Tianqi
├── agents/zihao/workspace/    # Zihao
└── agents/tri/workspace/      # Tri
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

## Skills Framework

Agents can use:
- **Per-agent skills** - Stored in `<workspace>/skills/` (agent-specific)
- **Shared skills** - Stored in `~/.openclaw/skills/` (all agents)
- **Bundled skills** - Shipped with OpenClaw

See [ClawHub](https://clawhub.com) for skill discovery and installation.

## Getting Started

### Spawning Research Agents

```javascript
// Direct agent spawn
sessions_spawn({
  agentId: "lianmin",
  task: "Design serving architecture for multi-model deployment",
  label: "lianmin-serving"
})

// Via Jarvis dispatch
sessions_spawn({
  agentId: "main",
  task: "Research and implement efficient attention",
  label: "tri-research"
})
```

### Using Skills

```bash
# Install skill to current agent workspace
clawhub install <skill-slug>

# List available skills
clawhub list
```

## Directory Structure

```
~/.openclaw/
├── workspace/                # Jarvis (main) workspace
│   ├── AGENTS.md
│   ├── skills/
│   └── memory/
└── agents/                   # All agent workspaces
    ├── main/
    │   └── docs/             # Lab documentation & reports
    ├── lianmin/
    │   ├── workspace/
    │   └── docs/README.md    # Agent persona
    ├── tianqi/
    ├── zihao/
    └── tri/
```

## GitHub Repositories

- **Working Repository:** https://github.com/uv-xiao/uvlab (Obsidian vault)
- **Lab Framework:** https://github.com/uv-xiao/pkbllm

## Lab Leadership

- **Lab Director:** Jarvis 🧐
- **Human:** uv (sir)
- **Timezone:** Asia/Shanghai

## Next Steps

1. **Configure Feishu bots** - One per agent in OpenClaw
2. **Start a project** - Create folder in agent workspace
3. **Spawn an agent** - Pick the right expert for the task
4. **Document findings** - Write to reports and MEMORY.md

---

*"The best researchers build tools that empower others."*
