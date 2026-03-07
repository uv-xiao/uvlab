# AI Infra Learning Plan - OpenClaw Automation Setup

> **Setup Date:** 2026-03-07  
> **Repository:** https://github.com/uv-xiao/ainfra  
> **Agents:** jarvis, lianmin, tianqi, zihao, tri

---

## 📋 Overview

This setup automates the AI Infrastructure learning plan with three daily workflows:

1. **20:00** - Daily learning notification with today's topic
2. **20:05** - Expert consultation request to the day's assigned expert
3. **24:00** - End-of-day summary with progress sync

---

## 🗂️ Files Created

### 1. Cron Jobs Configuration
**File:** `~/.openclaw/cron/jobs.json`

Three scheduled jobs:
| Time | Job | Description |
|------|-----|-------------|
| 20:00 | `daily-learning-notification` | Send daily briefing to Feishu group |
| 20:05 | `expert-consultation-request` | Message expert for suggestions |
| 00:00 | `end-of-day-summary` | Summarize progress and sync repo |

### 2. Automation Scripts
**Location:** `~/.openclaw/agents/jarvis/workspace/scripts/`

| Script | Purpose | Config Source |
|--------|---------|---------------|
| `daily-learning-notify.sh` | Generate daily notification message | `LEARNING_CONFIG.json` |
| `expert-consultation.sh` | Build expert consultation request | `LEARNING_CONFIG.json` |
| `eod-summary.sh` | Check git updates, summarize, auto-push | `LEARNING_CONFIG.json` |

**Configuration:** All scripts read from `LEARNING_CONFIG.json` which includes:
- Feishu group ID: `oc_922c749fb51de36a68f7b2f50eed20af`
- Repository URL and local path
- Expert definitions
- Schedule settings

**Note:** Scripts are stored in Jarvis's workspace since they are his responsibility.

### 3. Learning Schedule & Configuration
**Files:** 
- `~/.openclaw/agents/jarvis/workspace/LEARNING_SCHEDULE.md` - 30-day schedule
- `~/.openclaw/agents/jarvis/workspace/LEARNING_CONFIG.json` - Centralized configuration

**LEARNING_SCHEDULE.md includes:**
- Daily topics and focus areas
- Expert assignments
- Progress tracking checkboxes
- Notification templates

**LEARNING_CONFIG.json includes:**
- **Feishu group ID:** `oc_922c749fb51de36a68f7b2f50eed20af`
- Repository settings (URL, local path, branch)
- Expert definitions (names, emojis, expertise, keywords)
- Schedule settings (timezone, notification times)

### 4. Agent Configuration Updates

**Jarvis AGENTS.md** - Added:
- Learning plan automation section
- Expert rotation schedule
- User command reference
- Script usage instructions

**Jarvis SOUL.md** - Added:
- Learning plan management responsibilities
- Daily task workflow
- Expert mapping
- Key files to read

---

## 🎯 Expert Mapping

| Week | Focus Area | Expert | Agent ID |
|------|------------|--------|----------|
| Week 1 | GPU Fundamentals & Profiling | Zihao Ye | `zihao` |
| Week 2 | Kernel Engineering | Zihao/Tri | `zihao` / `tri` |
| Week 3 | LLM Serving | Lianmin Zheng | `lianmin` |
| Week 4 | Training & RL Infrastructure | Lianmin/Tianqi | `lianmin` / `tianqi` |

### Expert Specialties
- **lianmin** - LLM Serving, SGLang, vLLM, FastChat
- **tianqi** - ML Compilers, TVM, XGBoost, MLC-LLM
- **zihao** - GPU Kernels, CUDA, FlashInfer, Triton
- **tri** - Attention, FlashAttention, State Space Models

---

## 🚀 How It Works

### Daily Workflow (20:00)

```
┌─────────────────────────────────────────────────────────────┐
│  20:00  Cron triggers daily-learning-notification          │
│         ↓                                                   │
│  Jarvis runs: ~/.openclaw/scripts/daily-learning-notify.sh │
│         ↓                                                   │
│  Reads LEARNING_SCHEDULE.md for today's topic              │
│         ↓                                                   │
│  Sends Feishu message with:                                │
│  • Today's topic                                           │
│  • Focus area                                              │
│  • Assigned expert                                         │
│  • Tasks to complete                                       │
└─────────────────────────────────────────────────────────────┘
```

### Expert Consultation (20:05)

