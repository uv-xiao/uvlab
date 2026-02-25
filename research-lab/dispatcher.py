#!/usr/bin/env python3
"""
UV Lab Multi-Agent Dispatcher

Dispatches tasks to specialized research agents based on task analysis.
Used by Jarvis (main agent) to coordinate the research team.
"""

import json
import os
from pathlib import Path
from typing import Optional, List, Dict, Any

CONFIGS_DIR = Path(__file__).parent / "configs"

# Agent expertise keywords for routing
AGENT_EXPERTISE = {
    "lianmin": {
        "keywords": [
            "serving", "inference", "compiler", "distributed", "parallel",
            "deployment", "api", "framework", "runtime", "vicuna", "sglang",
            "chatbot", "arena", "fastchat", "llm serving", "model serving"
        ],
        "priority": 1
    },
    "tianqi": {
        "keywords": [
            "optimization", "training", "xgboost", "boosting", "ensemble",
            "tvm", "mlc", "compiler", "operator", "architecture", "ecosystem",
            "scalable", "distributed training", "ml system", "gradient"
        ],
        "priority": 1
    },
    "zihao": {
        "keywords": [
            "kernel", "cuda", "gpu", "flashinfer", "quantization", "deployment",
            "graph", "gnn", "sparse", "tensor", "ffi", "mlc-llm", "dgl",
            "low-level", "hardware", "memory", "operator fusion"
        ],
        "priority": 1
    },
    "tri": {
        "keywords": [
            "attention", "flash attention", "transformer", "theory", "algorithm",
            "complexity", "proof", "analysis", "long context", "memory-efficient",
            "fused", "io-aware", "block-wise", "princeton", "hpc"
        ],
        "priority": 1
    }
}


def load_agent_config(agent_id: str) -> Optional[Dict[str, Any]]:
    """Load agent configuration from JSON file."""
    config_path = CONFIGS_DIR / f"{agent_id}.json"
    if not config_path.exists():
        return None
    with open(config_path, 'r') as f:
        return json.load(f)


def analyze_task(task: str) -> Dict[str, Any]:
    """
    Analyze a task and determine which agent(s) should handle it.
    Returns routing decision with confidence scores.
    """
    task_lower = task.lower()
    
    scores = {}
    for agent_id, expertise in AGENT_EXPERTISE.items():
        score = 0
        for keyword in expertise["keywords"]:
            if keyword in task_lower:
                score += 1
        scores[agent_id] = score
    
    # Sort by score descending
    ranked = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    
    # Filter to agents with positive scores
    candidates = [(agent, score) for agent, score in ranked if score > 0]
    
    if not candidates:
        # Default to Lianmin for general tasks
        candidates = [("lianmin", 0)]
    
    primary = candidates[0]
    secondary = candidates[1] if len(candidates) > 1 and candidates[1][1] > 0 else None
    
    return {
        "task": task,
        "primary_agent": primary[0],
        "primary_score": primary[1],
        "secondary_agent": secondary[0] if secondary else None,
        "secondary_score": secondary[1] if secondary else None,
        "all_scores": scores,
        "requires_collaboration": secondary is not None and secondary[1] >= 2
    }


def create_agent_task(agent_config: Dict[str, Any], task: str, context: str = "") -> str:
    """
    Create a formatted task prompt for an agent.
    Includes persona, expertise, and task context.
    """
    prompt = f"""# Task Assignment

## Your Identity
You are **{agent_config['name']}**, {agent_config['description']}

## Your Persona
{agent_config['persona']}

## Your Expertise
{chr(10).join('- ' + exp for exp in agent_config['expertise'])}

## Your Skills
You have access to these pkbllm skills: {', '.join(agent_config['skills'])}

## Task
{task}

{f"## Context/n{context}" if context else ""}

## Output Format
Provide a structured response with:
1. **Approach** - How you'll tackle this
2. **Execution** - What you're doing/finding
3. **Results** - Your findings/implementation
4. **Next Steps** - Recommendations or follow-ups

Be thorough, rigorous, and production-minded in your work."""
    
    return prompt


def dispatch(task: str, context: str = "") -> Dict[str, Any]:
    """
    Main dispatch function. Analyzes task and returns routing info.
    
    Usage from OpenClaw:
    ```python
    from dispatcher import dispatch
    result = dispatch("Implement flash attention kernel")
    # result = {
    #     "primary_agent": "tri",
    #     "task_prompt": "...",
    #     "requires_collaboration": False
    # }
    ```
    """
    analysis = analyze_task(task)
    primary_config = load_agent_config(analysis["primary_agent"])
    
    if not primary_config:
        return {
            "error": f"Agent {analysis['primary_agent']} config not found",
            "fallback": "lianmin"
        }
    
    task_prompt = create_agent_task(primary_config, task, context)
    
    result = {
        "primary_agent": analysis["primary_agent"],
        "task_prompt": task_prompt,
        "agent_config": primary_config,
        "requires_collaboration": analysis["requires_collaboration"],
        "analysis": analysis
    }
    
    if analysis["secondary_agent"]:
        secondary_config = load_agent_config(analysis["secondary_agent"])
        if secondary_config:
            result["secondary_agent"] = analysis["secondary_agent"]
            result["secondary_config"] = secondary_config
    
    return result


if __name__ == "__main__":
    # Test dispatch
    import sys
    task = sys.argv[1] if len(sys.argv) > 1 else "Implement efficient attention mechanism"
    result = dispatch(task)
    print(json.dumps(result, indent=2))
