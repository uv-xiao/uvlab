# UV Lab Multi-Agent Workflow

This document describes how Jarvis (Lab Director) coordinates with specialized research agents to complete complex tasks.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Sir (uv)                             │
│                    Sends task to Jarvis                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Jarvis (Main)                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  1. Receive & Analyze Task                           │   │
│  │  2. Dispatch to appropriate RA agent(s)              │   │
│  │  3. Monitor progress & coordinate collaboration      │   │
│  │  4. Synthesize results                               │   │
│  │  5. Deliver final output to Sir                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
    ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
    │  Lianmin    │  │   Tianqi    │  │   Zihao     │
    │  (serving)  │  │ (optimization)│ │  (kernels)  │
    └─────────────┘  └─────────────┘  └─────────────┘
                              │
                              ▼
                    ┌─────────────┐
                    │    Tri      │
                    │  (attention)│
                    └─────────────┘
```

## Agent Roster

| Agent | Expertise | Best For |
|-------|-----------|----------|
| **Lianmin** | LLM serving, compilers, distributed systems | Inference engines, API design, serving frameworks |
| **Tianqi** | ML systems, optimization, scalable training | Training frameworks, optimization algorithms, ecosystem design |
| **Zihao** | Kernel optimization, LLM deployment, graph ML | CUDA kernels, quantization, deployment, GNNs |
| **Tri** | Efficient attention, ML theory, HPC | Attention mechanisms, theoretical analysis, algorithms |

## Workflow Steps

### 1. Task Reception

Sir sends a task to Jarvis:
> "Build an efficient LLM serving system for our models"

### 2. Task Analysis

Jarvis analyzes the task using the dispatcher:
```python
from research_lab.dispatcher import dispatch
result = dispatch("Build an efficient LLM serving system")
# Returns: primary_agent="lianmin", secondary_agent="zihao"
```

### 3. Agent Dispatch

Jarvis spawns the primary agent with context:
```javascript
sessions_spawn({
  agentId: "main",
  task: result.task_prompt,
  label: `lianmin-${task_id}`
})
```

### 4. Collaboration (if needed)

If multiple agents are needed:
- Jarvis spawns secondary agent(s)
- Coordinates communication between them
- Manages shared context and artifacts

### 5. Progress Monitoring

Jarvis monitors agent progress:
- Checks session status
- Reviews intermediate outputs
- Intervenes if blockers arise

### 6. Result Synthesis

When agents complete:
- Jarvis collects all outputs
- Synthesizes into coherent response
- Identifies gaps or follow-ups needed

### 7. Delivery to Sir

Jarvis presents final result:
- Clear summary
- Key findings/outputs
- Recommendations
- Offers follow-up actions

## Dispatcher Logic

The dispatcher (`research-lab/dispatcher.py`) routes tasks based on keyword matching:

### Lianmin Keywords
`serving`, `inference`, `compiler`, `distributed`, `deployment`, `api`, `framework`, `runtime`, `vicuna`, `sglang`, `fastchat`

### Tianqi Keywords
`optimization`, `training`, `xgboost`, `boosting`, `ensemble`, `tvm`, `mlc`, `operator`, `architecture`, `ecosystem`, `scalable`

### Zihao Keywords
`kernel`, `cuda`, `gpu`, `flashinfer`, `quantization`, `graph`, `gnn`, `sparse`, `tensor`, `ffi`, `low-level`, `hardware`

### Tri Keywords
`attention`, `flash attention`, `transformer`, `theory`, `algorithm`, `complexity`, `proof`, `analysis`, `long context`, `fused`

## Example Workflows

### Example 1: Single Agent Task

**Sir:** "Implement a flash attention variant"

**Jarvis:**
1. Analyzes → Tri (attention keywords)
2. Spawns Tri with task prompt
3. Monitors progress
4. Delivers Tri's implementation to Sir

### Example 2: Multi-Agent Collaboration

**Sir:** "Build and deploy an optimized LLM serving system"

**Jarvis:**
1. Analyzes → Lianmin (serving) + Zihao (deployment/kernels)
2. Spawns Lianmin for system architecture
3. Spawns Zihao for kernel optimization
4. Coordinates: Lianmin's API design → Zihao's kernel impl
5. Synthesizes: Complete system with optimized kernels
6. Delivers integrated solution to Sir

### Example 3: Complex Research Project

**Sir:** "Research and implement efficient long-context transformers"

**Jarvis:**
1. Analyzes → Tri (attention/theory) + Tianqi (scalable training)
2. Spawns Tri for attention mechanism research
3. Spawns Tianqi for training infrastructure
4. Coordinates research ↔ implementation loop
5. Synthesizes: Paper + code + benchmarks
6. Delivers: Complete research package

## Task Prompt Format

Each agent receives a structured prompt:

```markdown
# Task Assignment

## Your Identity
You are **{Name}**, {description}

## Your Persona
{persona}

## Your Expertise
- {expertise items}

## Your Skills
{pkbllm skills}

## Task
{specific task}

## Context
{additional context if needed}

## Output Format
1. **Approach** - How you'll tackle this
2. **Execution** - What you're doing/finding
3. **Results** - Your findings/implementation
4. **Next Steps** - Recommendations
```

## Implementation Notes

### For Jarvis (Main Agent)

When receiving a task:

1. **Always analyze first** - Use dispatcher to route correctly
2. **Spawn with context** - Include full agent persona in task
3. **Monitor actively** - Check session status periodically
4. **Synthesize thoroughly** - Don't just forward agent output
5. **Offer follow-ups** - Suggest next actions to Sir

### For RA Agents

Each agent should:

1. **Embody their persona** - Think like their inspiration
2. **Use their skills** - Invoke pkbllm skills appropriately
3. **Be production-minded** - Code that ships, docs that help
4. **Communicate clearly** - Structured outputs, clear explanations
5. **Flag collaboration needs** - Tell Jarvis if another agent would help

## Future Enhancements

- [ ] Automatic parallel spawning for multi-agent tasks
- [ ] Shared workspace for agent collaboration
- [ ] Agent-to-agent direct communication
- [ ] Progress dashboard in OpenClaw Studio
- [ ] Task queue and priority scheduling
- [ ] Agent performance tracking and feedback
