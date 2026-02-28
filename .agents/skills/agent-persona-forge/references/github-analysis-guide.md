# GitHub Project Analysis Guide

Deep guide for extracting engineering expertise from GitHub repositories.

## Analysis Dimensions

### 1. Codebase Understanding

#### Architecture Analysis
- **Entry points**: Main modules, CLI interfaces, API endpoints
- **Core components**: Key classes, modules, subsystems
- **Data flow**: How data moves through the system
- **Dependencies**: External libraries and frameworks

#### Implementation Quality
- **Code organization**: Module structure, naming conventions
- **Testing**: Test coverage, testing patterns
- **Documentation**: Code comments, docstrings, README quality
- **Type safety**: Type hints, interfaces

### 2. Contribution Pattern Analysis

#### Commit Analysis
```bash
# Get commit history by author
git log --author="Author Name" --pretty=format:"%h %s" --reverse

# Analyze commit types
git log --author="Author Name" --pretty=format:"%s" | grep -E "^(feat|fix|docs|test|refactor|perf)"
```

**Extract patterns:**
- **Commit frequency**: Active development periods
- **Commit size**: Small focused changes vs. large refactors
- **Commit messages**: Descriptive patterns, issue references
- **Code areas**: Which parts of codebase they touch most

#### PR Analysis
Using GitHub API:
```bash
# List PRs by author
gh pr list --author="username" --state all --limit 100

# Get PR details
gh pr view <number> --json title,body,additions,deletions,comments
```

**Extract patterns:**
- **PR description style**: Detailed vs. brief, what information included
- **Review engagement**: How they respond to feedback
- **Code review focus**: Performance, correctness, style, architecture
- **Collaboration style**: Assertive vs. consensus-building

#### Issue Analysis
```bash
# Issues created by author
gh issue list --author="username" --state all

# Issues commented on by author
gh api repos/{owner}/{repo}/issues --paginate | jq '.[] | select(.user.login == "username")'
```

**Extract patterns:**
- **Issue reporting**: Bug reports, feature requests, questions
- **Debugging approach**: How they diagnose problems
- **User support**: Helping others, documentation references
- **Communication tone**: Technical depth, patience level

### 3. Technical Expertise Extraction

#### Domain Knowledge
From code analysis:
- **Algorithms implemented**: What complex algorithms do they write?
- **Optimizations**: Performance tuning, low-level optimizations
- **Design patterns**: Architectural decisions, abstractions
- **Technology mastery**: Deep usage of specific frameworks/libraries

#### Engineering Practices
- **Testing philosophy**: Unit tests, integration tests, benchmarks
- **Documentation habits**: Inline docs, examples, tutorials
- **Code review standards**: What they care about in reviews
- **Refactoring patterns**: Code improvement strategies

## Analysis Workflow

### Step 1: Repository Overview

```bash
# Clone and analyze structure
git clone --depth 100 <repo_url>
cd <repo>

# Get structure
tree -L 3 -d
find . -name "*.py" | head -20

# Get README
cat README.md | head -100
```

**Document:**
- Project purpose and scope
- Main technologies used
- Architecture overview
- Key directories

### Step 2: Author's Code Contributions

```bash
# Find files modified by author
git log --author="Author Name" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20

# Get first commit (founding contributor?)
git log --author="Author Name" --reverse --pretty=format:"%h %ai %s" | head -5

# Get recent activity
git log --author="Author Name" --since="6 months ago" --oneline
```

**Document:**
- Key files/modules they own
- Contribution timeline
- Current activity level

### Step 3: Deep Code Reading

Read and analyze key files:

1. **Core algorithm files** - Their technical contributions
2. **Design docs/ADRs** - Architecture decisions
3. **Test files** - Testing philosophy
4. **Configuration/setup** - System design understanding

