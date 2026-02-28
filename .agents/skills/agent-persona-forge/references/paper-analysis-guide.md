# Paper Analysis Guide

Deep guide for extracting both technical skills and research methodology from academic papers.

## Pre-Reading: Scan Strategy

Before deep reading, scan for:
1. **Title and abstract** - Core contribution
2. **Introduction** - Problem motivation and approach overview
3. **Figures and tables** - Key results and system diagrams
4. **Related work** - How this differs from prior approaches
5. **Conclusion** - Summary of contributions

## Deep Reading: What to Extract

### Type A: Technical Skills Extraction

Focus on WHAT the paper achieves.

#### 1. Problem Definition
- What specific problem does this paper solve?
- Why is this problem important?
- What are the constraints/requirements?

**Extraction template:**
```yaml
problem:
  description: ""
  importance: ""
  constraints: []
  domain: ""
```

#### 2. Technical Approach
- What is the core technique/algorithm?
- What are the key components?
- How do they interact?

**Look for:**
- Algorithm listings (pseudocode)
- System architecture diagrams
- Data flow descriptions
- Mathematical formulations

**Extraction template:**
```yaml
approach:
  core_technique: ""
  components:
    - name: ""
      purpose: ""
      implementation: ""
  algorithms:
    - name: ""
      key_steps: []
  innovations: []
```

#### 3. System Building
- What system was built?
- What are the implementation details?
- What technologies/platforms are used?

**Look for:**
- Implementation section
- System architecture
- Code repositories mentioned
- Deployment details

**Extraction template:**
```yaml
system:
  name: ""
  purpose: ""
  architecture: ""
  technologies: []
  codebase: ""
  deployment: ""
```

#### 4. Evaluation Methodology
- What metrics are used?
- What baselines are compared?
- What datasets/workloads are used?

**Extraction template:**
```yaml
evaluation:
  metrics: []
  baselines: []
  datasets: []
  key_results: []
  hardware: ""
```

### Type B: Research Methodology Extraction

Focus on HOW the researcher approaches problems.

#### 1. Problem Identification Process

**Questions to answer:**
- What observations led to this problem?
- What prior work was analyzed?
- What gaps were identified?
- How did the researcher know this was an important problem?

**Look for:**
- Introduction motivation paragraphs
- Analysis of limitations in prior work
- Real-world observations/anecdotes
- Quantification of the problem

**Extraction template:**
```yaml
problem_identification:
  observations: []
  prior_analysis: []
  gap_identified: ""
  importance_justification: ""
  key_insight: ""
```

#### 2. Solution Development Process

**Questions to answer:**
- What was the initial approach?
- What alternatives were considered?
- How did the solution evolve?
- What insights led to breakthroughs?

**Look for:**
- Design exploration sections
- Failed approaches mentioned
- Evolution of ideas
- Key insights highlighted

**Extraction template:**
```yaml
solution_development:
  initial_approach: ""
  alternatives_considered: []
  evolution: []
  key_breakthroughs: []
  cross_domain_inspiration: ""
  iteration_count: ""
```

#### 3. Validation Strategy

**Questions to answer:**
- How did they validate the approach?
- Why those specific experiments?
- What would disprove their claims?
- How thorough is the evaluation?

**Look for:**
- Ablation studies
- Sensitivity analysis
- Edge cases tested
- Real-world validation

**Extraction template:**
```yaml
validation_strategy:
  experiment_design: ""
  ablations: []
  sensitivity_analysis: []
  real_world_validation: ""
  negative_results: []
  limitations_discussed: []
```

#### 4. Research Patterns

**Extract generalizable patterns:**
- How do they decompose complex problems?
- What analogies/domaubstractions do they use?
- How do they balance theory and practice?
- What is their approach to system building?

**Extraction template:**
```yaml
research_patterns:
  problem_decomposition: ""
  abstractions_used: []
  theory_practice_balance: ""
  system_building_approach: ""
  collaboration_style: ""
  writing_style: ""
```

## Example: vLLM Paper Analysis

### Type A Extraction

