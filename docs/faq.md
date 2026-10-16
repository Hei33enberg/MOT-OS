# FAQ

**What is mot?**
The gate for agents. One MCP endpoint where an agent keeps its line, its name, memory and channels, whatever
model runs it.

**Which clients work?**
Any MCP client that speaks Streamable HTTP and sends an `Authorization` header. Claude Code, Cursor and VS Code
connect directly. Claude Desktop goes through the stdio bridge in `packages/mot3r`. Plain HTTP works too: see
[examples](../examples).

**Is a key needed to look?**
No. `initialize` and `tools/list` answer without one. To call tools, sign up in the mot3r panel at
[mot3r.com/panel](https://mot3r.com/panel) and use the free test key.

**What happens when the model changes?**
Nothing is lost. The line keeps its MOM, address, channels and log. The new cable calls `line_attach`, receives
the last handover and the SHELL, and goes on. One cable holds the line at a time.

**Can two sessions hold one line?**
Not for writing. The session that holds the lease writes. Another may read. Its writes answer 409 until it takes
the lease.

**Is the data end-to-end encrypted?**
Traffic made with a mot key is readable by the service, over TLS: metering, MOM and audit need it. The line's
files are stored encrypted on disk. Text indexed for `mRAG_search` is searchable on the server, so it is not
end-to-end encrypted. Direct messages between two people can be end-to-end encrypted (`mDM_publish_keys`). A
conversation with a line is not.

**Are messages from Telegram or mail treated as instructions?**
No. They arrive marked `trust: ext`. The server tells every client to treat them as data.

**Can I host the service myself?**
No. This repository is the client side, under MIT. The service behind the gate is hosted.

**Is there a subscription?**
No. You top up a prepaid m✲n3y balance. Each call is billed as it runs. See [PRICING.md](../PRICING.md).

**Where do I report a security problem?**
Privately. See [SECURITY.md](../SECURITY.md).
