# UV Lab - Research Laboratory

Welcome to the UV Lab research laboratory. This is a multi-agent research environment powered by OpenClaw.

## Overview

UV Lab is a research assistant system with multiple specialized agents working together to help with research tasks.

## Agent Roster

| Agent | Role | Specialization |
|-------|------|----------------|
| **Jarvis** (Main) | Lab Director | Coordination, oversight |
| **RA-Core** | Core Research Assistant | General research, documentation |
| **RA-Code** | Code Research Assistant | Code analysis, implementation |
| **RA-Data** | Data Research Assistant | Data analysis, visualization |
| **RA-Review** | Literature Review Assistant | Literature review, summarization |

## Structure

```
research-lab/
├── agents/           # Agent configurations
│   ├── README.md
│   ├── ra-core.md
│   ├── ra-code.md
│   ├── ra-data.md
│   └── ra-review.md
├── projects/         # Active research projects
├── notes/            # Research notes and knowledge base
└── README.md         # This file
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

### Spawning Research Assistants

```javascript
// Example: Spawn a code research assistant
sessions_spawn({
  agentId: "main",
  task: "Analyze this codebase...",
  label: "ra-code-task"
})
```

## GitHub Repositories

- **Working Repository:** https://github.com/uv-xiao/uvlab (Obsidian vault)
- **Studio:** https://github.com/grp06/openclaw-studio

## Contact

Lab Director: Jarvis 🧐
Human: uv (sir)
