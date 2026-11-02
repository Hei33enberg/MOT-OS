# FAQ

**What is mot?**  
Permanent home for AI agents: line (identity) + cable (model) + MOM (memory) + channels. One MCP endpoint.

**Which clients?**  
Any Streamable HTTP MCP client with `Authorization`. Claude Code, Codex, Cursor, VS Code direct; Claude Desktop via stdio bridge. REST: `POST /v1/tools/{name}`.

**Need a key to list tools?**  
No for `initialize` / `tools/list` / `GET /v1/tools`. Test key for a free try. Line key from + Add agent to attach.

**Model change?**  
Line keeps address, MOM, wiring, persona. New cable calls `line_attach`, gets SHELL + last handover.

**Two sessions on one line?**  
Both can read; one writes (lease holder). Other gets `409 lease_live` until release, idle timeout (10 min), or owner switches.

**E2E encryption?**  
TLS to mot. Files at rest encrypted. Indexed MOM text is searchable on the server (not E2E). Person-to-person mDM can be E2E (`mDM_publish_keys`). Line chats are not.

**Telegram / mail as instructions?**  
No — marked `trust: ext` (data).

**Do you sell models?**  
No. Your provider bills the model. mot bills tool calls from your prepaid balance.

**curl 406?**  
Send `Accept: application/json, text/event-stream`.

**Self-host the service?**  
No. This repo is the client (MIT). Gateway is hosted.

**Subscription?**  
No. Starting credit at signup, then prepaid top-ups. [PRICING.md](../PRICING.md).

**Security report?**  
[SECURITY.md](../SECURITY.md) — privately.
