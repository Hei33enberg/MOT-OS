# Architecture

Two things share a name and must not be collapsed.

| Thing | What it is | Version on 2026-11-11 |
|---|---|---|
| **mot**, the gateway | Hosted MCP gate at `https://mcp.mot3r.com/mcp` | `serverInfo.version` **0.3.9**. Title: "mot — tunnels for agents". **97** tools on `tools/list` |
| **mot3r**, the client in this repo | Installer and stdio bridge, npm package `mot3r` | **0.3.4** |

`npx mot3r` and the one-line installer install **0.3.4**. They point a host at the live gate. They do not download 0.3.9, and they do not contain the gate.

This repository is the client, under MIT. The hosted service is not in this tree. There is no self-host.

## Path of one call

```
AI host
  Claude Code, Codex, Cursor, VS Code  →  Streamable HTTP
  Claude Desktop                       →  stdio  →  mot3r.mjs mcp  →  Streamable HTTP
        │
        │  POST https://mcp.mot3r.com/mcp
        │  Authorization: Bearer <MOT_KEY>     (tools/call only)
        │  Accept: application/json, text/event-stream
        ▼
mot 0.3.9  (hosted, not in this repo)
        │
        ├─ line_ / cable_ / vault_     identity, lease, memory reads
        ├─ mDM_ mIRC_ mURL_ mAYL_      messenger families
        ├─ mRAG_                       MOM
        ├─ comms_ threat_ sms_         capabilities, classify, carrier SMS
        └─ REST twins on api.mot3r.com
              GET  /v1/tools
              POST /v1/tools/{name}
              GET  /v1/pricing
              GET  /v1/balance
              GET  /v1/channels/kinds
```

`initialize` and `tools/list` answer without a key. Every `tools/call` needs one. A batch that contains `tools/call` is refused. One call per request.

The same key and the same meters apply on the REST twin. Prices are public: `GET https://api.mot3r.com/v1/pricing` (no key). Failed calls are not billed. An empty balance is `402` and the call does not run.

## Line and cable

A **line** is the agent that stays: address, MOM, wiring, persona.

A **cable** is the model sitting on that line. `line_attach` takes `model` and `runs_on`, returns the identity package and **SHELL**, and holds the lease. One cable writes. Another live cable gets `409 lease_live` until release, until the lease goes idle (10 minutes without renewal), or until the owner switches.

`line_handover` while the cable is working, `line_release` with a handover text when it stops. The next cable reads that handover on attach.

The panel draws each line as a **tunnel**. The tools stay `line_*`. See [words.md](./words.md).

Mail and Telegram that arrive on the line are `trust: ext`. The cable may quote them. It does not take orders from them.

## What lives in this repository

| Path | Role |
|---|---|
| `packages/mot3r` | `mot3r.mjs` — installer, `doctor`, stdio bridge. No dependencies. Node.js 18+. Version **0.3.4** |
| `install/` | `install.sh` and `install.ps1`. They embed that same file and copy it to `~/.mot` (or `MOT_HOME`) |
| `examples/` | Node, Python, and curl against the live gate. No SDK |
| `docs/` | quickstart, tools, auth, limits, words, architecture, realm, FAQ |
| `community/realm.json` | the open ledger of who has earned a level |

`doctor` checks that the endpoint answers, reports the tool count it sees, and checks the shape of `MOT_KEY`. It does not send the key.

Hosts the installer writes, when it finds them: Claude Code, Claude Desktop, Cursor, VS Code. Claude Desktop cannot speak Streamable HTTP by itself, so the installer points it at `mot3r mcp`. The others get the URL and a reference to `MOT_KEY`, not the key pasted into the file. Claude Desktop's config is the exception: its `env` block is where that host reads the key, and the installer says so when it writes it.

## What does not live here

- The panel and amplitun3r
- The gateway process, the lease, and the meters
- Postal egress and the Telegram bridge
- The database

Those belong to the hosted product. Docs name tools that were on `tools/list` on 2026-11-11. If the count moves, the endpoint wins and this page should be dated again. Do not freeze 97 into code.

## Versions, said once

| Surface | Field | What a person should believe |
|---|---|---|
| Live gate `mcp.mot3r.com` | **0.3.9** | What `initialize` returned on 2026-11-11. 97 tools the same day |
| npm / this repo `mot3r` | **0.3.4** | What `packages/mot3r/package.json` and `VERSION` inside `mot3r.mjs` say |
| One-line installer | embeds **0.3.4** | Running it configures hosts. It does not upgrade the gate |

Bump rules for the client: [GOVERNANCE.md](../GOVERNANCE.md).
