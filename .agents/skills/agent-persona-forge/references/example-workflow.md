# Example Workflow: Forging Lianmin's Persona

This document demonstrates the complete workflow for creating an agent persona from https://lmzheng.net/

## Step 1: Fetch Homepage

```bash
./scripts/fetch-homepage.sh https://lmzheng.net/ ./lianmin-workspace
```

Expected homepage content:
- About: PhD student at UC Berkeley, working with Ion Stoica
- Research: ML systems, LLM serving, distributed training
- Projects: vLLM, SGLang, FastChat, LMSYS-Chat-1M

## Step 2: Paper Analysis

### Identified Papers from Homepage

1. **vLLM: Efficient Memory Management for LLM Serving** (SOSP 2023)
2. **SGLang: Efficient Execution of Structured Language Model Programs** (OSDI 2024)
3. **AlpacaEval**: Automatic evaluator for instruction-following models
4. **Chatbot Arena**: Benchmarking LLMs in the wild

### Analysis for vLLM Paper

```bash
# Download and analyze
./scripts/analyze-paper.sh "vLLM: Efficient Memory Management for LLM Serving" ./lianmin-workspace/papers

# Or by arXiv ID
./scripts/analyze-paper.sh 2309.06180 ./lianmin-workspace/papers
```

**Type A Extraction (Technical Skills):**
```yaml
skill:
  name: llm-serving-system-design
  domain: Machine Learning Systems
  problem: Memory inefficiency in LLM batching due to fragmentation
  solution: PagedAttention - dynamic memory allocation for KV cache
  techniques:
    - PagedAttention with block-based memory management
    - Continuous batching for throughput optimization
    - Copy-on-write for KV cache sharing
  systems: [vLLM]
  metrics: [Throughput, latency, memory utilization]
```

**Type B Extraction (Methodology):**
```yaml
methodology:
  problem_identification:
    - Analyzed production LLM serving workloads
    - Identified memory fragmentation as key bottleneck
    - Observed variable sequence lengths cause poor utilization
  approach:
    - Applied virtual memory paging concepts to attention
    - Designed block-based allocation instead of contiguous
    - Implemented copy-on-write for sharing across sequences
  evaluation:
    - Built end-to-end serving system (vLLM)
    - Compared against TensorRT-LLM, FasterTransformer, Orca
    - Tested on production workloads from Azure
  insights:
    - "Memory fragmentation matters more than raw capacity"
    - "Batching efficiency > single-request optimization"
    - "OS techniques can solve ML systems problems"
```

## Step 3: GitHub Project Analysis

### vLLM Project

```bash
./scripts/analyze-github.sh https://github.com/vllm-project/vllm "Lianmin Zheng" ./lianmin-workspace/projects
```

**Code Analysis:**
- Core: `vllm/` - attention backends, model executors, scheduler
- Key files:
  - `vllm/core/scheduler.py` - Continuous batching logic
  - `vllm/attention/ops/paged_attention.py` - PagedAttention kernels
  - `vllm/worker/model_runner.py` - Model execution

**Commit Pattern Analysis:**
- Initial commits: Core scheduler and memory management
- Later commits: Distributed serving, speculative decoding
- PR reviews: Focus on correctness, performance benchmarks

**Extracted Skills:**
```yaml
project_skill:
  name: vllm-contributor
  expertise_level: Core contributor and founding developer
  capabilities:
    - Design and implement LLM serving schedulers
    - Optimize CUDA kernels for attention operations
    - Build distributed inference systems
    - Write performance benchmarking frameworks
  maintenance_patterns:
    - Detailed PR descriptions with benchmark results
    - Responds to issues with debugging suggestions
    - Emphasizes reproducible performance numbers
    - Active in design discussions for new features
```

### SGLang Project

```bash
./scripts/analyze-github.sh https://github.com/sgl-project/sglang "Lianmin Zheng" ./lianmin-workspace/projects
```

**Key Observations:**
- Structured generation for LLMs
- RadixAttention for KV cache reuse
- Frontend: Python DSL for LLM programs

## Step 4: Integration

```bash
./scripts/integrate-persona.sh \
    --homepage ./lianmin-workspace/homepage.md \
    --papers-dir ./lianmin-workspace/papers \
    --projects-dir ./lianmin-workspace/projects \
    --name "Lianmin Zheng" \
    --output ./agents/lianmin/USER.md
```

## Step 5: Generate Materials Report

Generate a comprehensive report documenting all materials explored:

```bash
./scripts/generate-materials-report.sh \
    --workspace ./lianmin-workspace \
    --name "Lianmin Zheng" \
    --homepage https://lmzheng.net/ \
    --output ./lianmin-workspace/MATERIALS-REPORT.md
```

The generated report will include:

| Section | Content |
|---------|---------|
| Executive Summary | Count of papers, projects, and homepage analyzed |
| Homepage Analysis | URL, fetch date, sections analyzed |
| Papers Explored | List of papers with metadata and extracted skills |
| GitHub Projects | Repository details and commit analysis |
| Analysis Artifacts | All generated skill and methodology extractions |
| Data Quality | Coverage analysis and limitations |
| File Inventory | Complete workspace structure |

## Step 6: Final USER.md

The generated USER.md synthesizes:

1. **Background**: UC Berkeley PhD, ML systems focus, Ion Stoica's group
2. **Technical Skills**:
   - LLM serving system design (vLLM)
   - Structured LLM programming (SGLang)
   - Distributed ML systems
   - CUDA kernel optimization
3. **Methodology**:
   - Systems approach: identify bottlenecks, build end-to-end solutions
   - Production-first evaluation on real workloads
   - Combining OS concepts with ML systems
4. **Engineering**:
   - vLLM core maintainer
   - FastChat contributor
   - Benchmark and evaluation frameworks
5. **Communication**:
   - Technical depth with system diagrams
   - Benchmark-driven discussions
   - Open-source collaboration style

## Output Files

After running the full workflow:

```
lianmin-workspace/
├── homepage.md              # Fetched homepage
├── papers/
│   ├── 2309.06180.pdf      # vLLM paper
│   ├── 2309.06180_skills.md    # Type A extraction
│   ├── 2309.06180_methodology.md # Type B extraction
│   └── ...
├── projects/
│   ├── vllm/               # Cloned repo
│   ├── vllm_analysis.md    # Repository analysis
│   ├── sglang/
│   └── sglang_analysis.md
├── skills-registry.yaml    # All extracted skills
└── MATERIALS-REPORT.md     # 📋 Documentation of all explored materials

agents/lianmin/
└── USER.md                 # Final persona
```

### Materials Report Contents

The `MATERIALS-REPORT.md` provides transparency by documenting:

1. **What was analyzed** - Homepage URL, paper titles, GitHub repositories
2. **When it was accessed** - Fetch/clone dates for reproducibility
3. **What was extracted** - Skills, methodology, patterns from each source
4. **What was missing** - Inaccessible papers, private repos, paywalled content
5. **Data quality** - Coverage assessment and known limitations

This report helps users understand the basis of the persona and identify opportunities for enhancement with additional sources.
