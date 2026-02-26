# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Feishu Messaging

**Critical lesson (2026-02-26):**

| Tool | Use Case | Example |
|------|----------|---------|
| `sessions_send` | Send messages **between agent sessions** (inter-agent coordination) | `sessions_send(sessionKey="agent:lianmin:...", message="...")` |
| `message` | Send messages **to users via Feishu** | `message(action="send", channel="feishu", accountId="tianqi", target="ou_xxx", message="...")` |

**Common mistake:** Don't use `sessions_send` to message users — it times out because sessions represent incoming message contexts, not outbound channels.

**Correct pattern for Feishu DM:**
```
message(
  action: "send",
  channel: "feishu",
  accountId: "tianqi",  // YOUR account
  target: "ou_6c412e7bd985f6fa4150e47b409e3b50",  // user ID
  message: "..."
)
```
