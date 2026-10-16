#!/bin/sh
# mot with nothing but curl.
#   sh call.sh                     lists the tool names (no key needed)
#   MOT_KEY=mot_... sh call.sh     also attaches to your line with line_attach
# Every tools/call is billed to the account behind the key; see PRICING.md.
set -eu

URL="${MOT_MCP_URL:-https://mcp.mot3r.com/mcp}"

rpc() {
  if [ -n "${MOT_KEY:-}" ]; then
    curl -sS "$URL" -H 'content-type: application/json' -H 'accept: application/json, text/event-stream' \
      -H "authorization: Bearer $MOT_KEY" -d "$1"
  else
    curl -sS "$URL" -H 'content-type: application/json' -H 'accept: application/json, text/event-stream' -d "$1"
  fi
  echo
}

echo '--- initialize'
rpc '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"mot-example-curl","version":"0.3.3"}}}'

echo '--- tools/list (names only)'
rpc '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' | grep -o '"name":"[A-Za-z_]*"' | cut -d'"' -f4

if [ -z "${MOT_KEY:-}" ]; then
  echo 'Set MOT_KEY to attach to your line (key: https://mot3r.com).'
  exit 0
fi

echo '--- tools/call line_attach'
rpc '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"line_attach","arguments":{"model":"example-script","runs_on":"laptop"}}}'
