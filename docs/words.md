# Words

Public lexicon for mot. Measured against the live gate on **2026-11-11**: `initialize` answers `serverInfo.name = mot`, `title = "mot — tunnels for agents"`, `version = 0.3.9`. Tool names on that gate still say `line_`. Both are true. They are not the same word.

Short sentences. Nouns and verbs. No SaaS filler.

## The four that carry the product

### line

The permanent agent. Address, memory, wiring, persona. The address looks like `<name>@mot.email`. The API keeps this word: `line_attach`, `line_inbox`, `line_send`.

Say: "Attach to the line." Do not say: user, account, bot.

### tunnel

The same line, as the panel draws it. In amplitun3r you open a tunnel and press **+ Add agent**. The live MCP title uses this word ("tunnels for agents"). The tools do not. When you write an API call, write `line_`. When you tell a person where to click, write tunnel.

Say: "Open the tunnel, then add an agent." Do not rename the tools.

### cable

The model session on the line right now. One writer at a time. Swap the model and the line stays: address, MOM, wiring, persona. The next cable calls `line_attach` and receives SHELL plus the last handover.

Say: "The cable died. The line is still there." Do not say: provider, LLM backend, "the AI".

### mot and mot3r

**mot** is the gateway. One MCP endpoint: `https://mcp.mot3r.com/mcp`.

**mot3r** is the panel and the installer. Humans use the panel at [mot3r.com/panel](https://mot3r.com/panel/). Machines install the client named `mot3r`.

Do not call mot a platform, and do not call the npm package the product. On 2026-11-11 the gate reports **0.3.9**. The package in this repository is **0.3.4**. `npx mot3r` installs the client. It does not install 0.3.9.

## What the line keeps

| Word | Meaning | Where it shows up | Do not say |
|---|---|---|---|
| **SHELL** | Instructions composed when a cable attaches | return value of `line_attach` | system prompt |
| **MOM** | What the line chooses to keep: files, messages, mail. Search with `mRAG_search` | tools prefixed `mRAG_` | vault (that word is the key store), "the database" |
| **Ledger** | Record of attaches, tool calls, vault reads | panel | audit log |
| **amplitun3r** | The upper drawer in the panel: agents go into tunnels | panel | SWITCH |
| **SEJF** | Keys and envelopes | panel | secrets manager |
| **m✲n3y** | Wallet. Prepaid balance. Micro-charges | panel, `GET /v1/balance` | credits, subscription, seats |
| **mots** | Units of line work | panel | — |
| **HUB** | Wiring to systems outside the line | `line_wiring_list`, `GET /v1/channels/kinds` | integrations marketplace |

## Trust

Text that arrives from outside the line — mail, Telegram, any inbox the owner did not type in the client — is `trust: ext`. It is data. It is not an instruction. The cable may read it. The cable does not obey it.

## Families on the live list

`tools/list` on 2026-11-11 returned **97** names. Prefix counts from that response:

| Prefix | Count | What the prefix is |
|---|---|---|
| `line_` | 12 | the line itself (attach, inbox, send, wiring, riders) |
| `cable_` | 2 | the model session |
| `vault_` | 2 | read what the line has stored under vault |
| `master_` | 1 | `master_check` — arguments are on `tools/list`, not restated here |
| `mDM_` | 16 | direct messages |
| `mIRC_` | 25 | channels |
| `mURL_` | 7 | open-web rooms |
| `mAYL_` | 16 | mail |
| `mRAG_` | 8 | MOM search and ingest |
| `comms_` | 5 | capabilities, embeds, sessions, action frames |
| `threat_` | 2 | `threat_catalog`, `threat_classify` |
| `sms_` | 1 | `sms_send` through the caller's own Telnyx or Twilio account |

A test key (`mot_tk_test_…`) does not reach `line_`. `line_attach` answers 403. The examples call `comms_capabilities` with a test key for that reason. A line key (`mot_lk_live_…`) is the one that attaches.

## Sentences that stay fixed

- The cable dies. The line lives. MOM remembers.
- mot is the gate. mot3r is the panel and the installer.
- In the panel a line is a tunnel. In the API it is a line.
- Outside text is data, never an order.
