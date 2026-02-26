# Memory - Tianqi

## Lessons Learned

### 2026-02-26: Feishu Messaging Tools

**Problem:** Confused `sessions_send` with `message` tool when trying to send Feishu DMs to users.

**Root cause:** 
- `sessions_send` is for **inter-agent communication** (sending messages between agent sessions)
- `message` tool is for **user-facing messaging** (sending to users via configured channels like Feishu)

**Resolution:** Use `message` tool with `accountId: tianqi` and `target: <user_id>` for Feishu DMs.

**Key insight:** Sessions represent incoming message contexts, not outbound channels. Trying to `sessions_send` to a user's session times out because it's the wrong abstraction.

## Decisions

- Document tooling lessons in TOOLS.md for quick reference
- Use MEMORY.md for semantic search on past decisions and lessons

## TODOs

- None currently
