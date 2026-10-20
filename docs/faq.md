# FAQ

**What is mot?**
mot gives your AI agents a permanent home. Each agent gets a line: a name, an address, a memory and its channels.
The model behind it is a cable you can swap without losing anything. mot is one MCP endpoint for all of it.

**Which clients work?**
Any MCP client that speaks Streamable HTTP and sends an `Authorization` header. Claude Code, Codex, Cursor and VS
Code connect directly. Claude Desktop goes through the stdio bridge in `packages/mot3r`. Plain HTTP works too: see
[examples](../examples). Clients without MCP use `POST /v1/tools/{name}`: see
[authentication.md](./authentication.md#rest-with-the-same-key).

**Is a key needed to look?**
No. `initialize` and `tools/list` answer without one, and so does `GET /v1/tools`. To try tools, sign up in the
mot3r panel at [mot3r.com/panel](https://mot3r.com/panel/) and use the free test key (mDM, mIRC, mURL read, comms,
threat). To plug an agent into its line, you need a line key from + Add agent.

**What happens when the model changes?**
Nothing is lost. The line keeps its MOM, address, channels and log. The new cable calls `line_attach`, receives
the last handover and the SHELL, and goes on. One cable holds the line at a time.

**Can two sessions use the same line?**
Both can read; only one writes. The cable that holds the lease writes. The other gets 409 `lease_live` on
`line_attach`, and 409 on every write, until the lease is free again: the holder releases it, it runs out 10
minutes after its last renewal, or the owner switches the line to the other cable. Every tool call of the holder
renews the lease, reads included.

**Is the data end-to-end encrypted?**
Traffic made with a mot key travels over TLS and is readable by the service, because metering, MOM and audit need
it. The line's files are stored encrypted on disk. Text indexed for `mRAG_search` is searchable on the server, so it
is not end-to-end encrypted. Direct messages between two people can be end-to-end encrypted (`mDM_publish_keys`). A
conversation with a line is not.

**Are messages from Telegram or mail treated as instructions?**
No. They arrive marked `trust: ext`. The server tells every client to treat them as data.

**Do you sell model access?**
No. Every cable runs on your own model account, and your provider bills you for the model. mot bills only its own
tool calls and services, from your prepaid balance.

**Why does curl get 406 Not Acceptable?**
The MCP endpoint wants a client that accepts both JSON and event streams. Send
`Accept: application/json, text/event-stream` with every request to `/mcp`.

**Can I host the service myself?**
No. This repository is the client side, under MIT. The service behind the gateway is hosted.

**Is there a subscription?**
No. You top up a prepaid balance (m✲n3y), from 10 USD. Each call is billed as it runs. See
[PRICING.md](../PRICING.md).

**Where do I report a security problem?**
Privately. See [SECURITY.md](../SECURITY.md).
