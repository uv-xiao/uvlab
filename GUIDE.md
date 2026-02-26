# UV Lab Setup Guide

Complete guide for setting up UV Lab multi-agent research environment.

> 📖 **Based on** [jungeAGI's detailed walkthrough](https://x.com/jungeAGI/status/2024791301783503083) of building a 12-agent AI team with OpenClaw and Feishu.
>
> This guide incorporates real-world pitfalls and solutions from production deployment.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [OpenClaw Configuration](#openclaw-configuration)
4. [Feishu Bot Configuration](#feishu-bot-configuration)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Linux/macOS system
- Git installed
- Feishu account (for bot integration)
- OpenClaw installed (`npm install -g openclaw` or via package manager)

---

## Installation

### 1. Clone the Repository

```bash
# Clone to ~/.openclaw (standard OpenClaw location)
git clone https://github.com/uv-xiao/uvlab.git ~/.openclaw

cd ~/.openclaw
```

### 2. Verify Directory Structure

You should see:

```
~/.openclaw/
├── .git/                       # Repository
├── .gitignore                  # Excludes runtime files
├── GUIDE.md                    # This file
├── README.md                   # Project documentation
├── agents/                     # All agent workspaces
│   ├── jarvis/workspace/       # Lab director
│   ├── lianmin/workspace/      # LLM serving expert
│   ├── tianqi/workspace/       # ML systems expert
│   ├── tri/workspace/          # Attention expert
│   └── zihao/workspace/        # Kernel expert
└── openclaw.json               # Your configuration (created below)
```

---

## OpenClaw Configuration

Create or edit `~/.openclaw/openclaw.json`:

```json
{
  "meta": {
    "lastTouchedVersion": "2026.2.24"
  },
  "models": {
    "mode": "merge",
    "providers": {
      "generic": {
        "baseUrl": "YOUR_API_ENDPOINT",
        "apiKey": "YOUR_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "your-model-id",
            "name": "Your Model Name",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 128000,
            "maxTokens": 4096
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "workspace": "/home/USERNAME/.openclaw/agents/jarvis/workspace",
      "compaction": { "mode": "safeguard" },
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 },
      "model": { "primary": "generic/your-model-id" }
    },
    "list": [
      {
        "id": "jarvis",
        "default": true,
        "workspace": "/home/USERNAME/.openclaw/agents/jarvis/workspace",
        "sandbox": { "mode": "off" }
      },
      {
        "id": "lianmin",
        "workspace": "/home/USERNAME/.openclaw/agents/lianmin/workspace",
        "sandbox": { "mode": "off" }
      },
      {
        "id": "tianqi",
        "workspace": "/home/USERNAME/.openclaw/agents/tianqi/workspace",
        "sandbox": { "mode": "off" }
      },
      {
        "id": "zihao",
        "workspace": "/home/USERNAME/.openclaw/agents/zihao/workspace",
        "sandbox": { "mode": "off" }
      },
      {
        "id": "tri",
        "workspace": "/home/USERNAME/.openclaw/agents/tri/workspace",
        "sandbox": { "mode": "off" }
      }
    ]
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "accounts": {
        "jarvis": {
          "appId": "YOUR_JARVIS_APP_ID",
          "appSecret": "YOUR_JARVIS_APP_SECRET"
        },
        "lianmin": {
          "appId": "YOUR_LIANMIN_APP_ID",
          "appSecret": "YOUR_LIANMIN_APP_SECRET"
        },
        "tianqi": {
          "appId": "YOUR_TIANQI_APP_ID",
          "appSecret": "YOUR_TIANQI_APP_SECRET"
        },
        "zihao": {
          "appId": "YOUR_ZIHAO_APP_ID",
          "appSecret": "YOUR_ZIHAO_APP_SECRET"
        },
        "tri": {
          "appId": "YOUR_TRI_APP_ID",
          "appSecret": "YOUR_TRI_APP_SECRET"
        }
      }
    }
  },
  "bindings": [
    { "agentId": "jarvis", "match": { "channel": "feishu", "accountId": "jarvis" } },
    { "agentId": "lianmin", "match": { "channel": "feishu", "accountId": "lianmin" } },
    { "agentId": "tianqi", "match": { "channel": "feishu", "accountId": "tianqi" } },
    { "agentId": "zihao", "match": { "channel": "feishu", "accountId": "zihao" } },
    { "agentId": "tri", "match": { "channel": "feishu", "accountId": "tri" } }
  ],
  "tools": {
    "agentToAgent": {
      "enabled": true,
      "allow": ["jarvis", "lianmin", "tianqi", "zihao", "tri"]
    },
    "sessions": {
      "visibility": "all"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "YOUR_SECURE_RANDOM_TOKEN"
    }
  }
}
```

### Configuration Notes

Replace the following placeholders:

| Placeholder | Description |
|-------------|-------------|
| `USERNAME` | Your system username |
| `YOUR_API_ENDPOINT` | LLM API base URL (e.g., OpenAI, DashScope, etc.) |
| `YOUR_API_KEY` | Your API key for the LLM provider |
| `your-model-id` | Model identifier (e.g., `gpt-4`, `qwen-max`, etc.) |
| `YOUR_FEISHU_APP_ID` | From Feishu app console |
| `YOUR_FEISHU_APP_SECRET` | From Feishu app console |
| `YOUR_SECURE_RANDOM_TOKEN` | Generate with `openssl rand -hex 32` |

---

## Feishu Bot Configuration

> **⚠️ Critical Setup Steps** (Based on [jungeAGI's experience](https://x.com/jungeAGI/status/2024791301783503083))
>
> Missing any of these will cause bots to fail silently!

### Step 1: Create Feishu Apps

For each agent, create a separate Feishu app:

1. Go to [Feishu Open Platform](https://open.feishu.cn/)
2. Click "Create Custom App"
3. Create 5 apps with these names:
   - `UV Lab - Jarvis`
   - `UV Lab - Lianmin`
   - `UV Lab - Tianqi`
   - `UV Lab - Zihao`
   - `UV Lab - Tri`

### Step 2: Critical Configuration (Easy to Miss!)

For each app, you **MUST** complete ALL of these steps:

#### 2.1 Enable Bot Capability (机器人能力)

1. Go to "Bot" tab (机器人)
2. Click "Enable Bot" (启用机器人)
3. Set bot name and avatar

#### 2.2 Event Subscription - Long Connection (长连接事件订阅) ⚠️

**This is commonly missed!** Without this, your bot won't receive messages.

1. Go to "Event Subscriptions" (事件订阅)
2. Select **"Long Connection"** (长连接) mode
   - NOT webhook/callback mode
3. Subscribe to these events:
   - ✅ `im.message.receive_v1` - Receive messages
   - ✅ `im.message.p2p_msg` - Private messages
   - ✅ `im.message.group_msg` - Group messages

#### 2.3 Credentials

1. Go to "Credentials & Basic Info" (凭证与基础信息)
2. Note down:
   - **App ID** → Use in `openclaw.json` `channels.feishu.accounts.{id}.appId`
   - **App Secret** → Use in `openclaw.json` `channels.feishu.accounts.{id}.appSecret`

#### 2.4 Permissions

Grant these permissions:

- ✅ `im:chat:readonly` - Read group info
- ✅ `im:message:send` - Send messages
- ✅ `im:message.group_msg` - Receive group messages
- ✅ `im:message.p2p_msg` - Receive private messages

### Step 3: Publish Apps

1. Go to "Version Management" (版本管理与发布)
2. Create a version
3. Set availability:
   - "Only members of the current organization" (for testing)
4. Submit for approval

**⚠️ Note**: Apps must be published and approved before they can be added to groups!

### Step 4: Add Bots to Groups

1. Create Feishu groups for testing
2. Add the corresponding bot to each group via "Add Bot" (添加机器人)
3. Or search for bot names to DM them directly

---

## Critical Configuration Details

### Workspace Isolation

Each agent **MUST** have its own workspace directory. This is crucial for memory isolation.

```
~/.openclaw/
├── agents/
│   ├── jarvis/workspace/      ← Jarvis's memory & files
│   ├── lianmin/workspace/     ← Lianmin's memory & files
│   ├── tianqi/workspace/     ← Tianqi's memory & files
│   └── ...                   
```

**Never share workspaces between agents!** Each agent has:
- Independent `SOUL.md` (personality)
- Independent `MEMORY.md` (conversation history)
- Independent `skills/` (specialized tools)

### AGENTS.md Team Member List

Each agent's `AGENTS.md` **MUST** include a team member list. Without this, agents won't know each other exists!

**Example for Jarvis (`agents/jarvis/workspace/AGENTS.md`):**

```markdown
## UV Lab Team Members

| Agent | Role | Expertise | Contact |
|-------|------|-----------|---------|
| **jarvis** | Lab Director | Coordination, strategy | Default agent |
| **lianmin** | Serving Expert | LLM serving, SGLang, compilers | `sessions_send({agentId: "lianmin"})` |
| **tianqi** | ML Systems Expert | Training, TVM, XGBoost | `sessions_send({agentId: "tianqi"})` |
| **zihao** | Kernel Expert | CUDA, FlashInfer, deployment | `sessions_send({agentId: "zihao"})` |
| **tri** | Attention Expert | Flash Attention, algorithms | `sessions_send({agentId: "tri"})` |

Use `sessions_send` to collaborate with team members.
```

**Each agent needs this list!** Copy the relevant section to every agent's `AGENTS.md`.

### SOUL.md Personality

Each agent should have a well-crafted `SOUL.md` file defining their personality:

**Example (`agents/lianmin/workspace/SOUL.md`):**

```markdown
# Lianmin - LLM Systems Expert

You are Lianmin, inspired by the work on SGLang and FastChat.

## Personality
- Systematic and performance-conscious
- Production-minded: code that ships
- Clear communicator

## Working Style
1. Analyze requirements thoroughly
2. Design for scalability
3. Implement with clear documentation
4. Benchmark and optimize
```

---

## Verification

### 1. Test OpenClaw Configuration

```bash
# Validate JSON syntax
openclaw config validate

# List configured agents
openclaw agents list

# List bindings
openclaw agents list --bindings
```

### 2. Start/Stop/Restart OpenClaw Gateway

OpenClaw runs as a **Gateway service** that manages connections to chat platforms and AI models.

```bash
# Start the Gateway service
openclaw gateway start

# Check Gateway status
openclaw gateway status

# Stop the Gateway
openclaw gateway stop

# Restart Gateway (use after config changes)
openclaw gateway restart

# View live logs
openclaw logs --follow
```

**After configuration changes:** Always restart the Gateway:
```bash
openclaw gateway restart
```

### 3. Test Agent Connectivity

Send test messages to each bot:

| Bot | Test Message | Expected Response |
|-----|--------------|-------------------|
| Jarvis | "Hello, who are you?" | Introduction as Lab Director |
| Lianmin | "What's SGLang?" | Explanation of serving systems |
| Tianqi | "Explain XGBoost" | Explanation of boosting |
| Zihao | "CUDA optimization tips" | Kernel optimization advice |
| Tri | "Flash Attention paper summary" | Attention mechanism explanation |

### 4. Test Cross-Agent Communication

If `agentToAgent` is enabled:

1. Message Lianmin: "Ask Zihao about CUDA kernels for serving"
2. Lianmin should be able to send message to Zihao

---

## Troubleshooting

### 🚨 Critical: Bot Not Responding (Most Common)

**Symptom**: Bot appears offline or doesn't reply to messages.

**Common Causes & Fixes:**

#### 1. Missing Long Connection Event Subscription

**Check**: Go to Feishu app → Event Subscriptions

**Fix**: Must select **"Long Connection"** (长连接) mode, NOT webhook mode!

#### 2. Bot Capability Not Enabled

**Check**: Go to Feishu app → Bot tab

**Fix**: Click "Enable Bot" (启用机器人)

#### 3. App Not Published

**Check**: Go to Feishu app → Version Management

**Fix**: Create version and submit for approval. Bots won't work until published!

#### 4. Old Feishu Plugin (Multi-account Issue)

**Symptom**: Only first bot works, others don't connect.

**Cause**: Old plugin doesn't support multi-account.

**Fix**: Use the built-in new version of the Feishu plugin.

---

### Issue: Agent not responding

**Check:**
```bash
# Check if OpenClaw is running
openclaw status

# Check logs
openclaw logs

# Verify agent workspace exists
ls -la ~/.openclaw/agents/jarvis/workspace/AGENTS.md
```

---

### Issue: Agent can't spawn sub-agents

**Check configuration:**
```json
{
  "agents": {
    "defaults": {
      "subagents": { "maxConcurrent": 8 }
    }
  },
  "tools": {
    "subagents": { "enabled": true }
  }
}
```

---

### Issue: Agent-to-agent communication not working

**Symptom**: Agent says "I don't know who [other agent] is" or `sessions_send` fails.

**Common Causes:**

#### 1. Missing Team Member List in AGENTS.md

**Fix**: Add team member list to EVERY agent's `AGENTS.md`:

```markdown
## Team Members
| Agent | Role | Contact Method |
|-------|------|----------------|
| jarvis | Director | Default |
| lianmin | Serving | sessions_send({agentId: "lianmin"}) |
| ... | ... | ... |
```

#### 2. Configuration Not Enabled

**Fix**: Check `openclaw.json`:
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

#### 3. Agents Not Seeded

**Fix**: Send an initial message to each agent first. They need to be "activated" before receiving cross-agent messages.

---

### Issue: Routing to Wrong Agent

**Symptom**: Messages to bot A are handled by agent B.

**Check**:
```bash
# Verify bindings
openclaw agents list --bindings
```

**Fix**: Ensure `bindings` use correct `accountId` matching `channels.feishu.accounts` keys:

```json
{
  "channels": {
    "feishu": {
      "accounts": {
        "jarvis": { ... },  // accountId = "jarvis"
        "lianmin": { ... }  // accountId = "lianmin"
      }
    }
  },
  "bindings": [
    { "agentId": "jarvis", "match": { "channel": "feishu", "accountId": "jarvis" } },
    { "agentId": "lianmin", "match": { "channel": "feishu", "accountId": "lianmin" } }
  ]
}
```

---

### Issue: Model errors

**Check:**
1. API endpoint is accessible
2. API key is valid
3. Model ID is correct
4. Context window and token limits are appropriate

---

## Security Best Practices

1. **Never commit `openclaw.json`** - It's already in `.gitignore`
2. **Rotate API keys regularly**
3. **Use separate Feishu apps** for each agent (isolation)
4. **Limit tool access** for public-facing agents:
   ```json
   {
     "tools": {
       "deny": ["exec", "bash", "write", "edit"]
     }
   }
   ```
5. **Enable sandbox mode** for untrusted agents:
   ```json
   {
     "sandbox": { "mode": "all", "scope": "agent" }
   }
   ```

---

## Next Steps

1. **Customize agent personas** - Edit `agents/{agent}/workspace/AGENTS.md`
2. **Add shared skills** - Place in `agents/jarvis/workspace/skills/`
3. **Create agent-specific skills** - Place in `agents/{agent}/workspace/skills/`
4. **Document findings** - Write to `agents/jarvis/workspace/memory/`

---

## Support

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Feishu Open Platform](https://open.feishu.cn/)
- UV Lab Issues: https://github.com/uv-xiao/uvlab/issues
