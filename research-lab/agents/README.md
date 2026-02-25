# UV Lab - Elite Research Agents

This lab employs **elite research agents** - each a versatile expert capable of deep, cross-domain research. Unlike traditional specialized assistants, our agents embody the spirit of brilliant open-source contributors who excel across systems, theory, and implementation.

## Philosophy

> "Every researcher should be powerful enough to tackle any problem."

Our agents are inspired by contributors like:
- **merrymercy** (Lianmin Zheng) - SGLang, FastChat, Vicuna, TVM
- **tqchen** - XGBoost, TVM, DMLC
- **yzh119** (Zihao Ye) - FlashInfer, MLC-LLM, DGL
- **tridao** (Tri Dao) - Flash Attention, Princeton CS

Each agent combines:
- **Systems expertise** - Building scalable, production-ready systems
- **Research depth** - Understanding theory and pushing boundaries
- **Implementation skill** - Writing code that ships and performs
- **Communication** - Clear documentation and knowledge sharing

## Agent Roster

| Agent | Inspiration | Focus Areas |
|-------|-------------|-------------|
| **Lianmin** | merrymercy (Lianmin Zheng) | LLM serving, compilers, distributed systems |
| **Tianqi** | tqchen (Tianqi Chen) | ML systems, optimization, scalable training |
| **Zihao** | yzh119 (Zihao Ye) | Kernel optimization, LLM deployment, graph ML |
| **Tri** | tridao (Tri Dao) | Efficient attention, ML theory, high-performance computing |

## Skills Framework (pkbllm)

All agents leverage the [pkbllm](https://github.com/uv-xiao/pkbllm) skills system:

```
pkbllm/
├── common/         # Cross-domain skills
├── productivity/   # Engineering workflow
├── knowledge/      # Domain & research skills
├── human/          # Human-facing material generation
└── bootstrap/      # Maintenance scripts
```

### Core Skill Categories

1. **Planning & Execution** - `uv-plan-*`, `uv-execute-*`
2. **Research** - `uv-research-*`, `uv-literature-*`
3. **Implementation** - `uv-code-*`, `uv-build-*`
4. **Review** - `uv-review-*`, `uv-evaluate-*`
5. **Human Materials** - `uv-slides-*`, `uv-report-*`

## Usage

Agents are spawned with full capabilities:

```javascript
sessions_spawn({
  agentId: "main",
  task: "Research and implement efficient attention mechanisms",
  label: "flashattn-research"
})
```

Each agent can:
- Read/write code and documentation
- Execute research workflows
- Generate human-facing materials
- Coordinate with other agents
- Access pkbllm skills on demand

## Workspace Structure

```
research-lab/
├── agents/           # Agent configurations (this folder)
├── projects/         # Active research projects
├── notes/            # Knowledge base & literature notes
└── .references/      # Cached papers, repos, PDFs (gitignored)
```