```yaml
problem:
  description: "Memory inefficiency in LLM serving due to fragmentation from variable-length sequences"
  importance: "Limits batch size and throughput in production LLM serving"
  constraints: [Low latency requirements, Variable sequence lengths, Memory bandwidth bound]
  domain: "LLM inference systems"

approach:
  core_technique: "PagedAttention - block-based memory allocation for KV cache"
  components:
    - name: "Block Manager"
      purpose: "Allocate and deallocate fixed-size blocks for KV cache"
      implementation: "Reference counting with copy-on-write"
    - name: "Scheduler"
      purpose: "Continuous batching with preemption"
      implementation: "Priority-based scheduling with swapping"
  algorithms:
    - name: "PagedAttention"
      key_steps: ["Divide KV cache into fixed-size blocks", "Allocate blocks dynamically", "Share blocks via copy-on-write"]
  innovations: ["Applying virtual memory to attention", "Copy-on-write for sequence sharing"]

system:
  name: "vLLM"
  purpose: "High-throughput LLM serving system"
  architecture: "Distributed serving with centralized scheduler"
  technologies: [PyTorch, CUDA, NCCL]
  codebase: "https://github.com/vllm-project/vllm"
  deployment: "Production workloads on Azure"

evaluation:
  metrics: [Throughput, latency, memory utilization]
  baselines: [TensorRT-LLM, FasterTransformer, Orca, HuggingFace TGI]
  datasets: [ShareGPT, production workloads]
  key_results: ["2-4x throughput improvement", "Near-zero memory waste"]
  hardware: "NVIDIA A100 GPUs"
```

### Type B Extraction

```yaml
problem_identification:
  observations: ["Existing systems allocate contiguous memory for maximum sequence length", "Real workloads have variable lengths causing fragmentation", "Memory waste limits batch size"]
  prior_analysis: ["Analyzed Orca's memory management", "Studied production Azure workloads"]
  gap_identified: "No system optimizes KV cache memory layout for variable-length sequences"
  importance_justification: "Memory is the bottleneck for LLM serving economics"
  key_insight: "Internal fragmentation in KV cache is analogous to OS memory fragmentation"

solution_development:
  initial_approach: "Improve existing continuous batching"
  alternatives_considered: ["Dynamic sequence padding", "Memory compaction", "Paged allocation"]
  evolution: ["Started with compaction, too expensive", "Borrowed paging from OS", "Added copy-on-write for sharing"]
  key_breakthroughs: ["Realized KV cache can be non-contiguous", "Copy-on-write enables efficient beam search"]
  cross_domain_inspiration: "Virtual memory paging from operating systems"
  iteration_count: "Multiple prototypes over 6 months"

validation_strategy:
  experiment_design: "End-to-end serving comparison on production workloads"
  ablations: ["Block size sensitivity", "Scheduling policy comparison"]
  sensitivity_analysis: ["Varying request rates", "Different model sizes"]
  real_world_validation: "Deployed on Azure production serving"
  negative_results: ["Compaction had too much overhead", "Static allocation couldn't adapt"]
  limitations_discussed: ["Block size trade-offs", "Overhead for very short sequences"]

research_patterns:
  problem_decomposition: "Identify resource bottleneck → Analyze allocation pattern → Borrow solution from adjacent field"
  abstractions_used: ["Virtual memory paging", "Copy-on-write", "Continuous batching"]
  theory_practice_balance: "Systems paper with practical implementation and real deployment"
  system_building_approach: "Build complete end-to-end system, not just algorithm"
  collaboration_style: "Multi-institution collaboration with industry partner (Azure)"
  writing_style: "Clear problem motivation, detailed system design, comprehensive evaluation"
```

## Output: Skill Documentation

Convert extractions into agent-usable skill documentation:

```markdown
## Skill: LLM Serving System Design

**Domain**: Machine Learning Systems
**Source**: vLLM paper (SOSP 2023)

### Capabilities
- Design memory-efficient attention mechanisms
- Implement continuous batching schedulers
- Optimize KV cache management for variable-length sequences
- Build production LLM serving systems

### Techniques
1. **PagedAttention**: Block-based dynamic memory allocation
2. **Copy-on-write sharing**: Efficient beam search and parallel sampling
3. **Continuous batching**: Maximize GPU utilization

### When to Apply
- Serving LLMs with variable request lengths
- Memory-constrained inference environments
- High-throughput serving requirements

## Methodology: Systems Problem Solving

**Source**: Lianmin Zheng's research pattern

### Approach
1. **Identify bottlenecks** through workload analysis
2. **Look for analogies** in adjacent domains (e.g., OS → ML systems)
3. **Build end-to-end systems** to validate ideas
4. **Evaluate on real workloads** from production

### Strengths
- Strong systems building ability
- Cross-domain inspiration
- Production-focused evaluation
```
