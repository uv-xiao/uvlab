# AI Infra Learning Schedule

> Auto-generated from repository: https://github.com/uv-xiao/ainfra
> This file is used by Jarvis for daily notifications and expert routing.

## Expert Mapping

| Expert | Agent ID | Expertise Areas | Keywords |
|--------|----------|-----------------|----------|
| **Lianmin Zheng** | lianmin | LLM Serving, SGLang, Distributed Training | serving, sglang, vllm, fastchat, alpa, distributed, inference |
| **Tianqi Chen** | tianqi | ML Compilers, TVM, XGBoost | compiler, tvm, xgboost, mxnet, mlc-llm, optimization, schedule |
| **Zihao Ye** | zihao | GPU Kernels, CUDA, FlashInfer | kernel, cuda, flashinfer, triton, cutlass, cute, gpu, memory |
| **Tri Dao** | tri | Attention, FlashAttention, Algorithms | flashattention, attention, ssm, mamba, algorithm, linear attention |

## Four-Week Schedule

### Week 1: GPU Fundamentals and Profiling (Days 1-7)

| Day | Date | Topic | Focus Area | Assigned Expert |
|-----|------|-------|------------|-----------------|
| 1 | 2026-03-07 | CUDA Programming Basics | GPU Architecture | zihao |
| 2 | 2026-03-08 | GPU Memory Hierarchy | Memory Optimization | zihao |
| 3 | 2026-03-09 | Occupancy and Performance Modeling | Performance Analysis | zihao |
| 4 | 2026-03-10 | Profiling with Nsight | Profiling Tools | zihao |
| 5 | 2026-03-11 | Triton Basics | Kernel Framework | zihao |
| 6 | 2026-03-12 | CUDA Exercises Practice | Hands-on | zihao |
| 7 | 2026-03-13 | Week 1 Review | Review | zihao |

### Week 2: Kernel Engineering (Days 8-14)

| Day | Date | Topic | Focus Area | Assigned Expert |
|-----|------|-------|------------|-----------------|
| 8 | 2026-03-14 | FlashAttention Deep Dive | Attention Kernels | tri |
| 9 | 2026-03-15 | FlashInfer Architecture | LLM Kernels | zihao |
| 10 | 2026-03-16 | Cutlass/Cute Basics | NVIDIA Templates | zihao |
| 11 | 2026-03-17 | Kernel Optimization Patterns | Optimization | zihao |
| 12 | 2026-03-18 | Implement Simplified Kernel | Hands-on | zihao |
| 13 | 2026-03-19 | Profiling Kernel Performance | Analysis | zihao |
| 14 | 2026-03-20 | Week 2 Review | Review | zihao |

### Week 3: LLM Serving (Days 15-21)

| Day | Date | Topic | Focus Area | Assigned Expert |
|-----|------|-------|------------|-----------------|
| 15 | 2026-03-21 | SGLang Architecture | Serving Framework | lianmin |
| 16 | 2026-03-22 | Request Flow and Scheduling | Scheduling | lianmin |
| 17 | 2026-03-23 | KV Cache Management | Memory Management | lianmin |
| 18 | 2026-03-24 | Batching Strategies | Throughput | lianmin |
| 19 | 2026-03-25 | Mooncake and LMCache | Caching Systems | lianmin |
| 20 | 2026-03-26 | Serving System Tradeoffs | Design Decisions | lianmin |
| 21 | 2026-03-27 | Week 3 Review | Review | lianmin |

### Week 4: Training and RL Infrastructure (Days 22-30)

| Day | Date | Topic | Focus Area | Assigned Expert |
|-----|------|-------|------------|-----------------|
| 22 | 2026-03-28 | Training Framework Basics | Distributed Training | tianqi |
| 23 | 2026-03-29 | Slime Architecture | RL Framework | lianmin |
| 2026-03-30 | AReal System Design | RL Infrastructure | lianmin |
| 25 | 2026-03-31 | Distributed Training Patterns | Parallelism | tianqi |
| 26 | 2026-04-01 | Runtime Requirements | System Design | tianqi |
| 27 | 2026-04-02 | Profiling Training Workloads | Analysis | tianqi |
| 28 | 2026-04-03 | End-to-End Exercise | Hands-on | lianmin |
| 29 | 2026-04-04 | Review Weak Areas | Review | (rotating) |
| 30 | 2026-04-05 | Final Interview Prep | Preparation | (rotating) |

## Daily Notification Template

```
🎯 Daily Learning Reminder - {{DATE}}

📚 Today's Topic: {{TOPIC}}
🔬 Focus Area: {{FOCUS}}
👨‍🏫 Expert Advisor: {{EXPERT_NAME}} ({{EXPERT_AGENT_ID}})

📋 What to do today:
1. Read the roadmap: docs/plans/2026-03-06-ai-infra-roadmap.md
2. Create notes from template: notes/templates/topic-note.md
3. Complete exercises: exercises/templates/exercise.md
4. Update progress in this schedule

🔗 Repository: https://github.com/uv-xiao/ainfra

💬 Expert {{EXPERT_NAME}} will provide detailed suggestions shortly!

Reply "done" when you finish, or "question: [your question]" if you need help.
```

## Expert Consultation Template

```
@{{EXPERT_AGENT_ID}} 

Hi {{EXPERT_NAME}}, today's learning topic is "{{TOPIC}}" ({{FOCUS}}).

As our expert in {{EXPERTISE}}, could you provide:
1. Key concepts to focus on
2. Common pitfalls to avoid
3. Recommended resources or papers
4. One hands-on exercise suggestion

The user is preparing for AI infrastructure interviews. Please give detailed, practical advice!
```

## Progress Tracking

- [ ] Week 1: GPU Fundamentals and Profiling
  - [ ] Day 1: CUDA Programming Basics
  - [ ] Day 2: GPU Memory Hierarchy
  - [ ] Day 3: Occupancy and Performance Modeling
  - [ ] Day 4: Profiling with Nsight
  - [ ] Day 5: Triton Basics
  - [ ] Day 6: CUDA Exercises Practice
  - [ ] Day 7: Week 1 Review

- [ ] Week 2: Kernel Engineering
  - [ ] Day 8: FlashAttention Deep Dive
  - [ ] Day 9: FlashInfer Architecture
  - [ ] Day 10: Cutlass/Cute Basics
  - [ ] Day 11: Kernel Optimization Patterns
  - [ ] Day 12: Implement Simplified Kernel
  - [ ] Day 13: Profiling Kernel Performance
  - [ ] Day 14: Week 2 Review

- [ ] Week 3: LLM Serving
  - [ ] Day 15: SGLang Architecture
  - [ ] Day 16: Request Flow and Scheduling
  - [ ] Day 17: KV Cache Management
  - [ ] Day 18: Batching Strategies
  - [ ] Day 19: Mooncake and LMCache
  - [ ] Day 20: Serving System Tradeoffs
  - [ ] Day 21: Week 3 Review

- [ ] Week 4: Training and RL Infrastructure
  - [ ] Day 22: Training Framework Basics
  - [ ] Day 23: Slime Architecture
  - [ ] Day 24: AReal System Design
  - [ ] Day 25: Distributed Training Patterns
  - [ ] Day 26: Runtime Requirements
  - [ ] Day 27: Profiling Training Workloads
  - [ ] Day 28: End-to-End Exercise
  - [ ] Day 29: Review Weak Areas
  - [ ] Day 30: Final Interview Prep

## Last Updated
2026-03-07
