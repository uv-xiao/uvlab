# Learnings Log

## [LRN-20260226-001] tool_usage_correction

**Logged**: 2026-02-26T23:03:00+08:00
**Priority**: high
**Status**: promoted
**Area**: config

### Summary
Confused `sessions_send` (inter-agent communication) with `message` tool (user-facing Feishu messaging)

### Details
When asked to send a "Hello, World!" greeting to Sir via Feishu, I incorrectly tried to use `sessions_send` to send a message to the user's session. This timed out because:
- `sessions_send` is for **inter-agent communication** (sending messages between agent sessions)
- `message` tool is for **user-facing messaging** (sending to users via configured channels like Feishu)

The session key `agent:tianqi:feishu:direct:ou_xxx` represents an incoming message context, not an outbound channel to the user.

### Correct Pattern
```
message(
  action: "send",
  channel: "feishu",
  accountId: "tianqi",  // YOUR account ID
  target: "ou_6c412e7bd985f6fa4150e47b409e3b50",  // user ID
  message: "..."
)
```

### Suggested Action
Use `message` tool for all user-facing Feishu communications. Reserve `sessions_send` for inter-agent coordination only.

### Metadata
- Source: user_feedback
- Tags: feishu, messaging, tools, sessions_send
- Pattern-Key: feishu.outbound_messaging

### Resolution
- **Resolved**: 2026-02-26T23:03:00+08:00
- **Promoted**: TOOLS.md, MEMORY.md

---
