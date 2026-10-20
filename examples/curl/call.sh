#!/bin/sh
# mot with nothing but curl.
#   sh call.sh                       lists the tool names (no key needed)
#   MOT_KEY=mot_lk_... sh call.sh    also plugs into the line with line_attach
#   MOT_KEY=mot_tk_... sh call.sh    a test key: calls comms_capabilities (test keys do not reach the line tools)
# Every tools/call with a line key draws from the balance behind it. See PRICING.md.
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
  echo 'Set MOT_KEY to a line key to attach to your line. Get one in the mot3r panel: https://mot3r.com/panel/'
  exit 0
fi

case "$MOT_KEY" in
  mot_tk_*)
    # A test key does not reach the line tools (403 test_family_forbidden).
    echo '--- tools/call comms_capabilities (test key)'
    rpc '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"comms_capabilities","arguments":{}}}'
    echo 'line_attach needs a line key from + Add agent in the mot3r panel.'
    exit 0
    ;;
esac

echo '--- tools/call line_attach'
rpc '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"line_attach","arguments":{"model":"example-script","runs_on":"laptop"}}}'
