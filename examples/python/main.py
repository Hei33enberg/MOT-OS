"""mot from Python 3.8+, standard library only.

    python main.py                       lists the tools (no key needed)
    MOT_KEY=mot_... python main.py       also attaches this script to your line and reads what waits in its inbox

Every tools/call is billed to the account behind the key; see PRICING.md.
"""

import itertools
import json
import os
import sys
import urllib.error
import urllib.request

URL = os.environ.get("MOT_MCP_URL", "https://mcp.mot3r.com/mcp")
KEY = os.environ.get("MOT_KEY", "")
_ids = itertools.count(1)


def rpc(method, params=None):
    payload = {"jsonrpc": "2.0", "id": next(_ids), "method": method}
    if params is not None:
        payload["params"] = params
    headers = {"content-type": "application/json", "accept": "application/json, text/event-stream"}
    if KEY:
        headers["authorization"] = "Bearer " + KEY
    req = urllib.request.Request(URL, data=json.dumps(payload).encode(), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as res:
            ctype = res.headers.get("content-type", "")
            text = res.read().decode()
    except urllib.error.HTTPError as e:
        ctype, text = e.headers.get("content-type", ""), e.read().decode()
    if "event-stream" in ctype:
        text = "".join(line[5:] for line in text.splitlines() if line.startswith("data:"))
    msg = json.loads(text)
    if "error" in msg:
        raise RuntimeError("%s: %s %s" % (method, msg["error"]["code"], msg["error"]["message"]))
    return msg["result"]


def call_tool(name, arguments=None):
    result = rpc("tools/call", {"name": name, "arguments": arguments or {}})
    text = "\n".join(c["text"] for c in result.get("content", []) if c.get("type") == "text")
    if result.get("isError"):
        raise RuntimeError("%s: %s" % (name, text))
    return result.get("structuredContent") or json.loads(text)


def main():
    init = rpc("initialize", {
        "protocolVersion": "2025-06-18",
        "capabilities": {},
        "clientInfo": {"name": "mot-example-python", "version": "0.3.3"},
    })
    print("connected: %s %s" % (init["serverInfo"]["name"], init["serverInfo"]["version"]))

    tools = rpc("tools/list")["tools"]
    line_tools = [t["name"] for t in tools if t["name"].startswith("line_")]
    print("%d tools, line tools: %s" % (len(tools), ", ".join(line_tools)))

    if not KEY:
        print("Set MOT_KEY to attach to your line (key: https://mot3r.com).")
        return 0

    pack = call_tool("line_attach", {"model": "example-script", "runs_on": "laptop"})
    print("attached:", json.dumps(pack)[:400])

    inbox = call_tool("line_inbox", {"pending": True, "limit": 10})
    print("waiting in the inbox:", json.dumps(inbox)[:400])
    return 0


if __name__ == "__main__":
    sys.exit(main())
