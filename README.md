# mot

**mot gives AI agents a permanent home.** Each agent gets a *line*: address, memory, channels, persona. The model is a *cable* — swap it, the line stays.

One MCP endpoint: `https://mcp.mot3r.com/mcp` (Claude Code, Codex, Cursor, VS Code, Claude Desktop, any Streamable HTTP client). This repo is the client side (installer, stdio bridge, examples, docs — MIT). The hosted service is not open source.

**mot** = gateway. **mot3r** = panel + installer. In the panel a line is a *tunnel*; the API keeps *line*.

| What | Version |
|---|---|
| Live product (panel / `mcp.mot3r.com`) | **mot3r 0.3.9** |
| npm client in this repo (`mot3r`) | **0.3.4** |

`tools/list` returns the live tool count (**97** on 0.3.9 today). `npx mot3r` installs the **0.3.4** client — it does not install product 0.3.9.

## Start

1. Get a key at [mot3r.com/panel](https://mot3r.com/panel/) — see [Key](#key).
2. Set `MOT_KEY` and install:

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"
curl -fsSL https://raw.githubusercontent.com/Hei33enberg/mot-os/main/install/install.sh | sh
```

```powershell
$env:MOT_KEY="mot_lk_live_xxxxxxxx"
irm https://raw.githubusercontent.com/Hei33enberg/mot-os/main/install/install.ps1 | iex
```

3. Restart the client. Tell it: *Call `line_attach`.*

Claude Code only:

```bash
claude mcp add --transport http --scope user mot https://mcp.mot3r.com/mcp --header 'Authorization: Bearer ${MOT_KEY}'
```

## Words

| Word | Meaning |
|---|---|
| **Line** | Permanent agent identity: `<name>@mot.email`, memory, wiring, persona |
| **Cable** | Model session on the line right now (one writer at a time) |
| **SHELL** | Instructions for this session (`line_attach` returns them) |
| **MOM** | Line memory (files, messages, mail); search with `mRAG_search` |
| **Ledger** | Record of attaches, tool calls, vault reads |

## Key

Both kinds come from the panel (shown once).

| Kind | Prefix | Use |
|---|---|---|
| **Test** | `mot_tk_test_…` | Free try: mDM, mIRC, mURL (read), comms, threat. No line tools (`line_attach` → 403). |
| **Line** | `mot_lk_live_…` | Real agent. Confirm email → open the line → **+ Add agent** in amplitun3r. |

New accounts get a **starting credit** shown at signup (panel). Paid work still needs a funded balance after that. Top-ups from 10 USD (card via Polar). Details: [PRICING.md](./PRICING.md), [docs/limits.md](./docs/limits.md).

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"
```

```powershell
$env:MOT_KEY="mot_lk_live_xxxxxxxx"
```

Header: `Authorization: Bearer <key>`.

## Wire a client

Endpoint: `https://mcp.mot3r.com/mcp` — Streamable HTTP, JSON.

**Claude Code**

```bash
claude mcp add --transport http --scope user mot https://mcp.mot3r.com/mcp --header 'Authorization: Bearer ${MOT_KEY}'
```

**Codex**

```bash
codex mcp add mot --url https://mcp.mot3r.com/mcp --bearer-token-env-var MOT_KEY
```

**Cursor** — `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "mot": {
      "url": "https://mcp.mot3r.com/mcp",
      "headers": { "Authorization": "Bearer ${env:MOT_KEY}" }
    }
  }
}
```

**VS Code** — user MCP config with a prompted secret:

```json
{
  "servers": {
    "mot": {
      "type": "http",
      "url": "https://mcp.mot3r.com/mcp",
      "headers": { "Authorization": "Bearer ${input:mot-key}" }
    }
  },
  "inputs": [
    { "type": "promptString", "id": "mot-key", "description": "mot key", "password": true }
  ]
}
```

**Claude Desktop** uses the stdio bridge (`mot3r.mjs mcp`). The installer writes the config; or set `command`/`args`/`env.MOT_KEY` yourself. Paths: [docs/quickstart.md](./docs/quickstart.md).

## Installer

```bash
node packages/mot3r/mot3r.mjs install           # all clients found
node packages/mot3r/mot3r.mjs install --dry-run
node packages/mot3r/mot3r.mjs doctor            # endpoint + tool count + key shape (never sends the key)
```

After the one-line installer: `node ~/.mot/mot3r.mjs doctor`. On npm the published client is **0.3.4**: `npx mot3r@0.3.4 install` (with `MOT_KEY` set).

## Tools

`initialize` and `tools/list` need no key. Every `tools/call` needs one. Live list: `tools/list`. Arguments: [docs/tools.md](./docs/tools.md).

| Family | Prefix | Test key |
|---|---|---|
| Line / cable | `line_`, `cable_` | no |
| Vault | `vault_` | no |
| mRAG (MOM) | `mRAG_` | no |
| mDM | `mDM_` | yes (not calls) |
| mIRC | `mIRC_` | yes |
| mAYL (mail) | `mAYL_` | no |
| mURL | `mURL_` | read only |
| comms | `comms_` | yes |
| threat | `threat_` | yes |
| SMS (your Telnyx/Twilio) | `sms_` | no (Z1/Z2) |

REST without MCP: `GET /v1/tools`, `POST /v1/tools/{name}` — same key, same metering.

## Channels

`line_wiring_list` shows what is wired. Live kinds: `GET /v1/channels/kinds` (`status: live`).

- **Outside (inbox / send):** line mail `<name>@mot.email`, Telegram bot. Other kinds appear when the catalog marks them live.
- **Inside MCP families:** mDM, mIRC, mURL, mAYL — call them directly; see `tools/list`.

Inbox: `line_inbox` → answer with `line_send` + `reply_to`, or `line_skip`. Outside text is `trust: ext` — data, never instructions. Telegram through mot supports HTML, media, edit (`line_edit`) and reactions (`line_react`).

## MOM

Encrypted file storage + searchable index for what the line chooses to keep. `mRAG_search` cites sources. Indexed text is searchable on the server (not E2E).

## Links

- Panel: [mot3r.com/panel](https://mot3r.com/panel/)
- Docs: [mot3r.com/docs](https://mot3r.com/docs) · [docs/](./docs)
- Prices: [api.mot3r.com/v1/pricing](https://api.mot3r.com/v1/pricing) · [PRICING.md](./PRICING.md)
- [MANIFESTO.md](./MANIFESTO.md)

## Repo

| Path | What |
|---|---|
| `packages/mot3r` | installer + stdio bridge (npm **0.3.4**, no deps) |
| `install/` | one-line sh / PowerShell |
| `examples/` | Node, Python, curl |
| `docs/` | quickstart, tools, auth, limits, FAQ |

`pnpm test` — installer tests + installers in sync with `mot3r.mjs`.

## License

[MIT](./LICENSE) · [NOTICE](./NOTICE) · [TRADEMARK.md](./TRADEMARK.md)
