# UV Lab Multi-Agent Workflow

This document describes how agents in UV Lab collaborate using **Direct Channel Routing**.

## Architecture

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

## Design Philosophy: Direct Routing

UV Lab uses **Direct Channel Routing** instead of the Orchestrator pattern because:

1. **Full Context Preservation** - Sub-agents don't inherit SOUL.md, IDENTITY.md, MEMORY.md. Direct routing ensures each agent has complete context.

2. **Simpler Mental Model** - One Feishu bot per expert. Sir knows exactly who to contact.

3. **Better Responsibility** - Each agent owns their domain completely.

4. **Still Collaborative** - Agents can use `sessions_send` when they need cross-domain input.

## Workflow

### 1. Task Reception

Sir sends a task **directly** to the appropriate agent:

| Task Type | Contact |
|-----------|---------|
| Serving system design | → **Lianmin** |
| Training optimization | → **Tianqi** |
| CUDA kernel work | → **Zihao** |
| Attention mechanisms | → **Tri** |
| General / cross-domain | → **Jarvis** |

### 2. Independent Execution

Each agent works with their **full workspace context**:
- AGENTS.md (identity)
- SOUL.md (lab values)
- IDENTITY.md (persona)
- MEMORY.md (past work)
- TOOLS.md (available skills)

### 3. Self-Directed Sub-tasks

If an agent needs parallel work, they spawn their **own** sub-agents:

```javascript
// Lianmin working on serving system
sessions_spawn({
  task: "Benchmark different batching strategies",
  label: "batching-benchmark"
})
```

### 4. Cross-Agent Collaboration

When an agent needs input from another domain:

```javascript
// Lianmin needs kernel optimization input
sessions_send({
  agentId: "zihao",
  message: "What's the most efficient way to implement chunked prefill kernels?"
})
```

**Note:** Cross-agent communication requires:
```json
{
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["jarvis", "lianmin", "tianqi", "zihao", "tri"]
    },
    "sessions": { "visibility": "all" }
  }
}
```

## Task Routing Reference

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

**Sir → Lianmin:** "Design a serving system for multi-model deployment"

1. Lianmin receives task with full context
2. Works independently on architecture
3. Delivers design to Sir

### Example 2: Cross-Domain Task

**Sir → Jarvis:** "Build an optimized LLM serving system"

**Jarvis approach:**
1. Analyzes task components:
   - Serving architecture → **Lianmin**
   - Kernel optimization → **Zihao**
2. Advises Sir: "This needs both serving and kernel expertise. You should contact Lianmin for architecture and Zihao for kernel work."

**Or, if Jarvis handles it:**
1. Researches general architecture
2. Uses `sessions_send` to consult Lianmin/Zihao on specific points
3. Synthesizes final recommendation

### Example 3: Agent-Initiated Collaboration

**Sir → Lianmin:** "Implement efficient batching for LLM serving"

**Lianmin:**
1. Works on batching strategy
2. Realizes need optimized attention kernel
3. Sends message to Zihao: `sessions_send({agentId: "zihao", message: "Need batch-friendly attention kernel"})`
4. Zihao responds with kernel design
5. Lianmin integrates and delivers complete solution

## Comparison: Direct Routing vs. Orchestrator

| Aspect | Direct Routing (UV Lab) | Orchestrator Pattern |
|--------|------------------------|---------------------|
| Context | ✅ Full workspace preserved | ❌ Sub-agents lose SOUL.md, IDENTITY.md |
| Complexity | Simple - one bot per agent | Complex - dispatcher logic needed |
| Flexibility | Agent decides when to collaborate | Centralized coordination |
| Best for | Domain experts with clear boundaries | Tasks requiring tight coordination |

## Configuration

### Feishu Bindings

```json
{
  "bindings": [
    { "agentId": "jarvis", "match": { "channel": "feishu", "peer": "jarvis-bot" } },
    { "agentId": "lianmin", "match": { "channel": "feishu", "peer": "lianmin-bot" } },
    { "agentId": "tianqi", "match": { "channel": "feishu", "peer": "tianqi-bot" } },
    { "agentId": "zihao", "match": { "channel": "feishu", "peer": "zihao-bot" } },
    { "agentId": "tri", "match": { "channel": "feishu", "peer": "tri-bot" } }
  ]
}
```

### Agent-to-Agent Communication (Optional)

Enable if agents need to consult each other:

```json
{
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["jarvis", "lianmin", "tianqi", "zihao", "tri"]
    },
    "sessions": { "visibility": "all" }
  }
}
```

## Best Practices

### For Sir (Human)

1. **Contact the right expert** - Use keyword matching
2. **Jarvis as fallback** - When unsure
3. **Let agents own their domain** - Don't micro-manage through Jarvis
4. **Encourage direct collaboration** - Agents can use `sessions_send`

### For Agents

1. **Embody your persona** - Full context means full responsibility
2. **Know your limits** - Escalate to other agents when needed
3. **Document in memory/** - Keep track of decisions
4. **Be proactive** - Offer follow-ups and next steps

### For Jarvis (Director)

1. **Route, don't execute** - Know when to defer to specialists
2. **Strategic synthesis** - Handle cross-domain questions
3. **Help Sir choose** - Guide to the right expert
4. **Coordinate when asked** - Help manage multi-agent projects

## References

- [OpenClaw Sub-agents Documentation](https://docs.openclaw.ai/tools/subagents)
- [OpenClaw Best Practices](https://docs.openclaw.ai/help/faq)
