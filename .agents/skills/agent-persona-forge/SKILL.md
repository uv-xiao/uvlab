---
name: agent-persona-forge
description: Forge a rich agent persona by analyzing a researcher's personal homepage. Extract personality traits, research expertise, and capabilities from their about section, papers, and GitHub projects. Use when you need to (1) Create a detailed USER.md for an agent based on a researcher's public profile, (2) Extract domain-specific skills from academic papers with full PDF analysis, (3) Analyze GitHub projects to capture development expertise and maintenance patterns, or (4) Build a comprehensive agent personality from multiple data sources including web pages, papers, and code repositories.
---

# Agent Persona Forge

Transform a researcher's personal homepage into a rich, capable agent persona. This skill orchestrates multiple data sources to build a comprehensive understanding of the researcher and encode it into agent configuration.

## Overview

The persona forging process extracts knowledge from three primary sources:
1. **Personal homepage** - Background, interests, research trajectory
2. **Academic papers** - Technical expertise and research methodology
3. **GitHub projects** - Engineering skills and open-source contributions

## Prerequisites

Required skills (auto-loaded when available):
- `jina-web-fetcher` or `summarize` - Web page fetching
- `arxiv-watcher` - Academic paper search and retrieval
- `pdf-extract` - Deep PDF content extraction
- `github` - GitHub API operations

## Workflow

### Phase 1: Homepage Analysis

Fetch and analyze the researcher's personal homepage:

```bash
# Fetch homepage content
/skill:jina-web-fetcher fetch <homepage_url>
```

Extract from the page:
- **About/Bio** - Background, education, career trajectory
- **Research interests** - Key domains and focus areas
- **Publications list** - Paper titles, venues, links
- **Projects** - GitHub repos, demos, tools
- **Awards/Service** - Recognition and community involvement

Create initial persona draft:
```markdown
# Agent: [Researcher Name]

## Background
[Extracted bio and trajectory]

## Research Interests
- [Domain 1]: [Specific focus]
- [Domain 2]: [Specific focus]

## Core Capabilities
[Initial capability list from about section]
```

### Phase 2: Paper Deep Dive

For each identified paper:

#### 2.1 Locate and Download PDF

```bash
# Search arXiv
/skill:arxiv-watcher search "[paper title]"

# Or search by author
/skill:arxiv-watcher search "au:[author_name]" --limit 20

# Download PDF
/skill:arxiv-watcher download [arxiv_id]
```

For non-arXiv papers:
- Check author's homepage for PDF links
- Use OpenReview, PapersWithCode, or venue proceedings
- Use web search to find accessible versions

#### 2.2 Deep PDF Analysis

Use `pdf-extract` for structured extraction:

```bash
# Extract full text with structure
/skill:pdf-extract extract --format markdown [paper.pdf]

# Extract figures and tables
/skill:pdf-extract extract --figures --tables [paper.pdf]
```

#### 2.3 Paper Skill Extraction

Extract TWO types of skills from each paper:

**Type A: Domain-Specific Technical Skills**
- What problem does the paper solve?
- What techniques/methods are introduced?
- What systems/tools are built?
- What domains does it apply to?

Example extraction:
```yaml
skill:
  name: vllm-inference-optimization
  domain: LLM serving systems
  problem: Efficient memory management for batched LLM inference
  solution: PagedAttention with dynamic memory allocation
  techniques: [PagedAttention, continuous batching, KV cache management]
  systems: [vLLM]
```

**Type B: Research Methodology Skills**
- How did the author identify the problem?
- What approach did they take to solve it?
- How did they evaluate the solution?
- What insights led to breakthroughs?

Example extraction:
```yaml
methodology:
  problem_identification: Analyzed memory fragmentation patterns in existing LLM serving systems
  approach: Applied virtual memory paging concepts to attention key-value caching
  evaluation: Built end-to-end system with production workloads, compared against TensorRT-LLM, FasterTransformer
  insights: [Traditional contiguous memory allocation is suboptimal for variable-length sequences, Batching efficiency matters more than single-request latency]
```

### Phase 3: GitHub Project Analysis

For each identified project:

#### 3.1 Repository Overview

```bash
# Clone repository
git clone --depth 100 [repo_url] /tmp/[repo_name]

# Get repo statistics
/skill:github api repos/[owner]/[repo]
```

#### 3.2 Code Analysis

Read and analyze:
- `README.md` - Project description and usage patterns
- Architecture overview - Main modules and design patterns
- Key source files - Core algorithms and implementations
- Examples/tutorials - How users interact with the project

#### 3.3 Contribution Pattern Analysis