**Documentation template:**
```markdown
### Code Analysis: [filename]

**Purpose**: What this code does
**Key contributions by [author]**:
- [Specific implementation detail]
- [Algorithm choice]
- [Optimization technique]

**Technical depth demonstrated**:
- [Deep knowledge area 1]
- [Deep knowledge area 2]

**Code quality**:
- [Testing approach]
- [Documentation quality]
- [Design patterns used]
```

### Step 4: Collaboration Pattern Analysis

```bash
# PRs authored
gh pr list --author="username" --state merged --limit 50

# PRs reviewed
gh pr list --reviewed-by="username" --state merged --limit 50

# Issue comments
gh api repos/{owner}/{repo}/issues/comments --paginate | jq '.[] | select(.user.login == "username")'
```

**Document interaction style:**
```markdown
### Collaboration Pattern: [author] in [repo]

**PR style**:
- Description detail: [High/Medium/Low]
- Includes benchmarks: [Yes/No]
- Includes tests: [Yes/No]
- Response to feedback: [Pattern]

**Code review focus**:
- Performance: [High/Medium/Low]
- Correctness: [High/Medium/Low]
- Style/naming: [High/Medium/Low]
- Architecture: [High/Medium/Low]

**Communication tone**:
- Technical depth: [Deep/Moderate/Basic]
- Teaching orientation: [High/Medium/Low]
- Directness: [Direct/Diplomatic]
```

## Example: vLLM Project Analysis

### Repository Overview

```
vllm/
├── vllm/                    # Main package
│   ├── core/               # Scheduler, block manager
│   ├── attention/          # Attention backends
│   ├── worker/             # Model execution
│   ├── engine/             # LLM engine
│   └── model_executor/     # Model loading
├── tests/                   # Test suite
├── benchmarks/              # Performance benchmarks
└── examples/                # Usage examples
```

### Lianmin's Contributions

**Key files (from git log):**
- `vllm/core/scheduler.py` - Continuous batching
- `vllm/core/block_manager.py` - PagedAttention
- `vllm/attention/` - Attention kernels

**Commit pattern:**
```
Early commits:
- Initial scheduler implementation
- Block manager with reference counting
- PagedAttention CUDA kernels

Recent commits:
- Distributed serving architecture
- Speculative decoding support
- Performance optimizations
```

### Technical Expertise Extracted

```yaml
expertise:
  domain: LLM serving systems
  
  core_capabilities:
    - Design and implement distributed inference schedulers
    - Optimize CUDA kernels for attention operations
    - Build memory management systems for GPU
    - Implement continuous batching algorithms
    
  technical_depth:
    - CUDA programming: Expert (custom kernels)
    - PyTorch internals: Advanced (distributed)
    - ML compilers: Knowledgeable (Triton kernels)
    - Network protocols: Knowledgeable (NCCL)
    
  engineering_practices:
    - Testing: Unit tests for core components, integration tests
    - Benchmarking: Comprehensive performance benchmarks
    - Documentation: Detailed PR descriptions with numbers
    - Code review: Focus on correctness and performance
    
  collaboration_style:
    - PR_descriptions: Detailed with benchmark results
    - Review_comments: Technical, focused on performance
    - Issue_responses: Debugging guidance, reproduction steps
    - Design_discussions: Data-driven, benchmark-backed
```

## Output: Engineering Skills Documentation

```markdown
## Engineering Skill: vLLM System Development

**Expertise Level**: Core contributor and architect

### Capabilities
- Architect distributed LLM serving systems
- Implement CUDA kernels for attention optimization
- Design memory-efficient batching schedulers
- Build production-grade ML infrastructure

### Technical Stack
- **Core**: Python, PyTorch, CUDA
- **Distributed**: Ray, NCCL, Megatron-LM
- **Optimization**: Triton, CUTLASS
- **Infrastructure**: Docker, Kubernetes

### Development Approach
- Benchmark-driven development
- Extensive testing for correctness
- Performance-first optimization
- Clear documentation and examples

### When to Consult
- LLM serving architecture questions
- CUDA kernel optimization
- Distributed training/inference
- Memory optimization for GPU workloads
```
