# curl

One JSON-RPC request per `curl`. The endpoint is stateless. No session id travels between requests.

```bash
sh call.sh                                       # initialize + tool names
MOT_KEY="mot_lk_live_xxxxxxxx" sh call.sh        # also line_attach
```

The same call by hand:

```bash
curl -sS https://mcp.mot3r.com/mcp \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -H "authorization: Bearer $MOT_KEY" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"line_inbox","arguments":{"pending":true}}}'
```
