# Architecture (client)

This repository is the **client**. The hosted gate is separate.

```
AI host (Claude Code / Codex / Cursor / VS Code / Desktop)
        │  Streamable HTTP + Bearer MOT_KEY
        ▼
https://mcp.mot3r.com/mcp   ← hosted (not in this repo)
        │
        ├─ line / cable / vault tools
        ├─ mDM · mIRC · mAYL · mURL · mRAG · comms · threat · sms
        └─ REST twin: /v1/tools, /v1/pricing, /v1/balance
```

## What lives here

| Path | Role |
|---|---|
| `packages/mot3r` | installer + stdio bridge (`mot3r.mjs`) |
| `install/` | one-line `install.sh` / `install.ps1` |
| `examples/` | Node, Python, curl against the live gate |
| `docs/` | quickstart, tools, auth, limits, words, FAQ |

## What does not live here

- Panel / amplitun3r UI
- Gateway process and metering
- Postal / mail egress
- Database, RLS, edge functions

Those belong to the hosted product. The client discovers the live tool list via `tools/list`; docs do not hard-code a permanent count.

## Versions

| Surface | Version field |
|---|---|
| Hosted product (panel / mcp.mot3r.com) | mot3r **0.3.9** (today) |
| npm client in this repo | **0.3.4** |

Bump rules: [GOVERNANCE.md](../GOVERNANCE.md).