```bash
# Get author's commits
/skill:github api repos/[owner]/[repo]/commits --author=[author_name]

# Get author's PRs and reviews
/skill:github api repos/[owner]/[repo]/pulls --creator=[author_name]
/skill:github api repos/[owner]/[repo]/issues --creator=[author_name]
```

Analyze:
- **Commit patterns** - Code organization, testing practices, documentation
- **PR style** - How they propose changes, handle feedback
- **Issue responses** - Debugging approach, user support style
- **Code review patterns** - What they focus on when reviewing

#### 3.4 Project Skill Extraction

Extract capabilities:
```yaml
project_skill:
  name: [project_name]
  expertise_level: Expert (core contributor/maintainer)
  capabilities:
    - Architecture design and system building
    - [Specific domain, e.g., CUDA kernel optimization]
    - [Specific technique, e.g., Attention mechanism implementation]
  maintenance_patterns:
    - Responds to issues with debugging suggestions
    - Reviews PRs focusing on [specific aspects]
    - Documentation-first approach to features
```

### Phase 4: Persona Integration

Synthesize all extracted information into final outputs:

#### 4.1 Create USER.md

```markdown
# [Researcher Name]

## Identity
- Role: [Position]
- Institution: [Organization]
- Research Area: [Primary domains]

## Background
[2-3 paragraphs synthesizing about section with paper/project highlights]

## Technical Expertise

### Core Domains
- [Domain 1]: [Depth and specific capabilities]
- [Domain 2]: [Depth and specific capabilities]

### Specific Capabilities
[From paper Type A extractions - technical skills]
- vLLM inference optimization with PagedAttention
- Distributed training for large language models
- [More specific capabilities...]

### Research Methodology
[From paper Type B extractions - how they approach problems]
- Systems-oriented approach with production-scale evaluation
- Identifies bottlenecks through workload analysis
- Builds end-to-end prototypes to validate ideas

### Engineering Skills
[From GitHub project analysis]
- Expert in [project 1]: [specific capabilities]
- Expert in [project 2]: [specific capabilities]
- Maintenance style: [patterns from commit/PR analysis]

## Communication Style
[Inferred from writing and interaction patterns]
- Technical depth: [level]
- Code examples: [frequency and style]
- Documentation preference: [style]

## Limitations
- Does not have access to private/behind-paywall content
- Knowledge cutoff: [date of homepage analysis]
```

#### 4.2 Create Skill Registry

Document all extracted skills for potential individual skill creation:

```yaml
# skills-registry.yaml
extracted_skills:
  - name: vllm-system-design
    source: "vLLM: Efficient Memory Management for LLM Serving"
    type: technical
    description: Design and optimize LLM serving systems using PagedAttention
    
  - name: distributed-training-optimization
    source: "[Paper name]"
    type: technical
    description: Optimize distributed training for large models
    
  - name: systems-problem-identification
    source: Multiple papers
    type: methodology
    description: Identify performance bottlenecks in ML systems through workload analysis
```

## Execution Scripts

Use the provided scripts for automation:

### `scripts/fetch-homepage.sh`
Fetch and parse a homepage:
```bash
./scripts/fetch-homepage.sh <homepage_url>
```

### `scripts/analyze-paper.sh`
Download and analyze a paper:
```bash
./scripts/analyze-paper.sh <paper_url_or_arxiv_id>
```

### `scripts/analyze-github.sh`
Clone and analyze a GitHub repository:
```bash
./scripts/analyze-github.sh <repo_url> [author_name]
```

### `scripts/integrate-persona.sh`
Generate final USER.md from extracted data:
```bash
./scripts/integrate-persona.sh --papers-dir ./papers --projects-dir ./projects --output ./USER.md
```

## Quality Checklist

Before finalizing the persona:

- [ ] Homepage fully parsed (about, research, projects)
- [ ] All papers with available PDFs analyzed
- [ ] PDF analysis includes both technical skills and methodology
- [ ] GitHub projects cloned and code reviewed
- [ ] Commit/PR patterns analyzed for maintenance style
- [ ] USER.md synthesizes all sources coherently
- [ ] Communication style inferred from available content
- [ ] Limitations clearly documented

## Example Usage

```
Forge a persona for agent "lianmin" from https://lmzheng.net/

Process:
1. Fetch homepage and extract about, research, projects
2. For each paper on the page:
   - Search arXiv for PDF
   - Deep read and extract technical + methodology skills
3. For each GitHub project:
   - Clone and analyze codebase
   - Analyze commit/PR patterns
4. Generate USER.md and skill registry
```

## Notes

- Paper PDFs may require manual download for non-arXiv venues
- Some GitHub repos may be private or archived
- The goal is rich persona extraction, not perfect reproduction
- Focus on capabilities that make the agent useful for relevant tasks
