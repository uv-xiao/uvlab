# UV Lab Setup Guide

Complete guide for setting up UV Lab multi-agent research environment.

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
      "appId": "YOUR_FEISHU_APP_ID",
      "appSecret": "YOUR_FEISHU_APP_SECRET"
    }
  },
  "bindings": [
    { "agentId": "jarvis", "match": { "channel": "feishu", "peer": "jarvis-bot" } },
    { "agentId": "lianmin", "match": { "channel": "feishu", "peer": "lianmin-bot" } },
    { "agentId": "tianqi", "match": { "channel": "feishu", "peer": "tianqi-bot" } },
    { "agentId": "zihao", "match": { "channel": "feishu", "peer": "zihao-bot" } },
    { "agentId": "tri", "match": { "channel": "feishu", "peer": "tri-bot" } }
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

### Step 2: Configure Each App

For each app, complete these steps:

#### 2.1 Credentials

1. Go to "Credentials & Basic Info"
2. Note down:
   - **App ID** → Use in `openclaw.json` `channels.feishu.appId`
   - **App Secret** → Use in `openclaw.json` `channels.feishu.appSecret`

#### 2.2 Bot Settings

1. Go to "Bot" tab
2. Enable bot
3. Set bot name (e.g., "Jarvis", "Lianmin", etc.)
4. Upload avatar (optional)

#### 2.3 Permissions

Grant these permissions:

- `im:chat:readonly` - Read group info
- `im:message:send` - Send messages
- `im:message.group_msg` - Receive group messages
- `im:message.p2p_msg` - Receive private messages

#### 2.4 Event Subscription

1. Go to "Event Subscriptions"
2. Enable encryption (optional but recommended)
3. Configure callback URL: `https://your-domain/feishu` or use local tunnel
4. Subscribe to these events:
   - `im.message.receive_v1` - Receive messages

### Step 3: Publish Apps

1. Go to "Version Management"
2. Create a version
3. Set availability:
   - "Only members of the current organization" (if testing)
   - Or specific users/groups
4. Submit for approval (if required by your org)

### Step 4: Add Bots to Groups

1. Create Feishu groups for each agent (or use existing)
2. Add the corresponding bot to each group
3. For direct messaging, users can search for the bot name

### Step 5: Get Group/Peer IDs

To configure precise bindings, you may need group IDs:

1. Send a message to the group
2. Check OpenClaw logs for the incoming message format
3. Extract the `peer` or `chat_id` value

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

### 2. Start OpenClaw

```bash
# Start with Feishu integration
openclaw start

# Or start in background
openclaw start --daemon
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

### Issue: Feishu messages not received

**Check:**
1. App is published and visible
2. Bot is added to the group (for group messages)
3. Event subscription URL is correct and accessible
4. Required permissions are granted

**Test webhook:**
```bash
curl -X POST https://your-domain/feishu \
  -H "Content-Type: application/json" \
  -d '{"test": "connection"}'
```

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

### Issue: Agent-to-agent communication not working

**Check:**
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

Also ensure agents have been "seeded" (initial message sent) before they can receive messages.

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
