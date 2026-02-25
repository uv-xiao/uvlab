# UV Lab - Elite Research Laboratory

> "Every researcher should be powerful enough to tackle any problem."

Welcome to UV Lab - a research environment where each agent is a **versatile expert** capable of deep, cross-domain research. Our agents embody the spirit of brilliant open-source contributors who excel across systems, theory, and implementation.

## Philosophy

Traditional AI assistants are narrowly specialized. Our agents are **elite researchers** - each capable of:

- 🧠 **Deep research** - Reading papers, understanding theory, pushing boundaries
- 💻 **Production implementation** - Writing code that ships and performs
- 🔧 **Systems expertise** - Building scalable, robust infrastructure
- 📝 **Clear communication** - Documentation, papers, presentations

## Agent Roster

Each agent is named after groundbreaking open-source projects and inspired by their creators:

| Agent | Inspired By | Key Projects | Expertise |
|-------|-------------|--------------|-----------|
| **SGLang** | merrymercy (Lianmin Zheng) | SGLang, FastChat, Vicuna | LLM serving, compilers, distributed systems |
| **XGBoost** | tqchen (Tianqi Chen) | XGBoost, TVM, DMLC | ML systems, optimization, scalable training |
| **FlashInfer** | yzh119 (Zihao Ye) | FlashInfer, MLC-LLM, DGL | Kernel optimization, LLM deployment, graph ML |
| **FlashAttn** | tridao (Tri Dao) | Flash Attention, Princeton CS | Efficient attention, ML theory, HPC |

## Skills Framework (pkbllm)

All agents leverage the [pkbllm](https://github.com/uv-xiao/pkbllm) skills system - a curated repository of reusable instruction sets for effective LLM-human interaction.

### Skill Categories

```
pkbllm/
├── common/         # Cross-domain skills (planning, execution, review)
├── productivity/   # Engineering workflow (git, testing, debugging)
├── knowledge/      # Domain expertise (research, analysis, synthesis)
├── human/          # Human-facing materials (slides, reports, docs)
└── bootstrap/      # Maintenance and updates
```

### Core Workflows

1. **Discover** - `uv-using-pkb` to find the right skill
2. **Execute** - Invoke skill with clear task definition
3. **Generate** - Produce artifacts (code, docs, slides, reports)
4. **Review** - Self-evaluate and iterate
5. **Codify** - Extract lessons into knowledge base

## Workspace Structure

```
research-lab/
├── agents/              # Agent configurations
│   ├── README.md        # This philosophy document
│   ├── sglang.md        # LLM systems expert
│   ├── xgboost.md       # ML systems expert
│   ├── flashinfer.md    # Kernel optimization expert
│   └── flashattn.md     # Attention/theory expert
├── projects/            # Active research projects
│   └── <project-name>/
│       ├── README.md
│       ├── notes/
│       ├── code/
│       └── outputs/
├── notes/               # Knowledge base & literature notes
│   ├── papers/          # Paper summaries
│   ├── concepts/        # Concept explanations
│   └── meetings/        # Research discussions
└── .references/         # Cached sources (gitignored)
    ├── pdfs/            # Downloaded papers
    ├── arxiv/           # arXiv snapshots
    └── repos/           # Cloned repositories
```

## Getting Started

### OpenClaw Studio

The lab uses OpenClaw Studio for visibility and management:

```bash
cd /home/admin/openclaw-studio
npm run dev
```

Then open http://localhost:3000 and connect with:
- **Upstream URL:** ws://localhost:18789
- **Token:** (from gateway config)

### Spawning Research Agents

```javascript
// Example: Research and implement efficient attention
sessions_spawn({
  agentId: "main",
  task: "Research flash attention variants and implement optimized kernel",
  label: "flashattn-research"
})

// Example: Build LLM serving infrastructure
sessions_spawn({
  agentId: "main",
  task: "Design serving architecture for multi-model deployment",
  label: "serving-design"
})
```

### Using pkbllm Skills

```bash
# List available skills
npx skills add . --list

# Install skills for project (recommended: project scope)
npx skills add . -a codex --skill '*' -y

# Use in AGENTS.md (recommended workflow)
python /path/to/pkbllm/bootstrap/scripts/pkb_agents_md.py assemble \
  --query "implement efficient attention" \
  --agents-md ./AGENTS.md \
  --pick --init
```

## GitHub Repositories

- **Working Repository:** https://github.com/uv-xiao/uvlab (Obsidian vault)
- **Skills Framework:** https://github.com/uv-xiao/pkbllm
- **Studio:** https://github.com/grp06/openclaw-studio

## Lab Leadership

- **Lab Director:** Jarvis 🧐
- **Human:** uv (sir)
- **Timezone:** Asia/Shanghai

## Next Steps

1. **Start a project** - Create folder in `projects/`
2. **Spawn an agent** - Pick the right expert for the task
3. **Use pkbllm skills** - Invoke the right skill at the right time
4. **Document findings** - Write to `notes/` and `MEMORY.md`
5. **Generate materials** - Slides, reports, code, papers

---

*"The best researchers build tools that empower others."*