```
┌─────────────────────────────────────────────────────────────┐
│  20:05  Cron triggers expert-consultation-request          │
│         ↓                                                   │
│  Jarvis runs: ~/.openclow/scripts/expert-consultation.sh   │
│         ↓                                                   │
│  Uses sessions_send to message today's expert              │
│         ↓                                                   │
│  Expert receives request with:                             │
│  • Today's topic                                           │
│  • Request for key concepts                                │
│  • Request for common pitfalls                             │
│  • Request for resources                                   │
│  • Request for exercise suggestion                         │
└─────────────────────────────────────────────────────────────┘
```

### End-of-Day Summary (00:00)

```
┌─────────────────────────────────────────────────────────────┐
│  00:00  Cron triggers end-of-day-summary                   │
│         ↓                                                   │
│  Jarvis runs: ~/.openclaw/scripts/eod-summary.sh           │
│         ↓                                                   │
│  1. Syncs local repo: ~/.openclaw/repos/ainfra             │
│  2. Checks for commits from yesterday                      │
│  3. Counts notes and exercises                             │
│  4. Auto-commits local changes if any                      │
│  5. Sends summary to Feishu group                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 💬 User Commands

When you receive daily notifications, reply with:

| Command | Action |
|---------|--------|
| `done` | Mark today's topic as complete |
| `question: [text]` | Forward question to today's expert |
| `skip` | Reschedule today's topic |
| `progress` | Show current progress statistics |
| `tomorrow` | Preview next day's topic |

---

## 🛠️ Manual Testing

To test the setup before the scheduled times:

### Test Daily Notification
```bash
# Generate notification message
cd ~/.openclaw/agents/jarvis/workspace
./scripts/daily-learning-notify.sh

# Expected output: Formatted message with today's topic
```

### Test Expert Consultation
```bash
# Generate expert request
cd ~/.openclaw/agents/jarvis/workspace
./scripts/expert-consultation.sh

# Expected output: Message for today's expert
```

### Test EOD Summary
```bash
# Generate summary (reads yesterday's data)
cd ~/.openclaw/agents/jarvis/workspace
./scripts/eod-summary.sh

# Expected output: Progress summary and git status
```

---

## 🔧 Customization

### Change Notification Time
Edit `~/.openclaw/cron/jobs.json`:
```json
"expression": "0 9 * * *"  // Change from 20:00 to 9:00
```

### Change Expert Assignment
Edit `~/.openclaw/agents/jarvis/workspace/LEARNING_SCHEDULE.md`:
```markdown
| 15 | 2026-03-21 | SGLang Architecture | Serving | lianmin |
                                                        ^^^^^^^
                                                        Change this
```

### Add New Topics
1. Edit `LEARNING_SCHEDULE.md`
2. Add row to the schedule table
3. Assign appropriate expert

---

## 📊 Progress Tracking

Progress is tracked in multiple ways:

1. **LEARNING_SCHEDULE.md** - Checkboxes for each day
2. **Git commits** - Count commits per day
3. **File counts** - Number of notes and exercises
4. **Repository updates** - Daily sync and push

---

## 🔄 Restart OpenClaw

After any configuration changes:

```bash
# Restart the gateway
openclaw gateway restart

# Or reload cron jobs (if supported)
openclaw cron reload

# Check status
openclaw gateway status
openclaw logs --follow
```

---

## 🐛 Troubleshooting

### Jobs Not Running
1. Check OpenClaw is running: `openclaw gateway status`
2. Verify cron config: `cat ~/.openclaw/cron/jobs.json`
3. Check logs: `openclaw logs`

### Scripts Not Found
```bash
# Ensure scripts are executable
chmod +x ~/.openclaw/scripts/*.sh
```

### Expert Not Responding
- Ensure expert agent is properly configured in `openclaw.json`
- Check Feishu bot is added to the group
- Verify agent workspace exists

### Git Sync Issues
```bash
# Manually test repo sync
cd ~/.openclaw/repos/ainfra
git status
git pull origin main
```

---

## 📚 Related Documentation

- [Repository README](https://github.com/uv-xiao/ainfra/blob/main/README.md)
- [Learning Roadmap](https://github.com/uv-xiao/ainfra/blob/main/docs/plans/2026-03-06-ai-infra-roadmap.md)
- [Jarvis AGENTS.md](./agents/jarvis/workspace/AGENTS.md)
- [Learning Schedule](./agents/jarvis/workspace/LEARNING_SCHEDULE.md)

---

## ✅ Setup Checklist

- [x] Cron jobs configured
- [x] Automation scripts created
- [x] Learning schedule defined
- [x] Expert mapping configured
- [x] Jarvis documentation updated
- [x] Repository cloned locally
- [x] Scripts made executable
- [ ] Test notifications manually
- [ ] Verify Feishu group ID
- [ ] Restart OpenClaw gateway

---

*Happy Learning! 🚀*
