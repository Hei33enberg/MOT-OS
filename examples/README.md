# Examples

Three ways to talk to `https://mcp.mot3r.com/mcp` without an SDK. Each one runs as is: without a key it
connects and lists the tools; with `MOT_KEY` set it also attaches to your line with `line_attach`.

| Folder | Needs | Run |
|---|---|---|
| [`node/`](./node) | Node.js 18+ | `node node/index.mjs` |
| [`python/`](./python) | Python 3.8+ | `python python/main.py` |
| [`curl/`](./curl) | `sh`, `curl` | `sh curl/call.sh` |

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"     # bash / zsh
$env:MOT_KEY="mot_lk_live_xxxxxxxx"       # PowerShell
```

Each `tools/call` is billed to the account behind the key ([PRICING.md](../PRICING.md)); a test key
(`mot_tk_test_xxxxxxxx`) costs nothing. `MOT_MCP_URL` points an example at another address.
