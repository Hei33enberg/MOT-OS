# Examples

Three clients for `https://mcp.mot3r.com/mcp`. No SDK. Each runs as is. Without a key it connects and lists the
tools. With a line key in `MOT_KEY` it also plugs into the line as a cable, with `line_attach`, and reads what waits
in `line_inbox`. With a test key it calls `comms_capabilities` instead: a test key does not reach the line tools.

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

Each `tools/call` with a line key draws from the balance behind it ([PRICING.md](../PRICING.md)). A test key
(`mot_tk_test_xxxxxxxx`) costs nothing. `line_attach` needs a line key from + Add agent in the mot3r panel at
[mot3r.com/panel](https://mot3r.com/panel/). `MOT_MCP_URL` points an example at another address.
