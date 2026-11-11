# Examples

Three clients for the live gate. No SDK. Each file runs as it is.

| | |
|---|---|
| Endpoint | `https://mcp.mot3r.com/mcp` |
| Live product, measured 2026-11-11 | **mot 0.3.9**, 97 tools |
| Client these examples declare | **0.3.4** (`clientInfo.version` in the scripts) |

Without `MOT_KEY` the script connects, calls `initialize` and `tools/list`, and stops. With a line key (`mot_lk_live_…`) it calls `line_attach` (`model`, `runs_on`) and `line_inbox` with `pending: true`. With a test key (`mot_tk_test_…`) it calls `comms_capabilities` instead. A test key does not reach the line tools (`403`).

A `tools/call` made with a line key draws on the balance behind that key. A test key does not. Prices: [PRICING.md](../PRICING.md).

| Folder | Needs | Run |
|---|---|---|
| [`node/`](./node) | Node.js 18+ | `node node/index.mjs` |
| [`python/`](./python) | Python 3.8+ | `python python/main.py` |
| [`curl/`](./curl) | `sh`, `curl` | `sh curl/call.sh` |

bash / zsh:

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"
```

PowerShell:

```powershell
$env:MOT_KEY="mot_lk_live_xxxxxxxx"
```

`MOT_MCP_URL` points an example at another address. Leave it unset to hit the public gate.

The line key comes from **+ Add agent** on a tunnel in the panel: [mot3r.com/panel](https://mot3r.com/panel/). The scripts print that URL when no key is set.

## What you should see

`initialize` returns `serverInfo.name` `mot` and a version. On 2026-11-11 that version was `0.3.9`. The script's own `clientInfo.version` stays `0.3.4`. Those two numbers in one log line are the product split, not a bug.

`tools/list` is the count that matters. Do not edit the examples to hard-code 97.

## Check the syntax

From the repository root:

```bash
node --check examples/node/index.mjs
python -m py_compile examples/python/main.py
sh -n examples/curl/call.sh
```

`pnpm check:examples` runs the same three.
