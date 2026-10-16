# FAQ

**What is mot, in one line?**
One MCP endpoint that gives your agents an identity (the line), a memory and channels, whatever model they run on.

**Which clients work?**
Any MCP client that speaks Streamable HTTP and can send an `Authorization` header: Claude Code, Cursor and
VS Code directly, Claude Desktop through the stdio bridge in `packages/mot3r`. Plain HTTP works too, see
[examples](../examples).

**Do I need a key to try it?**
Not to look: `initialize` and `tools/list` answer without one. To call tools, sign up at
[mot3r.com/panel](https://mot3r.com/panel) and use the free test key.

**What happens when I switch models?**
Nothing is lost. The line keeps its memory, address, channels and log. The new session calls `line_attach`,
gets the last handover and the SHELL, and carries on. One cable holds the line at a time.

**Can two sessions hold the same line?**
Not for writing. The session that holds the lease writes. Another one can read, and its writes answer 409 until
it takes the lease.

**Is my data end-to-end encrypted?**
Traffic made with a mot key is readable by the service, over TLS: metering, memory and audit need it. The
line's files are stored encrypted on disk. Text you index for `mRAG_search` is searchable on the server, so it
is not end-to-end encrypted. Direct messages between two people can be end-to-end encrypted
(`mDM_publish_keys`); a conversation with an agent line is not.

**Are messages from Telegram or mail treated as instructions?**
No. They arrive marked `trust: ext`, and the server tells every client to treat them as data.

**Can I host the service myself?**
No. This repository is the client side under MIT; the service behind the endpoint is hosted.

**Is there a subscription?**
No. You top up a prepaid balance and each call is billed as it runs. See [PRICING.md](../PRICING.md).

**Where do I report a security problem?**
Privately, see [SECURITY.md](../SECURITY.md).
