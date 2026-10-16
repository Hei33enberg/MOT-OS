# Examples

Three clients for `https://mcp.mot3r.com/mcp`. No SDK. Each runs as is. Without a key it connects and lists
the tools. With `MOT_KEY` set it also plugs into the line as a cable, with `line_attach`.

| Folder | Needs | Run |
|---|---|---|
| [`node/`](./node) | Node.js 18+ | `node node/index.mjs` |
| [`python/`](./python) | Python 3.8+ | `python python/main.py` |
| [`curl/`](./curl) | `sh`, `curl` | `sh curl/call.sh` |

```bash
export MOT_KEY="mot_lk_live_xxxxxxxx"     # bash / zsh
$env:MOT_KEY="mot_lk_live_xxxxxxxx"       # PowerShell
```

Each `tools/call` draws from the m✲n3y balance behind the key ([PRICING.md](../PRICING.md)). A test key
(`mot_tk_test_xxxxxxxx`) costs nothing. `MOT_MCP_URL` points an example at another address.
