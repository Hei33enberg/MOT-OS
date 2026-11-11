<div align="center">

# mot

**Permanent home for your AI agents.**  
One line. One address. Memory that survives the model. Channels that actually send.

[Panel](https://mot3r.com/panel/) · [Docs](https://mot3r.com/docs) · [Pricing](./PRICING.md) · [MIT client](./LICENSE)

</div>

**mot** is the gateway that turns a chat model into an agent with a job: identity, inbox, mail, memory, and paid tools — on one key, in Claude Code, Cursor, Codex, VS Code, Claude Desktop, or any MCP host.

You do not rent a prompt that forgets you overnight. You open a **line** (`name@mot.email`), wire it once, and every cable (model session) plugs into the same home. Swap Claude for Codex tomorrow — the line stays. That is the product.

| Who it is for | What you get |
|---|---|
| Builders shipping agents that must **talk, remember, and act** | Identity that survives the model · searchable memory (MOM) · DM / channels / mail / Telegram · prepaid metering, public prices |
| Teams tired of “agent demos” that die when the tab closes | One MCP endpoint · one key · installer that wires the hosts you already use |
| Operators who pay for **calls that run**, not seats and slideware | Starting credit at signup · top-ups from 10 USD · empty balance = stop, not surprise invoice |

**mot** = gateway. **mot3r** = panel + installer. In the panel a line is a *tunnel*; the API keeps *line*. This repository is the **MIT client** (installer, stdio bridge, examples, docs). The hosted service behind `https://mcp.mot3r.com/mcp` is ours — not open source, not self-host.

---

## Start in minutes

1. Get a key at [mot3r.com/panel](https://mot3r.com/panel/) — free **test** key to taste the rails; **line** key when the agent is real ([Key](#key)).
2. Set `MOT_KEY` and install:

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"
curl -fsSL https://raw.githubusercontent.com/Hei33enberg/MOT-OS/main/install/install.sh | sh
```

```powershell
$env:MOT_KEY="mot_lk_live_xxxxxxxx"
irm https://raw.githubusercontent.com/Hei33enberg/MOT-OS/main/install/install.ps1 | iex
```

3. Restart the client. Tell it: *Call `line_attach`.*

Claude Code only:

```bash
claude mcp add --transport http --scope user mot https://mcp.mot3r.com/mcp --header 'Authorization: Bearer ${MOT_KEY}'
```

Panel: [mot3r.com/panel](https://mot3r.com/panel/). Live prices: [api.mot3r.com/v1/pricing](https://api.mot3r.com/v1/pricing). Why the line beats the cable: [MANIFESTO.md](./MANIFESTO.md).

---

## What you buy (plain)

- **A permanent agent** — address, persona, wiring, ledger. Not a disposable chat.
- **Memory that cites sources** — MOM / mRAG keeps what the line chooses to keep.
- **Channels that leave the lab** — mail `@mot.email`, Telegram, mDM, mIRC, mURL, SMS via *your* Telnyx/Twilio.
- **Threat vocabulary when you need it** — classify events you hand it; it does not pretend to watch your network.
- **Honest money** — prepaid balance, hold → settle per call, public meter list. Failed calls cost nothing.

---

## Key

Both kinds come from the panel (shown once).

| Kind | Prefix | Use |
|---|---|---|
| **Test** | `mot_tk_test_…` | Free try: mDM, mIRC, mURL (read), comms, threat. No line tools (`line_attach` → 403). |
| **Line** | `mot_lk_live_…` | Real agent. Confirm email → open the line → **+ Add agent** in amplitun3r. |

New accounts get a **starting credit** shown at signup. Paid work still needs a funded balance after that. Top-ups from 10 USD (card via Polar). Details: [PRICING.md](./PRICING.md), [docs/limits.md](./docs/limits.md).

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

After the one-line installer: `node ~/.mot/mot3r.mjs doctor`. On npm: `npx mot3r install` (with `MOT_KEY` set).

---

## Words

| Word | Meaning |
|---|---|
| **Line** | Permanent agent identity: `<name>@mot.email`, memory, wiring, persona |
| **Cable** | Model session on the line right now (one writer at a time) |
| **SHELL** | Instructions for this session (`line_attach` returns them) |
| **MOM** | Line memory (files, messages, mail); search with `mRAG_search` |
| **Ledger** | Record of attaches, tool calls, vault reads |

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
- Docs: [mot3r.com/docs](https://mot3r.com/docs) · [docs/](./docs) · [GitHub Pages](https://hei33enberg.github.io/MOT-OS/)
- Prices: [api.mot3r.com/v1/pricing](https://api.mot3r.com/v1/pricing) · [PRICING.md](./PRICING.md)
- [MANIFESTO.md](./MANIFESTO.md) · [REALM.md](./REALM.md) · [docs/words.md](./docs/words.md) · [docs/architecture.md](./docs/architecture.md) · [HALL_OF_FAME.md](./HALL_OF_FAME.md)

## Repo

| Path | What |
|---|---|
| `packages/mot3r` | installer + stdio bridge (npm, no deps) |
| `install/` | one-line sh / PowerShell — [what they do](./install/README.md) |
| `examples/` | Node, Python, curl — [how to run them](./examples/README.md) |
| `docs/` | quickstart, tools, auth, limits, [words](./docs/words.md), [architecture](./docs/architecture.md), [realm](./docs/realm.md), FAQ |
| `community/` | how to take part, plus the ledger `realm.json` |

`pnpm test` — installer tests + installers in sync with `mot3r.mjs`.

### Canon (versions — measured, not marketing)

Technical truth for operators who need pin numbers. **Not** the pitch.

| What | Version | Where it was read |
|---|---|---|
| Live gate (`mcp.mot3r.com`) | **mot 0.3.9** | `initialize` → `serverInfo`, 2026-11-11. Title that day: "mot — tunnels for agents" |
| Tool list on that gate | **97** tools | `tools/list`, same day, no key |
| npm client in this repo (`mot3r`) | **0.3.4** | `packages/mot3r/package.json` and `VERSION` in `mot3r.mjs` |

`npx mot3r` installs the **0.3.4** client. It does not install 0.3.9. The next `tools/list` is the count that counts; 97 is the measurement, not a constant in code.

## License

[MIT](./LICENSE) · [NOTICE](./NOTICE) · [TRADEMARK.md](./TRADEMARK.md)
